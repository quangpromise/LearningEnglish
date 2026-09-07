-- Truoc day gia han dich vu dinh ky CHI tru tien vao Vi (wealth_balance_entries,
-- source='service_renewal') ma KHONG cong vao wealth_transactions - khien man
-- Bao cao (Thu chi trong thang) bi thieu khoan chi nay, gay lech so voi tong
-- tai san Bank/Cash thuc te da giam. Them cot lien ket de renew() co the ghi
-- them 1 dong wealth_transactions (loai expense) va xoa dung dong do khi
-- nguoi dung xoa lai lan gia han (xem recurring_service_repository.dart).
alter table public.wealth_service_renewals
  add column if not exists transaction_id uuid references public.wealth_transactions (id) on delete set null;
