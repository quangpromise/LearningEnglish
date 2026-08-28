-- Trang thai da doc cho tin nhan 1-1, phuc vu nut tin nhan + badge do o
-- Home (giong Facebook: hien so/dau cham khi co tin chua doc). Xem
-- app/lib/features/social/ cho code Flutter dung cac RPC nay.

alter table public.messages add column if not exists read_at timestamptz;

-- ============================================================
-- RPC: tong so tin nhan CHUA DOC gui DEN minh (moi nguoi gui) - dung cho
-- badge tren nut tin nhan o Home.
-- ============================================================
create or replace function public.unread_message_count()
returns integer
language sql
stable
security definer set search_path = public
as $$
  select count(*)::integer
  from public.messages
  where receiver_id = auth.uid() and read_at is null;
$$;

grant execute on function public.unread_message_count() to authenticated;

-- ============================================================
-- RPC: danh dau toan bo tin nhan cua 1 cuoc hoi thoai la DA DOC - goi khi
-- mo ChatScreen voi 1 nguoi ban.
-- ============================================================
create or replace function public.mark_conversation_read(other_user_id uuid)
returns void
language sql
security definer set search_path = public
as $$
  update public.messages
  set read_at = now()
  where receiver_id = auth.uid()
    and sender_id = other_user_id
    and read_at is null;
$$;

grant execute on function public.mark_conversation_read(uuid) to authenticated;
