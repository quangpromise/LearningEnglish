// Edge Function: quet toan bo (asset_type, symbol) dang co it nhat 1 user
// theo doi trong price_alert_watchlist, so gia hien tai voi 24h truoc - neu
// LECH >=5% (tang hoac giam) VA day la lan DAU vua vuot nguong (khac
// price_alert_state da luu), gui push FCM cho MOI user dang theo doi ma do
// (loc theo profiles.price_alerts_enabled = true) - goi 1 lan/15 phut boi
// GitHub Actions scheduled workflow (xem
// .github/workflows/price-alert-check.yml), KHONG goi truc tiep tu app
// Flutter (giong check-service-expiry, batch-driven theo lich).
//
// Can 4 secret (supabase secrets set ...) - 3 cai dau da co san tu
// send-chat-push/check-service-expiry, chi can them 1:
//   PRICE_ALERT_WEBHOOK_SECRET   - chuoi bi mat tu chon, PHAI khop voi
//                                  secret cung ten trong GitHub Actions
//   FIREBASE_SERVICE_ACCOUNT_JSON - da co san
//   FIREBASE_PROJECT_ID           - da co san
//   SUPABASE_SERVICE_ROLE_KEY     - da co san (bien moi truong mac dinh)
//
// Deploy: supabase functions deploy price-alert-check --no-verify-jwt --use-api

import { createClient } from 'jsr:@supabase/supabase-js@2';

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemBody = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const der = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

function base64url(input: ArrayBuffer | string): string {
  const bytes =
    typeof input === 'string' ? new TextEncoder().encode(input) : new Uint8Array(input);
  let str = '';
  bytes.forEach((b) => (str += String.fromCharCode(b)));
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function getAccessToken(clientEmail: string, privateKeyPem: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claims))}`;
  const key = await importPrivateKey(privateKeyPem);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64url(signature)}`;
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`Khong lay duoc access token: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token as string;
}

const ALERT_THRESHOLD_PERCENT = 5;

interface PriceInfo {
  assetType: 'crypto' | 'stock_okx' | 'stock_vn';
  symbol: string;
  price: number;
  changePercent: number;
}

async function fetchOkxTicker(instId: string): Promise<{ last: number; open24h: number } | null> {
  try {
    const res = await fetch(`https://www.okx.com/api/v5/market/ticker?instId=${instId}`);
    const body = await res.json();
    const row = (body?.data as Array<Record<string, string>> | undefined)?.[0];
    if (!row) return null;
    const last = Number(row.last);
    const open24h = Number(row.open24h);
    if (!last || !open24h) return null;
    return { last, open24h };
  } catch {
    return null;
  }
}

async function fetchCryptoPrices(symbols: string[]): Promise<PriceInfo[]> {
  const results = await Promise.all(
    symbols.map(async (symbol) => {
      const ticker = await fetchOkxTicker(`${symbol}-USDT`);
      if (!ticker) return null;
      return {
        assetType: 'crypto' as const,
        symbol,
        price: ticker.last,
        changePercent: ((ticker.last - ticker.open24h) / ticker.open24h) * 100,
      };
    }),
  );
  return results.filter((r): r is PriceInfo => r !== null);
}

async function fetchStockOkxPrices(symbols: string[]): Promise<PriceInfo[]> {
  const results = await Promise.all(
    symbols.map(async (symbol) => {
      const ticker = await fetchOkxTicker(`X${symbol}-USDT`);
      if (!ticker) return null;
      return {
        assetType: 'stock_okx' as const,
        symbol,
        price: ticker.last,
        changePercent: ((ticker.last - ticker.open24h) / ticker.open24h) * 100,
      };
    }),
  );
  return results.filter((r): r is PriceInfo => r !== null);
}

async function fetchStockVnPrices(
  symbols: string[],
  supabaseUrl: string,
  serviceRoleKey: string,
): Promise<PriceInfo[]> {
  if (symbols.length === 0) return [];
  try {
    const res = await fetch(
      `${supabaseUrl}/functions/v1/stocks-vn?symbols=${symbols.join(',')}`,
      { headers: { Authorization: `Bearer ${serviceRoleKey}` } },
    );
    if (!res.ok) return [];
    const rows = (await res.json()) as Array<{
      symbol: string;
      price: number;
      changePercent: number;
    }>;
    return rows.map((r) => ({
      assetType: 'stock_vn' as const,
      symbol: r.symbol,
      price: r.price,
      changePercent: r.changePercent,
    }));
  } catch {
    return [];
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }
  const expectedSecret = Deno.env.get('PRICE_ALERT_WEBHOOK_SECRET');
  const gotSecret = req.headers.get('x-webhook-secret');
  if (!expectedSecret || gotSecret !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);

  const { data: watched, error: watchedError } = await admin
    .from('price_alert_watchlist')
    .select('asset_type, symbol');
  if (watchedError) {
    return new Response(JSON.stringify({ error: watchedError.message }), { status: 500 });
  }
  if (!watched || watched.length === 0) {
    return new Response(JSON.stringify({ notified: 0, checked: 0 }), { status: 200 });
  }

  const bySymbol = new Map<string, Set<string>>();
  for (const row of watched as Array<{ asset_type: string; symbol: string }>) {
    const set = bySymbol.get(row.asset_type) ?? new Set<string>();
    set.add(row.symbol);
    bySymbol.set(row.asset_type, set);
  }

  const [cryptoPrices, stockOkxPrices, stockVnPrices] = await Promise.all([
    fetchCryptoPrices([...(bySymbol.get('crypto') ?? [])]),
    fetchStockOkxPrices([...(bySymbol.get('stock_okx') ?? [])]),
    fetchStockVnPrices([...(bySymbol.get('stock_vn') ?? [])], supabaseUrl, serviceRoleKey),
  ]);
  const allPrices = [...cryptoPrices, ...stockOkxPrices, ...stockVnPrices];

  const { data: states } = await admin
    .from('price_alert_state')
    .select('asset_type, symbol, direction');
  const stateByKey = new Map<string, string | null>();
  for (const s of (states as Array<{ asset_type: string; symbol: string; direction: string | null }>) ?? []) {
    stateByKey.set(`${s.asset_type}:${s.symbol}`, s.direction);
  }

  let accessToken: string | null = null;
  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');

  let notified = 0;
  for (const info of allPrices) {
    const direction: 'up' | 'down' | null =
      info.changePercent >= ALERT_THRESHOLD_PERCENT
        ? 'up'
        : info.changePercent <= -ALERT_THRESHOLD_PERCENT
          ? 'down'
          : null;

    const key = `${info.assetType}:${info.symbol}`;
    const previousDirection = stateByKey.get(key) ?? null;

    // Luon ghi de state moi nhat (ke ca khi direction ve null) - de lan vuot
    // nguong TIEP THEO duoc tinh la 1 su kien moi, khong bi coi la "da bao roi".
    await admin.from('price_alert_state').upsert({
      asset_type: info.assetType,
      symbol: info.symbol,
      direction,
      change_percent: info.changePercent,
      alerted_at: new Date().toISOString(),
    });

    if (direction === null || direction === previousDirection) continue;

    if (!serviceAccountRaw || !projectId) continue; // chua cau hinh Firebase - bo qua gui push, van cap nhat state
    if (!accessToken) {
      const serviceAccount = JSON.parse(serviceAccountRaw);
      accessToken = await getAccessToken(serviceAccount.client_email, serviceAccount.private_key);
    }

    // Khong dung embed join qua nhieu bang (price_alert_watchlist khong co
    // FK truc tiep toi device_tokens) - tach thanh 3 buoc don gian, chac
    // chan hoat dong voi PostgREST: watcher -> loc profile bat thong bao ->
    // lay token cua dung nhung user con lai.
    const { data: watchers } = await admin
      .from('price_alert_watchlist')
      .select('user_id')
      .eq('asset_type', info.assetType)
      .eq('symbol', info.symbol);
    const watcherIds = [...new Set((watchers ?? []).map((w: { user_id: string }) => w.user_id))];
    if (watcherIds.length === 0) continue;

    const { data: optedInProfiles } = await admin
      .from('profiles')
      .select('id')
      .in('id', watcherIds)
      .eq('price_alerts_enabled', true);
    const optedInIds = (optedInProfiles ?? []).map((p: { id: string }) => p.id);
    if (optedInIds.length === 0) continue;

    const { data: tokenRows } = await admin
      .from('device_tokens')
      .select('fcm_token')
      .in('user_id', optedInIds);
    const tokens = new Set((tokenRows ?? []).map((t: { fcm_token: string }) => t.fcm_token));
    if (tokens.size === 0) continue;

    const body =
      direction === 'up'
        ? `${info.symbol} tăng ${info.changePercent.toFixed(1)}% (24h) - giá hiện tại ${info.price}`
        : `${info.symbol} giảm ${Math.abs(info.changePercent).toFixed(1)}% (24h) - giá hiện tại ${info.price}`;

    await Promise.all(
      [...tokens].map((fcm_token) =>
        fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token: fcm_token,
              data: {
                type: 'price_alert',
                asset_type: info.assetType,
                symbol: info.symbol,
                price: String(info.price),
                change_percent: String(info.changePercent),
                direction,
                body,
              },
              android: { priority: 'high' },
            },
          }),
        }).catch(() => null),
      ),
    );
    notified++;
  }

  return new Response(JSON.stringify({ notified, checked: allPrices.length }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
