// Edge Function: lay DOI HINH + THONG KE cua 1 tran tu Highlightly.
//
// KHAC 2 ham football-sync/football-live (chay theo lich): ham nay duoc goi
// TU APP, dung luc nguoi dung mo tab Doi hinh/Thong ke cua Match Center.
//
// VI SAO KHONG DONG BO SAN: 2 endpoint nay tinh theo TUNG TRAN. Cuoi tuan 6
// giai co ~50 tran, lay truoc het la 100 request - dung bang han muc ca ngay
// cua bac Basic, trong khi nguoi dung thuc te chi mo vai tran. Lay theo nhu
// cau + cache lai la cach duy nhat vua du du lieu vua khong vo quota.
//
// Ham NAY co verify JWT (khac 2 ham kia dung webhook secret): app goi bang
// token cua nguoi dung dang dang nhap, nen khong can secret rieng va cung
// khong the bi goi boi nguoi la.
//
// Deploy: supabase functions deploy football-match --use-api

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const HIGHLIGHTLY_BASE = 'https://sports.highlightly.net/football';
const HIGHLIGHTLY_KEY = Deno.env.get('HIGHLIGHTLY_KEY');
const PROVIDER = 'highlightly';

/// Da lay trong vong 3 phut thi khong goi lai - chong truong hop nhieu nguoi
/// cung mo 1 tran hot (vd derby) lam no quota trong vai giay.
const FRESH_MS = 3 * 60 * 1000;

async function callProvider(
  admin: SupabaseClient,
  path: string,
): Promise<unknown | null> {
  const { data: allowed } = await admin.rpc('football_spend', {
    p_provider: PROVIDER,
    p_amount: 1,
  });
  if (allowed !== true) return null;
  try {
    const res = await fetch(`${HIGHLIGHTLY_BASE}${path}`, {
      headers: { 'x-rapidapi-key': HIGHLIGHTLY_KEY! },
    });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  if (!HIGHLIGHTLY_KEY) {
    return new Response(JSON.stringify({ ok: false, error: 'Thieu HIGHLIGHTLY_KEY' }), {
      status: 500,
    });
  }

  let fixtureId: number;
  try {
    const body = await req.json();
    fixtureId = Number(body?.fixtureId);
    if (!Number.isFinite(fixtureId)) throw new Error('fixtureId khong hop le');
  } catch {
    return new Response(JSON.stringify({ ok: false, error: 'Thieu fixtureId' }), {
      status: 400,
    });
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // Con tuoi -> tra ve ngay, khong ton request nao.
  const since = new Date(Date.now() - FRESH_MS).toISOString();
  const [{ data: freshLineups }, { data: freshStats }] = await Promise.all([
    admin.from('football_lineups').select('team_id').eq('fixture_id', fixtureId).gt('updated_at', since).limit(1),
    admin.from('football_match_stats').select('team_id').eq('fixture_id', fixtureId).gt('updated_at', since).limit(1),
  ]);
  if (freshLineups?.length && freshStats?.length) {
    return new Response(JSON.stringify({ ok: true, cached: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const [lineupBody, statsBody] = await Promise.all([
    callProvider(admin, `/lineups/${fixtureId}`),
    callProvider(admin, `/statistics/${fixtureId}`),
  ]);

  let savedLineups = 0;
  let savedStats = 0;

  // --- Doi hinh ------------------------------------------------------------
  // Nha cung cap tra ve 1 object co 2 khoa homeTeam/awayTeam, moi ben co
  // formation + initialLineup (mang cac tuyen) + substitutes. `initialLineup`
  // la mang LONG (mang cua tung tuyen) nen phai lam phang.
  if (lineupBody && typeof lineupBody === 'object') {
    const body = lineupBody as Record<string, any>;
    for (const side of ['homeTeam', 'awayTeam']) {
      const entry = body[side];
      if (!entry) continue;
      const teamId = Number(entry?.id ?? entry?.team?.id);
      if (!Number.isFinite(teamId)) continue;

      const initial = entry.initialLineup ?? entry.startXI ?? [];
      const starters = Array.isArray(initial) ? initial.flat() : [];

      const { error } = await admin.from('football_lineups').upsert(
        {
          fixture_id: fixtureId,
          team_id: teamId,
          formation: entry.formation ?? null,
          starters,
          substitutes: entry.substitutes ?? [],
          coach_name: entry.coach?.name ?? null,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'fixture_id,team_id' },
      );
      if (!error) savedLineups++;
    }
  }

  // --- Thong ke ------------------------------------------------------------
  // Tra ve 1 MANG, moi phan tu 1 doi: { team: {...}, statistics: [...] }.
  if (Array.isArray(statsBody)) {
    for (const entry of statsBody as Array<Record<string, any>>) {
      const teamId = Number(entry?.team?.id);
      if (!Number.isFinite(teamId)) continue;
      const { error } = await admin.from('football_match_stats').upsert(
        {
          fixture_id: fixtureId,
          team_id: teamId,
          stats: entry.statistics ?? [],
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'fixture_id,team_id' },
      );
      if (!error) savedStats++;
    }
  }

  return new Response(
    JSON.stringify({ ok: savedLineups > 0 || savedStats > 0, savedLineups, savedStats }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  );
});
