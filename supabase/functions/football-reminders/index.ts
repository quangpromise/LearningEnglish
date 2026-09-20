// Edge Function: 2 loai thong bao TRUOC tran ma football-live khong lo duoc
// (ham do chi nhin cac tran DANG DA):
//   1. `fixture_reminder` - nhac truoc 1 ngay khi doi yeu thich co tran.
//      TU DONG, nguoi dung khong phai tu dat lich (yeu cau muc 8 de bai).
//   2. `lineup_available` - khi doi hinh chinh thuc duoc cong bo (muc 9).
//
// Goi theo lich boi GitHub Actions (football-reminders.yml). Dung chung
// FOOTBALL_WEBHOOK_SECRET voi 2 ham kia.
//
// CHONG GUI TRUNG: dung chung bang football_push_state nhu football-live,
// nhung event_key la khoa TU SINH ('_reminder' / '_lineup') thay vi van tay
// su kien - nen 1 tran chi nhac dung 1 lan du ham chay lai bao nhieu lan.
//
// Deploy: supabase functions deploy football-reminders --no-verify-jwt --use-api

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const HIGHLIGHTLY_BASE = 'https://sports.highlightly.net/football';
const HIGHLIGHTLY_KEY = Deno.env.get('HIGHLIGHTLY_KEY');

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemBody = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const der = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

function base64url(input: ArrayBuffer | string): string {
  const bytes = typeof input === 'string' ? new TextEncoder().encode(input) : new Uint8Array(input);
  let str = '';
  bytes.forEach((b) => (str += String.fromCharCode(b)));
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function getAccessToken(clientEmail: string, privateKeyPem: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const unsigned =
    `${base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))}.` +
    `${base64url(
      JSON.stringify({
        iss: clientEmail,
        scope: 'https://www.googleapis.com/auth/firebase.messaging',
        aud: 'https://oauth2.googleapis.com/token',
        iat: now,
        exp: now + 3600,
      }),
    )}`;
  const key = await importPrivateKey(privateKeyPem);
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${unsigned}.${base64url(sig)}`,
    }),
  });
  if (!res.ok) throw new Error(`Khong lay duoc access token: ${res.status}`);
  return (await res.json()).access_token as string;
}

interface FixtureRow {
  id: number;
  kickoff_at: string;
  home_team_id: number | null;
  away_team_id: number | null;
  status_short: string | null;
}

/** Gui 1 thong bao toi tat ca thiet bi cua nhung user thoa dieu kien. */
async function push(
  admin: SupabaseClient,
  opts: {
    fixtureId: number;
    eventKey: string;
    prefColumn: string;
    teamIds: number[];
    title: string;
    body: string;
    accessToken: string;
    projectId: string;
  },
): Promise<number> {
  const { data: already } = await admin
    .from('football_push_state')
    .select('event_key')
    .eq('fixture_id', opts.fixtureId)
    .eq('event_key', opts.eventKey)
    .maybeSingle();
  if (already) return 0;

  const { data: favs } = await admin
    .from('football_favorite_teams')
    .select('user_id')
    .in('team_id', opts.teamIds);
  const userIds = [...new Set((favs ?? []).map((r: { user_id: string }) => r.user_id))];
  if (userIds.length === 0) {
    // Khong ai theo doi -> danh dau da xu ly de khoi quet lai moi lan chay.
    await admin.from('football_push_state').upsert({
      fixture_id: opts.fixtureId,
      event_key: opts.eventKey,
    });
    return 0;
  }

  const { data: prefsRows } = await admin
    .from('football_notification_prefs')
    .select('*')
    .in('user_id', userIds);
  const prefsByUser = new Map<string, Record<string, boolean>>();
  for (const p of (prefsRows ?? []) as Array<Record<string, any>>) prefsByUser.set(p.user_id, p);

  // Chua co dong prefs = dung mac dinh, ma ca 2 loai nay mac dinh deu BAT
  // (xem migration 0070) - nen chi loai nguoi da TU TAT.
  const wanted = userIds.filter((id) => {
    const p = prefsByUser.get(id);
    return p ? p[opts.prefColumn] !== false : true;
  });
  if (wanted.length === 0) {
    await admin.from('football_push_state').upsert({
      fixture_id: opts.fixtureId,
      event_key: opts.eventKey,
    });
    return 0;
  }

  const { data: tokenRows } = await admin
    .from('device_tokens')
    .select('fcm_token')
    .in('user_id', wanted);
  const tokens = [...new Set((tokenRows ?? []).map((t: { fcm_token: string }) => t.fcm_token))];
  if (tokens.length === 0) return 0;

  const results = await Promise.all(
    tokens.map((token) =>
      fetch(`https://fcm.googleapis.com/v1/projects/${opts.projectId}/messages:send`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${opts.accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token,
            data: {
              type: 'football_event',
              event_type: opts.eventKey === '_lineup' ? 'lineup' : 'reminder',
              fixture_id: String(opts.fixtureId),
              title: opts.title,
              body: opts.body,
            },
            android: { priority: 'high' },
          },
        }),
      })
        .then((r) => r.ok)
        .catch(() => false),
    ),
  );

  const sent = results.filter(Boolean).length;
  // Chi danh dau DA GUI khi that su gui duoc - giong bai hoc cua
  // price-alert-check: ghi state truoc se an luon thong bao neu FCM loi.
  if (sent > 0) {
    await admin.from('football_push_state').upsert({
      fixture_id: opts.fixtureId,
      event_key: opts.eventKey,
    });
  }
  return sent;
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const expected = Deno.env.get('FOOTBALL_WEBHOOK_SECRET');
  if (!expected || req.headers.get('x-webhook-secret') !== expected) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }

  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');
  if (!serviceAccountRaw || !projectId) {
    return new Response(JSON.stringify({ error: 'Chua cau hinh Firebase' }), { status: 500 });
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // Chi quan tam cac doi CO NGUOI theo doi - khong co ai thi khong lam gi ca,
  // khong ton request nao.
  const { data: favTeams } = await admin.from('football_favorite_teams').select('team_id');
  const teamIds = [...new Set((favTeams ?? []).map((r: { team_id: number }) => r.team_id))];
  if (teamIds.length === 0) {
    return new Response(JSON.stringify({ reminders: 0, lineups: 0, note: 'chua ai chon doi' }), {
      status: 200,
    });
  }

  const sa = JSON.parse(serviceAccountRaw);
  const accessToken = await getAccessToken(sa.client_email, sa.private_key);

  const now = Date.now();
  let reminders = 0;
  let lineups = 0;

  // --- 1. Nhac truoc 1 ngay -------------------------------------------------
  // Cua so 22h-26h truoc gio bong lan: rong hon 1 tiếng ve moi phia de khong
  // truot khi cron chay tre (GitHub Actions hay tre vai phut).
  const { data: soon } = await admin
    .from('football_fixtures')
    .select('id, kickoff_at, home_team_id, away_team_id, status_short')
    .gte('kickoff_at', new Date(now + 22 * 3600_000).toISOString())
    .lte('kickoff_at', new Date(now + 26 * 3600_000).toISOString());

  for (const f of (soon ?? []) as FixtureRow[]) {
    const ids = [f.home_team_id, f.away_team_id].filter(Boolean) as number[];
    if (!ids.some((id) => teamIds.includes(id))) continue;

    const { data: teams } = await admin
      .from('football_teams')
      .select('id, name')
      .in('id', ids);
    const nameOf = (id: number | null) =>
      (teams ?? []).find((t: { id: number }) => t.id === id)?.name ?? '?';

    const kickoff = new Date(f.kickoff_at);
    // Gio in trong thong bao la gio VIET NAM (UTC+7): server khong biet mui
    // gio cua tung may, ma phan lon nguoi dung app nay o VN.
    const vn = new Date(kickoff.getTime() + 7 * 3600_000);
    const hh = String(vn.getUTCHours()).padStart(2, '0');
    const mm = String(vn.getUTCMinutes()).padStart(2, '0');

    reminders += await push(admin, {
      fixtureId: f.id,
      eventKey: '_reminder',
      prefColumn: 'fixture_reminder',
      teamIds: ids,
      title: 'Ngày mai có trận đấu',
      body: `${nameOf(f.home_team_id)} vs ${nameOf(f.away_team_id)}\n${hh}:${mm}`,
      accessToken,
      projectId,
    });
  }

  // --- 2. Doi hinh ra san ---------------------------------------------------
  // Doi hinh thuong cong bo ~60 phut truoc gio bong lan -> chi do trong cua
  // so 0-75 phut truoc tran, va chi cho tran cua doi yeu thich. Ngoai cua so
  // do khong goi gi ca de khoi phi quota.
  const { data: nearKickoff } = await admin
    .from('football_fixtures')
    .select('id, kickoff_at, home_team_id, away_team_id, status_short')
    .gte('kickoff_at', new Date(now).toISOString())
    .lte('kickoff_at', new Date(now + 75 * 60_000).toISOString());

  for (const f of (nearKickoff ?? []) as FixtureRow[]) {
    const ids = [f.home_team_id, f.away_team_id].filter(Boolean) as number[];
    if (!ids.some((id) => teamIds.includes(id))) continue;

    // Da bao roi thi khong goi API nua.
    const { data: already } = await admin
      .from('football_push_state')
      .select('event_key')
      .eq('fixture_id', f.id)
      .eq('event_key', '_lineup')
      .maybeSingle();
    if (already) continue;

    const { data: allowed } = await admin.rpc('football_spend', {
      p_provider: 'highlightly',
      p_amount: 1,
    });
    if (allowed !== true) break; // het quota - de lan chay sau

    let hasLineup = false;
    try {
      const res = await fetch(`${HIGHLIGHTLY_BASE}/lineups/${f.id}`, {
        headers: { 'x-rapidapi-key': HIGHLIGHTLY_KEY! },
      });
      if (res.ok) {
        const body = await res.json();
        hasLineup = Boolean(body?.homeTeam?.formation || body?.awayTeam?.formation);
      }
    } catch {
      hasLineup = false;
    }
    if (!hasLineup) continue;

    const { data: teams } = await admin
      .from('football_teams')
      .select('id, name')
      .in('id', ids);
    const nameOf = (id: number | null) =>
      (teams ?? []).find((t: { id: number }) => t.id === id)?.name ?? '?';

    lineups += await push(admin, {
      fixtureId: f.id,
      eventKey: '_lineup',
      prefColumn: 'lineup_available',
      teamIds: ids,
      title: 'ĐỘI HÌNH ĐÃ RA!',
      body: `${nameOf(f.home_team_id)} vs ${nameOf(f.away_team_id)}\nXem đội hình chính thức`,
      accessToken,
      projectId,
    });
  }

  return new Response(JSON.stringify({ reminders, lineups }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
