-- Nang cap "Thong bao gia" tu 1 nguong DUY NHAT (+-5%) sang NHIEU moc lien
-- tiep cach nhau 5% (5%, 10%, 15%, 20%...) - moi lan gia VUOT THEM 1 moc moi
-- (theo huong dang di) se co 1 thong bao rieng, thay vi chi bao 1 lan duy
-- nhat luc vua cham 5% roi im lang du gia tiep tuc tang/giam manh hon nhieu.
-- Xem supabase/functions/price-alert-check/index.ts.

alter table public.price_alert_state
  add column if not exists tier integer;

-- "direction" (chi 2 gia tri up/down) khong con du bieu dien duoc TUNG moc
-- (vd tier=2 = da vuot moc 10%) - thay bang "tier" (so nguyen co dau: duong
-- = tang, am = giam, do lon = da vuot bao nhieu moc 5%). Khong ai doc lai
-- cot nay ngoai chinh Edge Function (khong co API/man hinh nao dung toi) nen
-- xoa an toan.
alter table public.price_alert_state
  drop column if exists direction;
