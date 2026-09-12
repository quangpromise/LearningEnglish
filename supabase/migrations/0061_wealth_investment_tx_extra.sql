-- Bo sung cho wealth_investment_transactions: luu kem ten/anh coin ngay tai
-- thoi diem giao dich (denormalized) - can cho lich su mua/ban Crypto hien
-- dung y het UI cu (CryptoTransaction co name/imageUrl rieng, khong chi dua
-- vao wealth_holdings vi holding co the da bi xoa sau khi ban het).
alter table public.wealth_investment_transactions
  add column if not exists name text,
  add column if not exists image_url text;
