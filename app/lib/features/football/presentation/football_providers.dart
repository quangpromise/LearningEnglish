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
