-- Them avatar_url vao ket qua quiz_leaderboard() de hien anh dai dien tren
-- man Bang xep hang thay vi chi chu cai dau ten.
drop function if exists public.quiz_leaderboard(integer);

create function public.quiz_leaderboard(top_n integer default 20)
returns table (
  rank integer,
  display_name text,
  avatar_url text,
  xp integer,
  is_me boolean
)
language sql
stable
security definer set search_path = public
as $$
  select
    row_number() over (order by q.total_xp desc, q.user_id asc)::integer as rank,
    coalesce(p.display_name, p.username, split_part(p.email, '@', 1)) as display_name,
    p.avatar_url,
    q.total_xp as xp,
    q.user_id = auth.uid() as is_me
  from public.user_quiz_xp q
  join public.profiles p on p.id = q.user_id
  where q.total_xp > 0
  order by q.total_xp desc, q.user_id asc
  limit greatest(top_n, 1);
$$;

grant execute on function public.quiz_leaderboard(integer) to authenticated;
