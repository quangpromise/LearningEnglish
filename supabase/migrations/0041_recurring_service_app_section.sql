-- Cho phep 1 dich vu dinh ky (wealth_recurring_services) duoc GAN cho 1
-- trong 2 mini-app khac (Fitness/Hoc Tieng Anh) - vd goi tap gym, khoa hoc
-- tieng Anh tra phi... Man Ho so cua 2 app do se hien danh sach dich vu gan
-- cho chinh no + cho tao moi truc tiep tu do; man Dich vu dinh ky ben Quan
-- ly tai san van la noi QUAN LY DUY NHAT (sua/gia han/xoa/gan lai) vi day la
-- 1 bang chung, khong tach rieng theo app.
--
-- null = dich vu chung (khong gan app nao, hanh vi cu khong doi).

alter table public.wealth_recurring_services
  add column if not exists app_section text
  check (app_section in ('fitness', 'learn_english'));

create index if not exists wealth_recurring_services_app_section_idx
  on public.wealth_recurring_services (app_section)
  where app_section is not null;
