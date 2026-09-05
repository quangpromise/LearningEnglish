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
// Deploy: `supabase functions deploy stocks-vn`. Khong can secret/API key.

const HOSE_BOARD_URL =
  "https://api.hsx.vn/l/api/v1/securities/load-securities-matching/0";

const CACHE_TTL_MS = 3 * 60 * 1000;
let cache: { data: unknown; expiresAt: number } | null = null;

interface HoseRow {
  securitySymbol?: string;
  accumulatedPrice?: string;
  priorClosePrice?: string;
  changePrice?: string;
  changePriceRatio?: string;
  name?: string;
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

// api.hsx.vn thuc te kha "chap chon" - da do thu: ~1/4 lan bi timeout du cho
// toi 15s, khong lien quan gi den do lon payload (408 dong, ~300KB). Thu lai
// toi da 3 lan (timeout 10s/lan) truoc khi bao loi - tang ty le thanh cong
// trong 1 lan goi function ma khong can nguoi dung tu bam refresh lai.
async function fetchBoard(): Promise<HoseRow[]> {
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
  const symbolsParam = url.searchParams.get("symbols") ?? "";
  const symbols = symbolsParam
    .split(",")
    .map((s) => s.trim().toUpperCase())
    .filter((s) => s.length > 0);

  if (symbols.length === 0) {
    return new Response(JSON.stringify([]), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    let board: HoseRow[];
    if (cache && cache.expiresAt > Date.now()) {
      board = cache.data as HoseRow[];
    } else {
      board = await fetchBoard();
      cache = { data: board, expiresAt: Date.now() + CACHE_TTL_MS };
    }

    const bySymbol = new Map(
      board
        .filter((r) => r.securitySymbol)
        .map((r) => [r.securitySymbol!.toUpperCase(), r]),
    );

    const result = symbols
      .map((sym) => {
        const row = bySymbol.get(sym);
        if (!row) return null;
        const price = Number(row.accumulatedPrice) ||
          Number(row.priorClosePrice) || 0;
        if (price <= 0) return null;
        return {
          symbol: sym,
          name: row.name ?? null,
          price,
          changePercent: Number(row.changePriceRatio) || 0,
          currency: "VND",
        };
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
