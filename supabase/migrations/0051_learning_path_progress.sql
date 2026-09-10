-- Tien do tung buoc (stage) trong "Lo trinh hoc" theo persona - xem
-- docs/research-learning-path.md muc 5. Khac voi user_learning_path_choice
-- (0042, chi luu persona DANG chon, 1 dong/user): bang nay luu NHIEU dong,
-- moi dong la 1 buoc da duoc nguoi dung TU danh dau hoan thanh (khong tu
-- dong do tien do tu cac bang khac - xem ly do trong research doc muc 5).
-- persona_id la text (khop ten enum LearningPersona.name, vd 'beginner') -
-- khong dung foreign key toi bang nao vi danh sach persona dinh nghia trong
-- code (learning_path_models.dart), giong cach user_learning_path_choice.persona
-- da lam.
create table if not exists public.user_learning_path_progress (
  user_id uuid not null references public.profiles (id) on delete cascade,
  persona_id text not null,
  step_index int not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, persona_id, step_index)
);

alter table public.user_learning_path_progress enable row level security;

drop policy if exists "learning_path_progress_select_own" on public.user_learning_path_progress;
create policy "learning_path_progress_select_own"
  on public.user_learning_path_progress for select
  using (auth.uid() = user_id);

drop policy if exists "learning_path_progress_insert_own" on public.user_learning_path_progress;
create policy "learning_path_progress_insert_own"
  on public.user_learning_path_progress for insert
  with check (auth.uid() = user_id);

drop policy if exists "learning_path_progress_update_own" on public.user_learning_path_progress;
create policy "learning_path_progress_update_own"
  on public.user_learning_path_progress for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Chua co ai gap phai delete tien do tung buoc (bo danh dau hoan thanh) o
-- v1 - them policy delete cung tu day de tranh vet nut "Bo danh dau" bi
-- silent-fail giong bai hoc rut ra tu 0025_progress_update_policies.sql (loi
-- thieu policy UPDATE luc dau cho user_lesson_progress).
drop policy if exists "learning_path_progress_delete_own" on public.user_learning_path_progress;
create policy "learning_path_progress_delete_own"
  on public.user_learning_path_progress for delete
  using (auth.uid() = user_id);

-- RLS chi loc HANG, van can GRANT tuong minh o cap bang cho instance
-- Supabase local (khong co bootstrap grant ngam nhu Cloud) - xem giai thich
-- day du trong 0026_lesson_progress.sql.
grant select, insert, update, delete on public.user_learning_path_progress to authenticated;
