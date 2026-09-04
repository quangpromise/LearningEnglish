// Edge Function: quet toan bo wealth_recurring_services con <=7 ngay den han
// (va CHUA duoc nhac trong ngay hom nay), gui push FCM nhac han cho tung
// user - goi 1 lan/ngay boi GitHub Actions scheduled workflow (xem
// .github/workflows/service-expiry-check.yml), KHONG goi truc tiep tu app
// Flutter (khac send-chat-push la event-driven qua trigger Postgres, day la
// batch-driven theo lich hang ngay vi khong co "su kien" nao de bam vao).
//
// Can 4 secret (supabase secrets set ...) - 3 cai dau da co san tu
// send-chat-push, chi can them 1:
//   SERVICE_EXPIRY_WEBHOOK_SECRET  - chuoi bi mat tu chon, PHAI khop voi
//                                    secret cung ten trong GitHub Actions
//   FIREBASE_SERVICE_ACCOUNT_JSON  - da co san
//   FIREBASE_PROJECT_ID            - da co san
//   SUPABASE_SERVICE_ROLE_KEY      - da co san (bien moi truong mac dinh)
//
// Deploy: supabase functions deploy check-service-expiry --no-verify-jwt --use-api

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

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }
  const expectedSecret = Deno.env.get('SERVICE_EXPIRY_WEBHOOK_SECRET');
  const gotSecret = req.headers.get('x-webhook-secret');
  if (!expectedSecret || gotSecret !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);

  const today = new Date().toISOString().slice(0, 10);
  const in30Days = new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10);

  // Loc truoc theo nguong xa nhat co the (30 ngay, gia tri lon nhat cua
  // reminder_lead_days) de giam so dong tra ve, roi loc chinh xac theo
  // reminder_lead_days RIENG cua tung dich vu ngay ben duoi (khong the lam
  // 1 lan trong query vi la so sanh giua 2 cot).
  const { data: services, error } = await admin
    .from('wealth_recurring_services')
    .select('id, user_id, name, expiry_date, last_notified_on, reminder_lead_days')
    .eq('is_active', true)
    .lte('expiry_date', in30Days)
    .or(`last_notified_on.is.null,last_notified_on.lt.${today}`);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
  if (!services || services.length === 0) {
    return new Response(JSON.stringify({ notified: 0 }), { status: 200 });
  }

  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');
  if (!serviceAccountRaw || !projectId) {
    return new Response(
      JSON.stringify({ error: 'Chua cau hinh Firebase service account' }),
      { status: 500 },
    );
  }
  const serviceAccount = JSON.parse(serviceAccountRaw);
  const accessToken = await getAccessToken(serviceAccount.client_email, serviceAccount.private_key);

  let notified = 0;
  for (const svc of services) {
    const daysLeft = Math.round(
      (new Date(svc.expiry_date).getTime() - new Date(today).getTime()) / 86400000,
    );
    if (daysLeft < 0 || daysLeft > svc.reminder_lead_days) continue;

    const { data: tokens } = await admin
      .from('device_tokens')
      .select('fcm_token')
      .eq('user_id', svc.user_id);

    if (tokens && tokens.length > 0) {
      const body =
        daysLeft === 0
          ? `Dịch vụ "${svc.name}" hết hạn HÔM NAY.`
          : `Dịch vụ "${svc.name}" còn ${daysLeft} ngày sẽ hết hạn.`;
      await Promise.all(
        tokens.map(({ fcm_token }: { fcm_token: string }) =>
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
                  type: 'service_expiry',
                  service_id: svc.id,
                  service_name: svc.name,
                  days_left: String(daysLeft),
                  body,
                },
                android: { priority: 'high' },
              },
            }),
          }).catch(() => null)
        ),
      );
    }

    await admin
      .from('wealth_recurring_services')
      .update({ last_notified_on: today })
      .eq('id', svc.id);
    notified++;
  }

  return new Response(JSON.stringify({ notified }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
