-- Bang xep hang do vui hien dang la DU LIEU GIA cung cung trong code Flutter
-- (leaderboard_screen.dart: danh sach ten + XP co dinh, khong lien quan gi
-- toi nguoi dung that). Migration nay them 1 he thong XP do vui THAT, tach
-- rieng voi he thong "point_transactions" (chi admin cap - xem 0001), vi XP
-- do vui la nguoi dung tu kiem duoc khi hoan thanh thu thach.

-- ============================================================
-- 1. user_quiz_xp — tong XP do vui cua 1 user
-- ============================================================
create table if not exists public.user_quiz_xp (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  total_xp integer not null default 0
);

alter table public.user_quiz_xp enable row level security;

drop policy if exists "quiz_xp_select_own" on public.user_quiz_xp;
create policy "quiz_xp_select_own"
  on public.user_quiz_xp for select
  using (auth.uid() = user_id);

-- Khong co policy insert/update truc tiep - chi ghi qua add_quiz_xp
-- (security definer) de gioi han so XP moi lan cong, tranh gian lan.

-- ============================================================
-- 2. add_quiz_xp(amount): cong XP sau khi hoan thanh 1 luot do vui.
--    Gioi han amount trong [0, 150] - toi da hien co 10 cau x 15 XP/cau
--    (xem kRiddles trong quiz_data.dart) - phong truong hop client gui gia
--    tri gia mao lon bat thuong.
-- ============================================================
create or replace function public.add_quiz_xp(amount integer)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  clamped integer := greatest(0, least(amount, 150));
begin
  insert into public.user_quiz_xp (user_id, total_xp)
  values (auth.uid(), clamped)
  on conflict (user_id) do update
    set total_xp = public.user_quiz_xp.total_xp + clamped;
end;
$$;

grant execute on function public.add_quiz_xp(integer) to authenticated;

-- ============================================================
-- 3. quiz_leaderboard(top_n): top N user theo tong XP, kem co ban than
--    nguoi goi co nam trong top hay khong. Chay security definer de doc
--    duoc display_name/username cua NGUOI KHAC (RLS cua profiles chi cho
--    tu xem chinh minh) ma khong can noi long RLS cua profiles.
-- ============================================================
create or replace function public.quiz_leaderboard(top_n integer default 20)
returns table (rank integer, display_name text, xp integer, is_me boolean)
language sql
stable
security definer set search_path = public
as $$
  select
    row_number() over (order by q.total_xp desc, q.user_id asc)::integer as rank,
    coalesce(p.display_name, p.username, split_part(p.email, '@', 1)) as display_name,
    q.total_xp as xp,
    q.user_id = auth.uid() as is_me
  from public.user_quiz_xp q
  join public.profiles p on p.id = q.user_id
  where q.total_xp > 0
  order by q.total_xp desc, q.user_id asc
  limit greatest(top_n, 1);
$$;

grant execute on function public.quiz_leaderboard(integer) to authenticated;

-- ============================================================
-- 4. my_quiz_rank(): hang that + XP that cua nguoi dung hien tai, du ho co
--    nam trong top hay khong (dung cho the "hang cua ban" o cuoi man hinh).
-- ============================================================
create or replace function public.my_quiz_rank()
returns table (rank integer, xp integer)
language sql
stable
security definer set search_path = public
as $$
  select
    (
      select count(*)::integer + 1 from public.user_quiz_xp
      where total_xp > coalesce(
        (select total_xp from public.user_quiz_xp where user_id = auth.uid()),
        0
      )
    ) as rank,
    coalesce(
      (select total_xp from public.user_quiz_xp where user_id = auth.uid()),
      0
    ) as xp;
$$;

grant execute on function public.my_quiz_rank() to authenticated;

-- ============================================================
-- 5. reset_my_stats(): xoa luon XP do vui khi nguoi dung tu reset thong ke.
-- ============================================================
create or replace function public.reset_my_stats()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  delete from public.user_learned_words where user_id = auth.uid();
  delete from public.user_completed_songs where user_id = auth.uid();
  delete from public.user_pronunciation_attempts where user_id = auth.uid();
  delete from public.user_daily_activity where user_id = auth.uid();
  delete from public.user_quiz_xp where user_id = auth.uid();
  update public.user_practice_time set seconds = 0 where user_id = auth.uid();
end;
$$;
