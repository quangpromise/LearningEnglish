// Edge Function proxy cho gia co phieu quoc te (Twelve Data) - tinh nang
// Quan ly tai san, tab Dau tu. BAT BUOC phai qua day thay vi goi thang tu
// Flutter client vi Twelve Data can API key - nhung neu nhung key vao APK
// se bi trich xuat/lam dung (khac CoinGecko cua crypto khong can key, xem
// docs/research-wealth-stock-apis.md). Deploy: `supabase functions deploy
// stocks-intl --use-api`. Can set secret truoc: `supabase secrets set
// TWELVE_DATA_API_KEY=...` (lay tu twelvedata.com, free tier 800 call/ngay,
// nhung CHI 8 credit/phut - xem gioi han o duoi).
//
// DO TIN CAY: free tier Twelve Data chi cho 8 API credit/phut CHUNG cho ca
// app (khong phan biet theo user) - da xac nhan qua test thuc te goi 1 lan
// 40 ma bi tra ve loi 429 "run out of API credits". Client da gioi han moi
// lan goi toi da 8 ma (xem stock_picker_sheet.dart), nhung nhieu man hinh
// (picker, tab Dau tu...) co the goi CUNG LUC trong 1 phut va van vuot han
// muc chung. Vi vay ap dung CUNG mo hinh cache BEN VUNG + stale-fallback da
// dung cho stocks-vn (xem migration 0038, bang wealth_edge_cache): uu tien
// tra cache con "tuoi" (khong goi Twelve Data neu chua het TTL), va neu lan
// fetch moi that bai (vd dinh dung rate limit), fallback ve cache CU (du da
// qua TTL) thay vi tra loi 502 - "co gia hoi cu con hon khong co gia".

import { createClient } from "jsr:@supabase/supabase-js@2";

const TWELVE_DATA_API_KEY = Deno.env.get("TWELVE_DATA_API_KEY");
const CACHE_TTL_MS = 3 * 60 * 1000;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface StockQuoteRow {
  symbol: string;
  price: number;
  changePercent: number;
  currency: string;
}

interface TwelveDataQuote {
  symbol: string;
  close: string;
  percent_change: string;
  currency: string;
  code?: number;
  message?: string;
}

async function readCache(
  cacheKey: string,
): Promise<{ data: StockQuoteRow[]; updatedAt: number } | null> {
  const { data } = await supabase
    .from("wealth_edge_cache")
    .select("data, updated_at")
    .eq("cache_key", cacheKey)
    .maybeSingle();
  if (!data) return null;
  return {
    data: data.data as StockQuoteRow[],
    updatedAt: new Date(data.updated_at as string).getTime(),
  };
}

async function writeCache(cacheKey: string, rows: StockQuoteRow[]): Promise<void> {
  await supabase.from("wealth_edge_cache").upsert({
    cache_key: cacheKey,
    data: rows,
    updated_at: new Date().toISOString(),
  });
}

async function fetchFresh(symbols: string[]): Promise<StockQuoteRow[]> {
  const quoteUrl = `https://api.twelvedata.com/quote?symbol=${symbols.join(",")}&apikey=${TWELVE_DATA_API_KEY}`;
  const res = await fetch(quoteUrl);
  const raw = await res.json();

  // Khi ca batch bi loi CHUNG (vd 429 het credit/phut), Twelve Data tra ve 1
  // OBJECT LOI DUY NHAT o cap cao nhat (khong theo dinh dang { [symbol]:
  // {...} } nhu binh thuong) - PHAI phat hien truong hop nay va nem loi de
  // KHONG coi 1 mang RONG la thanh cong (truoc day Object.values() tren
  // object loi nay tra ve cac gia tri nguyen thuy khong co .symbol, bi loc
  // het -> ket qua RONG duoc coi la "thanh cong" va cache lai, khien user
  // thay danh sach trong hoan toan ma khong co dau hieu loi nao).
  if (
    raw && typeof raw === "object" && !Array.isArray(raw) &&
    "status" in raw && raw.status === "error"
  ) {
    throw new Error(`Twelve Data: ${raw.message ?? "loi khong xac dinh"}`);
  }

  // Twelve Data tra ve 1 object don khi 1 symbol, hoac { [symbol]: {...} }
  // khi nhieu symbol - chuan hoa ve 1 mang duy nhat.
  const rows: TwelveDataQuote[] = symbols.length === 1
    ? [raw as TwelveDataQuote]
    : Object.values(raw as Record<string, TwelveDataQuote>);

  return rows
    .filter((r) => r && r.symbol && !r.code)
    .map((r) => ({
      symbol: r.symbol,
      price: Number(r.close),
      changePercent: Number(r.percent_change),
      currency: r.currency ?? "USD",
    }));
}

/// Uu tien cache con "tuoi" (trong TTL) de tra loi nhanh, khong goi Twelve
/// Data. Het TTL thi thu fetch moi; neu fetch moi that bai (rate limit/loi
/// mang), fallback ve cache CU (du qua TTL) thay vi bao loi - chi bao loi
/// that su khi CHUA TUNG co cache nao cho dung bo ma nay.
async function getQuotes(cacheKey: string, symbols: string[]): Promise<StockQuoteRow[]> {
  const cached = await readCache(cacheKey);
  if (cached && Date.now() - cached.updatedAt < CACHE_TTL_MS) {
    return cached.data;
  }
  try {
    const fresh = await fetchFresh(symbols);
    await writeCache(cacheKey, fresh);
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

  if (!TWELVE_DATA_API_KEY) {
    return new Response(
      JSON.stringify({ error: "Thiếu TWELVE_DATA_API_KEY trên server" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
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

  const cacheKey = `stocks_intl:${symbols.slice().sort().join(",")}`;

  try {
    const result = await getQuotes(cacheKey, symbols);
    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: `Không lấy được giá cổ phiếu: ${err}` }),
      {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
