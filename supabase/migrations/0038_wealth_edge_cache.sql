-- Bang cache dung chung cho cac Edge Function goi nguon du lieu KHONG on
-- dinh (vd stocks-vn goi API cong khai cua HOSE - da xac nhan qua test thuc
-- te la ~1/4-3/4 lan bi timeout/loi du da retry 3 lan trong 1 request, vi
-- day la API noi bo khong chinh thuc). Cache trong bo nho (bien global cua
-- function) truoc day KHONG du vi moi Edge Function co the chay tren 1
-- isolate MOI (cold start) cho moi request rieng le, khien cache khong bao
-- gio duoc dung lai giua cac lan goi cach nhau vai giay/phut trong thuc te.
-- Bang nay ben vung qua moi lan cold start, cho phep: (1) dung lai ket qua
-- thanh cong gan nhat trong TTL, (2) fallback ve du lieu CU (con hon la
-- loi trang) neu lan fetch moi that bai het.
create table if not exists public.wealth_edge_cache (
  cache_key text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.wealth_edge_cache enable row level security;
-- Khong co policy nao ca - chi Edge Function (dung SUPABASE_SERVICE_ROLE_KEY,
-- tu dong bypass RLS) moi doc/ghi duoc bang nay, khong client nao truy cap
-- truc tiep qua PostgREST voi anon/user key.
