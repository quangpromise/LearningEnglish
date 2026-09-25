-- Lo trinh tieng Anh A1 -> C1 (spec #45, ticket #54): dong bo state lo trinh
-- (English Level, tien do Unit, Placement, Level Test, cau tung sai) theo
-- TAI KHOAN. Chi THEM 1 cot jsonb vao bang da co - khong tao bang moi; RLS
-- cua bang (chi doc/ghi dong cua minh, migration 0074) ap dung luon.
--
-- Noi dung: {"schemaVersion": n, ...} - xem english_path_state.dart. May
-- khach tu gop (merge) truoc khi ghi va KHONG BAO GIO ghi de ban do app moi
-- hon ghi (schemaVersion lon hon) - xem gymtalk_sync_service.dart.
-- null = chua tung dong bo lo trinh.
alter table public.user_gymtalk_state
  add column if not exists path jsonb;
