// Edge Function: theo doi cac tran DANG DA va gui push cho nguoi dung co doi
// yeu thich trong tran do. Goi dinh ky boi GitHub Actions
// (.github/workflows/football-live.yml), KHONG goi tu app Flutter - giong
// price-alert-check.
//
// VI SAO PHAN LIVE DUNG API-Football CHU KHONG PHAI HIGHLIGHTLY: endpoint
// `/fixtures?live=all` tra ve MOI tran dang da tren the gioi trong DUNG 1
// request, kem san mang `events` (ban thang, the, thay nguoi). Da test that
// 2026-09-20: 175 tran, 114 tran co events. Highlightly khong co endpoint
// tuong duong (tham so `live` khong ton tai) - muon live phai hoi tung giai
// mot, tuc 6 request moi nhip thay vi 1.
//
// CHONG GUI TRUNG (yeu cau muc 6 + 14 cua de bai): API khong cap id on dinh
// cho su kien, va cung 1 ban thang se xuat hien lai o MOI lan poll. Nen moi
// su kien duoc bam dau van tay `event_key` = loai|phut|doi|cau thu; bang
// football_push_state ghi lai key nao DA gui push -> gui dung 1 lan.
//
// Can 4 secret (3 cai dau da co san tu price-alert-check):
//   FIREBASE_SERVICE_ACCOUNT_JSON
//   FIREBASE_PROJECT_ID
//   FOOTBALL_WEBHOOK_SECRET   - dung chung voi football-sync
//   API_FOOTBALL_KEY          - khoa API-Football (header x-apisports-key)
//
// Deploy: supabase functions deploy football-live --no-verify-jwt --use-api

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const API_FOOTBALL_BASE = 'https://v3.football.api-sports.io';
const PROVIDER = 'api_football';

// ---------------------------------------------------------------------------
// FCM v1 - giong het price-alert-check (khong tach ra file chung vi Edge
// Function moi ham la 1 bundle doc lap, import cheo se pha cach deploy hien tai)
// ---------------------------------------------------------------------------
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
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claims))}`;
  const key = await importPrivateKey(privateKeyPem);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64url(signature)}`;
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`Khong lay duoc access token: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token as string;
}

// ---------------------------------------------------------------------------
// Ghep du lieu giua 2 nha cung cap
// ---------------------------------------------------------------------------
/**
 * Ban TypeScript cua ham SQL public.football_name_key - PHAI giu giong nhau,
 * doi 1 ben ma quen ben kia thi khong ghep duoc doi nao nua.
 */
function nameKey(input: string): string {
  return (input ?? '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\b(fc|afc|cf|sc|ac|as|ss|ssc|us|rc|cd|ud|club|team)\b/g, '')
    .replace(/[^a-z0-9]/g, '');
}

/** Dau van tay cua 1 su kien - xem doc o dau file. */
function eventKey(ev: Record<string, any>): string {
  const parts = [
    ev?.type ?? '',
    ev?.detail ?? '',
    ev?.time?.elapsed ?? '',
    ev?.time?.extra ?? '',
    ev?.team?.id ?? '',
    ev?.player?.name ?? '',
  ];
  return parts.join('|').toLowerCase();
}

interface PushTarget {
  userId: string;
  tokens: string[];
}

/** Loai su kien -> ten cot bat/tat trong football_notification_prefs. */
function prefColumn(type: string, detail: string): string | null {
  const t = (type ?? '').toLowerCase();
  const d = (detail ?? '').toLowerCase();
  if (t === 'goal') return 'goal';
  if (t === 'card' && d.includes('yellow')) return 'yellow_card';
  if (t === 'card' && d.includes('red')) return 'red_card';
  if (t === 'subst') return 'substitution';
  if (t === '_match_started') return 'match_started';
  if (t === '_half_time') return 'half_time';
  if (t === '_match_finished') return 'match_finished';
  return null;
}

/**
 * Mac dinh khi nguoi dung CHUA co dong trong football_notification_prefs -
 * phai khop y het gia tri `default` cua cac cot trong migration 0070, neu
 * lech thi nguoi chua mo man cai dat se nhan thong bao khac han nguoi da mo.
 */
const DEFAULT_PREFS: Record<string, boolean> = {
  goal: true,
  yellow_card: true,
  red_card: true,
  substitution: false,
  match_started: true,
  half_time: false,
  match_finished: true,
  lineup_available: true,
  fixture_reminder: true,
};

/** Tieu de + noi dung thong bao, tieng Viet (app doi ngon ngu o tang hien thi). */
function pushText(
  type: string,
  detail: string,
  ev: Record<string, any>,
  home: string,
  away: string,
  score: string,
): { title: string; body: string } {
  const minute = ev?.time?.elapsed != null ? `${ev.time.elapsed}'` : '';
  const player = ev?.player?.name ?? '';
  const line = `${home} ${score} ${away}`;
  switch (type.toLowerCase()) {
    case 'goal':
      return { title: 'BÀN THẮNG!', body: `${line}\n${player} — ${minute}` };
    case 'card':
      return {
        title: detail.toLowerCase().includes('red') ? 'THẺ ĐỎ' : 'THẺ VÀNG',
        body: `${line}\n${player} — ${minute}`,
      };
    case 'subst':
      return { title: 'THAY NGƯỜI', body: `${line}\n${player} — ${minute}` };
    case '_match_started':
      return { title: 'BẮT ĐẦU TRẬN', body: line };
    case '_half_time':
      return { title: 'HẾT HIỆP 1', body: line };
    case '_match_finished':
      return { title: 'KẾT THÚC TRẬN', body: line };
    default:
      return { title: 'Cập nhật trận đấu', body: line };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });

  const expectedSecret = Deno.env.get('FOOTBALL_WEBHOOK_SECRET');
  if (!expectedSecret || req.headers.get('x-webhook-secret') !== expectedSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret khong khop' }), { status: 401 });
  }
  const apiKey = Deno.env.get('API_FOOTBALL_KEY');
  if (!apiKey) {
    return new Response(JSON.stringify({ error: 'Thieu secret API_FOOTBALL_KEY' }), { status: 500 });
  }

  const admin: SupabaseClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // 1 nhip = dung 1 request. Xin phep truoc, het han muc thi ngung han -
  // tha khong co live con hon dot sach quota roi hong ca ngay.
  const { data: allowed } = await admin.rpc('football_spend', { p_provider: PROVIDER, p_amount: 1 });
  if (allowed !== true) {
    return new Response(JSON.stringify({ skipped: 'het quota api_football hom nay' }), { status: 200 });
  }

  // --- Lay moi tran dang da tren the gioi trong 1 call ---------------------
  let live: Array<Record<string, any>> = [];
  try {
    const res = await fetch(`${API_FOOTBALL_BASE}/fixtures?live=all`, {
      headers: { 'x-apisports-key': apiKey },
    });
    if (!res.ok) throw new Error(`API-Football tra ve ${res.status}`);
    const body = await res.json();
    live = (body?.response ?? []) as Array<Record<string, any>>;
  } catch (err) {
    console.error('[football-live] Goi API that bai:', err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 502 });
  }

  // --- Chi giu tran thuoc giai dang bat ------------------------------------
  const { data: comps } = await admin
    .from('football_competitions')
    .select('id, api_football_league_id')
    .eq('is_enabled', true);
  const leagueMap = new Map<number, number>();
  for (const c of (comps ?? []) as Array<{ id: number; api_football_league_id: number | null }>) {
    if (c.api_football_league_id != null) leagueMap.set(c.api_football_league_id, c.id);
  }
  const relevant = live.filter((f) => leagueMap.has(Number(f?.league?.id)));

  let newEvents = 0;
  let pushed = 0;
  let accessToken: string | null = null;
  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');

  for (const f of relevant) {
    const apiFixtureId = Number(f?.fixture?.id);
    const homeName = String(f?.teams?.home?.name ?? '');
    const awayName = String(f?.teams?.away?.name ?? '');
    const homeGoals = f?.goals?.home ?? null;
    const awayGoals = f?.goals?.away ?? null;
    const status = String(f?.fixture?.status?.short ?? '');
    const elapsed = f?.fixture?.status?.elapsed ?? null;

    // --- Tim dong fixture chuan (da dong bo tu Highlightly) ---------------
    let fixtureRow: { id: number; status_short: string | null } | null = null;

    const { data: byApiId } = await admin
      .from('football_fixtures')
      .select('id, status_short')
      .eq('api_football_fixture_id', apiFixtureId)
      .maybeSingle();
    fixtureRow = byApiId ?? null;

    if (!fixtureRow) {
      // Chua ghep bao gio: doi chieu bang gio bong lan (+-15 phut) va ten 2
      // doi da chuan hoa. Id cua 2 nha cung cap khong lien quan gi nhau nen
      // day la cach duy nhat.
      const kickoff = new Date(f?.fixture?.date ?? Date.now()).getTime();
      const from = new Date(kickoff - 15 * 60_000).toISOString();
      const to = new Date(kickoff + 15 * 60_000).toISOString();

      const { data: candidates } = await admin
        .from('football_fixtures')
        .select('id, status_short, home_team_id, away_team_id')
        .gte('kickoff_at', from)
        .lte('kickoff_at', to)
        .eq('competition_id', leagueMap.get(Number(f.league.id))!);

      // Doc name_key qua 1 truy van rieng cho don gian (so ung vien rat nho).
      for (const cand of (candidates ?? []) as Array<Record<string, any>>) {
        const { data: teams } = await admin
          .from('football_teams')
          .select('id, name_key')
          .in('id', [cand.home_team_id, cand.away_team_id].filter(Boolean));
        const keys = new Set((teams ?? []).map((t: { name_key: string }) => t.name_key));
        if (keys.has(nameKey(homeName)) && keys.has(nameKey(awayName))) {
          fixtureRow = { id: cand.id, status_short: cand.status_short };
          await admin
            .from('football_fixtures')
            .update({ api_football_fixture_id: apiFixtureId })
            .eq('id', cand.id);
          break;
        }
      }
    }

    // Khong ghep duoc (lich chua dong bo toi ngay do) -> bo qua tran nay.
    // Lan chay sau, sau khi football-sync da chay, se ghep duoc.
    if (!fixtureRow) continue;

    const previousStatus = fixtureRow.status_short;

    await admin
      .from('football_fixtures')
      .update({
        status_short: status,
        status_long: f?.fixture?.status?.long ?? null,
        elapsed,
        home_goals: homeGoals,
        away_goals: awayGoals,
        updated_at: new Date().toISOString(),
      })
      .eq('id', fixtureRow.id);

    // --- Gop su kien that + 3 su kien "moc tran" tu sinh -------------------
    const rawEvents = (f?.events ?? []) as Array<Record<string, any>>;
    const synthetic: Array<Record<string, any>> = [];
    const wasNotStarted = previousStatus == null || previousStatus === 'NS';
    if (wasNotStarted && ['1H', 'LIVE'].includes(status)) {
      synthetic.push({ type: '_match_started', time: { elapsed: 0 } });
    }
    if (previousStatus !== 'HT' && status === 'HT') {
      synthetic.push({ type: '_half_time', time: { elapsed: 45 } });
    }
    if (previousStatus !== 'FT' && ['FT', 'AET', 'PEN'].includes(status)) {
      synthetic.push({ type: '_match_finished', time: { elapsed: 90 } });
    }

    const allEvents = [...rawEvents, ...synthetic];
    if (allEvents.length === 0) continue;

    // Luu su kien that (khong luu su kien tu sinh - chung khong phai du lieu
    // cua nha cung cap, chi dung de quyet dinh co push hay khong).
    const eventRows = rawEvents.map((ev) => ({
      fixture_id: fixtureRow!.id,
      event_key: eventKey(ev),
      type: String(ev?.type ?? ''),
      detail: ev?.detail ?? null,
      elapsed: ev?.time?.elapsed ?? null,
      elapsed_extra: ev?.time?.extra ?? null,
      team_name: ev?.team?.name ?? null,
      player_name: ev?.player?.name ?? null,
      assist_name: ev?.assist?.name ?? null,
      raw: ev,
    }));
    if (eventRows.length > 0) {
      const { error } = await admin
        .from('football_match_events')
        .upsert(eventRows, { onConflict: 'fixture_id,event_key', ignoreDuplicates: true });
      if (error) console.error('[football-live] Luu su kien loi:', error.message);
      else newEvents += eventRows.length;
    }

    // --- Ai can duoc bao? ---------------------------------------------------
    // Nguoi dung co 1 trong 2 doi trong danh sach yeu thich. Lam 1 lan cho ca
    // tran thay vi moi su kien mot lan.
    const { data: fx } = await admin
      .from('football_fixtures')
      .select('home_team_id, away_team_id')
      .eq('id', fixtureRow.id)
      .maybeSingle();
    const teamIds = [fx?.home_team_id, fx?.away_team_id].filter(Boolean) as number[];
    if (teamIds.length === 0) continue;

    const { data: favs } = await admin
      .from('football_favorite_teams')
      .select('user_id')
      .in('team_id', teamIds);
    const userIds = [...new Set((favs ?? []).map((r: { user_id: string }) => r.user_id))];
    if (userIds.length === 0) continue;

    const { data: prefsRows } = await admin
      .from('football_notification_prefs')
      .select('*')
      .in('user_id', userIds);
    const prefsByUser = new Map<string, Record<string, boolean>>();
    for (const p of (prefsRows ?? []) as Array<Record<string, any>>) {
      prefsByUser.set(p.user_id, p);
    }

    const { data: tokenRows } = await admin
      .from('device_tokens')
      .select('user_id, fcm_token')
      .in('user_id', userIds);
    const tokensByUser = new Map<string, string[]>();
    for (const t of (tokenRows ?? []) as Array<{ user_id: string; fcm_token: string }>) {
      tokensByUser.set(t.user_id, [...(tokensByUser.get(t.user_id) ?? []), t.fcm_token]);
    }

    const score = `${homeGoals ?? 0} - ${awayGoals ?? 0}`;

    for (const ev of allEvents) {
      const key = eventKey(ev);
      const type = String(ev?.type ?? '');
      const detail = String(ev?.detail ?? '');

      const column = prefColumn(type, detail);
      if (!column) continue; // loai su kien khong co trong danh sach thong bao

      // Da gui roi thi thoi - CHOT chong trung o day.
      const { data: already } = await admin
        .from('football_push_state')
        .select('event_key')
        .eq('fixture_id', fixtureRow.id)
        .eq('event_key', key)
        .maybeSingle();
      if (already) continue;

      // Loc nguoi dung con BAT loai thong bao nay. Chua co dong prefs =
      // dung mac dinh cua bang (ban thang/the/bat dau/ket thuc deu BAT).
      const targets: PushTarget[] = [];
      for (const userId of userIds) {
        const prefs = prefsByUser.get(userId);
        const enabled = prefs ? prefs[column] === true : DEFAULT_PREFS[column] === true;
        if (!enabled) continue;
        const tokens = tokensByUser.get(userId) ?? [];
        if (tokens.length > 0) targets.push({ userId, tokens });
      }
      if (targets.length === 0) {
        // Khong ai can bao: van GHI NHAN da xu ly de lan poll sau khong
        // phai kiem tra lai su kien nay nua.
        await admin.from('football_push_state').upsert({ fixture_id: fixtureRow.id, event_key: key });
        continue;
      }

      if (!serviceAccountRaw || !projectId) continue; // chua cau hinh Firebase - thu lai lan sau
      if (!accessToken) {
        const sa = JSON.parse(serviceAccountRaw);
        accessToken = await getAccessToken(sa.client_email, sa.private_key);
      }

      const { title, body } = pushText(type, detail, ev, homeName, awayName, score);
      const allTokens = targets.flatMap((t) => t.tokens);

      const results = await Promise.all(
        allTokens.map((token) =>
          fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
            method: 'POST',
            headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
            body: JSON.stringify({
              message: {
                token,
                // Data-only giong chat_push.dart: app tu dung thong bao de
                // kiem soat icon/kenh/hanh dong khi bam vao.
                data: {
                  type: 'football_event',
                  event_type: type,
                  fixture_id: String(fixtureRow!.id),
                  title,
                  body,
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
      if (sent > 0) {
        pushed += sent;
        await admin.from('football_push_state').upsert({ fixture_id: fixtureRow.id, event_key: key });
      }
      // Gui that bai het -> KHONG ghi push_state, de nhip sau thu lai (dung
      // bai hoc cua price-alert-check: ghi state truoc khi gui thanh cong se
      // "an" luon su kien do vinh vien).
    }
  }

  return new Response(
    JSON.stringify({ liveTotal: live.length, tracked: relevant.length, newEvents, pushed }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  );
});
