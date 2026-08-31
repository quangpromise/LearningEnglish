-- Bo sung 'kind'/'file_name' vao payload gui cho Edge Function send-chat-push
-- (xem 0014_chat_push_notifications.sql) - can de thong bao he thong hien
-- "[Hinh anh]"/"da gui 1 tep" thay vi in thang URL kho hieu khi tin nhan la
-- anh/file/gif (xem migration 0016_chat_media.sql cho cot kind/file_name).

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
      'message_id', new.id,
      'kind', new.kind,
      'file_name', new.file_name
    )
  );
  return new;
end;
$$;
