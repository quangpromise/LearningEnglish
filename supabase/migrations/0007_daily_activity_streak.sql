-- Thong ke "hoat dong tuan nay" va "so ngay lien tiep" (streak) o man hinh Ho
-- so hien dang la SO LIEU GIA cung cung trong code Flutter (xem
-- profile_screen.dart: "12 ngay lien tiep" va cac thanh _Bar co gia tri
-- co dinh). Migration nay them 1 bang ghi lai so giay luyen tap THEO TUNG
-- NGAY, dua tren do tinh duoc ca 2 con so that.

-- ============================================================
-- 1. user_daily_activity — moi dong la tong so giay luyen tap cua 1 user
--    trong 1 ngay cu the (theo mui gio server, UTC).
-- ============================================================
create table if not exists public.user_daily_activity (
  user_id uuid not null references public.profiles (id) on delete cascade,
  activity_date date not null,
  seconds integer not null default 0,
  primary key (user_id, activity_date)
);

alter table public.user_daily_activity enable row level security;

drop policy if exists "daily_activity_select_own" on public.user_daily_activity;
create policy "daily_activity_select_own"
  on public.user_daily_activity for select
  using (auth.uid() = user_id);

-- Khong co policy insert/update truc tiep - chi ghi qua add_practice_seconds
-- (security definer) o duoi, giong nguyen tac cua user_practice_time.

-- ============================================================
-- 2. add_practice_seconds: ghi them vao ca tong (user_practice_time) LAN
--    vao ngay hom nay (user_daily_activity), thay vi chi ghi tong nhu truoc.
-- ============================================================
create or replace function public.add_practice_seconds(delta integer)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.user_practice_time (user_id, seconds)
  values (auth.uid(), greatest(delta, 0))
  on conflict (user_id) do update
    set seconds = public.user_practice_time.seconds + greatest(delta, 0);

  insert into public.user_daily_activity (user_id, activity_date, seconds)
  values (auth.uid(), current_date, greatest(delta, 0))
  on conflict (user_id, activity_date) do update
    set seconds = public.user_daily_activity.seconds + greatest(delta, 0);
end;
$$;

-- ============================================================
-- 3. my_weekly_activity(): so giay luyen tap cua 7 ngay gan nhat (tinh ca
--    hom nay), ke ca ngay khong luyen tap (tra ve 0), sap xep tu cu den moi.
-- ============================================================
create or replace function public.my_weekly_activity()
returns table (activity_date date, seconds integer)
language sql
stable
security definer set search_path = public
as $$
  select d::date as activity_date, coalesce(a.seconds, 0) as seconds
  from generate_series(current_date - 6, current_date, interval '1 day') d
  left join public.user_daily_activity a
    on a.user_id = auth.uid() and a.activity_date = d::date
  order by d;
$$;

grant execute on function public.my_weekly_activity() to authenticated;

-- ============================================================
-- 4. my_streak_days(): so ngay lien tiep co luyen tap (seconds > 0), tinh
--    lien tuc tu hom nay (hoac hom qua, neu hom nay chua luyen tap gi) lui
--    ve truoc. Dung ky thuat "gaps and islands" (date - row_number = hang
--    so cho 1 day ngay lien tiep) de gom nhom ngay lien tiep.
-- ============================================================
create or replace function public.my_streak_days()
returns integer
language sql
stable
security definer set search_path = public
as $$
  with active_days as (
    select activity_date
    from public.user_daily_activity
    where user_id = auth.uid() and seconds > 0
  ),
  grouped as (
    select
      activity_date,
      activity_date - (row_number() over (order by activity_date))::integer as island
    from active_days
  ),
  islands as (
    select island, count(*)::integer as len, max(activity_date) as last_day
    from grouped
    group by island
  )
  select coalesce(
    (
      select len from islands
      where last_day = current_date or last_day = current_date - 1
      order by last_day desc
      limit 1
    ),
    0
  );
$$;

grant execute on function public.my_streak_days() to authenticated;

-- ============================================================
-- 5. my_stats_summary(): them streak_days vao ket qua tong hop co san.
--    Phai DROP truoc vi Postgres khong cho doi kieu tra ve (them cot OUT
--    moi) bang create or replace - se bao loi 42P13.
-- ============================================================
drop function if exists public.my_stats_summary();

create function public.my_stats_summary()
returns table (
  words_learned integer,
  songs_completed integer,
  avg_pronunciation_score integer,
  practice_seconds integer,
  streak_days integer
)
language sql
stable
security definer set search_path = public
as $$
  select
    (select count(*)::integer from public.user_learned_words where user_id = auth.uid()),
    (select count(*)::integer from public.user_completed_songs where user_id = auth.uid()),
    (select coalesce(round(avg(score)), 0)::integer from public.user_pronunciation_attempts where user_id = auth.uid()),
    (select coalesce(seconds, 0) from public.user_practice_time where user_id = auth.uid()),
    public.my_streak_days();
$$;

grant execute on function public.my_stats_summary() to authenticated;

-- ============================================================
-- 6. reset_my_stats(): xoa luon lich su hoat dong theo ngay khi reset.
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
  update public.user_practice_time set seconds = 0 where user_id = auth.uid();
end;
$$;
