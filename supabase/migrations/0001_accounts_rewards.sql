-- Accounts, diem thuong, va phan quyen theo diem.
-- Xem thiet ke day du trong docs/research-backend-accounts.md

-- ============================================================
-- 1. profiles — 1 dong / 1 user, tao tu dong khi user dang ky qua Supabase Auth
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text,
  avatar_url text,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- User tu xem duoc ho so cua chinh minh; admin xem duoc tat ca.
create policy "profiles_select_own_or_admin"
  on public.profiles for select
  using (
    auth.uid() = id
    or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
  );

-- Chi cho user tu sua display_name/avatar cua chinh minh, KHONG duoc tu sua role.
create policy "profiles_update_own_limited"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Tu tao profile khi dang ky lan dau (trigger ben duoi se lam viec nay,
-- nhung van can policy insert cho truong hop goi truc tiep).
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Trigger: tu tao 1 dong profiles moi khi co user moi dang ky qua Supabase Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- 2. point_transactions — so giao dich diem thuong (khong cho sua/xoa,
--    chi duoc them dong moi — giu lich su minh bach)
-- ============================================================
create table if not exists public.point_transactions (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount integer not null,
  reason text,
  granted_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

alter table public.point_transactions enable row level security;

-- User xem duoc giao dich cua chinh minh; admin xem duoc tat ca.
create policy "point_tx_select_own_or_admin"
  on public.point_transactions for select
  using (
    auth.uid() = user_id
    or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
  );

-- CHI admin duoc insert (cap diem). Khong co policy update/delete -> khong ai sua/xoa duoc,
-- kem ca admin, dam bao lich su diem khong bi chinh sua nguoc.
create policy "point_tx_insert_admin_only"
  on public.point_transactions for insert
  with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
  );

-- ============================================================
-- 3. Ham tinh tong diem hien co cua 1 user
-- ============================================================
create or replace function public.user_points_balance(target_user_id uuid)
returns integer
language sql
stable
security definer set search_path = public
as $$
  select coalesce(sum(amount), 0)::integer
  from public.point_transactions
  where user_id = target_user_id;
$$;

-- ============================================================
-- 4. tiers — nguong diem mo khoa tinh nang
-- ============================================================
create table if not exists public.tiers (
  name text primary key,
  min_points integer not null,
  unlocked_features jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0
);

alter table public.tiers enable row level security;

-- Ai cung doc duoc danh sach tier (can hien thi trong app cho user thuong).
create policy "tiers_select_all"
  on public.tiers for select
  using (true);

-- Chi admin sua duoc cau hinh tier.
create policy "tiers_write_admin_only"
  on public.tiers for all
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

insert into public.tiers (name, min_points, unlocked_features, sort_order) values
  ('Bronze', 0,   '["home", "player", "grammar", "quiz_basic"]'::jsonb, 0),
  ('Silver', 100, '["quiz_advanced"]'::jsonb, 1),
  ('Gold',   500, '["ai_voice_chat"]'::jsonb, 2)
on conflict (name) do nothing;

-- Ham tra ve ten tier hien tai cua 1 user, dua tren tong diem
create or replace function public.user_tier(target_user_id uuid)
returns text
language sql
stable
security definer set search_path = public
as $$
  select t.name
  from public.tiers t
  where t.min_points <= public.user_points_balance(target_user_id)
  order by t.min_points desc
  limit 1;
$$;
