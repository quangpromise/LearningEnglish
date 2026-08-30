-- Push notification cho tin nhan chat khi app da dong/khoa may - xem
-- app/lib/core/notifications/chat_push.dart cho code Flutter dang ky token,
-- va supabase/functions/send-chat-push/index.ts cho ham gui push qua FCM.
--
-- Co che: 1 trigger tren bang messages goi pg_net.http_post() (bat dong bo,
-- khong lam cham insert) toi Edge Function send-chat-push moi khi co tin
-- nhan moi. Edge Function tra cuu device_tokens cua nguoi nhan roi goi FCM.

-- ============================================================
-- 1. device_tokens - token FCM cua tung THIET BI (1 user co the dang nhap
-- nhieu may). Client upsert token nay ngay sau khi dang nhap va moi khi
-- Firebase cap token moi (xem ChatPush.init()).
-- ============================================================
create table if not exists public.device_tokens (
  fcm_token text primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  updated_at timestamptz not null default now()
);

create index if not exists device_tokens_user_id_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

drop policy if exists "device_tokens_all_own" on public.device_tokens;
create policy "device_tokens_all_own"
  on public.device_tokens for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ============================================================
-- 2. Trigger goi Edge Function qua pg_net khi co tin nhan moi. URL + secret
-- doc tu Vault (khong hardcode vao migration nay vi day la thong tin rieng
-- cua tung project, khong nen commit len git) - xem docs/setup-firebase-
-- chat-push.md de biet cach tao 2 secret nay 1 lan duy nhat qua SQL editor:
--   select vault.create_secret('https://<project-ref>.functions.supabase.co/send-chat-push', 'send_chat_push_url');
--   select vault.create_secret('<chuoi bi mat tu chon>', 'send_chat_push_secret');
-- Neu chua tao secret, trigger tu bo qua (khong loi, khong chan insert tin nhan).
-- ============================================================
-- pg_net luon tao ham cua no trong schema rieng "net" bat ke khai bao
-- "with schema" gi - khong can chi dinh.
create extension if not exists pg_net;

create or replace function public.notify_new_message()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  function_url text;
  webhook_secret text;
begin
  select decrypted_secret into function_url
    from vault.decrypted_secrets where name = 'send_chat_push_url';
  select decrypted_secret into webhook_secret
    from vault.decrypted_secrets where name = 'send_chat_push_secret';

  if function_url is null or webhook_secret is null then
    return new;
  end if;

  perform net.http_post(
    url := function_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', webhook_secret
    ),
    body := jsonb_build_object(
      'sender_id', new.sender_id,
      'receiver_id', new.receiver_id,
      'content', new.content,
      'message_id', new.id
    )
  );
  return new;
end;
$$;

drop trigger if exists on_new_message_send_push on public.messages;
create trigger on_new_message_send_push
  after insert on public.messages
  for each row execute function public.notify_new_message();
