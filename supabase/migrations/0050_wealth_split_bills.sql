-- Tinh nang Chia tien bill (xem wealth_split_bill_screen.dart) - luu lai
-- lich su moi lan chia bill: 1 dong wealth_split_bills (tong tien, phuong
-- thuc thanh toan, lien ket sang wealth_transactions da tao) + nhieu dong
-- wealth_split_bill_shares (moi nguoi 1 dong: ten, so tien, trang thai
-- pending/debt/paid, lien ket sang wealth_debts neu chon "Ghi no").

create table if not exists public.wealth_split_bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  total_amount numeric not null check (total_amount >= 0),
  currency text not null default 'VND',
  payment_account_type text not null check (payment_account_type in ('cash', 'bank')),
  payment_bank_code text,
  payment_bank_name text,
  transaction_id uuid references public.wealth_transactions (id) on delete set null,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.wealth_split_bills enable row level security;

drop policy if exists "wealth_split_bills_select_own" on public.wealth_split_bills;
create policy "wealth_split_bills_select_own"
  on public.wealth_split_bills for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_split_bills_insert_own" on public.wealth_split_bills;
create policy "wealth_split_bills_insert_own"
  on public.wealth_split_bills for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_split_bills_delete_own" on public.wealth_split_bills;
create policy "wealth_split_bills_delete_own"
  on public.wealth_split_bills for delete
  using (auth.uid() = user_id);

create table if not exists public.wealth_split_bill_shares (
  id uuid primary key default gen_random_uuid(),
  bill_id uuid not null references public.wealth_split_bills (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  person_name text not null,
  is_me boolean not null default false,
  amount numeric not null check (amount >= 0),
  status text not null default 'pending' check (status in ('pending', 'debt', 'paid')),
  debt_id uuid references public.wealth_debts (id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.wealth_split_bill_shares enable row level security;

drop policy if exists "wealth_split_bill_shares_select_own" on public.wealth_split_bill_shares;
create policy "wealth_split_bill_shares_select_own"
  on public.wealth_split_bill_shares for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_split_bill_shares_insert_own" on public.wealth_split_bill_shares;
create policy "wealth_split_bill_shares_insert_own"
  on public.wealth_split_bill_shares for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_split_bill_shares_update_own" on public.wealth_split_bill_shares;
create policy "wealth_split_bill_shares_update_own"
  on public.wealth_split_bill_shares for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
