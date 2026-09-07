-- Phat hien qua man Bao cao: tong Thu nhap (wealth_transactions) khong khop
-- voi tong tien thuc te tang trong Vi, vi truoc day THEM Thu nhap KHONG bao
-- gio tao dong wealth_balance_entries tuong ung (chi Chi tieu moi lam dieu
-- nay) - nguoi dung phai tu tay cong tien vao Vi rieng, dan den de quen/sai
-- lech. Mo rong constraint de add_transaction_sheet.dart co the ghi them 1
-- dong wealth_balance_entries (+amount) khi loai giao dich la income, doi
-- xung voi cach Chi tieu da lam.
alter table public.wealth_balance_entries drop constraint if exists wealth_balance_entries_source_check;
alter table public.wealth_balance_entries
  add constraint wealth_balance_entries_source_check
  check (source in ('manual', 'expense', 'income', 'debt_payment', 'service_renewal'));
