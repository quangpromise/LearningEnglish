// Edge Function proxy cho gia Vang trong nuoc (SJC/PNJ), ty gia USD/VND, va
// gia The gioi Bac/Dong (quy doi) - dung cho tinh nang Quan ly tai san, Vi >
// Tai san dau tu + Market > Kim loai. Khac voi stocks-intl (Twelve Data can
// giau API key), KHONG nguon nao o day can key that su - van dat sau proxy
// nay de: (1) tu dong fallback sang nguon du phong khi 1 nguon sap, (2)
// cache giam tai, (3) doi nguon du lieu bat ky luc nao ma KHONG can build
// lai APK (quan trong vi app phat hanh qua sideload, nguoi dung cap nhat
// cham). Deploy: `supabase functions deploy wealth-vn-assets`.
//
// LUU Y DO TIN CAY DU LIEU (bat buoc UI hien thi ro):
// - Gia vang SJC/PNJ: tong hop tu ben thu ba (vang.today/btmc.vn), KHONG
//   phai gia chinh thuc do SJC/PNJ tu cong bo qua API rieng (khong ton tai).
// - Ty gia USD/VND: tham khao Vietcombank/thi truong, co the lech ty gia
//   thuc te tai quay giao dich.
// - Gia Bac/Dong: la GIA THE GIOI (XAG/USD, XCU/USD qua Twelve Data) quy
//   doi VND theo ty gia tren - KHONG PHAI gia ban le trong nuoc (khong ton
//   tai thi truong ban le Bac/Dong theo "luong" o VN nhu Vang).

const TWELVE_DATA_API_KEY = Deno.env.get("TWELVE_DATA_API_KEY");

const CACHE_TTL_MS = 5 * 60 * 1000;
let cache: { data: unknown; expiresAt: number } | null = null;

const TROY_OUNCE_TO_LUONG = 31.1034768 / 37.5; // 1 luong VN = 37.5g

async function fetchGold(): Promise<{
  sjc: { buy: number; sell: number } | null;
  pnj: { buy: number; sell: number } | null;
  source: string;
}> {
  try {
    // Endpoint that vang.today shows to its own homepage - xac nhan bang
    // curl thuc te, KHAC voi endpoint /api/v1/rates ghi trong trang tai
    // lieu API (/en/api) - trang do da loi thoi, tra ve 404.
    const res = await fetch("https://www.vang.today/api/prices", {
      signal: AbortSignal.timeout(5000),
    });
    if (!res.ok) throw new Error(`vang.today status ${res.status}`);
    const json = await res.json();
    const prices = (json.prices ?? {}) as Record<
      string,
      { name?: string; buy?: number; sell?: number }
    >;
    const rows = Object.values(prices);
    const findBrand = (needle: string) =>
      rows.find((r) => String(r.name ?? "").toLowerCase().includes(needle));
    const sjcRow = findBrand("sjc");
    const pnjRow = findBrand("pnj");
    const toPair = (row: { buy?: number; sell?: number } | undefined) =>
      row ? { buy: Number(row.buy ?? 0), sell: Number(row.sell ?? 0) } : null;
    const sjc = toPair(sjcRow);
    const pnj = toPair(pnjRow);
    if (sjc || pnj) return { sjc, pnj, source: "vang.today" };
    throw new Error("Khong tim thay SJC/PNJ trong response vang.today");
  } catch (_err) {
    // Fallback: BTMC cong bo gia cua chinh ho (khong phai SJC/PNJ chinh
    // thuc, nhung la 1 doanh nghiep kinh doanh vang that, dung tam thoi khi
    // vang.today sap).
    try {
      // Key cong khai san trong tai lieu API chinh thuc cua BTMC (khong phai
      // secret rieng cua app nay) - xem
      // https://btmc.vn/thong-tin/tai-lieu-api/api-gia-vang-17784.html
      const res = await fetch(
        "http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v",
        { signal: AbortSignal.timeout(5000) },
      );
      if (!res.ok) throw new Error(`btmc.vn status ${res.status}`);
      const json = await res.json();
      const rows: Array<Record<string, unknown>> = json.DataList?.Data ?? [];
      const sjcRow = rows.find((r) =>
        String(r.n_1 ?? "").toLowerCase().includes("sjc")
      );
      const toPair = (row: Record<string, unknown> | undefined) =>
        row
          ? { buy: Number(row.pb ?? 0) * 1000, sell: Number(row.ps ?? 0) * 1000 }
          : null;
      return { sjc: toPair(sjcRow), pnj: null, source: "btmc.vn" };
    } catch (fallbackErr) {
      return { sjc: null, pnj: null, source: `error: ${fallbackErr}` };
    }
  }
}

async function fetchUsdVnd(): Promise<{ rate: number | null; source: string }> {
  try {
    const res = await fetch(
      "https://portal.vietcombank.com.vn/Usercontrols/TVPortal.TyGia/pXML.aspx?b=10",
      { signal: AbortSignal.timeout(5000) },
    );
    if (!res.ok) throw new Error(`Vietcombank status ${res.status}`);
    const xml = await res.text();
    const match = xml.match(
      /CurrencyCode="USD"[^>]*Transfer="([\d,.]+)"/,
    );
    if (match) {
      const rate = Number(match[1].replace(/,/g, ""));
      if (rate > 0) return { rate, source: "vietcombank" };
    }
    throw new Error("Khong parse duoc ty gia USD tu XML Vietcombank");
  } catch (_err) {
    try {
      const res = await fetch("https://open.er-api.com/v6/latest/USD", {
        signal: AbortSignal.timeout(5000),
      });
      const json = await res.json();
      const rate = Number(json.rates?.VND);
      return { rate: rate > 0 ? rate : null, source: "open.er-api.com" };
    } catch (fallbackErr) {
      return { rate: null, source: `error: ${fallbackErr}` };
    }
  }
}

async function fetchMetalsUsd(): Promise<{ xagUsd: number | null; xcuUsd: number | null }> {
  if (!TWELVE_DATA_API_KEY) return { xagUsd: null, xcuUsd: null };
  try {
    const res = await fetch(
      `https://api.twelvedata.com/quote?symbol=XAG/USD,XCU/USD&apikey=${TWELVE_DATA_API_KEY}`,
      { signal: AbortSignal.timeout(5000) },
    );
    const raw = await res.json();
    const xag = Number(raw["XAG/USD"]?.close);
    const xcu = Number(raw["XCU/USD"]?.close);
    return {
      xagUsd: Number.isFinite(xag) ? xag : null,
      xcuUsd: Number.isFinite(xcu) ? xcu : null,
    };
  } catch (_err) {
    return { xagUsd: null, xcuUsd: null };
  }
}

Deno.serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (cache && cache.expiresAt > Date.now()) {
    return new Response(JSON.stringify(cache.data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const [gold, fx, metals] = await Promise.all([
    fetchGold(),
    fetchUsdVnd(),
    fetchMetalsUsd(),
  ]);

  const usdVnd = fx.rate;
  const xagVndPerLuong = usdVnd && metals.xagUsd
    ? metals.xagUsd * usdVnd * TROY_OUNCE_TO_LUONG
    : null;
  const xcuVndPerKg = usdVnd && metals.xcuUsd
    ? metals.xcuUsd * usdVnd * 2.20462
    : null; // Twelve Data XCU/USD la gia theo pound -> quy doi sang kg

  const result = {
    goldSjc: gold.sjc,
    goldPnj: gold.pnj,
    goldSource: gold.source,
    usdVnd,
    fxSource: fx.source,
    xagUsd: metals.xagUsd,
    xcuUsd: metals.xcuUsd,
    xagVndPerLuong,
    xcuVndPerKg,
    updatedAt: new Date().toISOString(),
  };

  cache = { data: result, expiresAt: Date.now() + CACHE_TTL_MS };

  return new Response(JSON.stringify(result), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
