-- Biet danh (nickname) CHO RIENG 1 nguoi dung dat cho 1 ban be - CHI hien
-- thi PHIA nguoi dat (khong doi ten nguoi kia thay cho ca 2 chieu), giong
-- tinh nang "Nickname" cua Messenger.

create table if not exists public.friend_nicknames (
  user_id uuid not null references public.profiles (id) on delete cascade,
  friend_id uuid not null references public.profiles (id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 50),
  created_at timestamptz not null default now(),
  primary key (user_id, friend_id)
);

alter table public.friend_nicknames enable row level security;

-- Chi chinh chu (nguoi dat) moi duoc xem/tao/sua/xoa - hoan toan rieng tu,
-- ban be khong biet minh dat biet danh gi cho ho.
drop policy if exists "friend_nicknames_all_own" on public.friend_nicknames;
create policy "friend_nicknames_all_own"
  on public.friend_nicknames for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

alter publication supabase_realtime add table public.friend_nicknames;
