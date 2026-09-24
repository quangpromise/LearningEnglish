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
}
