import 'package:supabase_flutter/supabase_flutter.dart';

import 'football_models.dart';

/// Doc du lieu bong da tu Supabase.
///
/// KHAC cac repository goi API ngoai (vd StocksIntlRepository phai di qua Edge
/// Function vi can API key): o day app doc THANG bang qua PostgREST, vi cac
/// bang `football_*` chi chua du lieu da dong bo san, khong dinh khoa API nao
/// (xem dau file supabase/migrations/0070_football.sql). Nho vay man Live con
/// dung duoc Supabase Realtime de tu cap nhat khi worker ghi ban thang moi.
class FootballRepository {
  FootballRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Cach goi 2 doi trong 1 dong fixture: bang `football_fixtures` co TOI 2
  /// khoa ngoai cung tro toi `football_teams` (home_team_id + away_team_id)
  /// nen PostgREST khong tu doan duoc phai join cai nao - bat buoc chi dinh
  /// dich danh TEN RANG BUOC. Ten nay do Postgres tu dat theo quy tac
  /// `<bang>_<cot>_fkey` khi khai bao REFERENCES o muc cot (migration 0070).
  static const _fixtureSelect = '''
    id, competition_id, season, round, kickoff_at, status_short, elapsed,
    home_goals, away_goals, venue,
    home:football_teams!football_fixtures_home_team_id_fkey (id, name, logo_url),
    away:football_teams!football_fixtures_away_team_id_fkey (id, name, logo_url)
  ''';

  Future<List<FootballCompetition>> competitions() async {
    final rows = await _supabase
        .from('football_competitions')
        .select('id, slug, name, country_name, logo_url, current_season')
        .eq('is_enabled', true)
        .order('priority');
    return (rows as List)
        .map((r) => FootballCompetition.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Cac tran DANG DA. Dung cho the "Truc tiep" o man Home.
  Future<List<FootballFixture>> liveFixtures() async {
    final rows = await _supabase
        .from('football_fixtures')
        .select(_fixtureSelect)
        .inFilter('status_short', const [
          '1H',
          'HT',
          '2H',
          'ET',
          'BT',
          'P',
          'LIVE',
        ])
        .order('kickoff_at');
    return (rows as List)
        .map((r) => FootballFixture.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Tran trong khoang [from, to). Truyen [competitionId] de loc 1 giai.
  ///
  /// Moc thoi gian gui len server PHAI la UTC: cot `kickoff_at` la timestamptz
  /// luu theo UTC, con DateTime cua nguoi dung la gio dia phuong - quen
  /// `.toUtc()` thi nguoi o mui gio +7 se mat cac tran dau/cuoi ngay.
  Future<List<FootballFixture>> fixturesBetween({
    required DateTime from,
    required DateTime to,
    int? competitionId,
    int limit = 100,
  }) async {
    var query = _supabase
        .from('football_fixtures')
        .select(_fixtureSelect)
        .gte('kickoff_at', from.toUtc().toIso8601String())
        .lt('kickoff_at', to.toUtc().toIso8601String());
    if (competitionId != null) {
      query = query.eq('competition_id', competitionId);
    }
    final rows = await query.order('kickoff_at').limit(limit);
    return (rows as List)
        .map((r) => FootballFixture.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Toan bo tran cua 1 doi tren MOI giai dau - dung cho trang Doi yeu thich
  /// (yeu cau muc 4: "lay toan bo lich thi dau cua doi tren TAT CA cac giai,
  /// khong chi Premier League").
  Future<List<FootballFixture>> fixturesOfTeam(
    int teamId, {
    int limit = 60,
  }) async {
    final rows = await _supabase
        .from('football_fixtures')
        .select(_fixtureSelect)
        .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId')
        .order('kickoff_at')
        .limit(limit);
    return (rows as List)
        .map((r) => FootballFixture.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Bang xep hang 1 giai. [season] null = lay mua moi nhat dang co du lieu.
  Future<List<FootballStandingRow>> standings({
    required int competitionId,
    int? season,
  }) async {
    var query = _supabase
        .from('football_standings')
        .select('''
          position, played, wins, draws, losses, goals_for, goals_against,
          points, group_label, form,
          team:football_teams (id, name, logo_url)
        ''')
        .eq('competition_id', competitionId);
    if (season != null) query = query.eq('season', season);

    final rows = await query.order('group_label').order('position');
    return (rows as List)
        .map((r) => FootballStandingRow.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<FootballMatchEvent>> events(int fixtureId) async {
    final rows = await _supabase
        .from('football_match_events')
        .select(
          'event_key, type, detail, elapsed, elapsed_extra, team_name, player_name, assist_name',
        )
        .eq('fixture_id', fixtureId)
        .order('elapsed');
    return (rows as List)
        .map((r) => FootballMatchEvent.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Luc nao du lieu duoc lam moi lan cuoi - hien "Cap nhat luc HH:mm" thay vi
  /// bao loi khi worker het quota trong ngay (yeu cau muc 18: khong hien
  /// thong tin gia, khong crash).
  Future<DateTime?> lastSyncedAt() async {
    final rows = await _supabase
        .from('football_fixtures')
        .select('updated_at')
        .order('updated_at', ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    final value = (list.first as Map<String, dynamic>)['updated_at'] as String?;
    return value == null ? null : DateTime.parse(value).toLocal();
  }

  // --- Doi yeu thich -------------------------------------------------------

  Future<List<int>> favoriteTeamIds(String userId) async {
    final rows = await _supabase
        .from('football_favorite_teams')
        .select('team_id')
        .eq('user_id', userId)
        .order('sort_order');
    return (rows as List)
        .map((r) => ((r as Map<String, dynamic>)['team_id'] as num).toInt())
        .toList();
  }

  Future<void> addFavorite(String userId, int teamId) async {
    await _supabase.from('football_favorite_teams').upsert({
      'user_id': userId,
      'team_id': teamId,
    });
  }

  /// Tim doi theo ten. Chi tim trong cac doi DA xuat hien o lich da dong bo
  /// (6 giai, cua so ~38 ngay) - dung y do: nguoi dung chi chon duoc doi ma
  /// app thuc su co du lieu, thay vi chon 1 doi rong khong bao gio hien tran nao.
  Future<List<FootballTeam>> searchTeams(String query, {int limit = 30}) async {
    final q = query.trim();
    final rows = await (q.isEmpty
        ? _supabase
              .from('football_teams')
              .select('id, name, logo_url')
              .order('name')
              .limit(limit)
        : _supabase
              .from('football_teams')
              .select('id, name, logo_url')
              .ilike('name', '%$q%')
              .order('name')
              .limit(limit));
    return (rows as List)
        .map((r) => FootballTeam.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Thong tin cac doi theo danh sach id - dung de hien the doi yeu thich.
  Future<List<FootballTeam>> teamsByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _supabase
        .from('football_teams')
        .select('id, name, logo_url')
        .inFilter('id', ids);
    final byId = {
      for (final r in rows as List)
        ((r as Map<String, dynamic>)['id'] as num).toInt():
            FootballTeam.fromRow(r),
    };
    // Giu dung thu tu nguoi dung da sap trong danh sach yeu thich.
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  // --- Match Center --------------------------------------------------------

  Future<FootballFixture?> fixtureById(int fixtureId) async {
    final row = await _supabase
        .from('football_fixtures')
        .select(_fixtureSelect)
        .eq('id', fixtureId)
        .maybeSingle();
    return row == null ? null : FootballFixture.fromRow(row);
  }

  Future<List<FootballLineup>> lineups(int fixtureId) async {
    final rows = await _supabase
        .from('football_lineups')
        .select('team_id, formation, starters, substitutes, coach_name')
        .eq('fixture_id', fixtureId);
    return (rows as List)
        .map((r) => FootballLineup.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<FootballTeamStats>> matchStats(int fixtureId) async {
    final rows = await _supabase
        .from('football_match_stats')
        .select('team_id, stats')
        .eq('fixture_id', fixtureId);
    return (rows as List)
        .map((r) => FootballTeamStats.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Yeu cau backend lay doi hinh + thong ke cua 1 tran TU NHA CUNG CAP.
  ///
  /// Day la truong hop DUY NHAT app cham vao Edge Function cua Football: 2
  /// bang tren chi duoc dien khi co nguoi thuc su mo Match Center, vi lay
  /// truoc cho moi tran se dot sach han muc 100 request/ngay. Ham tra ve
  /// true khi backend bao da co du lieu moi.
  Future<bool> requestMatchDetail(int fixtureId) async {
    try {
      final res = await _supabase.functions.invoke(
        'football-match',
        body: {'fixtureId': fixtureId},
      );
      final data = res.data;
      if (data is Map && data['ok'] == true) return true;
      return false;
    } catch (_) {
      // Mang loi/het quota: khong nem loi ra UI - man hinh da co trang thai
      // "chua co doi hinh" rieng.
      return false;
    }
  }

  // --- Cai dat thong bao ---------------------------------------------------

  Future<FootballNotificationPrefs> notificationPrefs(String userId) async {
    final row = await _supabase
        .from('football_notification_prefs')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    // Chua co dong nao = dung mac dinh, KHONG phai tat het.
    return row == null
        ? const FootballNotificationPrefs()
        : FootballNotificationPrefs.fromRow(row);
  }

  Future<void> saveNotificationPrefs(
    String userId,
    FootballNotificationPrefs prefs,
  ) async {
    await _supabase
        .from('football_notification_prefs')
        .upsert(prefs.toRow(userId));
  }

  Future<void> removeFavorite(String userId, int teamId) async {
    await _supabase
        .from('football_favorite_teams')
        .delete()
        .eq('user_id', userId)
        .eq('team_id', teamId);
  }
}
