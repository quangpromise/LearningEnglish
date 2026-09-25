import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/today_presentation.dart';

/// Thu Nam 2026-09-24.
final _thursday = DateTime(2026, 9, 24, 15);

DayProgress _done() =>
    const DayProgress(workouts: 1, wordsReviewed: kDailyLearnGoal);

ProgramExerciseRef _ex(int sets) => ProgramExerciseRef(
  exerciseId: 1,
  targetSets: sets,
  targetRepsMin: 8,
  targetRepsMax: 12,
  orderIndex: 0,
);

Program _program(List<int> trainingDays) => Program(
  id: 1,
  titleVi: 'Tăng cơ',
  titleEn: 'Muscle',
  level: 'Mới bắt đầu',
  equipment: 'gym',
  sessionsPerWeek: trainingDays.length,
  durationWeeks: 8,
  tags: const [],
  days: [
    for (var d = 1; d <= 7; d++)
      ProgramDay(
        dayOfWeek: d,
        exercises: trainingDays.contains(d) ? [_ex(4)] : const [],
      ),
  ],
);

void main() {
  group('week streak strip (Mon-Sun)', () {
    test('marks done, missed, today and future days', () {
      final days = {
        DateTime(2026, 9, 21): _done(), // T2
        DateTime(2026, 9, 23): _done(), // T4
      };
      final strip = weekStreakStrip(
        (d) => days[DateTime(d.year, d.month, d.day)] ?? const DayProgress(),
        _thursday,
      );
      expect(strip, [
        StreakCell.done,
        StreakCell.missed,
        StreakCell.done,
        StreakCell.today,
        StreakCell.future,
        StreakCell.future,
        StreakCell.future,
      ]);
    });

    test('Sunday is the last cell; the week starts on Monday', () {
      final strip = weekStreakStrip(
        (d) => const DayProgress(),
        DateTime(2026, 9, 27, 23, 59),
      );
      expect(strip.last, StreakCell.today);
      expect(strip.take(6), everyElement(StreakCell.missed));
    });

    test('a week spanning two months reads the right dates', () {
      final seen = <DateTime>[];
      weekStreakStrip((d) {
        seen.add(d);
        return const DayProgress();
      }, DateTime(2026, 10, 1, 8));
      expect(seen.first, DateTime(2026, 9, 28));
      expect(seen.last, DateTime(2026, 10, 4));
    });

    test('today fills once body + brain is done', () {
      final strip = weekStreakStrip((d) => _done(), _thursday);
      expect(strip[3], StreakCell.todayDone);
    });
  });

  group('today workout card state', () {
    test('covers every state of the old primary action', () {
      expect(
        todayCardState(
          loading: true,
          error: false,
          hasPlan: false,
          isRestDay: false,
          today: const DayProgress(),
        ),
        TodayCardState.loading,
      );
      expect(
        todayCardState(
          loading: false,
          error: true,
          hasPlan: false,
          isRestDay: false,
          today: const DayProgress(),
        ),
        TodayCardState.error,
      );
      expect(
        todayCardState(
          loading: false,
          error: false,
          hasPlan: false,
          isRestDay: false,
          today: const DayProgress(),
        ),
        TodayCardState.noPlan,
      );
      expect(
        todayCardState(
          loading: false,
          error: false,
          hasPlan: true,
          isRestDay: true,
          today: const DayProgress(),
        ),
        TodayCardState.restDay,
      );
      expect(
        todayCardState(
          loading: false,
          error: false,
          hasPlan: true,
          isRestDay: false,
          today: const DayProgress(workouts: 1),
        ),
        TodayCardState.done,
      );
      expect(
        todayCardState(
          loading: false,
          error: false,
          hasPlan: true,
          isRestDay: false,
          today: const DayProgress(),
        ),
        TodayCardState.start,
      );
    });
  });

  test('session number within the week counts training days only', () {
    final p = _program([1, 3, 5, 6]);
    expect(sessionOfWeek(p, 1), (session: 1, total: 4));
    expect(sessionOfWeek(p, 5), (session: 3, total: 4));
    expect(sessionOfWeek(p, 2), isNull);
  });

  test('estimated minutes rounds to 5 and never below 10', () {
    expect(estimatedMinutes(26), 45);
    expect(estimatedMinutes(1), 10);
    expect(estimatedMinutes(12), 20);
  });

  test('overall ring percent is a whole number 0-100', () {
    expect(ringsPercent(const DayProgress()), 0);
    expect(
      ringsPercent(
        const DayProgress(workouts: 1, wordsReviewed: 999, speakAttempts: 999),
      ),
      100,
    );
  });
}
