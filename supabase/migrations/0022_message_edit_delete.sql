-- Sua/xoa tin nhan CUA CHINH MINH da gui, kieu Messenger - xoa la XOA MEM
-- (danh dau deleted_at, khong xoa dong that su) de nguoi con lai van thay 1
-- vet "Tin nhan da bi xoa" thay vi mat hang trong luong tin, giong hanh vi
-- that cua Messenger.

alter table public.messages
  add column if not exists edited_at timestamptz,
  add column if not exists deleted_at timestamptz;

-- Bang messages TRUOC DAY chua co policy UPDATE nao (chi select/insert) -
-- chi nguoi GUI moi duoc sua noi dung/danh dau xoa tin nhan cua chinh minh.
drop policy if exists "messages_update_own" on public.messages;
create policy "messages_update_own"
  on public.messages for update
  using (auth.uid() = sender_id)
  with check (auth.uid() = sender_id);
