-- Noi 1 giao dich dau tu (wealth_investment_transactions) ve DUNG dong chi
-- tieu da sinh ra no (wealth_transactions, danh muc INVESTMENT).
--
-- LY DO: xoa 1 khoan "Dau tu" trong Vi/Chi tieu truoc day CHI xoa dong chi
-- tieu + tra lai so du, con so luong coin/co phieu da mua va lich su mua thi
-- van con nguyen trong Portfolio - danh muc phinh len bang nhung khoan ma
-- nguoi dung nghi la da xoa.
--
-- Co cot nay roi thi luc xoa biet chinh xac phai tru lai bao nhieu o holding
-- va xoa dong lich su nao, thay vi phai doan theo (symbol + gio + so tien).
--
-- ON DELETE SET NULL (khong phai CASCADE): neu vi ly do nao do dong chi tieu
-- bi xoa bang duong khac, ta KHONG muon lang le xoa mat lich su mua - de lai
-- lich su voi lien ket rong van tot hon la mat du lieu.
alter table public.wealth_investment_transactions
  add column if not exists source_transaction_id uuid
    references public.wealth_transactions (id) on delete set null;

create index if not exists wealth_investment_tx_source_idx
  on public.wealth_investment_transactions (source_transaction_id)
  where source_transaction_id is not null;
