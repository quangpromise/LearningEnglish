-- Bo sung cho tinh nang Chia tien bill (xem 0050_wealth_split_bills.sql):
-- 1) Ghi chu rieng cho 1 lan chia bill, hien duoi tong tien tren bien lai.
-- 2) Cho phep sua (note) + xoa 1 bill tu man Lich su - can them policy
--    update (truoc day chi co select/insert/delete) va 1 cot lien ket moi de
--    xoa bill co the cascade xoa dung dong wealth_balance_entries da tao cho
--    nguoi chon "Da tra" (truoc day khong co lien ket nao, khong xoa duoc).

alter table public.wealth_split_bills
  add column if not exists note text;

drop policy if exists "wealth_split_bills_update_own" on public.wealth_split_bills;
create policy "wealth_split_bills_update_own"
  on public.wealth_split_bills for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Dong wealth_balance_entries tao ra khi 1 nguoi (khac "Toi") duoc chon "Da
-- tra" ngay luc chia bill (xem wealth_split_bill_screen.dart _confirmPay) -
-- truoc day source='manual' khong co lien ket nao ca, nen xoa bill khong don
-- dep duoc dong nay. on delete cascade: xoa share (do bill bi xoa cascade
-- xuong) se xoa luon dong Vi tuong ung.
alter table public.wealth_balance_entries
  add column if not exists source_bill_share_id uuid references public.wealth_split_bill_shares (id) on delete cascade;
