// Edge Function: admin cap diem thuong cho 1 user.
// Goi voi header Authorization: Bearer <access_token cua admin dang dang nhap>
// Body JSON: { "userId": "uuid-cua-user-nhan-diem", "amount": 50, "reason": "Hoan thanh 10 bai hat" }
//
// Deploy: supabase functions deploy grant-points

import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Thiếu Authorization header' }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // Client dùng service_role để ghi vào DB (bỏ qua RLS) — CHỈ được dùng
  // sau khi đã tự xác minh caller thực sự là admin ở bước dưới.
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  // Client dùng token của caller để xác minh danh tính + role qua RLS bình thường.
  const callerClient = createClient(supabaseUrl, serviceRoleKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const {
    data: { user },
    error: userError,
  } = await callerClient.auth.getUser();

  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Token không hợp lệ' }), { status: 401 });
  }

  const { data: callerProfile, error: profileError } = await adminClient
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  if (profileError || callerProfile?.role !== 'admin') {
    return new Response(JSON.stringify({ error: 'Chỉ admin mới được cấp điểm' }), { status: 403 });
  }

  const { userId, amount, reason } = await req.json();

  if (!userId || typeof amount !== 'number' || amount === 0) {
    return new Response(JSON.stringify({ error: 'Thiếu userId hoặc amount không hợp lệ' }), { status: 400 });
  }

  const { error: insertError } = await adminClient.from('point_transactions').insert({
    user_id: userId,
    amount,
    reason: reason ?? null,
    granted_by: user.id,
  });

  if (insertError) {
    return new Response(JSON.stringify({ error: insertError.message }), { status: 500 });
  }

  const { data: balance } = await adminClient.rpc('user_points_balance', { target_user_id: userId });

  return new Response(JSON.stringify({ success: true, newBalance: balance }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
