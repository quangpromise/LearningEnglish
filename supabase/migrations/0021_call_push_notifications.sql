-- Bao thuc thiet bi khi co cuoc goi den ma app da dong/khoa may - giong het
-- co che push tin nhan chat (0014_chat_push_notifications.sql) nhung goi
-- Edge Function rieng (notify-incoming-call) va CHI kich hoat khi 1 dong moi
-- duoc INSERT vao bang calls (luon la trang thai 'ringing').
--
-- Secret rieng trong Vault (tao 1 lan qua SQL editor, xem
-- docs/setup-agora-calls.md):
--   select vault.create_secret('https://<project-ref>.functions.supabase.co/notify-incoming-call', 'send_call_push_url');
--   select vault.create_secret('<chuoi bi mat tu chon>', 'send_call_push_secret');

create or replace function public.notify_new_call()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  function_url text;
  webhook_secret text;
begin
  select decrypted_secret into function_url
    from vault.decrypted_secrets where name = 'send_call_push_url';
  select decrypted_secret into webhook_secret
    from vault.decrypted_secrets where name = 'send_call_push_secret';

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
      'call_id', new.id,
      'caller_id', new.caller_id,
      'callee_id', new.callee_id,
      'channel_name', new.channel_name,
      'call_type', new.call_type
    )
  );
  return new;
end;
$$;

drop trigger if exists on_new_call_send_push on public.calls;
create trigger on_new_call_send_push
  after insert on public.calls
  for each row execute function public.notify_new_call();
