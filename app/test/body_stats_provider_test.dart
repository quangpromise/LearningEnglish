import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/features/fitness/data/workout_repository.dart';

class _Repo implements WorkoutRepository {
  var calls = 0;
  Object? error;

  @override
  Future<List<DateTime>> getCompletedWorkoutTimes(String userId) async {
    calls++;
    final e = error;
    if (e != null) throw e;
    return [DateTime(2026, 9, 1), DateTime(2026, 9, 3)];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _sent = StateProvider<int>((ref) => 0);

void main() {
  testWidgets('offline: unknown (not Rookie), retried a minute later', (
    tester,
  ) async {
    final repo = _Repo()..error = Exception('offline');
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        workoutRepositoryProvider.overrideWithValue(repo),
        workoutsSentProvider.overrideWith((ref) => ref.watch(_sent)),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(bodyStatsProvider, (_, _) {});
    addTearDown(sub.close);
    await tester.pump();
    expect(repo.calls, 1);
    expect(container.read(bodyStatsProvider).valueOrNull, isNull);
    // Co mang lai: 1 phut sau tu thu lai.
    repo.error = null;
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(repo.calls, 2);
    expect(container.read(bodyStatsProvider).valueOrNull?.totalWorkouts, 2);
  });

  testWidgets('a workout reaching the server recomputes Body Level', (
    tester,
  ) async {
    final repo = _Repo();
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        workoutRepositoryProvider.overrideWithValue(repo),
        workoutsSentProvider.overrideWith((ref) => ref.watch(_sent)),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(bodyStatsProvider, (_, _) {});
    addTearDown(sub.close);
    await tester.pump();
    expect(repo.calls, 1);
    // Buoi tap gui bu sau khi mat mang vua len server.
    container.read(_sent.notifier).state++;
    await tester.pump();
    await tester.pump();
    expect(repo.calls, 2);
  });

  testWidgets('signed out: nothing is fetched', (tester) async {
    final repo = _Repo();
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(null),
        workoutRepositoryProvider.overrideWithValue(repo),
        workoutsSentProvider.overrideWith((ref) => ref.watch(_sent)),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(bodyStatsProvider, (_, _) {});
    addTearDown(sub.close);
    await tester.pump();
    expect(repo.calls, 0);
    expect(container.read(bodyStatsProvider).valueOrNull, isNull);
  });
}
