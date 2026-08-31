// Edge Function: sinh token RTC Agora cho 1 phien goi thoai/video - PHAI qua
// server vi can App Certificate (bi mat tuyet doi, khong duoc nhung vao app
// Flutter) de ky token. Goi truc tiep tu app (co kem JWT dang nhap cua
// nguoi dung, KHAC voi send-chat-push la webhook noi bo tu Postgres trigger).
//
// Can 2 secret (supabase secrets set ...):
//   AGORA_APP_ID            - App ID cua project Agora
//   AGORA_APP_CERTIFICATE   - App Certificate (Primary Certificate) - BI MAT
//
// Deploy: supabase functions deploy agora-token
// (CO xac thuc JWT binh thuong - khac send-chat-push - vi day la API goi
// truc tiep tu nguoi dung dang nhap, khong phai server-to-server.)

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { RtcRole, RtcTokenBuilder } from 'npm:agora-access-token@2.0.4';

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Thieu Authorization' }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();
  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
  }

  const { channel_name, uid } = (await req.json()) as {
    channel_name?: string;
    uid?: number;
  };
  if (!channel_name || typeof uid !== 'number') {
    return new Response(JSON.stringify({ error: 'Thieu channel_name/uid' }), { status: 400 });
  }

  const appId = Deno.env.get('AGORA_APP_ID');
  const appCertificate = Deno.env.get('AGORA_APP_CERTIFICATE');
  if (!appId || !appCertificate) {
    return new Response(JSON.stringify({ error: 'Chua cau hinh Agora' }), { status: 500 });
  }

  // Token song 1 gio - du cho 1 cuoc goi, nguoi dung goi lai API nay neu
  // can gia han (vd cuoc goi keo dai qua lau, hiem khi xay ra trong thuc te).
  const privilegeExpiredTs = Math.floor(Date.now() / 1000) + 3600;
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channel_name,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs,
  );

  return new Response(JSON.stringify({ token, app_id: appId }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
