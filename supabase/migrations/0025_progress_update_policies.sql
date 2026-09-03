-- Fix: user_completed_songs va user_favorite_songs thieu policy UPDATE.
--
-- Client goi .upsert() cho ca 2 bang nay (stats_repository.dart,
-- favorites_repository.dart) = INSERT ... ON CONFLICT DO UPDATE. Postgres RLS
-- doi hoi policy UPDATE rieng cho nhanh DO UPDATE do, kem ca policy INSERT
-- (cho nhanh INSERT ban dau). Thieu policy UPDATE khong lam vo du lieu hien
-- tai (dong da ton tai tu truoc), nhung MOI upsert vao 1 dong DA CO SAN (vd
-- nghe lai 1 bai da nghe, hoac them lai 1 bai da yeu thich) se bi RLS chan -
-- va loi do dang bi .catchError((_) {}) nuot lang le o player_screen.dart,
-- nen khong ai thay trieu chung tren UI.
--
-- Xem docs/architecture-multimedia-platform.md §A.3 (Lo tiem an #1) - phat
-- hien co san, khong do thay doi nao trong PR nay gay ra. Phai sua truoc khi
-- them bang tien do moi (0026_lesson_progress.sql) vi cung mau upsert se lap
-- lai loi nay tren bang moi neu khong ghi nho bai hoc nay.

drop policy if exists "completed_songs_update_own" on public.user_completed_songs;
create policy "completed_songs_update_own"
  on public.user_completed_songs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "favorite_songs_update_own" on public.user_favorite_songs;
create policy "favorite_songs_update_own"
  on public.user_favorite_songs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
