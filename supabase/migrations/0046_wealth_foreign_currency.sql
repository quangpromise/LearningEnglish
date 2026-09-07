-- Them 'foreign_currency' vao danh sach asset_type hop le - cho phep nguoi
-- dung luu khoan nam giu ngoai te (USD, EUR, JPY...) trong Vi > Tai san dau
-- tu, dinh gia theo ty gia Vietcombank thoi gian thuc (xem
-- supabase/functions/wealth-vn-assets/index.ts + foreign_currency_portfolio_screen.dart).
-- Dung lai dung cot co san cua wealth_holdings (symbol = ma tien te, quantity
-- = so luong, avg_cost = ty gia luc mua) - khong can bang moi.

alter table public.wealth_holdings drop constraint if exists wealth_holdings_asset_type_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate', 'foreign_currency'));

alter table public.wealth_investment_transactions drop constraint if exists wealth_investment_transactions_asset_type_check;
alter table public.wealth_investment_transactions
  add constraint wealth_investment_transactions_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate', 'foreign_currency'));
