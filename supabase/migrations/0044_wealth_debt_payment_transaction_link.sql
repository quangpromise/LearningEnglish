-- Cung 1 van de nhu migration 0043 (gia han dich vu): tra no (i_owe) truoc
-- day CHI tru vao Vi (wealth_balance_entries, source='debt_payment') ma
-- KHONG cong vao wealth_transactions, gay lech Chi tieu trong man Bao cao so
-- voi tong tai san Bank/Cash da giam thuc te. Them cot lien ket de
-- pay_debt_sheet.dart/edit_debt_payment_dialog.dart ghi/cap nhat/xoa dung 1
-- dong wealth_transactions (loai expense, danh muc DEBT) tuong ung.
alter table public.wealth_debt_payments
  add column if not exists transaction_id uuid references public.wealth_transactions (id) on delete set null;
