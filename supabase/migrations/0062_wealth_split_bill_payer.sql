-- Chia tien bill: chon NGUOI TRA BILL (xem wealth_split_bill_screen.dart).
-- payer_name null = "Toi" tra ca bill (hanh vi cu). Khac null = 1 nguoi
-- khac da tra - khi do phan cua "Toi" tra cho ho bang Cash/Bank (chi tru
-- dung phan cua minh) hoac Ghi no (tao khoan i_owe, payment_account_type =
-- 'debt', khong tru Vi); nhung nguoi con lai chi hien thi, khong tao no/
-- khong cong tru Vi.

alter table public.wealth_split_bills
  add column if not exists payer_name text;

alter table public.wealth_split_bills
  drop constraint if exists wealth_split_bills_payment_account_type_check;

alter table public.wealth_split_bills
  add constraint wealth_split_bills_payment_account_type_check
  check (payment_account_type in ('cash', 'bank', 'debt'));
