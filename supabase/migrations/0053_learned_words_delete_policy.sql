-- Bo sung policy DELETE con thieu cho user_learned_words (migration
-- 0004_real_stats.sql chi tao select/insert) - can de tinh nang "Bo danh
-- dau da hoc" o popup Words Learned (xem learned_words_popup.dart) xoa duoc
-- dung dong: thieu policy nay, lenh delete van tra ve THANH CONG (HTTP 200)
-- nhung xoa 0 dong do RLS chan am tham, khien nguoi dung bam "Delete" ma
-- tu khong bien mat khoi danh sach.
drop policy if exists "learned_words_delete_own" on public.user_learned_words;
create policy "learned_words_delete_own"
  on public.user_learned_words for delete
  using (auth.uid() = user_id);
