-- Them 'stock_vn' vao danh sach asset_type hop le - cho phep nguoi dung luu
-- co phieu Viet Nam (san HOSE) trong Vi > Tai san dau tu > Co phieu, tach
-- biet voi 'stock_intl' (co phieu quoc te, Twelve Data) vi 2 nguon gia +
-- don vi tien te khac nhau (VND vs USD). Xem supabase/functions/stocks-vn.

alter table public.wealth_holdings drop constraint if exists wealth_holdings_asset_type_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate'));

alter table public.wealth_investment_transactions drop constraint if exists wealth_investment_transactions_asset_type_check;
alter table public.wealth_investment_transactions
  add constraint wealth_investment_transactions_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate'));
