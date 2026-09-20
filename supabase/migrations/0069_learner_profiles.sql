-- Ho so dau vao cho bo lap ke hoach hoc ca nhan. Ke hoach v1 duoc tinh tu
-- content da co trong app; du lieu nay cung la contract an toan cho AI planner
-- o giai doan sau.
create table if not exists public.user_learner_profiles (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  persona text not null,
  goal text not null,
  daily_minutes int not null check (daily_minutes in (10, 20, 30, 45)),
  priority_skills jsonb not null default '[]'::jsonb,
  interest_topics jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_learner_profiles enable row level security;

drop policy if exists "learner_profiles_select_own" on public.user_learner_profiles;
create policy "learner_profiles_select_own" on public.user_learner_profiles for select using (auth.uid() = user_id);
drop policy if exists "learner_profiles_insert_own" on public.user_learner_profiles;
create policy "learner_profiles_insert_own" on public.user_learner_profiles for insert with check (auth.uid() = user_id);
drop policy if exists "learner_profiles_update_own" on public.user_learner_profiles;
create policy "learner_profiles_update_own" on public.user_learner_profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant select, insert, update on public.user_learner_profiles to authenticated;
