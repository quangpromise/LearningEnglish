-- Thong bao khi gia 1 tai san trong watchlist bien dong >5% (24h) - xem
-- docs trao doi trong task "Thong bao gia Crypto/Co phieu". Ap dung cho
-- Crypto (CoinGecko top100 + ngoai top100 qua OKX) va Co phieu (tokenized
-- tren OKX + HOSE Viet Nam) - Vang hoan lai vi chua co nguon %thay doi.

alter table public.profiles
  add column if not exists price_alerts_enabled boolean not null default true;

-- 1 dong / 1 (user, loai tai san, ma) dang duoc "sao" trong watchlist - dong
-- bo tu CryptoWatchlistRepository/AssetWatchlistRepository (dang chi luu
-- local) de Edge Function chay nen (khong co user dang nhap) biet ai can bao.
create table if not exists public.price_alert_watchlist (
  user_id uuid not null references public.profiles (id) on delete cascade,
  asset_type text not null check (asset_type in ('crypto', 'stock_okx', 'stock_vn')),
  symbol text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, asset_type, symbol)
);

alter table public.price_alert_watchlist enable row level security;

drop policy if exists "price_alert_watchlist_select_own" on public.price_alert_watchlist;
create policy "price_alert_watchlist_select_own"
  on public.price_alert_watchlist for select
  using (auth.uid() = user_id);

drop policy if exists "price_alert_watchlist_insert_own" on public.price_alert_watchlist;
create policy "price_alert_watchlist_insert_own"
  on public.price_alert_watchlist for insert
  with check (auth.uid() = user_id);

drop policy if exists "price_alert_watchlist_delete_own" on public.price_alert_watchlist;
create policy "price_alert_watchlist_delete_own"
  on public.price_alert_watchlist for delete
  using (auth.uid() = user_id);

-- Trang thai TOAN CUC (khong theo user) cho tung (asset_type, symbol) - dung
-- de chi bao 1 LAN khi gia VUA vuot nguong +-5%, khong nhac lai neu van giu
-- nguyen trang thai o lan quet dinh ky sau. Chi Edge Function (service role)
-- dung bang nay nen khong can policy cho client.
create table if not exists public.price_alert_state (
  asset_type text not null check (asset_type in ('crypto', 'stock_okx', 'stock_vn')),
  symbol text not null,
  direction text check (direction in ('up', 'down')),
  change_percent numeric,
  alerted_at timestamptz not null default now(),
  primary key (asset_type, symbol)
);

alter table public.price_alert_state enable row level security;
