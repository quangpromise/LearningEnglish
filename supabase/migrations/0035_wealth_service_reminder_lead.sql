-- Cho phep nguoi dung tuy chon thoi diem bat dau nhac han cho tung dich vu
-- (1 thang/nua thang/1 tuan truoc han) thay vi co dinh 7 ngay.
alter table public.wealth_recurring_services
  add column if not exists reminder_lead_days integer not null default 7
  check (reminder_lead_days in (7, 15, 30));
