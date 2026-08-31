// Edge Function: bao thuc thiet bi nguoi NHAN khi co cuoc goi den (qua FCM),
// hoat dong ca khi app da dong/khoa may - duoc goi tu dong boi trigger
// on_new_call_send_push (xem supabase/migrations/0021_call_push_notifications.sql),
// KHONG goi truc tiep tu app Flutter. Cau truc gan giong het send-chat-push,
// chi khac noi dung payload va type gui cho client.
//
// Can 3 secret (giong send-chat-push, DUNG CHUNG project-wide):
//   CALL_PUSH_WEBHOOK_SECRET       - phai KHOP voi secret 'send_call_push_secret' trong Vault
//   FIREBASE_SERVICE_ACCOUNT_JSON  - dung chung voi send-chat-push
//   FIREBASE_PROJECT_ID            - dung chung voi send-chat-push
//
// Deploy: supabase functions deploy notify-incoming-call --no-verify-jwt

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface CallPayload {
  call_id: number;
  caller_id: string;
  callee_id: string;
  channel_name: string;
  call_type: string;
}

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
  if (!res.ok) {
    throw new Error(`Khong lay duoc access token: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  return json.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const expectedSecret = Deno.env.get('CALL_PUSH_WEBHOOK_SECRET');
  const gotSecret = req.headers.get('x-webhook-secret');
  if (!expectedSecret || gotSecret !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }

  const payload = (await req.json()) as CallPayload;
  if (!payload.callee_id || !payload.caller_id || !payload.channel_name) {
    return new Response(JSON.stringify({ error: 'Thieu truong bat buoc' }), { status: 400 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const [{ data: tokens }, { data: callerProfile }] = await Promise.all([
    adminClient
      .from('device_tokens')
      .select('fcm_token')
      .eq('user_id', payload.callee_id),
    adminClient
      .from('profiles')
      .select('display_name, username, avatar_url')
      .eq('id', payload.caller_id)
      .single(),
  ]);

  if (!tokens || tokens.length === 0) {
    return new Response(JSON.stringify({ skipped: 'no_device_token' }), { status: 200 });
  }

  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');
  if (!serviceAccountRaw || !projectId) {
    return new Response(JSON.stringify({ error: 'Chua cau hinh Firebase service account' }), {
      status: 500,
    });
  }
  const serviceAccount = JSON.parse(serviceAccountRaw);
  const accessToken = await getAccessToken(
    serviceAccount.client_email,
    serviceAccount.private_key,
  );

  const callerName =
    callerProfile?.display_name || callerProfile?.username || 'Bạn bè';

  const results = await Promise.all(
    tokens.map(async ({ fcm_token }: { fcm_token: string }) => {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token: fcm_token,
              // Data-only (khong dung `notification`) - app tu dung 1 thong
              // bao full-screen-intent rieng cho cuoc goi (xem call_push.dart),
              // khac han thong bao tin nhan thuong.
              data: {
                type: 'incoming_call',
                call_id: String(payload.call_id),
                caller_id: payload.caller_id,
                caller_name: callerName,
                caller_avatar_url: callerProfile?.avatar_url ?? '',
                channel_name: payload.channel_name,
                call_type: payload.call_type,
              },
              android: {
                priority: 'high',
                // TTL ngan - cuoc goi khong con y nghia neu den tre qua vai
                // chuc giay (nguoi nhan coi nhu goi nho).
                ttl: '30s',
              },
            },
          }),
        },
      );
      if (!res.ok) {
        const body = await res.text();
        if (body.includes('UNREGISTERED') || body.includes('NOT_FOUND')) {
          await adminClient.from('device_tokens').delete().eq('fcm_token', fcm_token);
        }
        return { token: fcm_token, ok: false, error: body };
      }
      return { token: fcm_token, ok: true };
    }),
  );

  return new Response(JSON.stringify({ results }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
