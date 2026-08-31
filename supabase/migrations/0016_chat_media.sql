-- Gui anh/file trong chat (kem GIF - xem cot 'kind') + tu dong don file
-- qua han sau 1 ngay de khong ton dung luong luu tru vo thoi han.

alter table public.messages
  add column if not exists kind text not null default 'text' check (kind in ('text', 'gif', 'image', 'file')),
  add column if not exists file_name text;

-- Bucket rieng cho anh/file gui trong chat - public=true (giong bucket
-- 'avatars') vi RLS storage khong the join sang bang messages de biet ai la
-- nguoi NHAN cua 1 file cu the; bao mat dua vao ten file random (uuid) kho
-- doan, giong co che link CDN cua nhieu app chat khac.
insert into storage.buckets (id, name, public)
values ('chat_media', 'chat_media', true)
on conflict (id) do nothing;

drop policy if exists "chat_media_public_read" on storage.objects;
create policy "chat_media_public_read"
  on storage.objects for select
  using (bucket_id = 'chat_media');

-- Chi duoc tai len vao dung thu muc cua CHINH MINH (storage.foldername(name)
-- la mang cac phan thu muc trong duong dan, phan tu dau = uid nguoi gui).
drop policy if exists "chat_media_insert_own" on storage.objects;
create policy "chat_media_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'chat_media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "chat_media_delete_own" on storage.objects;
create policy "chat_media_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'chat_media'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Don dep tu dong: XOA FILE trong storage (khong dong tin nhan) sau 1 ngay -
-- client tu hien "Tep da het han" khi tai anh/file that bai voi tin nhan cu
-- hon 1 ngay (xem social_repository.dart/chat_screen.dart), khong can cap
-- nhat gi them o dong tin nhan.
create extension if not exists pg_cron with schema extensions;

create or replace function public.cleanup_expired_chat_media()
returns void
language sql
security definer
set search_path = public
as $$
  delete from storage.objects
  where bucket_id = 'chat_media'
    and created_at < now() - interval '1 day';
$$;

-- cron.schedule voi ten job da ton tai se TU CAP NHAT lich thay vi loi -
-- migration nay chay lai nhieu lan (vd re-apply thu cong) van an toan.
select cron.schedule(
  'cleanup-expired-chat-media',
  '0 * * * *',
  $$ select public.cleanup_expired_chat_media(); $$
);
