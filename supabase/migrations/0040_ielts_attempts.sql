-- Lich su lam bai IELTS (Luyen tap / Thi thu) - Phase 1 CHI co Reading +
-- Listening (Writing/Speaking se dung Gemini AI cham diem, lam o phase sau -
-- xem app/lib/features/ielts/data/ielts_scoring.dart). Band diem GAN DUNG
-- (bang buoc xap xi tu viet, KHONG PHAI bang quy doi chinh thuc cua
-- IELTS/British Council/IDP/Cambridge). Bang MOI, khong tai su dung
-- toeic_attempts (khac cot diem: band numeric 0-9 buoc 0.5 thay vi diem
-- scaled int 5-495) - moi lan lam bai la 1 ban ghi rieng (khong upsert) nen
-- chi can policy select+insert.
create table if not exists public.ielts_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  test_id text not null,
  mode text not null check (mode in ('practice', 'exam')),
  listening_correct int not null default 0,
  listening_total int not null default 0,
  reading_correct int not null default 0,
  reading_total int not null default 0,
  band_listening numeric(2, 1),
  band_reading numeric(2, 1),
  band_overall numeric(2, 1),
  duration_seconds int,
  created_at timestamptz not null default now()
);

alter table public.ielts_attempts enable row level security;

drop policy if exists "ielts_attempts_select_own" on public.ielts_attempts;
create policy "ielts_attempts_select_own"
  on public.ielts_attempts for select
  using (auth.uid() = user_id);

drop policy if exists "ielts_attempts_insert_own" on public.ielts_attempts;
create policy "ielts_attempts_insert_own"
  on public.ielts_attempts for insert
  with check (auth.uid() = user_id);

-- RLS chi loc HANG, khong tu cap quyen truy cap BANG - xem giai thich chi
-- tiet trong 0026_lesson_progress.sql.
grant select, insert on public.ielts_attempts to authenticated;
