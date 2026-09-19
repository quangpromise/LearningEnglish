// Edge Function: ghi 1 moc gia tri danh muc dau tu cho MOI user dang co tai
// san, vao bang wealth_investment_snapshots (xem migration 0068) - goi dinh
// ky boi GitHub Actions scheduled workflow (xem
// .github/workflows/investment-snapshot.yml), KHONG goi tu app Flutter.
//
// TAI SAO CAN: app cung tu ghi moc (WealthInvestmentSnapshotRepository), nhung
// CHI khi app dang mo. Nguoi dung mo app 1-2 tieng/ngay thi bieu do "Tong dau
// tu" co nhung quang trong dai hang chuc tieng, ve ra la duong THANG noi 2
// diem, con toan bo nhuc nhich don vao vai phut cuoi - dung hien tuong nguoi
// dung bao. Chi co ghi tu phia server moi phu duoc 24/7.
//
// BAT BUOC: cong thuc tinh tong o day phai GIONG HET
// totalInvestmentValueVndProvider (app/lib/core/providers/app_providers.dart).
// Neu lech, bieu do se giat cuc moi lan chuyen tu diem cron sang diem app ghi,
// va con so tren bieu do se khac the o man Home.
//
// Can 2 secret (supabase secrets set ...):
//   INVESTMENT_SNAPSHOT_WEBHOOK_SECRET - chuoi bi mat tu chon, PHAI khop voi
//                                        secret cung ten ben GitHub Actions
//   SUPABASE_SERVICE_ROLE_KEY          - da co san (bien moi truong mac dinh)
//
// Deploy: supabase functions deploy investment-snapshot --no-verify-jwt --use-api

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface Holding {
  user_id: string;
  asset_type: string;
  symbol: string;
  name: string | null;
  quantity: number | null;
  avg_cost: number | null;
  manual_value: number | null;
}

/// Gia vang trong nuoc + ty gia USD/VND - dung lai dung Edge Function ma app
/// dung (wealth-vn-assets) thay vi goi thang nguon goc: 2 ben luon doc cung 1
/// con so, va khi doi nguon gia chi phai sua 1 cho.
async function fetchVnAssets(
  supabaseUrl: string,
  serviceRoleKey: string,
): Promise<{ usdVnd: number | null; goldSell: number | null }> {
  try {
    const res = await fetch(`${supabaseUrl}/functions/v1/wealth-vn-assets`, {
      headers: { Authorization: `Bearer ${serviceRoleKey}` },
      signal: AbortSignal.timeout(10000),
    });
    if (!res.ok) return { usdVnd: null, goldSell: null };
    const json = await res.json();
    const usdVnd = Number(json?.usdVnd) || null;
    // Uu tien SJC, thieu thi PNJ - dung thu tu voi app
    // (snap?.goldSjcSell ?? snap?.goldPnjSell).
    const goldSell = Number(json?.goldSjc?.sell) || Number(json?.goldPnj?.sell) ||
      null;
    return { usdVnd, goldSell };
  } catch {
    return { usdVnd: null, goldSell: null };
  }
}

/// Gia coin theo USD tu OKX. Nhan vao cac ky hieu san giao dich (BTC, ETH...).
///
/// Lay tung ticker 1 request giong price-alert-check thay vi 1 request lay ca
/// bang: so coin nguoi dung thuc su nam giu rat it (vai chuc la nhieu), doi lai
/// khong phai tai va parse toan bo hang nghin cap giao dich cua OKX.
async function fetchCoinPricesUsd(
  tickerSymbols: string[],
): Promise<Map<string, number>> {
  const out = new Map<string, number>();
  const results = await Promise.all(
    tickerSymbols.map(async (sym) => {
      try {
        const res = await fetch(
          `https://www.okx.com/api/v5/market/ticker?instId=${sym}-USDT`,
          { signal: AbortSignal.timeout(8000) },
        );
        const body = await res.json();
        const last = Number(
          (body?.data as Array<Record<string, string>> | undefined)?.[0]?.last,
        );
        return last ? ([sym, last] as const) : null;
      } catch {
        return null;
      }
    }),
  );
  for (const r of results) {
    if (r) out.set(r[0], r[1]);
  }
  return out;
}

/// Crypto luu trong wealth_holdings voi symbol = coinId cua CoinGecko
/// ("bitcoin"), con ky hieu san ("BTC") nam o dau cot `name` theo dang
/// "BTC|Bitcoin" (xem crypto_portfolio_repository.dart) - o day can ky hieu san
/// vi OKX dinh danh theo no.
function tickerOf(h: Holding): string | null {
  const head = (h.name ?? '').split('|')[0].trim().toUpperCase();
  return head.length > 0 ? head : null;
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }
  const expectedSecret = Deno.env.get('INVESTMENT_SNAPSHOT_WEBHOOK_SECRET');
  const gotSecret = req.headers.get('x-webhook-secret');
  if (!expectedSecret || gotSecret !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), {
      status: 401,
    });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);

  // Chi 4 nhom nay duoc tinh vao "Tai san dau tu" - dung y het app. Ngoai te
  // (foreign_currency) va co phieu VN (stock_vn) CO TRONG BANG nhung KHONG nam
  // trong tong nay, loc o query cho khoi keo ve thua.
  const { data, error } = await admin
    .from('wealth_holdings')
    .select('user_id, asset_type, symbol, name, quantity, avg_cost, manual_value')
    .in('asset_type', ['crypto', 'stock_intl', 'gold', 'real_estate']);
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
  const holdings = (data ?? []) as Holding[];
  if (holdings.length === 0) {
    return new Response(JSON.stringify({ users: 0, written: 0 }), { status: 200 });
  }

  const { usdVnd, goldSell } = await fetchVnAssets(supabaseUrl, serviceRoleKey);
  // Thieu ty gia thi crypto + co phieu quoc te deu thanh 0, tong ghi ra se
  // THAP GIA TAO - ve len bieu do la mot cu sut thang dung khong co that. Tha
  // bo qua vong nay (15 phut sau chay lai) con hon lam ban du lieu vinh vien.
  if (usdVnd == null) {
    return new Response(
      JSON.stringify({ skipped: 'Chua lay duoc ty gia USD/VND' }),
      { status: 200 },
    );
  }

  const tickers = [
    ...new Set(
      holdings
        .filter((h) => h.asset_type === 'crypto')
        .map(tickerOf)
        .filter((t): t is string => t !== null),
    ),
  ];
  const coinPrices = await fetchCoinPricesUsd(tickers);

  const totalByUser = new Map<string, number>();
  for (const h of holdings) {
    const qty = Number(h.quantity ?? 0);
    let vnd = 0;
    switch (h.asset_type) {
      case 'crypto': {
        const t = tickerOf(h);
        const price = t ? coinPrices.get(t) : undefined;
        if (price != null) vnd = price * qty * usdVnd;
        break;
      }
      case 'stock_intl':
        // Theo dung app: dinh gia co phieu quoc te bang GIA VON (avg_cost), chua
        // phai gia thi truong. Sai so nay co chu dich - de bieu do khop voi the
        // tong o man Home; sua thi phai sua CA HAI cung luc.
        vnd = Number(h.avg_cost ?? 0) * qty * usdVnd;
        break;
      case 'gold':
        if (goldSell != null) vnd = goldSell * qty;
        break;
      case 'real_estate':
        vnd = Number(h.manual_value ?? 0);
        break;
    }
    if (!Number.isFinite(vnd) || vnd <= 0) continue;
    totalByUser.set(h.user_id, (totalByUser.get(h.user_id) ?? 0) + vnd);
  }

  const takenAt = new Date().toISOString();
  const rows = [...totalByUser.entries()]
    .filter(([, v]) => v > 0)
    .map(([user_id, value_vnd]) => ({ user_id, taken_at: takenAt, value_vnd }));
  if (rows.length === 0) {
    return new Response(JSON.stringify({ users: 0, written: 0 }), { status: 200 });
  }

  // upsert chu khong insert: khoa chinh la (user_id, taken_at), neu 2 lan chay
  // cua workflow chong nhau (GitHub Actions co the tre va don lich) thi insert
  // se vo vi trung khoa.
  const { error: insertError } = await admin
    .from('wealth_investment_snapshots')
    .upsert(rows, { onConflict: 'user_id,taken_at' });
  if (insertError) {
    return new Response(JSON.stringify({ error: insertError.message }), {
      status: 500,
    });
  }

  return new Response(
    JSON.stringify({ users: totalByUser.size, written: rows.length }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  );
});
