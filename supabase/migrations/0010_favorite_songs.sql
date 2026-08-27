-- Danh sach bai hat yeu thich cua tung user. Bai hat la du lieu tinh
-- (kSongs trong songs_data.dart), khong luu trong DB - chi luu TEN bai hat
-- lam dinh danh (giong cach user_completed_songs da lam).
create table if not exists public.user_favorite_songs (
  user_id uuid not null references public.profiles (id) on delete cascade,
  song_title text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, song_title)
);

alter table public.user_favorite_songs enable row level security;

drop policy if exists "favorite_songs_select_own" on public.user_favorite_songs;
create policy "favorite_songs_select_own"
  on public.user_favorite_songs for select
  using (auth.uid() = user_id);

drop policy if exists "favorite_songs_insert_own" on public.user_favorite_songs;
create policy "favorite_songs_insert_own"
  on public.user_favorite_songs for insert
  with check (auth.uid() = user_id);

drop policy if exists "favorite_songs_delete_own" on public.user_favorite_songs;
create policy "favorite_songs_delete_own"
  on public.user_favorite_songs for delete
  using (auth.uid() = user_id);
