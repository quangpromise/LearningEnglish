// Edge Function: gui push notification (Firebase Cloud Messaging) toi
// nguoi nhan khi co tin nhan chat moi - duoc goi tu dong boi trigger
// on_new_message_send_push (xem supabase/migrations/0014_chat_push_notifications.sql),
// KHONG goi truc tiep tu app Flutter.
//
// Can 3 secret (supabase secrets set ...):
//   CHAT_PUSH_WEBHOOK_SECRET       - phai KHOP voi secret 'send_chat_push_secret' trong Vault
//   FIREBASE_SERVICE_ACCOUNT_JSON  - noi dung FULL file service-account.json tai tu
//                                    Firebase Console > Project settings > Service accounts
//   FIREBASE_PROJECT_ID            - project ID Firebase (vd "learn-english-music-xxxxx")
//
// Deploy: supabase functions deploy send-chat-push --no-verify-jwt
// (--no-verify-jwt vi request den tu trigger Postgres, khong kem user JWT -
// da tu xac thuc bang header x-webhook-secret rieng thay the.)

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface MessagePayload {
  sender_id: string;
  receiver_id: string;
  content: string;
  message_id: number;
  kind?: string;
  file_name?: string | null;
}

// Chuyen PEM private key (tu service account JSON) thanh CryptoKey de ky JWT
// RS256 - Deno Edge Runtime ho tro Web Crypto (SubtleCrypto) san.
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

// Doi 1 service account JSON lay 1 access token OAuth2 (JWT Bearer flow) de
// goi FCM HTTP v1 API - API nay KHONG con dung server key tinh don gian
// nhu FCM legacy (da bi Google ngung ho tro).
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

  const expectedSecret = Deno.env.get('CHAT_PUSH_WEBHOOK_SECRET');
  const gotSecret = req.headers.get('x-webhook-secret');
  if (!expectedSecret || gotSecret !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }

  const payload = (await req.json()) as MessagePayload;
  if (!payload.receiver_id || !payload.sender_id || !payload.content) {
    return new Response(JSON.stringify({ error: 'Thieu truong bat buoc' }), { status: 400 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const [{ data: tokens }, { data: senderProfile }] = await Promise.all([
    adminClient
      .from('device_tokens')
      .select('fcm_token')
      .eq('user_id', payload.receiver_id),
    adminClient
      .from('profiles')
      .select('display_name, username, avatar_url')
      .eq('id', payload.sender_id)
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

  const senderName =
    senderProfile?.display_name || senderProfile?.username || 'Bạn bè';

  // Tin nhan anh/file/sticker co 'content' la 1 URL - khong hien thang URL
  // do trong noi dung thong bao (kho hieu, xau), thay bang mo ta ngan gon.
  // 'content' GOC van duoc gui kem rieng (xem duoi) de client tu quyet dinh
  // hien anh xem truoc that (vd sticker/anh dung BigPictureStyle) khi can.
  const previewText = (() => {
    switch (payload.kind) {
      case 'sticker':
        return '[Sticker]';
      case 'image':
        return '[Hình ảnh]';
      case 'file':
        return `📎 ${payload.file_name ?? 'Tệp đính kèm'}`;
      default:
        return payload.content;
    }
  })();

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
              // CO Y KHONG dung truong `notification` cua FCM - de Android
              // tu hien thong bao thi khong co cho nao nhet URL anh dai
              // dien RIENG cho tung tin nhan (chi co 1 icon nho co dinh cua
              // app). Gui data-only de app tu dung thong bao qua
              // flutter_local_notifications, moi co the tai anh dai dien
              // nguoi gui lam "large icon" tron nhu Messenger (xem
              // _showChatNotification trong chat_push.dart).
              data: {
                type: 'chat_message',
                sender_id: payload.sender_id,
                sender_name: senderName,
                sender_avatar_url: senderProfile?.avatar_url ?? '',
                content: previewText,
                kind: payload.kind ?? 'text',
                media_url: payload.kind === 'sticker' || payload.kind === 'image'
                  ? payload.content
                  : '',
              },
              android: { priority: 'high' },
            },
          }),
        },
      );
      if (!res.ok) {
        const body = await res.text();
        // Token het han/bi go cai dat app - xoa khoi bang de khong thu lai
        // vo ich cac lan sau.
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
