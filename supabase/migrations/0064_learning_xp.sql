-- He thong Level/XP cho mini-app "Hoc Tieng Anh" (thiet ke lai man Home:
-- vong tron "Lv 8 - Con 420 XP nua" o the tien do).
--
-- NGUYEN TAC: KHONG dung so gia. XP duoc TINH TU DU LIEU HOAT DONG CO THAT
-- ma app da ghi nhan tu truoc (xem 0004_real_stats.sql):
--   user_learned_words         - tu da hoc
--   user_completed_songs       - bai hat nghe het
--   user_practice_time.seconds - thoi gian luyen tap
--   user_pronunciation_attempts- cac lan cham diem phat am
--
-- Nho tinh tu nguon co san nen:
--   1. Nguoi dung cu co XP dung voi cong suc da bo ra ngay lan mo app dau
--      tien sau cap nhat, khong ai bi ve 0.
--   2. Khong phai chen loi "cong XP" vao hang chuc cho trong app -> khong
--      co rui ro quen cong o 1 man nao do roi lech so.
--
-- Bang `learning_xp` chi giu phan XP THUONG THEM (bonus) - danh cho su kien,
-- moc thanh tich, qua tang... Tong XP = XP tinh tu hoat dong + bonus.

-- ============================================================
-- 1. Bang XP thuong them
-- ============================================================
create table if not exists public.learning_xp (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  bonus_xp integer not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.learning_xp enable row level security;

drop policy if exists "learning_xp_select_own" on public.learning_xp;
create policy "learning_xp_select_own"
  on public.learning_xp for select
  using (auth.uid() = user_id);

-- Khong co policy insert/update cho client: chi cong duoc qua ham
-- add_learning_xp() ben duoi (security definer). Client tu ghi thang vao
-- bang nay se bi RLS chan - tranh viec sua XP tu phia may nguoi dung.

-- ============================================================
-- 2. Cong thuc quy doi hoat dong -> XP
-- ============================================================
-- Moc cac he so o 1 cho duy nhat de sau nay can chinh chi sua tai day.
--   10 XP / tu da hoc
--   25 XP / bai hat nghe het
--    1 XP / phut luyen tap
--    2 XP / lan cham phat am dat tu 60 diem tro len
create or replace function public.learning_xp_from_activity(p_user uuid)
returns integer
language sql
stable
security definer set search_path = public
as $$
  select
    (select count(*) from public.user_learned_words where user_id = p_user) * 10
  + (select count(*) from public.user_completed_songs where user_id = p_user) * 25
  + (select coalesce(seconds, 0) from public.user_practice_time where user_id = p_user) / 60
  + (select count(*) from public.user_pronunciation_attempts
       where user_id = p_user and score >= 60) * 2;
$$;

-- ============================================================
-- 3. Tong XP + cap do cua user hien tai
-- ============================================================
-- Moi cap can 500 XP. Cap 1 bat dau tu 0 XP.
--   level      = xp / 500 + 1
--   xp_in_level= xp % 500          (da di duoc bao nhieu trong cap nay)
--   xp_to_next = 500 - xp_in_level (con bao nhieu XP nua len cap)
--
-- `level_key` tra ve KHOA, khong phai chu hien thi - phia app tu dich sang
-- tieng Viet/Anh qua app_strings.dart (xem khoa `level_*`), de khong phai
-- sua database khi them ngon ngu moi.
create or replace function public.my_learning_xp()
returns table (
  xp integer,
  level integer,
  xp_in_level integer,
  xp_to_next integer,
  level_key text
)
language sql
stable
security definer set search_path = public
as $$
  with total as (
    select (
      public.learning_xp_from_activity(auth.uid())
      + coalesce((select bonus_xp from public.learning_xp where user_id = auth.uid()), 0)
    )::integer as xp
  ), lv as (
    select xp, (xp / 500 + 1)::integer as level from total
  )
  select
    lv.xp,
    lv.level,
    (lv.xp % 500)::integer,
    (500 - lv.xp % 500)::integer,
    case
      when lv.level <= 2  then 'beginner'
      when lv.level <= 5  then 'elementary'
      when lv.level <= 9  then 'intermediate'
      when lv.level <= 14 then 'upper'
      else 'advanced'
    end
  from lv;
$$;

grant execute on function public.my_learning_xp() to authenticated;

-- ============================================================
-- 4. Cong XP thuong them
-- ============================================================
-- Chi cong duoc so DUONG va toi da 1000 XP moi lan - chan truong hop client
-- bi sua goi mot lan cong so lon. Tra ve tong XP moi.
create or replace function public.add_learning_xp(p_amount integer)
returns integer
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'Chua dang nhap';
  end if;
  if p_amount is null or p_amount <= 0 or p_amount > 1000 then
    raise exception 'So XP khong hop le';
  end if;

  insert into public.learning_xp (user_id, bonus_xp, updated_at)
  values (v_user, p_amount, now())
  on conflict (user_id) do update
    set bonus_xp = public.learning_xp.bonus_xp + excluded.bonus_xp,
        updated_at = now();

  return public.learning_xp_from_activity(v_user)
       + (select bonus_xp from public.learning_xp where user_id = v_user);
end;
$$;

grant execute on function public.add_learning_xp(integer) to authenticated;
