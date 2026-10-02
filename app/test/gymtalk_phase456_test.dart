import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/gymtalk_reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';

SrsCard _card(String key, {int box = 0, DateTime? due, DateTime? rev}) =>
    SrsCard(
      key: key,
      en: key,
      vi: 'x',
      box: box,
      due: due ?? DateTime(2026, 9, 25),
      reviewedAt: rev,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SrsStore.mergeRemote', () {
    test('lan on MOI HON thang, ke ca khi la lan Quen', () async {
      final store = SrsStore.forTest();
      final now = DateTime(2026, 9, 25, 10);
      // May nay: nho -> hop 1, han ngay mai, on luc 10h.
      await store.review(
        'squat',
        known: true,
        now: now,
        content: _card('squat'),
      );
      // May kia: QUEN luc 11h (hop 0, han hom nay) -> phai thang.
      final remote = _card(
        'squat',
        box: 0,
        due: DateTime(2026, 9, 25),
        rev: now.add(const Duration(hours: 1)).toUtc(),
      );
      final changed = await store.mergeRemote([remote.toJson()]);
      expect(changed, isTrue);
      expect(store.boxOf('squat'), 0);
      expect(store.dueCount(now), 1);
    });

    test('ban cu hon khong de ban moi; gop 2 lan khong doi', () async {
      final store = SrsStore.forTest();
      final now = DateTime(2026, 9, 25, 10);
      await store.review(
        'lunge',
        known: true,
        now: now,
        content: _card('lunge'),
      );
      final old = _card(
        'lunge',
        rev: now.subtract(const Duration(days: 1)).toUtc(),
      );
      expect(await store.mergeRemote([old.toJson()]), isFalse);
      expect(store.boxOf('lunge'), 1);
      final exported = store.exportJson();
      expect(await store.mergeRemote(exported), isFalse);
    });

    test('the moi tu server duoc them, khoa chuan hoa chu thuong', () async {
      final store = SrsStore.forTest();
      await store.mergeRemote([_card('Bench Press', box: 2).toJson()]);
      expect(store.boxes, {'bench press': 2});
    });

    test('clearLocal xoa sach', () async {
      final store = SrsStore.forTest();
      await store.addIfAbsent(_card('rack'));
      await store.clearLocal();
      expect(store.totalCards, 0);
    });
  });

  group('DailyProgressStore.mergeRemote', () {
    test('lay MAX tung bo dem, ngay nghi = OR, idempotent', () async {
      final now = DateTime(2026, 9, 25, 9);
      final store = DailyProgressStore.forTest(clock: () => now);
      await store.addWordsReviewed(4);
      await store.addWorkout();
      final changed = await store.mergeRemote({
        '2026-09-25': {'w': 0, 'l': 12, 's': 3, 'r': false},
        '2026-09-24': {'w': 1, 'l': 10, 's': 0, 'r': false},
      });
      expect(changed, isTrue);
      expect(store.today.workouts, 1);
      expect(store.today.wordsReviewed, 12);
      expect(store.today.speakAttempts, 3);
      expect(store.bodyBrainStreak, 2);
      expect(await store.mergeRemote(store.exportJson()), isFalse);
    });

    test('clearLocal xoa sach', () async {
      final store = DailyProgressStore.forTest();
      await store.addWorkout();
      await store.clearLocal();
      expect(store.today.workouts, 0);
    });
  });

  group('nextReminderTimes', () {
    test('gio hom nay da qua -> bat dau ngay mai, luon du 7 lan', () {
      final times = nextReminderTimes(
        now: DateTime(2026, 9, 25, 19),
        hour: 18,
        minute: 0,
        count: 7,
      );
      expect(times, hasLength(7));
      expect(times.first, DateTime(2026, 9, 26, 18));
      expect(times.last, DateTime(2026, 10, 2, 18));
    });

    test('gio hom nay chua toi -> nhac ca hom nay', () {
      final times = nextReminderTimes(
        now: DateTime(2026, 9, 25, 7),
        hour: 18,
        minute: 30,
        count: 7,
      );
      expect(times.first, DateTime(2026, 9, 25, 18, 30));
    });
  });

  group('reminderFor', () {
    const program = Program(
      id: 1,
      titleVi: 'x',
      titleEn: 'x',
      level: 'Trung cấp',
      equipment: 'Phòng gym',
      sessionsPerWeek: 1,
      durationWeeks: 4,
      tags: [],
      days: [
        ProgramDay(
          dayOfWeek: DateTime.monday,
          exercises: [
            ProgramExerciseRef(
              exerciseId: 1,
              targetSets: 3,
              targetRepsMin: 8,
              targetRepsMax: 12,
              orderIndex: 0,
            ),
          ],
        ),
        ProgramDay(dayOfWeek: DateTime.tuesday, exercises: []),
      ],
    );

    test('ngay tap / ngay nghi / khong co dong / chua co giao an', () {
      // 2026-09-28 la thu Hai.
      expect(
        reminderFor(program: program, day: DateTime(2026, 9, 28)).titleKey,
        'remind_workout_title',
      );
      expect(
        reminderFor(program: program, day: DateTime(2026, 9, 29)).titleKey,
        'remind_rest_title',
      );
      expect(
        reminderFor(program: program, day: DateTime(2026, 9, 30)).titleKey,
        'remind_rest_title',
      );
      expect(
        reminderFor(program: null, day: DateTime(2026, 9, 28)).titleKey,
        'remind_generic_title',
      );
    });
  });
}
