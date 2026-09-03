-- Tach "hoat dong tuan nay" theo tung nguon (english/fitness) - man Ho so
-- gio dung CHUNG cho ca 3 app (Hoc Tieng Anh/Fitness/Assets Management),
-- va khi mo tu Fitness chi hien bieu do hoat dong THEO FITNESS, khong tron
-- lan voi thoi gian nghe nhac/luyen phat am tieng Anh.
alter table public.user_daily_activity
  add column if not exists source text not null default 'english';

alter table public.user_daily_activity
  drop constraint if exists user_daily_activity_pkey;

alter table public.user_daily_activity
  add primary key (user_id, activity_date, source);

create or replace function public.add_practice_seconds(
  delta integer,
  p_source text default 'english'
)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  -- Tong chung (user_practice_time) van cong don TAT CA nguon - dung cho
  -- the "Thoi gian luyen tap" o man Ho so khi xem tu Hoc Tieng Anh, khong
  -- doi y nghia cu.
  insert into public.user_practice_time (user_id, seconds)
  values (auth.uid(), greatest(delta, 0))
  on conflict (user_id) do update
    set seconds = public.user_practice_time.seconds + greatest(delta, 0);

  insert into public.user_daily_activity (user_id, activity_date, source, seconds)
  values (auth.uid(), current_date, p_source, greatest(delta, 0))
  on conflict (user_id, activity_date, source) do update
    set seconds = public.user_daily_activity.seconds + greatest(delta, 0);
end;
$$;

grant execute on function public.add_practice_seconds(integer, text) to authenticated;

create or replace function public.my_weekly_activity(p_source text default 'english')
returns table (activity_date date, seconds integer)
language sql
stable
security definer set search_path = public
as $$
  select d::date as activity_date, coalesce(a.seconds, 0) as seconds
  from generate_series(current_date - 6, current_date, interval '1 day') d
  left join public.user_daily_activity a
    on a.user_id = auth.uid() and a.activity_date = d::date and a.source = p_source
  order by d;
$$;

grant execute on function public.my_weekly_activity(text) to authenticated;

-- my_streak_days/my_stats_summary van tinh tren TAT CA nguon (seconds > 0
-- bat ky nguon nao van tinh la "co hoat dong" cho streak chung) - khong doi.
