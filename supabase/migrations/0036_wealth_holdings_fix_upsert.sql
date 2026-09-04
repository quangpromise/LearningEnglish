-- FIX BUG NGHIEM TRONG: upsert Co phieu/Crypto (upsertBySymbol, onConflict
-- 'user_id,asset_type,symbol') LUON LOI vi unique index cu la PARTIAL
-- (WHERE symbol IS NOT NULL) - Postgres KHONG cho phep dung partial index
-- lam arbiter cho ON CONFLICT tru khi cau lenh INSERT lap lai dung WHERE do
-- (PostgREST khong ho tro), nen moi lan them/sua Co phieu hay Crypto deu
-- nem loi 42P10 "no unique or exclusion constraint matching the ON
-- CONFLICT specification" - da xac nhan bang test truc tiep qua SQL.
--
-- Fix: doi thanh unique index THUONG (khong con WHERE) - Postgres van tu
-- coi moi dong co symbol NULL (Nha dat) la "khac nhau" (khong vi pham
-- unique) theo chuan SQL, nen Nha dat van chen duoc nhieu dong nhu cu,
-- trong khi Co phieu/Crypto/Kim loai (symbol luon co gia tri) gio upsert
-- dung.
drop index if exists public.wealth_holdings_user_asset_symbol_key;
create unique index wealth_holdings_user_asset_symbol_key
  on public.wealth_holdings (user_id, asset_type, symbol);
