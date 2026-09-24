-- Cho phep user xoa set CUA CHINH MINH - dung cho nut "Hoan tac set vua
-- ghi" o man dang tap (xem WorkoutOutbox op 'unset' trong
-- app/lib/features/fitness/data/workout_outbox.dart). Truoc day bang chi co
-- policy select/insert nen set da gui len server khong the go lai.
drop policy if exists "workout_set_logs_delete_own" on public.workout_set_logs;
create policy "workout_set_logs_delete_own"
  on public.workout_set_logs for delete
  using (auth.uid() = user_id);
