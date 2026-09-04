-- Tinh nang Dich vu dinh ky (Phase G) - theo doi cac dich vu tra phi dang
-- dung (Netflix, hosting, domain...), tu tinh ngay het han theo chu ky
-- (tuan/thang/nam/so nam tuy chon) hoac nguoi dung tu chon ngay het han,
-- nhac qua push moi ngay trong 7 ngay cuoi truoc han, va gia han (tru thang
-- vao Vi, ho tro tach nhieu hinh thuc thanh toan 1 luc).

create table if not exists public.wealth_recurring_services (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  default_amount numeric not null check (default_amount >= 0),
  currency text not null default 'VND' check (currency in ('VND', 'USD')),
  -- 'week'/'month'/'year' = chu ky co dinh; 'custom_years' = so nam tuy y
  -- (cycle_years); 'manual' = nguoi dung tu chon thang ngay het han moi lan,
  -- khong tu tinh theo chu ky.
  cycle_type text not null check (cycle_type in ('week', 'month', 'year', 'custom_years', 'manual')),
  cycle_years numeric,
  start_date date not null,
  expiry_date date not null,
  note text,
  is_active boolean not null default true,
  -- Ngay gan nhat da gui push nhac han - tranh gui trung nhieu lan trong
  -- cung 1 ngay neu job kiem tra chay hon 1 lan.
  last_notified_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists wealth_recurring_services_expiry_idx
  on public.wealth_recurring_services (expiry_date) where is_active;

alter table public.wealth_recurring_services enable row level security;

drop policy if exists "wealth_recurring_services_select_own" on public.wealth_recurring_services;
create policy "wealth_recurring_services_select_own"
  on public.wealth_recurring_services for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_recurring_services_insert_own" on public.wealth_recurring_services;
create policy "wealth_recurring_services_insert_own"
  on public.wealth_recurring_services for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_recurring_services_update_own" on public.wealth_recurring_services;
create policy "wealth_recurring_services_update_own"
  on public.wealth_recurring_services for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_recurring_services_delete_own" on public.wealth_recurring_services;
create policy "wealth_recurring_services_delete_own"
  on public.wealth_recurring_services for delete
  using (auth.uid() = user_id);

-- 1 lan gia han - luu lai ngay het han truoc/sau de xem lich su, so tien co
-- the khac default_amount neu nguoi dung tuy chinh luc gia han.
create table if not exists public.wealth_service_renewals (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.wealth_recurring_services (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount numeric not null check (amount >= 0),
  currency text not null,
  previous_expiry_date date not null,
  new_expiry_date date not null,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.wealth_service_renewals enable row level security;

drop policy if exists "wealth_service_renewals_select_own" on public.wealth_service_renewals;
create policy "wealth_service_renewals_select_own"
  on public.wealth_service_renewals for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_service_renewals_insert_own" on public.wealth_service_renewals;
create policy "wealth_service_renewals_insert_own"
  on public.wealth_service_renewals for insert
  with check (auth.uid() = user_id);

-- Chi tiet tung hinh thuc thanh toan cho 1 lan gia han - cho phep tach
-- Tien mat + 1/nhieu Ngan hang trong CUNG 1 lan gia han (yeu cau nguoi dung:
-- "gia han co the tuy chon tra bang tien mat va ngan hang").
create table if not exists public.wealth_service_renewal_payments (
  id uuid primary key default gen_random_uuid(),
  renewal_id uuid not null references public.wealth_service_renewals (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount numeric not null check (amount > 0),
  payment_account_type text not null check (payment_account_type in ('cash', 'bank')),
  payment_bank_code text,
  payment_bank_name text,
  currency text not null,
  created_at timestamptz not null default now()
);

alter table public.wealth_service_renewal_payments enable row level security;

drop policy if exists "wealth_service_renewal_payments_select_own" on public.wealth_service_renewal_payments;
create policy "wealth_service_renewal_payments_select_own"
  on public.wealth_service_renewal_payments for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_service_renewal_payments_insert_own" on public.wealth_service_renewal_payments;
create policy "wealth_service_renewal_payments_insert_own"
  on public.wealth_service_renewal_payments for insert
  with check (auth.uid() = user_id);

-- Lien ket 1 dong wealth_balance_entries voi 1 hinh thuc thanh toan gia han
-- (them sau khi bang tren da ton tai), va noi rong check cua source de cho
-- phep gia tri moi 'service_renewal'.
alter table public.wealth_balance_entries
  add column if not exists source_service_renewal_payment_id uuid references public.wealth_service_renewal_payments (id) on delete cascade;

alter table public.wealth_balance_entries drop constraint if exists wealth_balance_entries_source_check;
alter table public.wealth_balance_entries
  add constraint wealth_balance_entries_source_check
  check (source in ('manual', 'expense', 'debt_payment', 'service_renewal'));
