-- Dong bo tinh nang "To do list" (app/lib/features/todo/) len server - giong
-- het ly do cua planner_tasks (0063): chi luu SharedPreferences thi mat khi
-- doi may, va tren web iPhone Safari co the xoa storage sau 7 ngay khong mo
-- trang (docs/research-planner-app-ux.md §7.6).
--
-- BANG RIENG, khong dung chung planner_tasks: To do list la tinh nang doc
-- lap, schema khac han (khong co lap lai/nhac nho/appSection) - gop chung se
-- lam ca 2 ben phai hieu JSON cua nhau.
--
-- Moi viec 1 dong; `data` = nguyen JSON cua TodoTask phia app nen them truong
-- moi sau nay KHONG can migration. `id` do app tu sinh
-- (microsecondsSinceEpoch) nen khoa chinh ghep voi user_id.
--
-- Xoa = danh dau `deleted = true` (khong xoa dong) de may khac cua cung user
-- biet ma xoa theo. Gop du lieu theo `updated_at` - ban sua sau cung thang.
create table if not exists public.todo_tasks (
  user_id uuid not null references public.profiles (id) on delete cascade,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  primary key (user_id, id)
);

create index if not exists todo_tasks_user_updated_idx
  on public.todo_tasks (user_id, updated_at desc);

alter table public.todo_tasks enable row level security;

drop policy if exists "todo_tasks_select_own" on public.todo_tasks;
create policy "todo_tasks_select_own"
  on public.todo_tasks for select
  using (auth.uid() = user_id);

drop policy if exists "todo_tasks_insert_own" on public.todo_tasks;
create policy "todo_tasks_insert_own"
  on public.todo_tasks for insert
  with check (auth.uid() = user_id);

drop policy if exists "todo_tasks_update_own" on public.todo_tasks;
create policy "todo_tasks_update_own"
  on public.todo_tasks for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "todo_tasks_delete_own" on public.todo_tasks;
create policy "todo_tasks_delete_own"
  on public.todo_tasks for delete
  using (auth.uid() = user_id);
