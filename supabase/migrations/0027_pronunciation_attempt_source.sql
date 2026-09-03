-- Cot MOI, nullable, khong backfill - phan biet luot cham diem phat am tu
-- tab "Luyen phat am" voi luot shadowing long trong 1 bai hoc (vd
-- micro-story), xem docs/architecture-multimedia-platform.md §E.
alter table public.user_pronunciation_attempts
  add column if not exists source text;
