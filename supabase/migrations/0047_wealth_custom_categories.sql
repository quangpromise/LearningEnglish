-- Danh muc chi tieu TUY CHINH - nguoi dung tu them/sua/xoa trong man Cai dat
-- Quan ly tai san (ngoai 8 danh muc co dinh cua WealthExpenseCategory nhu
-- Food/Transport...), roi chon duoc ngay trong Wrap chon danh muc luc them
-- Chi tieu. Moi danh muc tuy chinh duoc gan 1 icon_key (tra ve IconData qua
-- bang co dinh kCustomCategoryIcons trong app, KHONG luu IconData truc tiep)
-- - category_code cua giao dich dung danh muc nay se la 'CUSTOM:<id>' (xem
-- wealth_custom_category_model.dart).

create table if not exists public.wealth_custom_categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  icon_key text not null default 'category',
  created_at timestamptz not null default now()
);

alter table public.wealth_custom_categories enable row level security;

drop policy if exists "wealth_custom_categories_select_own" on public.wealth_custom_categories;
create policy "wealth_custom_categories_select_own"
  on public.wealth_custom_categories for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_custom_categories_insert_own" on public.wealth_custom_categories;
create policy "wealth_custom_categories_insert_own"
  on public.wealth_custom_categories for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_custom_categories_update_own" on public.wealth_custom_categories;
create policy "wealth_custom_categories_update_own"
  on public.wealth_custom_categories for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "wealth_custom_categories_delete_own" on public.wealth_custom_categories;
create policy "wealth_custom_categories_delete_own"
  on public.wealth_custom_categories for delete
  using (auth.uid() = user_id);
