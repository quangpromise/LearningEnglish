-- Luu persona nguoi dung chon o khao sat "Goi y lo trinh hoc" tren Home
-- (xem docs/research-learning-path.md) - CHI 1 dong/user (khong phai lich
-- su, persona thay doi thi ghi de qua upsert onConflict user_id) - mirror
-- cau truc RLS cua 0026_lesson_progress.sql.
create table if not exists public.user_learning_path_choice (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  persona text not null,
  chosen_at timestamptz not null default now()
);

alter table public.user_learning_path_choice enable row level security;

drop policy if exists "learning_path_choice_select_own" on public.user_learning_path_choice;
create policy "learning_path_choice_select_own"
  on public.user_learning_path_choice for select
  using (auth.uid() = user_id);

drop policy if exists "learning_path_choice_insert_own" on public.user_learning_path_choice;
create policy "learning_path_choice_insert_own"
  on public.user_learning_path_choice for insert
  with check (auth.uid() = user_id);

drop policy if exists "learning_path_choice_update_own" on public.user_learning_path_choice;
create policy "learning_path_choice_update_own"
  on public.user_learning_path_choice for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- RLS chi loc HANG, van can GRANT tuong minh o cap bang cho instance
-- Supabase local (khong co bootstrap grant ngam nhu Cloud) - xem giai thich
-- day du trong 0026_lesson_progress.sql.
grant select, insert, update on public.user_learning_path_choice to authenticated;
