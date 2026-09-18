-- Lich su GIA TRI danh muc dau tu theo thoi gian, de ve bieu do "Tong tai
-- san dau tu" kieu chart coin (xem app/lib/features/wealth/presentation/
-- investment_value_chart.dart).
--
-- TAI SAO PHAI CO BANG NAY: totalInvestmentValueVndProvider tinh tong HOAN
-- TOAN TUC THOI tu gia song (crypto WebSocket, vang, ty gia) nhan voi so
-- luong dang nam giu - khong o dau trong app luu lai gia tri cua ngay hom
-- qua. Khong the dung lai lich su tu du lieu co san: tai san gom 4 nhom
-- nguon gia khac nhau, rieng Vang va Nha dat khong co API lich su nao.
-- Nen bieu do chi co the ve tu nhung moc app TU GHI LAI ke tu bay gio.
--
-- 1 dong = 1 lan do (app ghi toi da 1 lan/gio - xem
-- WealthInvestmentSnapshotRepository.record). Khoa chinh ghep (user_id,
-- taken_at) de 2 may cua cung 1 nguoi ghi cung luc khong de len nhau.
create table if not exists public.wealth_investment_snapshots (
  user_id uuid not null references public.profiles (id) on delete cascade,
  taken_at timestamptz not null default now(),
  -- Tong gia tri quy doi VND tai thoi diem do.
  value_vnd double precision not null,
  -- Tach theo tung nhom de sau nay ve duoc bieu do co cau ma khong phai
  -- them migration: crypto / stock / gold / real_estate.
  breakdown jsonb not null default '{}'::jsonb,
  primary key (user_id, taken_at)
);

create index if not exists wealth_investment_snapshots_user_time_idx
  on public.wealth_investment_snapshots (user_id, taken_at desc);

alter table public.wealth_investment_snapshots enable row level security;

drop policy if exists "wealth_investment_snapshots_select_own"
  on public.wealth_investment_snapshots;
create policy "wealth_investment_snapshots_select_own"
  on public.wealth_investment_snapshots for select
  using (auth.uid() = user_id);

drop policy if exists "wealth_investment_snapshots_insert_own"
  on public.wealth_investment_snapshots;
create policy "wealth_investment_snapshots_insert_own"
  on public.wealth_investment_snapshots for insert
  with check (auth.uid() = user_id);

drop policy if exists "wealth_investment_snapshots_delete_own"
  on public.wealth_investment_snapshots;
create policy "wealth_investment_snapshots_delete_own"
  on public.wealth_investment_snapshots for delete
  using (auth.uid() = user_id);
