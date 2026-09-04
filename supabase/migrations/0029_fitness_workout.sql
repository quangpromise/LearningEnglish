-- Du lieu Tap luyen (Fitness Phase 2: Giao an + Tap luyen - port tu FitViet)
-- CUA TUNG USER - khac voi thu vien bai tap/chuong trinh (noi dung TINH dong
-- goi san trong app, khong luu o day). Theo dung khuon RLS phang
-- (auth.uid() = user_id) nhu 0028_favorite_exercises.sql va moi bang khac
-- trong du an.

-- Giao an dang theo cua tung user - 1 dong/user, active_program_id tro vao
-- id trong app/assets/fitness/programs_seed.json (khong phai FK vi noi dung
-- do khong nam trong DB).
create table if not exists public.user_fitness_settings (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  active_program_id integer null,
  updated_at timestamptz not null default now()
);

alter table public.user_fitness_settings enable row level security;

drop policy if exists "fitness_settings_select_own" on public.user_fitness_settings;
create policy "fitness_settings_select_own"
  on public.user_fitness_settings for select
  using (auth.uid() = user_id);

drop policy if exists "fitness_settings_upsert_own" on public.user_fitness_settings;
create policy "fitness_settings_upsert_own"
  on public.user_fitness_settings for insert
  with check (auth.uid() = user_id);

drop policy if exists "fitness_settings_update_own" on public.user_fitness_settings;
create policy "fitness_settings_update_own"
  on public.user_fitness_settings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 1 buoi tap - program_id (neu co) cung tro vao programs_seed.json, khong
-- phai FK. completed_at null nghia la buoi tap dang do dang/chua hoan tat.
create table if not exists public.workout_sessions (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  program_id integer null,
  started_at timestamptz not null default now(),
  completed_at timestamptz null,
  total_volume_kg numeric not null default 0,
  duration_seconds integer null
);

alter table public.workout_sessions enable row level security;

drop policy if exists "workout_sessions_select_own" on public.workout_sessions;
create policy "workout_sessions_select_own"
  on public.workout_sessions for select
  using (auth.uid() = user_id);

drop policy if exists "workout_sessions_insert_own" on public.workout_sessions;
create policy "workout_sessions_insert_own"
  on public.workout_sessions for insert
  with check (auth.uid() = user_id);

drop policy if exists "workout_sessions_update_own" on public.workout_sessions;
create policy "workout_sessions_update_own"
  on public.workout_sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Tung set da log trong 1 buoi tap - user_id duoc GHI LAP LAI o day (thay vi
-- chi dua vao session_id -> workout_sessions.user_id) de RLS dung dung 1
-- kieu policy phang nhu moi bang khac trong du an, khong can subquery.
create table if not exists public.workout_set_logs (
  id bigint generated always as identity primary key,
  session_id bigint not null references public.workout_sessions (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  exercise_id integer not null,
  set_index integer not null,
  weight_kg numeric not null,
  reps integer not null,
  created_at timestamptz not null default now()
);

alter table public.workout_set_logs enable row level security;

drop policy if exists "workout_set_logs_select_own" on public.workout_set_logs;
create policy "workout_set_logs_select_own"
  on public.workout_set_logs for select
  using (auth.uid() = user_id);

drop policy if exists "workout_set_logs_insert_own" on public.workout_set_logs;
create policy "workout_set_logs_insert_own"
  on public.workout_set_logs for insert
  with check (auth.uid() = user_id);

create index if not exists workout_set_logs_session_idx on public.workout_set_logs (session_id);
create index if not exists workout_set_logs_user_exercise_idx on public.workout_set_logs (user_id, exercise_id);
create index if not exists workout_sessions_user_idx on public.workout_sessions (user_id);
