-- Fix: "infinite recursion detected in policy for relation profiles" (42P17).
--
-- Nguyen nhan: policy "profiles_select_own_or_admin" (va cac policy khac o
-- migration 0001) kiem tra quyen admin bang cach SELECT truc tiep tu chinh
-- bang public.profiles. Cau SELECT do lai bi RLS cua chinh profiles chan lai
-- -> Postgres phai ap dung lai policy profiles_select_own_or_admin -> lai
-- SELECT tu profiles -> lap vo han.
--
-- Cach sua chuan: dua phan kiem tra "co phai admin khong" ra 1 ham
-- SECURITY DEFINER rieng. Ham nay chay voi quyen cua nguoi tao (khong bi RLS
-- chan khi doc profiles), nen khong con de quy policy nua.

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

grant execute on function public.is_admin() to authenticated;

-- profiles: thay subquery de quy bang goi ham is_admin().
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
  on public.profiles for select
  using (
    auth.uid() = id
    or public.is_admin()
  );

-- point_transactions: cung dang SELECT truc tiep tu profiles trong policy,
-- doi sang is_admin() de nhat quan va tranh phai cham lai profiles.
drop policy if exists "point_tx_select_own_or_admin" on public.point_transactions;
create policy "point_tx_select_own_or_admin"
  on public.point_transactions for select
  using (
    auth.uid() = user_id
    or public.is_admin()
  );

drop policy if exists "point_tx_insert_admin_only" on public.point_transactions;
create policy "point_tx_insert_admin_only"
  on public.point_transactions for insert
  with check (public.is_admin());

-- tiers: tuong tu.
drop policy if exists "tiers_write_admin_only" on public.tiers;
create policy "tiers_write_admin_only"
  on public.tiers for all
  using (public.is_admin())
  with check (public.is_admin());
