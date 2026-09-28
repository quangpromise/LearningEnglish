import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/progress_presentation.dart';

void main() {
  final today = DateTime(2026, 9, 28, 21);

  group('weekly chart', () {
    test('7 columns ending today, learn and train minutes per day', () {
      final cols = weeklyChart(
        learnSeconds: {
          DateTime(2026, 9, 28): 1500, // 25 phut
          DateTime(2026, 9, 25): 89, // 1 phut (lam tron xuong)
        },
        trainSeconds: {
          DateTime(2026, 9, 28): 2700, // 45 phut
          DateTime(2026, 9, 22): 3600,
        },
        today: today,
      );
      expect(cols, hasLength(7));
      expect(cols.first.day, DateTime(2026, 9, 22));
      expect(cols.last.day, DateTime(2026, 9, 28));
      expect(cols.last.learnMin, 25);
      expect(cols.last.trainMin, 45);
      expect(cols[3].learnMin, 1);
      expect(cols.first.trainMin, 60);
      expect(cols[1].learnMin + cols[1].trainMin, 0);
    });

    test('ignores days outside the window and time-of-day in keys', () {
      final cols = weeklyChart(
        learnSeconds: {
          DateTime(2026, 9, 21): 6000, // truoc cua so 7 ngay
          DateTime(2026, 9, 27, 18, 30): 600,
        },
        trainSeconds: const {},
        today: today,
      );
      expect(cols.fold<int>(0, (s, c) => s + c.learnMin), 10);
      expect(cols[5].learnMin, 10);
    });

    test('total minutes and hours/minutes split', () {
      final cols = weeklyChart(
        learnSeconds: {DateTime(2026, 9, 28): 3 * 3600},
        trainSeconds: {DateTime(2026, 9, 27): 2 * 3600 + 48 * 60},
        today: today,
      );
      expect(weeklyTotalMinutes(cols), 348);
      expect(splitHoursMinutes(348), (hours: 5, minutes: 48));
    });

    test('bar scale: 1.6 px/min, shrunk to fit the tallest day', () {
      expect(chartScale(maxDayMinutes: 50, plotHeight: 110), 1.6);
      expect(chartScale(maxDayMinutes: 220, plotHeight: 110), 0.5);
      expect(chartScale(maxDayMinutes: 0, plotHeight: 110), 1.6);
    });
  });
}
