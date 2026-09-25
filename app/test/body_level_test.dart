import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';

/// Thu Hai 2026-09-21 (dau tuan).
final _monday = DateTime(2026, 9, 21);

/// [perWeek] buoi moi tuan, [weeks] tuan lien tiep ket thuc o tuan cua
/// [_monday] (tuan cuoi = tuan hien tai).
List<DateTime> _weeks(int weeks, {int perWeek = 2}) => [
  for (var w = weeks - 1; w >= 0; w--)
    for (var d = 0; d < perWeek; d++)
      _monday.subtract(Duration(days: 7 * w)).add(Duration(days: d, hours: 9)),
];

BodyStats _stats(List<DateTime> done, {DateTime? now}) =>
    computeBodyStats(done, now: now ?? _monday.add(const Duration(days: 3)));

void main() {
  group('week streak', () {
    test('a week counts only with at least 2 completed workouts', () {
      final oneAWeek = _stats(_weeks(4, perWeek: 1));
      expect(oneAWeek.totalWorkouts, 4);
      expect(oneAWeek.bestWeekStreak, 0);
      expect(_stats(_weeks(4)).bestWeekStreak, 4);
    });

    test('weeks start on Monday', () {
      // Chu Nhat 20/9 + Thu Hai 21/9 la 2 tuan khac nhau.
      final s = _stats([
        DateTime(2026, 9, 20, 9),
        DateTime(2026, 9, 20, 18),
        DateTime(2026, 9, 21, 9),
      ]);
      expect(s.bestWeekStreak, 1);
    });

    test('a gap week breaks the current streak but not the best', () {
      final old = _weeks(5).map((d) => d.subtract(const Duration(days: 14)));
      final recent = _weeks(1);
      final s = _stats([...old, ...recent]);
      expect(s.bestWeekStreak, 5);
      expect(s.currentWeekStreak, 1);
    });

    test('an unfinished current week does not break the streak', () {
      // 3 tuan truoc day du, tuan nay moi co 1 buoi.
      final done = [
        ..._weeks(4).where((d) => d.isBefore(_monday)),
        _monday.add(const Duration(hours: 9)),
      ];
      expect(_stats(done).currentWeekStreak, 3);
    });
  });

  group('Body Level', () {
    test('thresholds need both workouts and week streak', () {
      expect(bodyLevelFor(const BodyStats(0, 0, 0)), BodyLevel.rookie);
      expect(bodyLevelFor(const BodyStats(6, 2, 0)), BodyLevel.regular);
      expect(bodyLevelFor(const BodyStats(5, 2, 0)), BodyLevel.rookie);
      expect(bodyLevelFor(const BodyStats(30, 1, 0)), BodyLevel.rookie);
      expect(bodyLevelFor(const BodyStats(20, 4, 0)), BodyLevel.athlete);
      expect(bodyLevelFor(const BodyStats(45, 8, 0)), BodyLevel.pro);
      expect(bodyLevelFor(const BodyStats(90, 16, 0)), BodyLevel.beast);
      expect(bodyLevelFor(const BodyStats(500, 15, 0)), BodyLevel.pro);
    });

    test('never drops when the current streak is lost', () {
      final active = _stats(_weeks(8, perWeek: 6));
      final later = _stats(
        _weeks(8, perWeek: 6),
        now: _monday.add(const Duration(days: 60)),
      );
      expect(later.currentWeekStreak, 0);
      expect(bodyLevelFor(later), bodyLevelFor(active));
      expect(bodyLevelFor(later), BodyLevel.pro);
    });

    test('next target tells how many workouts and weeks are missing', () {
      final t = nextBodyTarget(const BodyStats(4, 1, 1))!;
      expect(t.level, BodyLevel.regular);
      expect(t.workoutsNeeded, 2);
      expect(t.weeksNeeded, 1);
      final done = nextBodyTarget(const BodyStats(10, 3, 3))!;
      expect(done.level, BodyLevel.athlete);
      expect(done.workoutsNeeded, 10);
      expect(done.weeksNeeded, 1);
      expect(nextBodyTarget(const BodyStats(90, 16, 0)), isNull);
    });
  });
}
