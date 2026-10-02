import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;
  late DailyProgressStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 9, 24, 19);
    store = DailyProgressStore.forTest(clock: () => now);
  });

  Future<void> completeDay({bool workout = true}) async {
    if (workout) await store.addWorkout();
    await store.addWordsReviewed(kDailyLearnGoal);
  }

  test('dem 3 vong trong ngay', () async {
    await store.addWorkout();
    await store.addWordsReviewed(3);
    await store.addSpeakAttempt();
    final today = store.today;
    expect(today.trainDone, isTrue);
    expect(today.learnRatio, closeTo(0.3, 1e-9));
    expect(today.speakAttempts, 1);
    expect(today.bodyBrainDone, isFalse);
  });

  test('chuoi Body + Brain: hom nay chua xong van giu chuoi hom qua', () async {
    await completeDay();
    now = now.add(const Duration(days: 1));
    await completeDay();
    now = now.add(const Duration(days: 1));
    expect(store.bodyBrainStreak, 2);
    await completeDay();
    expect(store.bodyBrainStreak, 3);
  });

  test('ngay nghi theo giao an tinh la xong vong Tap', () async {
    await store.markRestDay(true);
    await store.addWordsReviewed(kDailyLearnGoal);
    expect(store.today.trainDone, isTrue);
    expect(store.bodyBrainStreak, 1);
  });

  test('bo lo 1 ngay thi chuoi ve 0', () async {
    await completeDay();
    now = now.add(const Duration(days: 2));
    expect(store.bodyBrainStreak, 0);
  });

  test('luu lai va doc lai tu may', () async {
    await completeDay();
    final reloaded = DailyProgressStore.forTest(clock: () => now);
    await reloaded.ensureLoaded();
    expect(reloaded.today.workouts, 1);
    expect(reloaded.today.wordsReviewed, kDailyLearnGoal);
    final days = reloaded.lastDays(7);
    expect(days, hasLength(7));
    expect(days.last.$2.workouts, 1);
  });

  test('streaks longer than 60 days are counted (100 / 365)', () async {
    for (var i = 0; i < 120; i++) {
      await store.addWordsReviewed(kDailyLearnGoal);
      await store.markRestDay(true);
      now = now.add(const Duration(days: 1));
    }
    now = now.subtract(const Duration(days: 1));
    expect(store.bodyBrainStreak, 120);
  });

  test('the streak steps back by calendar day across a new year', () async {
    now = DateTime(2026, 12, 30, 19);
    for (var i = 0; i < 4; i++) {
      await completeDay();
      now = DateTime(now.year, now.month, now.day + 1, 19);
    }
    now = DateTime(2027, 1, 2, 8);
    expect(store.bodyBrainStreak, 4);
  });

  test('the cached streak follows synced days and account switches', () async {
    await completeDay();
    expect(store.bodyBrainStreak, 1);
    await store.mergeRemote({
      '2026-09-23': {'w': 1, 'l': kDailyLearnGoal, 's': 0, 'r': false},
    });
    expect(store.bodyBrainStreak, 2);
    await store.clearLocal();
    expect(store.bodyBrainStreak, 0);
  });

  test('days older than 60 keep only what the streak needs', () async {
    // 70 ngay truoc: 1 ngay dat (kem quest, khoa thuong), 1 ngay khong dat.
    now = DateTime(2026, 7, 16, 19);
    await completeDay();
    await store.markHandsFreeDone();
    await store.markRewarded(now, 'quest_review');
    now = DateTime(2026, 7, 17, 19);
    await store.addWordsReviewed(3);
    now = DateTime(2026, 9, 24, 19);
    await store.addSpeakAttempt();
    final exported = store.exportJson();
    expect(exported['2026-07-16'], {
      'w': 1,
      'l': kDailyLearnGoal,
      's': 0,
      'r': false,
    });
    expect(exported.containsKey('2026-07-17'), isFalse);
    expect(exported['2026-09-24'], {'w': 0, 'l': 0, 's': 1, 'r': false});
    final reloaded = DailyProgressStore.forTest(clock: () => now);
    await reloaded.ensureLoaded();
    expect(reloaded.dayOf(DateTime(2026, 7, 16)).bodyBrainDone, isTrue);
  });

  test('synced old days are kept compact and count as a change once', () async {
    final changed = await store.mergeRemote({
      '2026-07-16': {
        'w': 1,
        'l': 12,
        's': 4,
        'r': false,
        'hf': true,
        'rk': ['quest_review'],
      },
      '2026-07-17': {'w': 0, 'l': 3, 's': 0, 'r': false},
      // Qua 400 ngay: bo.
      '2025-01-01': {'w': 1, 'l': 12, 's': 0, 'r': false},
    });
    expect(changed, isTrue);
    expect(store.revision, 1);
    final exported = store.exportJson();
    expect(exported['2026-07-16'], {'w': 1, 'l': 12, 's': 0, 'r': false});
    expect(exported.containsKey('2026-07-17'), isFalse);
    expect(exported.containsKey('2025-01-01'), isFalse);
    // May kia van con ban day du: khong tinh la doi nua.
    expect(
      await store.mergeRemote({
        '2026-07-16': {'w': 1, 'l': 12, 's': 4, 'r': false, 'hf': true},
      }),
      isFalse,
    );
    expect(store.revision, 1);
  });

  test(
    'its own server copy changes nothing, even a day just past 60',
    () async {
      // Ngay vua qua moc 60 ngay: con day du ca tren may lan tren server.
      now = DateTime(2026, 7, 25, 19);
      await completeDay();
      await store.markRewarded(now, 'quest_review');
      final server = store.exportJson();
      now = DateTime(2026, 9, 24, 8);
      expect(await store.mergeRemote(server), isFalse);
      expect(store.revision, 0);
    },
  );

  test('a merge that raises the streak is remembered for the day', () async {
    await completeDay();
    expect(store.syncedStreakRiseToday, isNull);
    // May khac da xong 6 ngay truoc do.
    expect(
      await store.mergeRemote({
        for (var i = 1; i <= 6; i++)
          DailyProgressStore.keyOf(DateTime(2026, 9, 24 - i)): {
            'w': 1,
            'l': kDailyLearnGoal,
            's': 0,
            'r': false,
          },
      }),
      isTrue,
    );
    expect(store.bodyBrainStreak, 7);
    expect(store.syncedStreakRiseToday, (from: 1, to: 7));
    // Doi khac khong lam chuoi tang (vd luot noi o may khac): giu nguyen.
    await store.mergeRemote({
      '2026-09-24': {'w': 1, 'l': kDailyLearnGoal, 's': 3, 'r': false},
    });
    expect(store.syncedStreakRiseToday, (from: 1, to: 7));
    // Sang ngay moi: het hieu luc.
    now = DateTime(2026, 9, 25, 9);
    expect(store.syncedStreakRiseToday, isNull);
  });

  test('switching account forgets the synced rise', () async {
    await store.mergeRemote({
      '2026-09-24': {'w': 1, 'l': kDailyLearnGoal, 's': 0, 'r': false},
    });
    expect(store.syncedStreakRiseToday, (from: 0, to: 1));
    await store.clearLocal();
    expect(store.syncedStreakRiseToday, isNull);
  });
}
