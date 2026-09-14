-- Dong bo tinh nang "Lap ke hoach" (app/lib/features/planner/) len server -
-- truoc day chi luu SharedPreferences tren may nen mat khi doi may, va tren
-- web iPhone Safari co the xoa storage sau 7 ngay khong mo trang
-- (docs/research-planner-app-ux.md §7.6).
--
-- Moi viec 1 dong; `data` = nguyen JSON cua PlannerTask phia app (giu dung
-- schema cuc bo, them truong moi sau nay KHONG can migration). `id` la id do
-- app tu sinh (chuoi microsecondsSinceEpoch) nen khoa chinh ghep voi user_id.
--
-- Xoa = danh dau `deleted = true` (khong xoa dong) de may khac cua cung user
-- biet ma xoa theo khi dong bo. Gop du lieu phia app theo `updated_at` (ban
-- sua sau cung thang).
create table if not exists public.planner_tasks (
  user_id uuid not null references public.profiles (id) on delete cascade,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  primary key (user_id, id)
);

create index if not exists planner_tasks_user_updated_idx
  on public.planner_tasks (user_id, updated_at desc);

alter table public.planner_tasks enable row level security;

drop policy if exists "planner_tasks_select_own" on public.planner_tasks;
create policy "planner_tasks_select_own"
  on public.planner_tasks for select
  using (auth.uid() = user_id);

drop policy if exists "planner_tasks_insert_own" on public.planner_tasks;
create policy "planner_tasks_insert_own"
  on public.planner_tasks for insert
  with check (auth.uid() = user_id);

drop policy if exists "planner_tasks_update_own" on public.planner_tasks;
create policy "planner_tasks_update_own"
  on public.planner_tasks for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "planner_tasks_delete_own" on public.planner_tasks;
create policy "planner_tasks_delete_own"
  on public.planner_tasks for delete
  using (auth.uid() = user_id);
