-- Ma QR nhan tien "cua toi" (Phase 1: 1 QR duy nhat cho moi user, khong tach
-- theo tung ngan hang) - hien khi bam nut "QR Code" o the Tong Vi man Home
-- Quan ly tai san (xem wealth_home_screen.dart). Nguoi dung tai anh QR co
-- san (chup tu app ngan hang) len, kem ten chu tai khoan/so tai khoan/ten
-- ngan hang de hien thi ngay ben duoi anh (khong OCR/parse gi tu anh QR).

create table if not exists public.wealth_payment_qr (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  image_url text,
  bank_name text,
  account_number text,
  holder_name text,
  updated_at timestamptz not null default now()
);

alter table public.wealth_payment_qr enable row level security;

drop policy if exists "wealth_payment_qr_select_own" on public.wealth_payment_qr;
create policy "wealth_payment_qr_select_own"
  on public.wealth_payment_qr for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_payment_qr_insert_own" on public.wealth_payment_qr;
create policy "wealth_payment_qr_insert_own"
  on public.wealth_payment_qr for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_payment_qr_update_own" on public.wealth_payment_qr;
create policy "wealth_payment_qr_update_own"
  on public.wealth_payment_qr for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Bucket rieng luu anh QR (khong dung chung bucket 'avatars' de tach biet
-- muc dich) - cung mo hinh policy voi avatars: public doc duoc (hien anh
-- khong can ky URL), chi chinh chu (thu muc <user_id>/...) moi duoc ghi.
insert into storage.buckets (id, name, public)
values ('wealth-qr', 'wealth-qr', true)
on conflict (id) do nothing;

drop policy if exists "wealth_qr_public_read" on storage.objects;
create policy "wealth_qr_public_read"
  on storage.objects for select
  using (bucket_id = 'wealth-qr');

drop policy if exists "wealth_qr_insert_own" on storage.objects;
create policy "wealth_qr_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'wealth-qr'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "wealth_qr_update_own" on storage.objects;
create policy "wealth_qr_update_own"
  on storage.objects for update
  using (
    bucket_id = 'wealth-qr'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "wealth_qr_delete_own" on storage.objects;
create policy "wealth_qr_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'wealth-qr'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
