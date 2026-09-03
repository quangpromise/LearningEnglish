-- Tinh nang Quan ly tai san (Wealth Management), Phase 1: so giao dich
-- chi tieu/thu nhap + so nam giu co phieu quoc te thu cong. Danh muc
-- (category_code) la enum Dart tinh (xem wealth_category.dart), khong
-- luu bang rieng - giong cach MuscleGroup cua Fitness khong can bang DB.
create table if not exists public.wealth_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('expense', 'income')),
  category_code text not null,
  amount numeric not null check (amount > 0),
  currency text not null default 'VND',
  occurred_at timestamptz not null default now(),
  note text,
  -- Chi co gia tri khi type='income': 'active' (luong/freelance/kinh doanh)
  -- hoac 'passive' (cho thue nha/co tuc/lai tiet kiem...).
  income_kind text check (income_kind in ('active', 'passive')),
  created_at timestamptz not null default now()
);

alter table public.wealth_transactions enable row level security;

drop policy if exists "wealth_transactions_select_own" on public.wealth_transactions;
create policy "wealth_transactions_select_own"
  on public.wealth_transactions for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_transactions_insert_own" on public.wealth_transactions;
create policy "wealth_transactions_insert_own"
  on public.wealth_transactions for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_transactions_update_own" on public.wealth_transactions;
create policy "wealth_transactions_update_own"
  on public.wealth_transactions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_transactions_delete_own" on public.wealth_transactions;
create policy "wealth_transactions_delete_own"
  on public.wealth_transactions for delete
  using (auth.uid() = user_id);

-- So nam giu co phieu quoc te (thu cong - nguoi dung tu nhap so luong/gia
-- von, KHONG tu dong sync giao dich mua/ban that). Crypto portfolio van
-- giu nguyen o SharedPreferences hien co (crypto_portfolio_repository.dart),
-- khong gop vao bang nay o Phase 1.
create table if not exists public.wealth_holdings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  asset_type text not null default 'stock_intl' check (asset_type in ('stock_intl')),
  symbol text not null,
  quantity numeric not null check (quantity > 0),
  avg_cost numeric not null check (avg_cost >= 0),
  currency text not null default 'USD',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, symbol)
);

alter table public.wealth_holdings enable row level security;

drop policy if exists "wealth_holdings_select_own" on public.wealth_holdings;
create policy "wealth_holdings_select_own"
  on public.wealth_holdings for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_holdings_insert_own" on public.wealth_holdings;
create policy "wealth_holdings_insert_own"
  on public.wealth_holdings for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_holdings_update_own" on public.wealth_holdings;
create policy "wealth_holdings_update_own"
  on public.wealth_holdings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_holdings_delete_own" on public.wealth_holdings;
create policy "wealth_holdings_delete_own"
  on public.wealth_holdings for delete
  using (auth.uid() = user_id);
