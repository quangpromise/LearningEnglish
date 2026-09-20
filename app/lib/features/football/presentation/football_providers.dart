import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/football_models.dart';
import '../data/football_repository.dart';

final footballRepositoryProvider = Provider(
  (ref) => FootballRepository(ref.watch(supabaseClientProvider)),
);

final footballCompetitionsProvider = FutureProvider<List<FootballCompetition>>(
  (ref) => ref.watch(footballRepositoryProvider).competitions(),
);

/// Cac tran dang da. KHONG tu dat timer poll o phia app: worker
/// `football-live` ghi thang vao DB va app nghe qua Realtime
/// (xem football_live_stream.dart) - de moi may tu hoi lai server se lam
/// dung cai viec de bai cam ("khong polling lien tuc tu tung dien thoai").
final footballLiveFixturesProvider = FutureProvider<List<FootballFixture>>(
  (ref) => ref.watch(footballRepositoryProvider).liveFixtures(),
);

/// Tran trong ngay dang chon (mac dinh hom nay), theo gio DIA PHUONG cua may.
final footballSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final footballFixturesOfDayProvider = FutureProvider<List<FootballFixture>>((
  ref,
) async {
  final day = ref.watch(footballSelectedDateProvider);
  return ref
      .watch(footballRepositoryProvider)
      .fixturesBetween(from: day, to: day.add(const Duration(days: 1)));
});

/// Giai dang xem bang xep hang - null = chua chon (man Home hien giai dau tien).
final footballSelectedCompetitionProvider = StateProvider<int?>((ref) => null);

final footballStandingsProvider =
    FutureProvider.family<List<FootballStandingRow>, int>((ref, competitionId) {
      return ref
          .watch(footballRepositoryProvider)
          .standings(competitionId: competitionId);
    });

final footballEventsProvider =
    FutureProvider.family<List<FootballMatchEvent>, int>((ref, fixtureId) {
      return ref.watch(footballRepositoryProvider).events(fixtureId);
    });

/// Thoi diem du lieu duoc lam moi lan cuoi - hien o chan man Home.
final footballLastSyncedProvider = FutureProvider<DateTime?>(
  (ref) => ref.watch(footballRepositoryProvider).lastSyncedAt(),
);

/// Id cac doi yeu thich cua user dang dang nhap. Rong khi chua dang nhap.
final footballFavoriteTeamIdsProvider = FutureProvider<List<int>>((ref) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return const [];
  return ref.watch(footballRepositoryProvider).favoriteTeamIds(userId);
});

/// Lich thi dau cua 1 doi tren MOI giai (yeu cau muc 4 + 5 cua de bai).
final footballTeamFixturesProvider =
    FutureProvider.family<List<FootballFixture>, int>((ref, teamId) {
      return ref.watch(footballRepositoryProvider).fixturesOfTeam(teamId);
    });

/// Cac doi yeu thich (day du thong tin), theo dung thu tu da sap.
final footballFavoriteTeamsProvider = FutureProvider<List<FootballTeam>>((
  ref,
) async {
  final ids = await ref.watch(footballFavoriteTeamIdsProvider.future);
  if (ids.isEmpty) return const [];
  return ref.watch(footballRepositoryProvider).teamsByIds(ids);
});

/// Tu khoa dang go o o tim doi.
final footballTeamQueryProvider = StateProvider<String>((ref) => '');

final footballTeamSearchProvider = FutureProvider<List<FootballTeam>>((ref) {
  final q = ref.watch(footballTeamQueryProvider);
  return ref.watch(footballRepositoryProvider).searchTeams(q);
});

/// Giai dang loc o man lich doi yeu thich - null = tat ca giai.
final footballTeamLeagueFilterProvider = StateProvider<int?>((ref) => null);

// --- Match Center ----------------------------------------------------------

final footballFixtureProvider = FutureProvider.family<FootballFixture?, int>((
  ref,
  fixtureId,
) {
  return ref.watch(footballRepositoryProvider).fixtureById(fixtureId);
});

final footballLineupsProvider =
    FutureProvider.family<List<FootballLineup>, int>((ref, fixtureId) {
      return ref.watch(footballRepositoryProvider).lineups(fixtureId);
    });

final footballMatchStatsProvider =
    FutureProvider.family<List<FootballTeamStats>, int>((ref, fixtureId) {
      return ref.watch(footballRepositoryProvider).matchStats(fixtureId);
    });

/// Timeline TU CAP NHAT khi worker ghi su kien moi.
///
/// Dung Supabase Realtime thay vi cho app tu hoi lai server theo chu ky -
/// dung yeu cau "khong polling lien tuc tu tung dien thoai": server day
/// xuong, may nguoi dung khong goi them request nao.
final footballLiveEventsProvider =
    StreamProvider.family<List<FootballMatchEvent>, int>((ref, fixtureId) {
      final client = ref.watch(supabaseClientProvider);
      return client
          .from('football_match_events')
          .stream(primaryKey: ['fixture_id', 'event_key'])
          .eq('fixture_id', fixtureId)
          .map((rows) {
            final events = rows.map(FootballMatchEvent.fromRow).toList()
              ..sort((a, b) => (a.elapsed ?? 0).compareTo(b.elapsed ?? 0));
            return events;
          });
    });

/// Ti so + trang thai tran, cung tu cap nhat qua Realtime.
final footballLiveFixtureProvider =
    StreamProvider.family<FootballFixture?, int>((ref, fixtureId) {
      final client = ref.watch(supabaseClientProvider);
      return client
          .from('football_fixtures')
          .stream(primaryKey: ['id'])
          .eq('id', fixtureId)
          .map(
            (rows) => rows.isEmpty ? null : FootballFixture.fromRow(rows.first),
          );
    });

// --- Cai dat thong bao -----------------------------------------------------

final footballNotificationPrefsProvider =
    FutureProvider<FootballNotificationPrefs>((ref) async {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return const FootballNotificationPrefs();
      return ref.watch(footballRepositoryProvider).notificationPrefs(userId);
    });
