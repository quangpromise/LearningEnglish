-- Football Center - toan bo bang du lieu cho tinh nang xem bong da (live
-- score, bang xep hang, lich thi dau, doi yeu thich, thong bao su kien).
-- Xem ke hoach day du: docs/football-center-plan.md
--
-- HAI NGUON DU LIEU, moi ben lam dung viec no manh (da test that 2026-09-20,
-- xem muc B1 cua file ke hoach):
--   * Highlightly (bac Basic mien phi, 100 req/ngay) - bang xep hang mua
--     hien tai + lich thi dau MOI ngay (qua khu lan tuong lai) + doi hinh +
--     thong ke. La nguon CHINH, id cua no la id chuan trong cac bang duoi.
--   * API-Football (bac Free 100 req/ngay) - CHI dung `fixtures?live=all`:
--     1 call tra ve MOI tran dang da kem su kien. Highlightly khong co
--     endpoint tuong duong nen phan live bat buoc dung ben nay.
-- Bac Free cua API-Football chan mua giai hien tai o moi endpoint co tham so
-- `season` (loi nguyen van: "Free plans do not have access to this season,
-- try from 2022 to 2024") - do do KHONG dung no cho bang xep hang/lich.
--
-- VI SAO APP DOC THANG BANG NAY (khong qua Edge Function nhu ban ke hoach
-- dau): cac bang duoi chi chua du lieu DA dong bo san, khong dinh API key
-- nao ca - nen cho client doc truc tiep qua PostgREST + RLS gon hon han, va
-- dung duoc Supabase Realtime de man Live tu cap nhat khi co ban thang moi
-- (giong todo_tasks/planner_tasks dang lam). Edge Function chi con lam 1
-- viec: GOI API ben ngoai va GHI vao day (service role, bypass RLS).

-- ---------------------------------------------------------------------------
-- 1. Chuan hoa ten de GHEP du lieu giua 2 nguon
-- ---------------------------------------------------------------------------
-- 2 nha cung cap dat ten doi khac nhau ("Manchester United FC" vs
-- "Manchester United" vs "Man United") va id hoan toan khong lien quan. Khi
-- API-Football bao 1 tran dang da, ta phai tim dung dong fixture da dong bo
-- tu Highlightly - ghep bang (gio bong lan +-15 phut, ten 2 doi da chuan
-- hoa). Ham nay phai IMMUTABLE de dung duoc trong index.
-- Postgres cua Supabase co the chua bat extension `unaccent`. Boc them 1
-- lop de migration khong vo neu thieu: co unaccent thi dung, khong thi tra
-- ve nguyen chuoi (ten CLB 6 giai lon gan nhu khong dau nen van ghep duoc).
-- PHAI dinh nghia TRUOC football_name_key vi ham do goi toi no.
create or replace function public.unaccent_safe(input text)
returns text
language plpgsql
immutable
as $$
begin
  return unaccent(input);
exception
  when undefined_function then
    return input;
end;
$$;

create or replace function public.football_name_key(input text)
returns text
language sql
immutable
as $$
  select regexp_replace(
    regexp_replace(
      lower(public.unaccent_safe(coalesce(input, ''))),
      -- Bo cac hau to/tien to CLB pho bien truoc khi so khop
      '\m(fc|afc|cf|sc|ac|as|ss|ssc|us|rc|cd|ud|club|team)\M', '', 'g'
    ),
    '[^a-z0-9]', '', 'g'
  );
$$;

-- ---------------------------------------------------------------------------
-- 2. Giai dau - THEM GIAI MOI = THEM 1 DONG, khong sua code
-- ---------------------------------------------------------------------------
create table if not exists public.football_competitions (
  id bigint primary key,                    -- id cua Highlightly
  api_football_league_id integer,           -- id ben API-Football (loc live)
  slug text not null unique,                -- 'premier-league', dung lam khoa i18n
  name text not null,
  country_name text,
  country_code text,
  logo_url text,
  priority smallint not null default 100,   -- thu tu hien o man Home, nho = tren
  is_enabled boolean not null default true, -- tat 1 giai ma khong can xoa du lieu
  current_season integer,
  updated_at timestamptz not null default now()
);

alter table public.football_competitions enable row level security;
drop policy if exists "football_competitions_read" on public.football_competitions;
create policy "football_competitions_read"
  on public.football_competitions for select
  to authenticated
  using (true);

-- CHI gieo san giai da xac minh id that (Premier League England = 33973,
-- lay tu `/football/leagues` ngay 2026-09-20). 5 giai con lai KHONG gieo id
-- gia o day: id la khoa chinh va se co fixtures tro toi, doi id sau nay rat
-- ruc roi. Thay vao do danh sach "giai can co" nam o football_config key
-- `league_seeds` ben duoi - Edge Function football-sync doc danh sach do,
-- tim id that theo ten + quoc gia roi INSERT vao bang nay.
insert into public.football_competitions
  (id, api_football_league_id, slug, name, country_name, country_code, priority)
values
  (33973, 39, 'premier-league', 'Premier League', 'England', 'GB-ENG', 10)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 3. Doi bong
-- ---------------------------------------------------------------------------
create table if not exists public.football_teams (
  id bigint primary key,                    -- id Highlightly
  name text not null,
  short_name text,
  logo_url text,                            -- HOTLINK CDN nha cung cap, KHONG tu host
  country_name text,
  name_key text generated always as (public.football_name_key(name)) stored,
  updated_at timestamptz not null default now()
);

create index if not exists football_teams_name_key_idx on public.football_teams (name_key);

alter table public.football_teams enable row level security;
drop policy if exists "football_teams_read" on public.football_teams;
create policy "football_teams_read"
  on public.football_teams for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- 4. Tran dau
-- ---------------------------------------------------------------------------
-- `kickoff_at` luon luu UTC (timestamptz) - app tu doi sang mui gio may
-- nguoi dung khi hien thi, dung yeu cau muc 18 cua de bai.
create table if not exists public.football_fixtures (
  id bigint primary key,                    -- id Highlightly
  api_football_fixture_id bigint unique,    -- dien vao khi ghep duoc voi ban live
  competition_id bigint references public.football_competitions (id) on delete cascade,
  season integer,
  round text,
  kickoff_at timestamptz not null,
  status_short text,                        -- 'NS' | '1H' | 'HT' | '2H' | 'FT' | 'PST' | 'CANC'...
  status_long text,
  elapsed smallint,
  home_team_id bigint references public.football_teams (id),
  away_team_id bigint references public.football_teams (id),
  home_goals smallint,
  away_goals smallint,
  venue text,
  -- Giu nguyen ban tho de sau nay them truong moi khong can migration
  raw jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists football_fixtures_kickoff_idx
  on public.football_fixtures (kickoff_at desc);
create index if not exists football_fixtures_competition_idx
  on public.football_fixtures (competition_id, kickoff_at desc);
-- Tra cuu nhanh "tran nao dang da" cho worker live
create index if not exists football_fixtures_live_idx
  on public.football_fixtures (status_short)
  where status_short in ('1H', 'HT', '2H', 'ET', 'BT', 'P', 'LIVE');

alter table public.football_fixtures enable row level security;
drop policy if exists "football_fixtures_read" on public.football_fixtures;
create policy "football_fixtures_read"
  on public.football_fixtures for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- 5. Bang xep hang
-- ---------------------------------------------------------------------------
-- `group_label` cho giai co nhieu bang / league phase (Champions League tu
-- 2024/25 la 1 bang 36 doi nen chi co 1 group, nhung giu cot nay de khong
-- phai migration khi them giai co bang A-H).
--
-- KHONG luu cot "hieu so": tinh truc tiep tu goals_for - goals_against (2
-- nguon deu khong tra san). Cung KHONG luu thu hang tu tinh - lay thang
-- `position` cua nha cung cap, vi quy tac xep hang PHU khac nhau tung giai
-- (La Liga/Serie A xep theo doi dau truc tiep, Premier League theo hieu so)
-- va tu tinh sai la lech ca bang - xem docs/research-football-standings-source.md §6.
create table if not exists public.football_standings (
  competition_id bigint not null references public.football_competitions (id) on delete cascade,
  season integer not null,
  team_id bigint not null references public.football_teams (id),
  group_label text not null default '',
  position smallint not null,
  played smallint not null default 0,
  wins smallint not null default 0,
  draws smallint not null default 0,
  losses smallint not null default 0,
  goals_for smallint not null default 0,
  goals_against smallint not null default 0,
  points smallint not null default 0,
  form text,                                -- 'TTHBT' - suy tu 5 tran gan nhat
  updated_at timestamptz not null default now(),
  primary key (competition_id, season, group_label, team_id)
);

alter table public.football_standings enable row level security;
drop policy if exists "football_standings_read" on public.football_standings;
create policy "football_standings_read"
  on public.football_standings for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- 6. Su kien trong tran - CHONG TRUNG bang event_key
-- ---------------------------------------------------------------------------
-- API-Football KHONG cap id on dinh cho tung su kien, va cung 1 ban thang co
-- the xuat hien nhieu lan qua cac lan poll. `event_key` la dau van tay cua
-- su kien (loai + phut + doi + cau thu) - khoa chinh ghep voi fixture nen
-- upsert bao nhieu lan cung chi ra 1 dong. Yeu cau muc 6 + 14 cua de bai.
create table if not exists public.football_match_events (
  fixture_id bigint not null references public.football_fixtures (id) on delete cascade,
  event_key text not null,
  type text not null,                       -- 'Goal' | 'Card' | 'subst' | 'Var'
  detail text,                              -- 'Normal Goal' | 'Yellow Card' | 'Red Card'...
  elapsed smallint,
  elapsed_extra smallint,
  team_id bigint references public.football_teams (id),
  team_name text,                           -- giu ten tho phong khi chua map duoc team
  player_name text,
  assist_name text,
  raw jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  primary key (fixture_id, event_key)
);

create index if not exists football_match_events_fixture_idx
  on public.football_match_events (fixture_id, elapsed);

alter table public.football_match_events enable row level security;
drop policy if exists "football_match_events_read" on public.football_match_events;
create policy "football_match_events_read"
  on public.football_match_events for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- 7. Thong ke + doi hinh (1 dong / 1 doi / 1 tran)
-- ---------------------------------------------------------------------------
create table if not exists public.football_match_stats (
  fixture_id bigint not null references public.football_fixtures (id) on delete cascade,
  team_id bigint not null references public.football_teams (id),
  -- Danh sach chi so nguyen ban cua nha cung cap: [{"name":"Ball Possession",
  -- "value":56}, ...]. KHONG tach thanh cot rieng vi moi nguon tra 1 bo chi
  -- so khac nhau (Highlightly co them Expected Goals) va de bai yeu cau hien
  -- "cac statistics khac ma API cung cap".
  stats jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (fixture_id, team_id)
);

alter table public.football_match_stats enable row level security;
drop policy if exists "football_match_stats_read" on public.football_match_stats;
create policy "football_match_stats_read"
  on public.football_match_stats for select
  to authenticated
  using (true);

create table if not exists public.football_lineups (
  fixture_id bigint not null references public.football_fixtures (id) on delete cascade,
  team_id bigint not null references public.football_teams (id),
  formation text,                           -- '4-3-3'
  starters jsonb not null default '[]'::jsonb,
  substitutes jsonb not null default '[]'::jsonb,
  coach_name text,
  updated_at timestamptz not null default now(),
  primary key (fixture_id, team_id)
);

alter table public.football_lineups enable row level security;
drop policy if exists "football_lineups_read" on public.football_lineups;
create policy "football_lineups_read"
  on public.football_lineups for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- 8. Doi yeu thich + tuy chon thong bao (theo tung user)
-- ---------------------------------------------------------------------------
create table if not exists public.football_favorite_teams (
  user_id uuid not null references public.profiles (id) on delete cascade,
  team_id bigint not null references public.football_teams (id) on delete cascade,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, team_id)
);

create index if not exists football_favorite_teams_team_idx
  on public.football_favorite_teams (team_id);

alter table public.football_favorite_teams enable row level security;

drop policy if exists "football_favorite_teams_select_own" on public.football_favorite_teams;
create policy "football_favorite_teams_select_own"
  on public.football_favorite_teams for select
  using (auth.uid() = user_id);

drop policy if exists "football_favorite_teams_insert_own" on public.football_favorite_teams;
create policy "football_favorite_teams_insert_own"
  on public.football_favorite_teams for insert
  with check (auth.uid() = user_id);

drop policy if exists "football_favorite_teams_update_own" on public.football_favorite_teams;
create policy "football_favorite_teams_update_own"
  on public.football_favorite_teams for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "football_favorite_teams_delete_own" on public.football_favorite_teams;
create policy "football_favorite_teams_delete_own"
  on public.football_favorite_teams for delete
  using (auth.uid() = user_id);

-- 1 dong / user. Mac dinh BAT cac loai quan trong, TAT thay nguoi (de bai
-- muc 7: cho phep bat/tat tung loai).
create table if not exists public.football_notification_prefs (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  goal boolean not null default true,
  yellow_card boolean not null default true,
  red_card boolean not null default true,
  substitution boolean not null default false,
  match_started boolean not null default true,
  half_time boolean not null default false,
  match_finished boolean not null default true,
  lineup_available boolean not null default true,
  fixture_reminder boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.football_notification_prefs enable row level security;

drop policy if exists "football_notification_prefs_select_own" on public.football_notification_prefs;
create policy "football_notification_prefs_select_own"
  on public.football_notification_prefs for select
  using (auth.uid() = user_id);

drop policy if exists "football_notification_prefs_upsert_own" on public.football_notification_prefs;
create policy "football_notification_prefs_upsert_own"
  on public.football_notification_prefs for insert
  with check (auth.uid() = user_id);

drop policy if exists "football_notification_prefs_update_own" on public.football_notification_prefs;
create policy "football_notification_prefs_update_own"
  on public.football_notification_prefs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 8b. Nhat ky dong bo lich theo NGAY
-- ---------------------------------------------------------------------------
-- Cua so lich la 38 ngay (7 ngay truoc + 30 ngay sau) x 6 giai = 228 luot
-- goi neu dong bo tat ca moi lan chay -> vuot xa han muc 100/ngay. Bang nay
-- ghi lai "(giai, ngay) nay dong bo luc nao" de moi lan chay chi lam nhung
-- o CU NHAT con thieu:
--   * 3 ngay quanh hom nay (hom qua/hom nay/ngay mai): lam moi moi lan chay,
--     vi ti so va gio thi dau con doi.
--   * Cac ngay xa: lich hiem khi doi, lam moi khi qua 7 ngay chua dong bo.
create table if not exists public.football_sync_state (
  competition_id bigint not null references public.football_competitions (id) on delete cascade,
  day date not null,
  synced_at timestamptz not null default now(),
  match_count smallint not null default 0,
  primary key (competition_id, day)
);

alter table public.football_sync_state enable row level security;

-- ---------------------------------------------------------------------------
-- 9. Chong gui trung push
-- ---------------------------------------------------------------------------
-- Khac `football_match_events` (chong trung DU LIEU), bang nay chong trung
-- HANH DONG GUI: 1 su kien chi duoc bien thanh thong bao dung 1 lan, ke ca
-- khi worker chay lai hay API tra ve su kien do o nhieu lan poll lien tiep.
-- Chi Edge Function (service role) dung bang nay -> khong co policy nao.
create table if not exists public.football_push_state (
  fixture_id bigint not null,
  event_key text not null,
  pushed_at timestamptz not null default now(),
  primary key (fixture_id, event_key)
);

alter table public.football_push_state enable row level security;

-- ---------------------------------------------------------------------------
-- 10. Bo dem quota - THU BAO VE QUAN TRONG NHAT o bac mien phi
-- ---------------------------------------------------------------------------
-- Ca 2 nguon deu chi cho 100 request/NGAY. Neu 1 vong lap loi lam goi lien
-- tuc thi het quota trong vai phut va app "chet" ca ngay hom do. Moi loi goi
-- ra ben ngoai deu phai xin phep qua ham football_spend() ben duoi.
--
-- `day` la ngay theo UTC vi API-Football reset quota luc 00h00 UTC (da xac
-- nhan tren dashboard) - dung ngay dia phuong se lech.
create table if not exists public.football_api_budget (
  provider text not null check (provider in ('highlightly', 'api_football')),
  day date not null,
  used integer not null default 0,
  daily_limit integer not null default 100,
  updated_at timestamptz not null default now(),
  primary key (provider, day)
);

alter table public.football_api_budget enable row level security;

-- Xin `amount` luot goi cho `provider` trong ngay UTC hien tai.
-- Tra ve TRUE = duoc phep goi (da tru quota), FALSE = het han muc.
-- Atomic: dung 1 cau INSERT ... ON CONFLICT nen 2 worker chay song song
-- khong the cung tieu qua han muc.
create or replace function public.football_spend(
  p_provider text,
  p_amount integer default 1
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ok boolean;
begin
  -- Meo: dat dieu kien vao WHERE cua DO UPDATE. Con han muc -> dong duoc
  -- cap nhat -> RETURNING tra ve 1 dong -> v_ok = true. Het han muc ->
  -- KHONG dong nao duoc cap nhat -> RETURNING rong -> v_ok giu nguyen null
  -- -> tra ve false. Tat ca trong 1 cau lenh nen 2 worker chay song song
  -- khong the cung tieu qua han muc.
  insert into public.football_api_budget (provider, day, used)
  values (p_provider, (now() at time zone 'utc')::date, p_amount)
  on conflict (provider, day) do update
    set used = public.football_api_budget.used + p_amount,
        updated_at = now()
    where public.football_api_budget.used + p_amount
          <= public.football_api_budget.daily_limit
  returning true into v_ok;

  return coalesce(v_ok, false);
end;
$$;

-- Con bao nhieu luot goi hom nay - dung de worker biet co nen bat dau 1
-- vong quet ton nhieu call hay khong.
create or replace function public.football_budget_left(p_provider text)
returns integer
language sql
stable
as $$
  select coalesce(
    (select daily_limit - used
       from public.football_api_budget
      where provider = p_provider
        and day = (now() at time zone 'utc')::date),
    100
  );
$$;

-- ---------------------------------------------------------------------------
-- 11. Cau hinh chay - doi nhip poll KHONG can deploy lai code
-- ---------------------------------------------------------------------------
-- Nang cap goi tra phi sau nay = doi `daily_limit` o bang tren + `live_poll_
-- seconds` o day, khong dong vao code Edge Function.
create table if not exists public.football_config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.football_config enable row level security;
drop policy if exists "football_config_read" on public.football_config;
create policy "football_config_read"
  on public.football_config for select
  to authenticated
  using (true);

-- `league_seeds`: danh sach giai can dong bo. Edge Function football-sync
-- tra ten+quoc gia ra id that cua Highlightly roi tu them vao
-- football_competitions. THEM GIAI MOI = them 1 phan tu vao mang nay, khong
-- sua code, khong migration.
insert into public.football_config (key, value) values
  ('league_seeds', '[
     {"slug":"premier-league",   "name":"Premier League",        "country":"England", "apiFootballId":39,  "priority":10},
     {"slug":"la-liga",          "name":"La Liga",               "country":"Spain",   "apiFootballId":140, "priority":20},
     {"slug":"serie-a",          "name":"Serie A",               "country":"Italy",   "apiFootballId":135, "priority":30},
     {"slug":"bundesliga",       "name":"Bundesliga",            "country":"Germany", "apiFootballId":78,  "priority":40},
     {"slug":"ligue-1",          "name":"Ligue 1",               "country":"France",  "apiFootballId":61,  "priority":50},
     {"slug":"champions-league", "name":"UEFA Champions League", "country":"World",   "apiFootballId":2,   "priority":60}
   ]'::jsonb),
  ('live_poll_seconds',      '180'::jsonb),
  ('standings_ttl_hours',    '12'::jsonb),
  ('fixtures_sync_days_ahead', '30'::jsonb),
  ('fixtures_sync_days_back',  '7'::jsonb),
  ('current_season',         '2026'::jsonb)
on conflict (key) do nothing;

-- ---------------------------------------------------------------------------
-- 12. Realtime cho man Live
-- ---------------------------------------------------------------------------
-- App dang ky Supabase Realtime tren 2 bang nay de timeline tu cap nhat khi
-- worker ghi ban thang moi - khong can app tu hoi lai server.
do $$
begin
  alter publication supabase_realtime add table public.football_match_events;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.football_fixtures;
exception when duplicate_object then null;
end $$;
