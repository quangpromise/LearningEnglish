-- Tien do cho noi dung KHONG phai bai hat (vd micro-story tu viet, xem
-- docs/architecture-multimedia-platform.md Phase 1). Bang MOI, khong ALTER
-- user_completed_songs - bang do khoa theo song_title (not null, mot nua
-- khoa chinh) nen khong the tai dung cho noi dung khac ten (§A.3, Loi tiem
-- an #2). lesson_id la slug on dinh tu code (xem story_data.dart), khong
-- phai tieu de hien thi.
--
-- Bao gom policy UPDATE ngay tu dau (khac voi user_completed_songs/
-- user_favorite_songs luc dau) - xem 0025_progress_update_policies.sql de
-- biet vi sao thieu policy nay lam .upsert() hong am tham.
create table if not exists public.user_lesson_progress (
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id text not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

alter table public.user_lesson_progress enable row level security;

drop policy if exists "lesson_progress_select_own" on public.user_lesson_progress;
create policy "lesson_progress_select_own"
  on public.user_lesson_progress for select
  using (auth.uid() = user_id);

drop policy if exists "lesson_progress_insert_own" on public.user_lesson_progress;
create policy "lesson_progress_insert_own"
  on public.user_lesson_progress for insert
  with check (auth.uid() = user_id);

drop policy if exists "lesson_progress_update_own" on public.user_lesson_progress;
create policy "lesson_progress_update_own"
  on public.user_lesson_progress for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- RLS chi loc HANG, khong tu cap quyen truy cap BANG - PostgreSQL van doi
-- GRANT o cap bang truoc khi RLS duoc xet toi. Cac bang cu (user_completed_
-- songs, user_favorite_songs) chay duoc du migration cua chung khong co
-- GRANT tuong tu, nhieu kha nang nho 1 lan cap quyen mac dinh cho schema
-- public tu luc tao du an tren Supabase Cloud (ALTER DEFAULT PRIVILEGES,
-- nam ngoai lich su migration) - phat hien khi kiem thu bang mot instance
-- Supabase local sach (`supabase start`), instance nay KHONG co buoc bootstrap
-- do nen bang MOI hoan toan nay bi tu choi truy cap thang voi loi "permission
-- denied". Ghi GRANT tuong minh o day de khong phu thuoc hanh vi ngam cua
-- Cloud - dung cho ca moi truong dev local lan production.
grant select, insert, update on public.user_lesson_progress to authenticated;
