// Edge Function proxy cho gia Vang trong nuoc (SJC/PNJ) + ty gia USD/VND -
// dung cho tinh nang Quan ly tai san, Vi > Tai san dau tu + Market > Kim
// loai. KHONG nguon nao o day can key that su - van dat sau proxy nay de:
// (1) tu dong fallback sang nguon du phong khi 1 nguon sap, (2) cache giam
// tai, (3) doi nguon du lieu bat ky luc nao ma KHONG can build lai APK
// (quan trong vi app phat hanh qua sideload, nguoi dung cap nhat cham).
// Deploy: `supabase functions deploy wealth-vn-assets --use-api`.
//
// LUU Y DO TIN CAY DU LIEU (bat buoc UI hien thi ro):
// - Gia vang SJC/PNJ: tong hop tu ben thu ba (vang.today/btmc.vn), KHONG
//   phai gia chinh thuc do SJC/PNJ tu cong bo qua API rieng (khong ton tai).
// - Ty gia USD/VND: tham khao Vietcombank/thi truong, co the lech ty gia
//   thuc te tai quay giao dich.
//
// DA BO Bac/Dong hoan toan (truoc day dung Twelve Data XAG/USD, XCU/USD) -
// xac nhan qua test truc tiep API: XAG/USD tra loi 403 "not available with
// your plan" (chi co goi tra phi), XCU/USD tra loi 404 "symbol not found"
// (Twelve Data khong co du lieu dong). Da nghien cuu them cac nguon khac
// (Metals-API, MetalpriceAPI...) deu CAM RO mục dich thuong mai o goi mien
// phi - khong con nguon nao mien phi + hop le ve dieu khoan cho ca 2 kim
// loai nay cung luc, xem docs/research-wealth-stock-apis.md. Gia vang quoc
// te thay the dung XAUT (Tether Gold) tu OKX truc tiep tren client (xem
// okxXautTickerProvider), KHONG qua function nay nua.

const CACHE_TTL_MS = 5 * 60 * 1000;
let cache: { data: unknown; expiresAt: number } | null = null;

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

  const [gold, fx] = await Promise.all([fetchGold(), fetchUsdVnd()]);

  const result = {
    goldSjc: gold.sjc,
    goldPnj: gold.pnj,
    goldSource: gold.source,
    usdVnd: fx.rate,
    fxSource: fx.source,
    updatedAt: new Date().toISOString(),
  };

  cache = { data: result, expiresAt: Date.now() + CACHE_TTL_MS };

  return new Response(JSON.stringify(result), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
