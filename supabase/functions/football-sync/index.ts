// Edge Function: dong bo du lieu bong da TRA CUU tu Highlightly vao Postgres
// - giai dau, doi bong, lich thi dau (qua khu + tuong lai), bang xep hang.
// App KHONG goi ham nay; app doc thang cac bang football_* qua PostgREST
// (xem dau file migration 0070_football.sql). Ham nay chay theo lich, goi
// boi GitHub Actions (.github/workflows/football-sync.yml) giong het
// price-alert-check.
//
// VI SAO KHONG DUNG API-Football cho phan nay: bac Free cua ho chan mua giai
// hien tai o moi endpoint co tham so `season` ("Free plans do not have access
// to this season, try from 2022 to 2024") va chi cho lay lich trong cua so
// +-1 ngay. Highlightly bac Basic (mien phi) khong chan gi - da test that
// 2026-09-20, xem docs/football-center-plan.md muc B1.
//
// Can 2 secret (supabase secrets set ...):
//   HIGHLIGHTLY_KEY              - khoa API Highlightly (header x-rapidapi-key)
//   FOOTBALL_WEBHOOK_SECRET      - chuoi bi mat tu chon, PHAI khop voi secret
//                                  cung ten ben GitHub Actions
// SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY la bien moi truong co san.
//
// Deploy: supabase functions deploy football-sync --no-verify-jwt --use-api

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const HIGHLIGHTLY_BASE = 'https://sports.highlightly.net/football';
const HIGHLIGHTLY_KEY = Deno.env.get('HIGHLIGHTLY_KEY');

// Bac Basic cho 100 request/ngay. Moi lan goi ra ngoai deu phai xin phep qua
// football_spend() - het han muc thi DUNG, khong goi nua (thay vi de 1 vong
// lap loi dot sach quota trong vai phut roi app "chet" ca ngay).
const PROVIDER = 'highlightly';

interface LeagueSeed {
  slug: string;
  name: string;
  country: string;
  apiFootballId: number;
  priority: number;
}

/** Doc 1 khoa cau hinh trong football_config (doi nhip chay khong can deploy). */
async function readConfig<T>(admin: SupabaseClient, key: string, fallback: T): Promise<T> {
  const { data } = await admin.from('football_config').select('value').eq('key', key).maybeSingle();
  return (data?.value as T) ?? fallback;
}

/**
 * Goi Highlightly SAU KHI da tru quota. Tra ve null khi het han muc hoac loi
 * mang - moi cho goi deu phai xu ly null, KHONG duoc nem loi lam hong ca lan
 * dong bo (dong bo duoc 5/6 giai van hon khong duoc giai nao).
 */
async function call(
  admin: SupabaseClient,
  path: string,
  params: Record<string, string | number | undefined>,
): Promise<unknown | null> {
  const { data: allowed } = await admin.rpc('football_spend', {
    p_provider: PROVIDER,
    p_amount: 1,
  });
  if (allowed !== true) {
    console.warn(`[football-sync] Het quota ${PROVIDER} hom nay, bo qua ${path}`);
    return null;
  }

  const qs = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== null && v !== '') qs.set(k, String(v));
  }
  try {
    const res = await fetch(`${HIGHLIGHTLY_BASE}${path}?${qs}`, {
      headers: { 'x-rapidapi-key': HIGHLIGHTLY_KEY! },
    });
    if (!res.ok) {
      console.error(`[football-sync] ${path} tra ve ${res.status}`);
      return null;
    }
    return await res.json();
  } catch (err) {
    console.error(`[football-sync] ${path} loi mang:`, err);
    return null;
  }
}

/**
 * Buoc 1: bao dam moi giai trong `league_seeds` da co dong that trong
 * football_competitions. Giai nao da co id thi BO QUA (khong ton request) -
 * nen buoc nay chi that su goi API o lan chay dau tien.
 */
async function ensureCompetitions(admin: SupabaseClient): Promise<void> {
  const seeds = await readConfig<LeagueSeed[]>(admin, 'league_seeds', []);
  const { data: existing } = await admin.from('football_competitions').select('slug');
  const have = new Set((existing ?? []).map((r: { slug: string }) => r.slug));

  for (const seed of seeds) {
    if (have.has(seed.slug)) continue;

    const body = (await call(admin, '/leagues', {
      leagueName: seed.name,
      limit: 100,
    })) as { data?: Array<Record<string, any>> } | null;
    if (!body?.data?.length) continue;

    // Ten giai bi trung o rat nhieu nuoc ("Premier League" co o England,
    // Wales, Belarus, Ai Cap, Nga, Ukraine...) - BAT BUOC loc them quoc gia,
    // neu khong se dong bo nham giai Belarus vao o Premier League.
    const match = body.data.find(
      (l) =>
        String(l?.country?.name ?? '').toLowerCase() === seed.country.toLowerCase() ||
        // Champions League khong thuoc quoc gia nao - Highlightly de
        // "World"/"Europe" tuy giai, nen chap nhan ca 2.
        (seed.country === 'World' &&
          ['world', 'europe'].includes(String(l?.country?.name ?? '').toLowerCase())),
    );
    if (!match) {
      console.warn(`[football-sync] Khong tim thay giai ${seed.name} (${seed.country})`);
      continue;
    }

    await admin.from('football_competitions').upsert({
      id: match.id,
      api_football_league_id: seed.apiFootballId,
      slug: seed.slug,
      name: match.name ?? seed.name,
      country_name: match.country?.name ?? seed.country,
      country_code: match.country?.code ?? null,
      logo_url: match.logo ?? null,
      priority: seed.priority,
      updated_at: new Date().toISOString(),
    });
  }
}

/** Luu doi bong (upsert theo id) - goi truoc khi luu fixture tro toi no. */
async function upsertTeams(admin: SupabaseClient, teams: Array<Record<string, any>>): Promise<void> {
  const unique = new Map<number, Record<string, any>>();
  for (const t of teams) {
    if (t?.id != null) unique.set(Number(t.id), t);
  }
  if (unique.size === 0) return;
  await admin.from('football_teams').upsert(
    [...unique.values()].map((t) => ({
      id: Number(t.id),
      name: String(t.name ?? ''),
      // KHONG tai anh ve tu host: logo CLB la nhan hieu cua CLB, khong nha
      // cung cap nao cap quyen - hotlink CDN cua ho va app tu roi ve huy
      // hieu viet tat khi anh loi (xem docs/research-football-standings-source.md).
      logo_url: t.logo ?? null,
      updated_at: new Date().toISOString(),
    })),
    { onConflict: 'id' },
  );
}

/** Chuyen trang thai cua Highlightly ve ma ngan giong API-Football. */
function statusShort(description: string | undefined): string {
  const d = (description ?? '').toLowerCase();
  if (d.includes('not started')) return 'NS';
  if (d.includes('half') && d.includes('first')) return '1H';
  if (d.includes('half') && d.includes('second')) return '2H';
  if (d === 'halftime' || d.includes('half time')) return 'HT';
  if (d.includes('extra')) return 'ET';
  if (d.includes('penalt')) return 'P';
  if (d.includes('finished') || d.includes('ended')) return 'FT';
  if (d.includes('postpon')) return 'PST';
  if (d.includes('cancel')) return 'CANC';
  if (d.includes('suspend')) return 'SUSP';
  if (d.includes('abandon')) return 'ABD';
  return 'NS';
}

/** "2 - 1" -> [2, 1]; khong parse duoc thi [null, null]. */
function parseScore(current: string | null | undefined): [number | null, number | null] {
  if (!current) return [null, null];
  const m = current.match(/(\d+)\s*-\s*(\d+)/);
  if (!m) return [null, null];
  return [Number(m[1]), Number(m[2])];
}

/** 'YYYY-MM-DD' cua hom nay + offset ngay, theo UTC. */
function utcDay(offset: number): string {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + offset);
  return d.toISOString().slice(0, 10);
}

/**
 * Buoc 2: lich thi dau.
 *
 * Cua so can phu la 38 ngay x 6 giai = 228 o. Goi het moi lan chay se vuot
 * xa han muc 100/ngay, nen chon o theo DO UU TIEN roi cat theo quota:
 *   1. 3 ngay quanh hom nay (hom qua / hom nay / ngay mai) - luon lam moi,
 *      vi ti so chung cuoc va gio thi dau con doi.
 *   2. Cac o CHUA BAO GIO dong bo - lap day dan cua so tuong lai qua nhieu
 *      lan chay thay vi doi hoi mot lan.
 *   3. O da qua 7 ngay chua lam moi - bat cac truong hop doi lich.
 * Nho football_sync_state ma lan chay sau tiep tuc dung cho lan truoc bo do.
 */
async function syncFixtures(admin: SupabaseClient, budgetLeft: number): Promise<number> {
  const season = await readConfig<number>(admin, 'current_season', 2026);
  const daysAhead = await readConfig<number>(admin, 'fixtures_sync_days_ahead', 30);
  const daysBack = await readConfig<number>(admin, 'fixtures_sync_days_back', 7);

  const { data: comps } = await admin
    .from('football_competitions')
    .select('id')
    .eq('is_enabled', true)
    .order('priority');
  if (!comps?.length) return 0;

  const { data: state } = await admin
    .from('football_sync_state')
    .select('competition_id, day, synced_at, match_count');
  const seen = new Map<string, { at: number; count: number }>();
  for (const r of (state ?? []) as Array<{
    competition_id: number;
    day: string;
    synced_at: string;
    match_count: number;
  }>) {
    seen.set(`${r.competition_id}:${r.day}`, {
      at: new Date(r.synced_at).getTime(),
      count: r.match_count ?? 0,
    });
  }

  const now = Date.now();
  const STALE_MS = 7 * 24 * 3600_000;

  // 1 giai chi da ~2 ngay/tuan, nen phan lon o (giai, ngay) la RONG. Neu lan
  // truoc da biet ngay do khong co tran nao thi khong hoi lai ngay - doi it
  // nhat 6 gio. Khong co meo nay thi rieng 3 ngay "gan" da ton 6 giai x 3
  // ngay = 18 call MOI LAN CHAY, x8 lan/ngay = 144 call, vuot han muc 100 va
  // lam phan lich xa khong bao gio lap day duoc.
  const EMPTY_RECHECK_MS = 6 * 3600_000;

  type Cell = { compId: number; day: string; rank: number };
  const cells: Cell[] = [];

  for (const comp of comps as Array<{ id: number }>) {
    for (let offset = -daysBack; offset <= daysAhead; offset++) {
      const day = utcDay(offset);
      const prev = seen.get(`${comp.id}:${day}`);
      const isNear = offset >= -1 && offset <= 1;

      if (prev !== undefined && prev.count === 0 && now - prev.at < EMPTY_RECHECK_MS) {
        continue; // da biet ngay nay khong co tran, vua kiem tra xong
      }

      let rank: number;
      if (isNear) rank = 0;                                // ti so con doi
      else if (prev === undefined) rank = 1;               // chua bao gio co
      else if (now - prev.at > STALE_MS) rank = 2;         // qua cu
      else continue;                                       // con tuoi
      cells.push({ compId: comp.id, day, rank });
    }
  }

  // Uu tien thap hon truoc; cung muc thi ngay gan hom nay truoc.
  cells.sort((a, b) => a.rank - b.rank || a.day.localeCompare(b.day));

  // Chua lai 30% quota cho bang xep hang + cac viec khac.
  let remaining = Math.max(0, Math.floor(budgetLeft * 0.7));
  let saved = 0;

  for (const cell of cells) {
    if (remaining <= 0) break;

    const body = (await call(admin, '/matches', {
      leagueId: cell.compId,
      date: cell.day,
      season,
      limit: 100,
    })) as { data?: Array<Record<string, any>> } | null;
    remaining--;
    // null = het quota hoac loi mang: KHONG ghi sync_state de lan sau lam lai.
    if (body === null) break;

    const matches = body.data ?? [];
    if (matches.length > 0) {
      await upsertTeams(admin, matches.flatMap((m) => [m.homeTeam, m.awayTeam]).filter(Boolean));

      const rows = matches.map((m) => {
        const [hg, ag] = parseScore(m?.state?.score?.current);
        return {
          id: Number(m.id),
          competition_id: cell.compId,
          season,
          round: m.round ?? null,
          kickoff_at: m.date,
          status_short: statusShort(m?.state?.description),
          status_long: m?.state?.description ?? null,
          elapsed: m?.state?.clock ?? null,
          home_team_id: m?.homeTeam?.id != null ? Number(m.homeTeam.id) : null,
          away_team_id: m?.awayTeam?.id != null ? Number(m.awayTeam.id) : null,
          home_goals: hg,
          away_goals: ag,
          venue: m?.venue?.name ?? null,
          raw: m,
          updated_at: new Date().toISOString(),
        };
      });

      const { error } = await admin.from('football_fixtures').upsert(rows, { onConflict: 'id' });
      if (error) console.error('[football-sync] Luu fixture loi:', error.message);
      else saved += rows.length;
    }

    // Ghi nhan ca ngay KHONG co tran nao (match_count = 0) - neu khong se
    // goi lai ngay do mai mai vi tuong chua dong bo.
    await admin.from('football_sync_state').upsert(
      {
        competition_id: cell.compId,
        day: cell.day,
        synced_at: new Date().toISOString(),
        match_count: matches.length,
      },
      { onConflict: 'competition_id,day' },
    );
  }
  return saved;
}

/**
 * Buoc 3: bang xep hang. Re hon fixtures nhieu (1 call/giai) nen chay sau
 * cung nhung uu tien khong bi cat quota - da chua san 30% o tren.
 *
 * KHONG tu tinh thu hang: quy tac xep hang phu khac nhau tung giai (La Liga
 * va Serie A xep theo doi dau truc tiep, Premier League theo hieu so) nen
 * lay thang `position` cua nha cung cap.
 */
async function syncStandings(admin: SupabaseClient): Promise<number> {
  const season = await readConfig<number>(admin, 'current_season', 2026);
  const ttlHours = await readConfig<number>(admin, 'standings_ttl_hours', 12);

  const { data: comps } = await admin
    .from('football_competitions')
    .select('id')
    .eq('is_enabled', true)
    .order('priority');
  if (!comps?.length) return 0;

  const staleBefore = new Date(Date.now() - ttlHours * 3600_000).toISOString();
  let saved = 0;

  for (const comp of comps as Array<{ id: number }>) {
    // Con "tuoi" thi khong goi lai - tiet kiem quota.
    const { data: fresh } = await admin
      .from('football_standings')
      .select('team_id')
      .eq('competition_id', comp.id)
      .eq('season', season)
      .gt('updated_at', staleBefore)
      .limit(1);
    if (fresh?.length) continue;

    const body = (await call(admin, '/standings', {
      leagueId: comp.id,
      season,
    })) as { groups?: Array<Record<string, any>> } | null;
    if (!body?.groups?.length) continue;

    for (const group of body.groups) {
      const rows = (group.standings ?? []) as Array<Record<string, any>>;
      if (!rows.length) continue;

      await upsertTeams(admin, rows.map((r) => r.team).filter(Boolean));

      const { error } = await admin.from('football_standings').upsert(
        rows.map((r) => ({
          competition_id: comp.id,
          season,
          team_id: Number(r?.team?.id),
          group_label: String(group.name ?? ''),
          position: Number(r.position ?? 0),
          // Highlightly tach san total/home/away - ta luu phan `total`.
          played: Number(r?.total?.games ?? 0),
          wins: Number(r?.total?.wins ?? 0),
          draws: Number(r?.total?.draws ?? 0),
          losses: Number(r?.total?.loses ?? 0),
          goals_for: Number(r?.total?.scoredGoals ?? 0),
          goals_against: Number(r?.total?.receivedGoals ?? 0),
          points: Number(r.points ?? 0),
          updated_at: new Date().toISOString(),
        })),
        { onConflict: 'competition_id,season,group_label,team_id' },
      );
      if (error) console.error('[football-sync] Luu BXH loi:', error.message);
      else saved += rows.length;
    }
  }
  return saved;
}

/**
 * Buoc 4: phong do 5 tran gan nhat - KHONG goi them API. Highlightly khong
 * tra cot nay trong /standings, nhung ta da co san ket qua cac tran trong
 * football_fixtures nen tu suy ra, khong ton request nao.
 */
async function computeForm(admin: SupabaseClient): Promise<void> {
  const season = await readConfig<number>(admin, 'current_season', 2026);
  const { data: standings } = await admin
    .from('football_standings')
    .select('competition_id, team_id, group_label')
    .eq('season', season);
  if (!standings?.length) return;

  for (const row of standings as Array<{ competition_id: number; team_id: number; group_label: string }>) {
    const { data: games } = await admin
      .from('football_fixtures')
      .select('home_team_id, away_team_id, home_goals, away_goals')
      .eq('status_short', 'FT')
      .or(`home_team_id.eq.${row.team_id},away_team_id.eq.${row.team_id}`)
      .order('kickoff_at', { ascending: false })
      .limit(5);
    if (!games?.length) continue;

    // Chuoi doc tu TRAN CU NHAT sang moi nhat de doc xuoi tren giao dien.
    const form = [...(games as Array<Record<string, number | null>>)]
      .reverse()
      .map((g) => {
        const isHome = g.home_team_id === row.team_id;
        const mine = isHome ? g.home_goals : g.away_goals;
        const theirs = isHome ? g.away_goals : g.home_goals;
        if (mine == null || theirs == null) return '';
        if (mine > theirs) return 'W';
        if (mine < theirs) return 'L';
        return 'D';
      })
      .join('');

    await admin
      .from('football_standings')
      .update({ form })
      .eq('competition_id', row.competition_id)
      .eq('season', season)
      .eq('group_label', row.group_label)
      .eq('team_id', row.team_id);
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }
  const expectedSecret = Deno.env.get('FOOTBALL_WEBHOOK_SECRET');
  if (!expectedSecret || req.headers.get('x-webhook-secret') !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }
  if (!HIGHLIGHTLY_KEY) {
    return new Response(JSON.stringify({ error: 'Thieu secret HIGHLIGHTLY_KEY' }), { status: 500 });
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: budgetLeft } = await admin.rpc('football_budget_left', { p_provider: PROVIDER });
  const left = typeof budgetLeft === 'number' ? budgetLeft : 100;
  if (left <= 0) {
    return new Response(JSON.stringify({ skipped: 'het quota hom nay' }), { status: 200 });
  }

  await ensureCompetitions(admin);
  const standings = await syncStandings(admin);
  const fixtures = await syncFixtures(admin, left);
  // computeForm quet ~120 dong x 2 truy van = kha nang nang cho DB, ma ket
  // qua chi doi khi bang xep hang hoac ket qua tran vua doi. Bo qua khi lan
  // chay nay khong ghi duoc gi moi.
  if (standings > 0 || fixtures > 0) await computeForm(admin);

  const { data: budgetAfter } = await admin.rpc('football_budget_left', { p_provider: PROVIDER });

  return new Response(
    JSON.stringify({ fixtures, standings, budgetLeft: budgetAfter }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  );
});
