-- Bua an da log CUA TUNG USER (Fitness Phase 3: Dinh duong - port tu
-- FitViet). Danh sach mon an co san (FoodPreset) la noi dung TINH dong goi
-- san trong app, KHONG luu o day - chi bua an nguoi dung THAT SU chon/log
-- theo tung ngay moi can luu, theo dung khuon RLS phang (auth.uid() =
-- user_id) nhu moi bang khac trong du an.
create table if not exists public.fitness_meals (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  slot text not null,
  name text not null,
  kcal integer not null,
  protein_g numeric not null,
  carb_g numeric not null,
  fat_g numeric not null,
  logged_date date not null default current_date,
  created_at timestamptz not null default now()
);

alter table public.fitness_meals enable row level security;

drop policy if exists "fitness_meals_select_own" on public.fitness_meals;
create policy "fitness_meals_select_own"
  on public.fitness_meals for select
  using (auth.uid() = user_id);

drop policy if exists "fitness_meals_insert_own" on public.fitness_meals;
create policy "fitness_meals_insert_own"
  on public.fitness_meals for insert
  with check (auth.uid() = user_id);

drop policy if exists "fitness_meals_delete_own" on public.fitness_meals;
create policy "fitness_meals_delete_own"
  on public.fitness_meals for delete
  using (auth.uid() = user_id);

create index if not exists fitness_meals_user_date_idx on public.fitness_meals (user_id, logged_date);
