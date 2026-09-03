-- Danh sach bai tap yeu thich cua tung user (tinh nang Fitness, Phase 1:
-- Thu vien bai tap - port tu FitViet). Giong het pattern cua
-- user_favorite_songs (0010_favorite_songs.sql): danh sach bai tap la du
-- lieu TINH dong goi san trong app (assets/fitness/exercises_seed.json),
-- khong luu trong DB - chi luu ID bai tap lam dinh danh.
create table if not exists public.user_favorite_exercises (
  user_id uuid not null references public.profiles (id) on delete cascade,
  exercise_id integer not null,
  created_at timestamptz not null default now(),
  primary key (user_id, exercise_id)
);

alter table public.user_favorite_exercises enable row level security;

drop policy if exists "favorite_exercises_select_own" on public.user_favorite_exercises;
create policy "favorite_exercises_select_own"
  on public.user_favorite_exercises for select
  using (auth.uid() = user_id);

drop policy if exists "favorite_exercises_insert_own" on public.user_favorite_exercises;
create policy "favorite_exercises_insert_own"
  on public.user_favorite_exercises for insert
  with check (auth.uid() = user_id);

drop policy if exists "favorite_exercises_delete_own" on public.user_favorite_exercises;
create policy "favorite_exercises_delete_own"
  on public.user_favorite_exercises for delete
  using (auth.uid() = user_id);
