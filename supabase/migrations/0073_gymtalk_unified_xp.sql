-- GymTalk: GOP cac nguon XP thanh 1 cap do chung ("GymTalk XP") - tang len
-- tu CA tap luyen lan hoc tieng Anh, thay vi 2 he XP roi rac (XP hoc tu
-- 0064_learning_xp.sql va XP Quiz tu 0008_quiz_leaderboard.sql).
--
-- Chi dinh nghia lai learning_xp_from_activity (my_learning_xp /
-- add_learning_xp goi ham nay nen tu nhan cong thuc moi). Bang xep hang Quiz
-- (quiz_leaderboard, user_quiz_xp) giu nguyen de van so tai rieng o Quiz.
--
-- Cong thuc:
--   + 10 / tu da hoc, 25 / bai hat hoan thanh, 1 / phut luyen tap
--     tieng Anh, 2 / lan phat am >= 60 diem       (giu nguyen tu 0064)
--   + 25 / buoi tap gym DA HOAN THANH (workout_sessions.completed_at). Thoi
--     gian o tab Tap DA duoc tinh 1 XP/phut qua user_practice_time (nguon
--     'fitness' cung cong vao tong nay - xem 0031) nen muc thuong buoi tap
--     de vua phai, tranh tinh 2 lan.
--   + XP Quiz / 5 (user_quiz_xp.total_xp toi 150/luot, so voi 10/tu va
--     500/cap - chia 5 de nguoi choi Quiz nhieu khong nhay vot nhieu cap
--     ngay khi trien khai).
create or replace function public.learning_xp_from_activity(p_user uuid)
returns integer
language sql
stable
security definer set search_path = public
as $$
  select (
    (select count(*) from public.user_learned_words where user_id = p_user) * 10
  + (select count(*) from public.user_completed_songs where user_id = p_user) * 25
  -- coalesce BEN NGOAI subquery: user chua co dong nao thi subquery tra ve
  -- NULL va lam ca tong thanh NULL (loi tiem an cua ban 0064).
  + coalesce((select seconds from public.user_practice_time where user_id = p_user), 0) / 60
  + (select count(*) from public.user_pronunciation_attempts
       where user_id = p_user and score >= 60) * 2
  + (select count(*) from public.workout_sessions
       where user_id = p_user and completed_at is not null) * 25
  + coalesce((select total_xp from public.user_quiz_xp where user_id = p_user), 0) / 5
  )::integer;
$$;
