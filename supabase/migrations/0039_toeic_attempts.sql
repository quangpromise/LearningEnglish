-- Lich su lam bai TOEIC (Luyen tap / Thi thu) - luu diem theo tung ky nang
-- (Nghe/Doc) + diem quy doi GAN DUNG (cong thuc xap xi tuyen tinh tu viet,
-- KHONG PHAI bang quy doi chinh thuc doc quyen cua ETS - xem
-- app/lib/features/toeic/data/toeic_scoring.dart). Bang MOI, khong tai su
-- dung user_lesson_progress (chi co boolean hoan thanh, khong co diem chi
-- tiet) - moi lan lam bai la 1 ban ghi rieng (khong upsert) nen chi can
-- policy select+insert, khong can update/delete.
create table if not exists public.toeic_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  test_id text not null,
  mode text not null check (mode in ('practice', 'exam')),
  listening_correct int not null default 0,
  listening_total int not null default 0,
  reading_correct int not null default 0,
  reading_total int not null default 0,
  scaled_listening int,
  scaled_reading int,
  scaled_total int,
  duration_seconds int,
  created_at timestamptz not null default now()
);

alter table public.toeic_attempts enable row level security;

drop policy if exists "toeic_attempts_select_own" on public.toeic_attempts;
create policy "toeic_attempts_select_own"
  on public.toeic_attempts for select
  using (auth.uid() = user_id);

drop policy if exists "toeic_attempts_insert_own" on public.toeic_attempts;
create policy "toeic_attempts_insert_own"
  on public.toeic_attempts for insert
  with check (auth.uid() = user_id);

-- RLS chi loc HANG, khong tu cap quyen truy cap BANG - xem giai thich chi
-- tiet trong 0026_lesson_progress.sql.
grant select, insert on public.toeic_attempts to authenticated;
