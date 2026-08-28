-- Ket ban, chat 1-1, va trang thai online. Xem app/lib/features/social/
-- cho code Flutter dung cac bang/RPC nay.

-- ============================================================
-- 1. Trang thai online: 1 cot last_seen_at tren profiles, client tu goi
-- update_my_presence() dinh ky (heartbeat) khi app dang mo/foreground.
-- Online = last_seen_at trong vong 90 giay gan nhat.
-- ============================================================
alter table public.profiles add column if not exists last_seen_at timestamptz;

-- ============================================================
-- 2. friendships — 1 dong / 1 cap quan he, requester la nguoi gui loi moi.
-- status: 'pending' (dang cho) -> 'accepted' (da la ban be).
-- ============================================================
create table if not exists public.friendships (
  requester_id uuid not null references public.profiles (id) on delete cascade,
  addressee_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  primary key (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

alter table public.friendships enable row level security;

drop policy if exists "friendships_select_involved" on public.friendships;
create policy "friendships_select_involved"
  on public.friendships for select
  using (auth.uid() = requester_id or auth.uid() = addressee_id);

drop policy if exists "friendships_insert_as_requester" on public.friendships;
create policy "friendships_insert_as_requester"
  on public.friendships for insert
  with check (auth.uid() = requester_id);

-- Chi nguoi duoc moi (addressee) moi duoc doi status (chap nhan loi moi).
drop policy if exists "friendships_update_as_addressee" on public.friendships;
create policy "friendships_update_as_addressee"
  on public.friendships for update
  using (auth.uid() = addressee_id)
  with check (auth.uid() = addressee_id);

-- Ca 2 phia deu duoc xoa (huy loi moi / tu choi / huy ket ban).
drop policy if exists "friendships_delete_involved" on public.friendships;
create policy "friendships_delete_involved"
  on public.friendships for delete
  using (auth.uid() = requester_id or auth.uid() = addressee_id);

-- ============================================================
-- 3. messages — tin nhan 1-1, CHI gui duoc cho nguoi da la ban be
-- (accepted) - kiem tra ngay trong RLS insert, khong can qua RPC rieng
-- de client van dung duoc Supabase Realtime (postgres_changes) truc tiep
-- tren bang nay.
-- ============================================================
create table if not exists public.messages (
  id bigint generated always as identity primary key,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  receiver_id uuid not null references public.profiles (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists messages_conversation_idx
  on public.messages (least(sender_id, receiver_id), greatest(sender_id, receiver_id), created_at);

alter table public.messages enable row level security;

drop policy if exists "messages_select_involved" on public.messages;
create policy "messages_select_involved"
  on public.messages for select
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "messages_insert_as_sender_if_friends" on public.messages;
create policy "messages_insert_as_sender_if_friends"
  on public.messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.friendships f
      where f.status = 'accepted'
        and (
          (f.requester_id = auth.uid() and f.addressee_id = messages.receiver_id)
          or (f.addressee_id = auth.uid() and f.requester_id = messages.receiver_id)
        )
    )
  );

-- Bat Realtime (postgres_changes) cho bang messages de app nhan tin moi
-- ngay lap tuc khong can tu poll lai.
alter publication supabase_realtime add table public.messages;

-- ============================================================
-- 4. RPC: tim user theo username/display_name - profiles co RLS chi cho
-- xem ho so CUA CHINH MINH, nen phai qua SECURITY DEFINER de tra ve vai
-- truong cong khai (khong bao gio tra email) cho MOI user da dang nhap.
-- ============================================================
create or replace function public.search_users(query text)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  friend_status text
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
    coalesce(
      (
        select f.status from public.friendships f
        where (f.requester_id = auth.uid() and f.addressee_id = p.id)
           or (f.addressee_id = auth.uid() and f.requester_id = p.id)
        limit 1
      ),
      'none'
    ) as friend_status
  from public.profiles p
  where p.id <> auth.uid()
    and query <> ''
    and (p.username ilike '%' || query || '%' or p.display_name ilike '%' || query || '%')
  order by p.username nulls last
  limit 20;
$$;

grant execute on function public.search_users(text) to authenticated;

-- ============================================================
-- 5. RPC: danh sach ban be (accepted) kem trang thai online.
-- ============================================================
create or replace function public.my_friends()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  is_online boolean,
  last_seen_at timestamptz
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
    p.last_seen_at
  from public.friendships f
  join public.profiles p
    on p.id = (case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end)
  where f.status = 'accepted'
    and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  order by is_online desc, coalesce(p.display_name, p.username) asc;
$$;

grant execute on function public.my_friends() to authenticated;

-- ============================================================
-- 6. RPC: loi moi ket ban dang cho minh chap nhan (minh la addressee).
-- ============================================================
create or replace function public.my_pending_requests()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  created_at timestamptz
)
language sql
stable
security definer set search_path = public
as $$
  select p.id, p.username, p.display_name, p.avatar_url, f.created_at
  from public.friendships f
  join public.profiles p on p.id = f.requester_id
  where f.addressee_id = auth.uid() and f.status = 'pending'
  order by f.created_at desc;
$$;

grant execute on function public.my_pending_requests() to authenticated;

-- ============================================================
-- 7. RPC: heartbeat - client goi dinh ky de cap nhat last_seen_at.
-- ============================================================
create or replace function public.update_my_presence()
returns void
language sql
security definer set search_path = public
as $$
  update public.profiles set last_seen_at = now() where id = auth.uid();
$$;

grant execute on function public.update_my_presence() to authenticated;
