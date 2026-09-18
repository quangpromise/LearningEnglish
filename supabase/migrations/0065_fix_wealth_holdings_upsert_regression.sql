-- FIX BUG: moi thu them vao Vi > Tai san dau tu (crypto, co phieu, kim loai,
-- ngoai te...) deu "mat sach" sau khi tat app mo lai - vi cau lenh ghi len
-- Supabase that ra LUON LOI, UI chi dong sheet lai nen nhin nhu da luu.
--
-- Nguyen nhan: migration 0060_wealth_wallet.sql chay SAU 0036/0037/0046 da
-- vo tinh keo lui 2 thay doi truoc do:
--
-- 1) Tao lai unique index dang PARTIAL (`where symbol is not null`) - dung
--    lai dung loi ma 0036 da sua. Postgres KHONG cho dung partial index lam
--    arbiter cho ON CONFLICT tru khi INSERT lap lai dung menh de WHERE do
--    (PostgREST khong ho tro), nen moi upsert onConflict
--    'user_id,asset_type,symbol' deu nem 42P10 -> khong dong nao duoc ghi.
--    Bo `where` di: Postgres van coi moi dong symbol NULL (Nha dat) la khac
--    nhau theo chuan SQL, nen Nha dat van chen duoc nhieu dong nhu cu.
--
-- 2) Thay check constraint asset_type bang danh sach THIEU 'stock_vn' (them
--    o 0037) va 'foreign_currency' (them o 0046) -> them co phieu VN hoac
--    ngoai te bi chan boi check constraint.

drop index if exists public.wealth_holdings_user_asset_symbol_key;
create unique index wealth_holdings_user_asset_symbol_key
  on public.wealth_holdings (user_id, asset_type, symbol);

alter table public.wealth_holdings drop constraint if exists wealth_holdings_asset_type_check;
alter table public.wealth_holdings
  add constraint wealth_holdings_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate', 'foreign_currency'));

alter table public.wealth_investment_transactions drop constraint if exists wealth_investment_transactions_asset_type_check;
alter table public.wealth_investment_transactions
  add constraint wealth_investment_transactions_asset_type_check
  check (asset_type in ('stock_intl', 'stock_vn', 'crypto', 'gold', 'silver', 'copper', 'real_estate', 'foreign_currency'));
