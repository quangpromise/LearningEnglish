-- Them 'investment' vao danh sach source hop le cua wealth_balance_entries -
-- dung khi tru tien Vi (Tien mat/Ngan hang) de mua 1 khoan dau tu (Crypto/Co
-- phieu/Vang/Bat dong san) tu tab "Investment" trong man Pay/Receive moi
-- (xem wealth_pay_screen.dart). Khong lien ket sourceTransactionId nao (giong
-- 'manual') - xoa dong nay chi xoa dong Vi, KHONG dong bo xoa lai khoan dau
-- tu tuong ung (khac voi 'expense'/'debt_payment'/'service_renewal' da co
-- lien ket 2 chieu).

alter table public.wealth_balance_entries drop constraint if exists wealth_balance_entries_source_check;
alter table public.wealth_balance_entries
  add constraint wealth_balance_entries_source_check
  check (source in ('manual', 'expense', 'income', 'debt_payment', 'service_renewal', 'investment'));
