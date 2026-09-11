-- Cho phep "xoa" 1 nguoi khoi danh sach goi y (Them no + Chia bill deu dung
-- chung wealth_debt_persons, xem debt_person_picker_field.dart va
-- _PersonNameDropdownField trong wealth_split_bill_screen.dart) - dung SOFT
-- DELETE (an di) thay vi xoa cung dong, vi wealth_debts.person_id tham chieu
-- toi day voi "on delete cascade" (xem 0032_wealth_wallet.sql:176) - xoa cung
-- se xoa mat LICH SU NO THAT cua nguoi do, khong phai dieu nguoi dung muon
-- khi chi bam "x" o goi y. Them lai dung ten (findOrCreate) se tu bo an.
alter table public.wealth_debt_persons
  add column if not exists hidden_from_suggestions boolean not null default false;
