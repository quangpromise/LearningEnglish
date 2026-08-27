-- Thong ke THAT cho man hinh Ho so (thay du lieu gia cung trong code):
-- tu da hoc, bai hat hoan thanh, diem phat am trung binh, thoi gian luyen tap.
-- Kem ham reset_my_stats() de nguoi dung tu dua thong ke ve 0.

-- ============================================================
-- 1. user_learned_words — moi dong la 1 tu tieng Anh nguoi dung da tra nghia
-- ============================================================
create table if not exists public.user_learned_words (
  user_id uuid not null references public.profiles (id) on delete cascade,
  word text not null,
  first_seen_at timestamptz not null default now(),
  primary key (user_id, word)
);

alter table public.user_learned_words enable row level security;

drop policy if exists "learned_words_select_own" on public.user_learned_words;
create policy "learned_words_select_own"
  on public.user_learned_words for select
  using (auth.uid() = user_id);

drop policy if exists "learned_words_insert_own" on public.user_learned_words;
create policy "learned_words_insert_own"
  on public.user_learned_words for insert
  with check (auth.uid() = user_id);

-- ============================================================
-- 2. user_completed_songs — moi dong la 1 bai hat da nghe het it nhat 1 lan
-- ============================================================
create table if not exists public.user_completed_songs (
  user_id uuid not null references public.profiles (id) on delete cascade,
  song_title text not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, song_title)
);

alter table public.user_completed_songs enable row level security;

drop policy if exists "completed_songs_select_own" on public.user_completed_songs;
create policy "completed_songs_select_own"
  on public.user_completed_songs for select
  using (auth.uid() = user_id);

drop policy if exists "completed_songs_insert_own" on public.user_completed_songs;
create policy "completed_songs_insert_own"
  on public.user_completed_songs for insert
  with check (auth.uid() = user_id);

-- ============================================================
-- 3. user_pronunciation_attempts — moi dong la 1 lan cham diem phat am
-- ============================================================
create table if not exists public.user_pronunciation_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  score integer not null check (score >= 0 and score <= 100),
  created_at timestamptz not null default now()
);

alter table public.user_pronunciation_attempts enable row level security;

drop policy if exists "pron_attempts_select_own" on public.user_pronunciation_attempts;
create policy "pron_attempts_select_own"
  on public.user_pronunciation_attempts for select
  using (auth.uid() = user_id);

drop policy if exists "pron_attempts_insert_own" on public.user_pronunciation_attempts;
create policy "pron_attempts_insert_own"
  on public.user_pronunciation_attempts for insert
  with check (auth.uid() = user_id);

-- ============================================================
-- 4. user_practice_time — tong so giay da luyen tap (nghe nhac + luyen phat am)
-- ============================================================
create table if not exists public.user_practice_time (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  seconds integer not null default 0
);

alter table public.user_practice_time enable row level security;

drop policy if exists "practice_time_select_own" on public.user_practice_time;
create policy "practice_time_select_own"
  on public.user_practice_time for select
  using (auth.uid() = user_id);

-- Khong co policy insert/update truc tiep - chi sua qua ham add_practice_seconds
-- (security definer) de dam bao chi cong don, khong ai tu ghi de sai so.

create or replace function public.add_practice_seconds(delta integer)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.user_practice_time (user_id, seconds)
  values (auth.uid(), greatest(delta, 0))
  on conflict (user_id) do update
    set seconds = public.user_practice_time.seconds + greatest(delta, 0);
end;
$$;

grant execute on function public.add_practice_seconds(integer) to authenticated;

-- ============================================================
-- 5. Ham tong hop thong ke cho user hien tai
-- ============================================================
create or replace function public.my_stats_summary()
returns table (
  words_learned integer,
  songs_completed integer,
  avg_pronunciation_score integer,
  practice_seconds integer
)
language sql
stable
security definer set search_path = public
as $$
  select
    (select count(*)::integer from public.user_learned_words where user_id = auth.uid()),
    (select count(*)::integer from public.user_completed_songs where user_id = auth.uid()),
    (select coalesce(round(avg(score)), 0)::integer from public.user_pronunciation_attempts where user_id = auth.uid()),
    (select coalesce(seconds, 0) from public.user_practice_time where user_id = auth.uid());
$$;

grant execute on function public.my_stats_summary() to authenticated;

-- ============================================================
-- 6. Ham reset toan bo thong ke cua user hien tai ve 0
-- ============================================================
create or replace function public.reset_my_stats()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  delete from public.user_learned_words where user_id = auth.uid();
  delete from public.user_completed_songs where user_id = auth.uid();
  delete from public.user_pronunciation_attempts where user_id = auth.uid();
  update public.user_practice_time set seconds = 0 where user_id = auth.uid();
end;
$$;

grant execute on function public.reset_my_stats() to authenticated;
