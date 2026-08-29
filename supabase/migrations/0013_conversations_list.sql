-- Danh sach hoi thoai (kieu Messenger): moi ban be 1 dong, kem tin nhan
-- gan nhat + so tin chua doc - dung cho man hinh Tin nhan moi (thay the
-- viec phai mo tung ban de xem co tin moi khong). Xem
-- app/lib/features/social/ cho code Flutter dung RPC nay.

create or replace function public.my_conversations()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  is_online boolean,
  last_seen_at timestamptz,
  last_message text,
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
    lm.content as last_message,
    lm.created_at as last_message_at,
    (lm.sender_id = auth.uid()) as last_message_is_mine,
    coalesce(uc.unread_count, 0)::integer as unread_count
  from public.friendships f
  join public.profiles p
    on p.id = (case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end)
  left join lateral (
    select m.content, m.created_at, m.sender_id
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
