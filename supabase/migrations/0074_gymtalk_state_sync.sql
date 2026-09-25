-- GymTalk: dong bo bo the on tap (SRS) va so lieu 3 vong Tap/Hoc/Noi theo
-- TAI KHOAN (truoc day chi luu SharedPreferences tren 1 may - doi may/doi
-- tai khoan la mat chuoi ngay). 1 dong/user, 2 cot jsonb:
--   srs   : [{key, en, vi, ipa, exEn, exVi, box, due}, ...]
--   daily : {"YYYY-MM-DD": {"w": buoi tap, "l": luot on tu, "s": luot noi,
--            "r": ngay nghi}, ...}  (giu ~60 ngay)
-- May khach tu gop (merge) truoc khi ghi - xem gymtalk_sync_service.dart.
create table if not exists public.user_gymtalk_state (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  srs jsonb not null default '[]'::jsonb,
  daily jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_gymtalk_state enable row level security;

drop policy if exists "user_gymtalk_state_select_own" on public.user_gymtalk_state;
create policy "user_gymtalk_state_select_own"
  on public.user_gymtalk_state for select
  using (auth.uid() = user_id);

drop policy if exists "user_gymtalk_state_insert_own" on public.user_gymtalk_state;
create policy "user_gymtalk_state_insert_own"
  on public.user_gymtalk_state for insert
  with check (auth.uid() = user_id);

drop policy if exists "user_gymtalk_state_update_own" on public.user_gymtalk_state;
create policy "user_gymtalk_state_update_own"
  on public.user_gymtalk_state for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Thu thach tuan "Body + Brain" voi ban be: so ngay dat trong 7 ngay gan
-- nhat (tinh ca hom nay) cua chinh minh + moi ban be da chap nhan. 1 ngay
-- dat = on >= 10 tu VA (tap >= 1 buoi HOAC ngay nghi theo giao an) - cung
-- luat voi DayProgress.bodyBrainDone o may khach. security definer de doc
-- duoc dong cua ban be (RLS chi cho doc dong cua minh).
create or replace function public.friends_body_brain_week()
returns table (
  rank integer,
  user_id uuid,
  display_name text,
  avatar_url text,
  days_done integer,
  is_me boolean
)
language sql
stable
security definer set search_path = public
as $$
  with people as (
    select auth.uid() as id
    union
    select case when f.requester_id = auth.uid() then f.addressee_id
                else f.requester_id end
    from public.friendships f
    where f.status = 'accepted'
      and auth.uid() in (f.requester_id, f.addressee_id)
  ),
  days as (
    select to_char((now() at time zone 'Asia/Ho_Chi_Minh')::date - g, 'YYYY-MM-DD') as day_key
    from generate_series(0, 6) as g
  ),
  scores as (
    select
      p.id,
      count(*) filter (
        where coalesce((s.daily -> d.day_key ->> 'l')::int, 0) >= 10
          and (
            coalesce((s.daily -> d.day_key ->> 'w')::int, 0) >= 1
            or coalesce((s.daily -> d.day_key ->> 'r')::boolean, false)
          )
      )::integer as days_done
    from people p
    cross join days d
    left join public.user_gymtalk_state s on s.user_id = p.id
    group by p.id
  )
  select
    row_number() over (order by sc.days_done desc, pr.display_name asc nulls last)::integer,
    sc.id,
    coalesce(pr.display_name, pr.username, split_part(pr.email, '@', 1)),
    pr.avatar_url,
    sc.days_done,
    sc.id = auth.uid()
  from scores sc
  join public.profiles pr on pr.id = sc.id
  where auth.uid() is not null
  order by 1;
$$;

-- create function mac dinh cap EXECUTE cho PUBLIC (ca anon) - ham nay la
-- security definer doc du lieu ban be nen CHI cho user da dang nhap.
revoke all on function public.friends_body_brain_week() from public, anon;
grant execute on function public.friends_body_brain_week() to authenticated;
