-- Go bo hoan toan tinh nang Football Center (them o 0070_football.sql) theo
-- yeu cau chu du an ngay 2026-09-21.
--
-- Da go truoc do, ngoai migration nay:
--   * 4 Edge Function (football-sync, football-live, football-match,
--     football-reminders) - xoa khoi project bang `supabase functions delete`.
--   * 3 workflow cron trong .github/workflows/.
--   * Toan bo module app/lib/features/football/ + muc trong menu
--     AssistiveTouch + chuoi i18n + nhanh thong bao trong chat_push.dart.
--
-- THU TU XOA: bang con truoc, bang cha sau. Thuc ra moi khoa ngoai deu co
-- `on delete cascade` va `drop ... cascade` cung tu lo duoc, nhung viet ro
-- thu tu de doc lai con hieu bang nao phu thuoc bang nao.

-- Go khoi ban phat Realtime truoc khi xoa bang (xoa bang van chay duoc neu
-- quen, nhung de lai ban ghi rac trong publication).
do $$
begin
  alter publication supabase_realtime drop table public.football_match_events;
exception when others then null;
end $$;

do $$
begin
  alter publication supabase_realtime drop table public.football_fixtures;
exception when others then null;
end $$;

drop table if exists public.football_push_state;
drop table if exists public.football_notification_prefs;
drop table if exists public.football_favorite_teams;
drop table if exists public.football_match_stats;
drop table if exists public.football_lineups;
drop table if exists public.football_match_events;
drop table if exists public.football_standings;
drop table if exists public.football_sync_state;
drop table if exists public.football_fixtures;
drop table if exists public.football_teams;
drop table if exists public.football_competitions;
drop table if exists public.football_api_budget;
drop table if exists public.football_config;

drop function if exists public.football_spend(text, integer);
drop function if exists public.football_budget_left(text);
drop function if exists public.football_name_key(text);

-- `unaccent_safe` cung do 0070 tao ra nhung la ham DUNG CHUNG (bo unaccent
-- lai de khong vo khi thieu extension) - giu lai phong khi co cho khac da
-- dung toi. Khong ton gi, va xoa nham thi vo cho do.
