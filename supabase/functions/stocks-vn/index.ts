// Edge Function proxy cho gia co phieu Viet Nam (san HOSE) - tinh nang Quan
// ly tai san, Market > Chung khoan VN + Vi > Tai san dau tu > Co phieu.
//
// NGUON DU LIEU: KHONG dung SSI FastConnect (ToS mac dinh cam cung cap lai
// cho ben thu ba - xem docs/research-wealth-stock-apis.md), KHONG dung
// vnstock/Vietstock/cafef/iTick (deu bi loai vi ly do phap ly/thuong mai -
// xem lich su nghien cuu). Dung THANG API cong khai cua chinh HOSE
// (api.hsx.vn) - day la API noi bo ma trang bang gia CHINH THUC cua HOSE
// (rtboard.hsx.vn) tu goi tu trinh duyet nguoi dung, KHONG can API key, phoi
// bay cong khai cho bat ky ai truy cap trang bang gia cua ho - rui ro phap ly
// thap hon han cac nguon thuong mai tu nhan da bi loai (khong co ToS nao cam
// redistribute duoc tim thay, vi day la du lieu cong bo cua chinh So GDCK).
//
// LUU Y DO TIN CAY: day la "gia khop lenh gan nhat" (accumulatedPrice) do
// HOSE cong bo - la gia dong cua phien gan nhat neu ngoai gio giao dich
// (cuoi tuan/le), khong phai gia real-time chuan giao dich. KHONG dung de
// ra quyet dinh dau tu that, chi mang tinh tham khao (dung dinh vi phu cua
// app nay). Endpoint nay la KHONG CHINH THUC theo nghia "khong co tai lieu
// API cong khai tu HOSE" (reverse-engineer tu bundle JS cua rtboard.hsx.vn)
// nen CO THE doi/ngung hoat dong bat ky luc nao - da dat sau proxy nay de
// de sua khi can, khong anh huong APK da phat hanh.
//
// VN-Index (diem so tong) CHUA lam o day - HOSE chi day so nay qua kenh
// WebSocket/SignalR rieng (can Origin header dac biet, WebSocket chuan cua
// Deno khong ho tro dat header nay), phuc tap hon nhieu so voi REST don
// gian ben duoi. Se lam sau neu can.
//
// DO TIN CAY MANG: da xac nhan qua test thuc te api.hsx.vn kha "chap chon"
// (~1/4-3/4 lan bi timeout du retry 3 lan/15s trong 1 request) - VA cache
// trong bo nho (bien global) truoc day KHONG du vi Edge Function co the
// chay tren isolate MOI (cold start) moi request, khien cache khong bao gio
// duoc tai su dung giua cac lan goi that trong thuc te. Da chuyen sang cache
// BEN VUNG trong bang wealth_edge_cache (xem migration 0038): (1) dung lai
// ket qua thanh cong gan nhat trong TTL cho MOI isolate, (2) neu lan fetch
// moi that bai het 3 lan, fallback ve du lieu CU trong cache (du da qua
// TTL) thay vi tra loi 502 - uu tien "co gia hoi cu" hon "khong co gia".
//
// Deploy: `supabase functions deploy stocks-vn`. Can SUPABASE_URL +
// SUPABASE_SERVICE_ROLE_KEY (Edge Function tu dong co san, khong can set
// them secret).

import { createClient } from "jsr:@supabase/supabase-js@2";

const HOSE_BOARD_URL =
  "https://api.hsx.vn/l/api/v1/securities/load-securities-matching/0";
const CACHE_KEY = "stocks_vn_hose_board";
const CACHE_TTL_MS = 3 * 60 * 1000;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface HoseRow {
  securitySymbol?: string;
  accumulatedPrice?: string;
  priorClosePrice?: string;
  changePrice?: string;
  changePriceRatio?: string;
  name?: string;
  totalValue?: string;
}

async function fetchBoardOnce(): Promise<HoseRow[]> {
  const res = await fetch(HOSE_BOARD_URL, {
    signal: AbortSignal.timeout(10000),
    headers: { "User-Agent": "Mozilla/5.0" },
  });
  if (!res.ok) throw new Error(`HOSE status ${res.status}`);
  const json = await res.json();
  const rows = json?.data;
  if (!Array.isArray(rows)) throw new Error("HOSE tra ve du lieu sai dinh dang");
  return rows as HoseRow[];
}

async function fetchBoardWithRetry(): Promise<HoseRow[]> {
  let lastErr: unknown;
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      return await fetchBoardOnce();
    } catch (err) {
      lastErr = err;
    }
  }
  throw lastErr;
}

async function readCache(): Promise<{ data: HoseRow[]; updatedAt: number } | null> {
  const { data } = await supabase
    .from("wealth_edge_cache")
    .select("data, updated_at")
    .eq("cache_key", CACHE_KEY)
    .maybeSingle();
  if (!data) return null;
  return {
    data: data.data as HoseRow[],
    updatedAt: new Date(data.updated_at as string).getTime(),
  };
}

async function writeCache(board: HoseRow[]): Promise<void> {
  await supabase.from("wealth_edge_cache").upsert({
    cache_key: CACHE_KEY,
    data: board,
    updated_at: new Date().toISOString(),
  });
}

/// Uu tien cache con "tuoi" (trong TTL) de tra loi nhanh, khong goi HOSE.
/// Het TTL thi thu fetch moi; neu fetch moi that bai HET (3 lan), fallback
/// ve cache CU (du qua TTL) thay vi bao loi - chi bao loi that su khi CHUA
/// TUNG co cache nao (lan dau tien tuyet doi khong ai goi thanh cong).
async function getBoard(): Promise<HoseRow[]> {
  const cached = await readCache();
  if (cached && Date.now() - cached.updatedAt < CACHE_TTL_MS) {
    return cached.data;
  }
  try {
    const fresh = await fetchBoardWithRetry();
    await writeCache(fresh);
    return fresh;
  } catch (err) {
    if (cached) return cached.data;
    throw err;
  }
}

Deno.serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const wantAll = url.searchParams.get("all") === "true";
  const symbolsParam = url.searchParams.get("symbols") ?? "";
  const symbols = symbolsParam
    .split(",")
    .map((s) => s.trim().toUpperCase())
    .filter((s) => s.length > 0);

  if (!wantAll && symbols.length === 0) {
    return new Response(JSON.stringify([]), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const board = await getBoard();

    const toQuote = (row: HoseRow) => {
      const price = Number(row.accumulatedPrice) ||
        Number(row.priorClosePrice) || 0;
      if (price <= 0) return null;
      return {
        symbol: row.securitySymbol!.toUpperCase(),
        name: row.name ?? null,
        price,
        changePercent: Number(row.changePriceRatio) || 0,
        currency: "VND",
        // HOSE KHONG cong bo so co phieu dang luu hanh qua API nay nen
        // KHONG the tinh von hoa thi truong THAT (gia x so luong). Dung
        // tong gia tri khop lenh trong phien (totalValue) lam PROXY do quy
        // mo giao dich - KHONG PHAI von hoa, chi la uoc luong tuong doi.
        tradingValue: Number(row.totalValue) || 0,
      };
    };

    // ?all=true tra ve TOAN BO san HOSE (dung de tim kiem/chon ma khi them
    // co phieu VN vao Portfolio - khac ?symbols=... chi tra dung nhung ma
    // da yeu cau, dung cho man hien thi gia 1 danh sach co dinh).
    const result = wantAll
      ? board.filter((r) => r.securitySymbol).map(toQuote).filter((r) =>
        r !== null
      )
      : symbols
        .map((sym) => {
          const row = board.find((r) =>
            r.securitySymbol?.toUpperCase() === sym
          );
          return row ? toQuote(row) : null;
        })
        .filter((r) => r !== null);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: `Không lấy được giá cổ phiếu VN: ${err}` }),
      {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
