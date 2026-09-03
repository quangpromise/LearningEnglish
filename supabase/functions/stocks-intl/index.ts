// Edge Function proxy cho gia co phieu quoc te (Twelve Data) - tinh nang
// Quan ly tai san, tab Dau tu. BAT BUOC phai qua day thay vi goi thang tu
// Flutter client vi Twelve Data can API key - nhung neu nhung key vao APK
// se bi trich xuat/lam dung (khac CoinGecko cua crypto khong can key, xem
// docs/research-wealth-stock-apis.md). Deploy: `supabase functions deploy
// stocks-intl`. Can set secret truoc: `supabase secrets set
// TWELVE_DATA_API_KEY=...` (lay tu twelvedata.com, free tier 800 call/ngay).

const TWELVE_DATA_API_KEY = Deno.env.get("TWELVE_DATA_API_KEY");

// Cache trong bo nho function (song theo vong doi instance) - tranh goi lai
// Twelve Data lien tuc va ton quota free tier khi nhieu user mo tab Dau tu
// gan nhau. Khong can Redis/DB rieng cho Phase 1 vi luong dung con nho.
const CACHE_TTL_MS = 3 * 60 * 1000;
const cache = new Map<string, { data: unknown; expiresAt: number }>();

interface TwelveDataQuote {
  symbol: string;
  close: string;
  percent_change: string;
  currency: string;
  code?: number;
  message?: string;
}

Deno.serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (!TWELVE_DATA_API_KEY) {
    return new Response(
      JSON.stringify({ error: "Thiếu TWELVE_DATA_API_KEY trên server" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
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

  const cacheKey = symbols.slice().sort().join(",");
  const cached = cache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return new Response(JSON.stringify(cached.data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const quoteUrl = `https://api.twelvedata.com/quote?symbol=${symbols.join(",")}&apikey=${TWELVE_DATA_API_KEY}`;
    const res = await fetch(quoteUrl);
    const raw = await res.json();

    // Twelve Data tra ve 1 object don khi 1 symbol, hoac { [symbol]: {...} }
    // khi nhieu symbol - chuan hoa ve 1 mang duy nhat.
    const rows: TwelveDataQuote[] = symbols.length === 1
      ? [raw as TwelveDataQuote]
      : Object.values(raw as Record<string, TwelveDataQuote>);

    const result = rows
      .filter((r) => r && r.symbol && !r.code)
      .map((r) => ({
        symbol: r.symbol,
        price: Number(r.close),
        changePercent: Number(r.percent_change),
        currency: r.currency ?? "USD",
      }));

    cache.set(cacheKey, { data: result, expiresAt: Date.now() + CACHE_TTL_MS });

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: `Không lấy được giá cổ phiếu: ${err}` }),
      { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
