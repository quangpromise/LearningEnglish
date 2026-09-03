-- Loi THAT SU khien avatar/ten nguoi dung KHONG BAO GIO tai duoc (ke ca
-- restart app, ke ca du lieu trong bang profiles hoan toan dung): policy
-- "profiles_select_own_or_admin" tu truoc toi nay co dang:
--   (auth.uid() = id) OR (EXISTS (SELECT 1 FROM public.profiles p WHERE
--     p.id = auth.uid() AND p.role = 'admin'))
-- Subquery EXISTS truy van LAI CHINH BANG profiles dang duoc bao ve boi
-- CHINH policy nay - Postgres phat hien day la truy van RLS long nhau
-- KHONG DUNG (khong short-circuit truoc khi ap RLS cho subquery) va nem loi
-- "infinite recursion detected in policy for relation profiles" (42P17)
-- MOI LAN, cho MOI user, khong phai loi tam thoi/PGRST303 nhu nham tuong o
-- cac migration truoc.
--
-- Fix: chuyen phan kiem tra admin sang 1 ham SECURITY DEFINER rieng - ham
-- nay chay voi quyen cua chu so huu (postgres, co BYPASSRLS - da xac nhan
-- qua pg_roles), nen truy van profiles BEN TRONG ham KHONG bi ap lai chinh
-- policy nay nua, tranh duoc vong lap. Day la cach lam chuan cua Postgres
-- cho "policy tu tham chieu chinh bang no dang bao ve".
create or replace function public.is_current_user_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

grant execute on function public.is_current_user_admin() to authenticated;

drop policy if exists profiles_select_own_or_admin on public.profiles;
create policy profiles_select_own_or_admin on public.profiles
  for select
  using (auth.uid() = id or public.is_current_user_admin());
