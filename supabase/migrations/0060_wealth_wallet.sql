-- Quan ly tai san Phase 2: Vi (so du Tien mat/Ngan hang theo tung ngan
-- hang), Chi tieu tu dong tru vao Vi, No (minh no nguoi khac / nguoi khac
-- no minh) tu dong tru/cong vao Vi khi tra no, va Portfolio da dang hoa
-- (Crypto chuyen tu SharedPreferences sang day, them Vang/Bac/Dong/Nha dat).
-- Xem ke hoach chi tiet o buoi lam viec build lai Wealth (khong co file rieng
-- - quyet dinh kien truc nam trong lich su trao doi voi nguoi dung).

-- So bien dong so du Tien mat/Ngan hang - so du hien tai cua 1
-- (account_type, bank_code, currency) = SUM(amount) cac dong khop dieu kien.
-- amount duong = nap/thu nhap, am = rut/chi tieu/tra no.
create table if not exists public.wealth_balance_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  account_type text not null check (account_type in ('cash', 'bank')),
  -- bank_code/bank_name chi co gia tri khi account_type='bank'. Luu ca ten
  -- (khong chi ma) de khong phu thuoc danh sach VietQR con song hay khong.
  bank_code text,
  bank_name text,
  currency text not null check (currency in ('VND', 'USD')),
  amount numeric not null,
  note text,
  occurred_at timestamptz not null default now(),
  -- 'manual' = nguoi dung tu nhap trong man Vi; 'expense' = tu dong sinh ra
  -- khi them 1 giao dich Chi tieu; 'debt_payment' = tu dong sinh ra khi
  -- tra/nhan tra 1 khoan no.
  source text not null default 'manual' check (source in ('manual', 'expense', 'debt_payment')),
  source_transaction_id uuid references public.wealth_transactions (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.wealth_balance_entries enable row level security;

drop policy if exists "wealth_balance_entries_select_own" on public.wealth_balance_entries;
create policy "wealth_balance_entries_select_own"
  on public.wealth_balance_entries for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_balance_entries_insert_own" on public.wealth_balance_entries;
create policy "wealth_balance_entries_insert_own"
  on public.wealth_balance_entries for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_balance_entries_update_own" on public.wealth_balance_entries;
create policy "wealth_balance_entries_update_own"
  on public.wealth_balance_entries for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_balance_entries_delete_own" on public.wealth_balance_entries;
create policy "wealth_balance_entries_delete_own"
  on public.wealth_balance_entries for delete
  using (auth.uid() = user_id);

-- Chi tieu can biet tru vao dau (Tien mat hay 1 ngan hang cu the) de tu
-- dong sinh ra 1 dong wealth_balance_entries tuong ung.
alter table public.wealth_transactions
  add column if not exists payment_account_type text check (payment_account_type in ('cash', 'bank')),
  add column if not exists payment_bank_code text,
  add column if not exists payment_bank_name text;

-- Noi rong wealth_holdings de dung chung cho moi loai tai san dau tu (truoc
-- day chi co stock_intl). Crypto portfolio se chuyen tu SharedPreferences
-- sang day (asset_type='crypto'). Nha dat khong co symbol/quantity/avg_cost
-- - dung manual_value (nguoi dung tu nhap gia tri uoc tinh).
alter table public.wealth_holdings
  add column if not exists name text,
  add column if not exists image_url text,
  add column if not exists manual_value numeric;

alter table public.wealth_holdings drop constraint if exists wealth_holdings_asset_type_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_asset_type_check
  check (asset_type in ('stock_intl', 'crypto', 'gold', 'silver', 'copper', 'real_estate'));

alter table public.wealth_holdings alter column symbol drop not null;
alter table public.wealth_holdings alter column quantity drop not null;
alter table public.wealth_holdings alter column avg_cost drop not null;

alter table public.wealth_holdings drop constraint if exists wealth_holdings_quantity_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_quantity_check check (quantity is null or quantity > 0);

alter table public.wealth_holdings drop constraint if exists wealth_holdings_avg_cost_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_avg_cost_check check (avg_cost is null or avg_cost >= 0);

-- unique(user_id, symbol) cu khong con hop ly vi Nha dat khong co symbol va
-- co the co nhieu bat dong san doc lap - thay bang unique index chi ap dung
-- khi symbol khac null, phan biet them theo asset_type (cung symbol nhung
-- khac loai tai san van la 2 khoan nam giu khac nhau, vi du ca stock_intl
-- lan crypto deu co the dung ky hieu trung nhau ve mat ly thuyet).
alter table public.wealth_holdings drop constraint if exists wealth_holdings_user_id_symbol_key;
drop index if exists public.wealth_holdings_user_asset_symbol_key;
create unique index wealth_holdings_user_asset_symbol_key
  on public.wealth_holdings (user_id, asset_type, symbol)
  where symbol is not null;

-- Lich su mua/ban/dinh gia lai cho tung khoan nam giu dau tu (dung cho
-- Portfolio Crypto/Co phieu/Kim loai/Nha dat) - 'revalue' danh cho Nha dat
-- (khong co khai niem mua/ban theo so luong, chi tu cap nhat gia tri).
create table if not exists public.wealth_investment_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  asset_type text not null check (asset_type in ('stock_intl', 'crypto', 'gold', 'silver', 'copper', 'real_estate')),
  symbol text,
  action text not null check (action in ('buy', 'sell', 'revalue')),
  quantity numeric,
  price numeric,
  amount numeric,
  currency text not null default 'USD',
  note text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.wealth_investment_transactions enable row level security;

drop policy if exists "wealth_investment_transactions_select_own" on public.wealth_investment_transactions;
create policy "wealth_investment_transactions_select_own"
  on public.wealth_investment_transactions for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_investment_transactions_insert_own" on public.wealth_investment_transactions;
create policy "wealth_investment_transactions_insert_own"
  on public.wealth_investment_transactions for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_investment_transactions_delete_own" on public.wealth_investment_transactions;
create policy "wealth_investment_transactions_delete_own"
  on public.wealth_investment_transactions for delete
  using (auth.uid() = user_id);

-- Tinh nang No: 1 "chu no/nguoi no" (person) co the xuat hien trong nhieu
-- khoan no rieng biet theo thoi gian - gop lai thanh 1 "lich su no" khi
-- nguoi dung go trung ten (so khop khong phan biet hoa/thuong).
create table if not exists public.wealth_debt_persons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

drop index if exists public.wealth_debt_persons_user_name_lower_key;
create unique index wealth_debt_persons_user_name_lower_key
  on public.wealth_debt_persons (user_id, lower(name));

alter table public.wealth_debt_persons enable row level security;

drop policy if exists "wealth_debt_persons_select_own" on public.wealth_debt_persons;
create policy "wealth_debt_persons_select_own"
  on public.wealth_debt_persons for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_debt_persons_insert_own" on public.wealth_debt_persons;
create policy "wealth_debt_persons_insert_own"
  on public.wealth_debt_persons for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_debt_persons_update_own" on public.wealth_debt_persons;
create policy "wealth_debt_persons_update_own"
  on public.wealth_debt_persons for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_debt_persons_delete_own" on public.wealth_debt_persons;
create policy "wealth_debt_persons_delete_own"
  on public.wealth_debt_persons for delete
  using (auth.uid() = user_id);

-- 1 khoan no cu the cua 1 nguoi - direction 'i_owe' = minh no nguoi nay,
-- 'owed_to_me' = nguoi nay no minh. remaining_amount giam dan khi co
-- wealth_debt_payments, ve 0 thi coi la da tra xong (settled_at).
create table if not exists public.wealth_debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  person_id uuid not null references public.wealth_debt_persons (id) on delete cascade,
  direction text not null check (direction in ('i_owe', 'owed_to_me')),
  original_amount numeric not null check (original_amount > 0),
  remaining_amount numeric not null check (remaining_amount >= 0),
  currency text not null default 'VND' check (currency in ('VND', 'USD')),
  note text,
  occurred_at timestamptz not null default now(),
  settled_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.wealth_debts enable row level security;

drop policy if exists "wealth_debts_select_own" on public.wealth_debts;
create policy "wealth_debts_select_own"
  on public.wealth_debts for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_debts_insert_own" on public.wealth_debts;
create policy "wealth_debts_insert_own"
  on public.wealth_debts for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_debts_update_own" on public.wealth_debts;
create policy "wealth_debts_update_own"
  on public.wealth_debts for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_debts_delete_own" on public.wealth_debts;
create policy "wealth_debts_delete_own"
  on public.wealth_debts for delete
  using (auth.uid() = user_id);

-- Moi lan tra/nhan tra 1 phan khoan no - luon di kem 1 hinh thuc (tien mat
-- hoac 1 ngan hang cu the) de tu dong sinh dong wealth_balance_entries
-- tuong ung (cong hoac tru vao Vi).
create table if not exists public.wealth_debt_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  debt_id uuid not null references public.wealth_debts (id) on delete cascade,
  amount numeric not null check (amount > 0),
  payment_account_type text not null check (payment_account_type in ('cash', 'bank')),
  payment_bank_code text,
  payment_bank_name text,
  currency text not null default 'VND',
  note text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.wealth_debt_payments enable row level security;

drop policy if exists "wealth_debt_payments_select_own" on public.wealth_debt_payments;
create policy "wealth_debt_payments_select_own"
  on public.wealth_debt_payments for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_debt_payments_insert_own" on public.wealth_debt_payments;
create policy "wealth_debt_payments_insert_own"
  on public.wealth_debt_payments for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_debt_payments_delete_own" on public.wealth_debt_payments;
create policy "wealth_debt_payments_delete_own"
  on public.wealth_debt_payments for delete
  using (auth.uid() = user_id);

-- Lien ket 1 dong wealth_balance_entries voi 1 lan tra no (them sau khi ca
-- 2 bang da ton tai, vi wealth_debt_payments phai duoc tao truoc).
alter table public.wealth_balance_entries
  add column if not exists source_debt_payment_id uuid references public.wealth_debt_payments (id) on delete cascade;
