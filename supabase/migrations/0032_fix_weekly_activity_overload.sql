-- Migration 0031 tao ham my_weekly_activity(p_source text default 'english')
-- MOI nhung quen xoa ham CU my_weekly_activity() khong tham so - Postgres
-- gio co 2 ham trung ten, goi KHONG tham so (dung boi
-- StatsRepository.fetchMyStats(), thong ke o man Ho so) bi loi AMBIGUOUS
-- (khong xac dinh duoc goi ham nao) 100% MOI LAN, khong phai loi tam thoi -
-- day la nguyen nhan that su khien "Hoat dong tuan nay"/thong ke luon bao
-- loi cho MOI nguoi dung tu sau khi migration 0031 duoc ap dung.
drop function if exists public.my_weekly_activity();
