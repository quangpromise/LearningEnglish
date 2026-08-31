-- Bo sung deleted_at cua tin nhan GAN NHAT vao my_conversations() (hien "Tin
-- nhan da bi xoa" thay vi in lai noi dung that - xem
-- migration 0022_message_edit_delete.sql) VA bo sung nickname (bi mat, chi
-- minh thay - xem migration 0023_friend_nicknames.sql) vao ca 3 RPC ban be
-- de "hien thi bat cu man hinh nao" dung nhu yeu cau, khong chi rieng 1 cho.

drop function if exists public.my_conversations();

create or replace function public.my_conversations()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  is_online boolean,
  last_seen_at timestamptz,
  nickname text,
  last_message text,
  last_message_kind text,
  last_message_file_name text,
  last_message_deleted boolean,
  last_message_at timestamptz,
  last_message_is_mine boolean,
  unread_count integer
)
language sql
stable
security definer set search_path = public
as $$
  select
    p.id,
    p.username,
    p.display_name,
    p.avatar_url,
    (p.last_seen_at is not null and p.last_seen_at > now() - interval '90 seconds') as is_online,
    p.last_seen_at,
    fn.nickname,
    lm.content as last_message,
    lm.kind as last_message_kind,
    lm.file_name as last_message_file_name,
    (lm.deleted_at is not null) as last_message_deleted,
    lm.created_at as last_message_at,
    (lm.sender_id = auth.uid()) as last_message_is_mine,
    coalesce(uc.unread_count, 0)::integer as unread_count
  from public.friendships f
  join public.profiles p
    on p.id = (case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end)
  left join public.friend_nicknames fn
    on fn.user_id = auth.uid() and fn.friend_id = p.id
  left join lateral (
    select m.content, m.created_at, m.sender_id, m.kind, m.file_name, m.deleted_at
    from public.messages m
    where (m.sender_id = auth.uid() and m.receiver_id = p.id)
       or (m.sender_id = p.id and m.receiver_id = auth.uid())
    order by m.created_at desc
    limit 1
  ) lm on true
  left join lateral (
    select count(*) as unread_count
    from public.messages m
    where m.sender_id = p.id and m.receiver_id = auth.uid() and m.read_at is null
  ) uc on true
  where f.status = 'accepted'
    and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  order by coalesce(lm.created_at, f.created_at) desc;
$$;

grant execute on function public.my_conversations() to authenticated;

drop function if exists public.my_friends();

create or replace function public.my_friends()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  is_online boolean,
  last_seen_at timestamptz,
  nickname text
)
language sql
stable
security definer set search_path = public
as $$
  select
    p.id,
    p.username,
    p.display_name,
    p.avatar_url,
    (p.last_seen_at is not null and p.last_seen_at > now() - interval '90 seconds') as is_online,
    p.last_seen_at,
    fn.nickname
  from public.friendships f
  join public.profiles p
    on p.id = (case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end)
  left join public.friend_nicknames fn
    on fn.user_id = auth.uid() and fn.friend_id = p.id
  where f.status = 'accepted'
    and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  order by is_online desc, coalesce(fn.nickname, p.display_name, p.username) asc;
$$;

grant execute on function public.my_friends() to authenticated;

drop function if exists public.my_pending_requests();

create or replace function public.my_pending_requests()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  created_at timestamptz,
  nickname text
)
language sql
stable
security definer set search_path = public
as $$
  select p.id, p.username, p.display_name, p.avatar_url, f.created_at, fn.nickname
  from public.friendships f
  join public.profiles p on p.id = f.requester_id
  left join public.friend_nicknames fn
    on fn.user_id = auth.uid() and fn.friend_id = p.id
  where f.addressee_id = auth.uid() and f.status = 'pending'
  order by f.created_at desc;
$$;

grant execute on function public.my_pending_requests() to authenticated;
