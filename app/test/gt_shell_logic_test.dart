import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/shell_presentation.dart';

void main() {
  group('quickStartTarget', () {
    test('no program yet -> choose a plan', () {
      expect(
        quickStartTarget(
          hasPlan: false,
          isRestDay: false,
          today: const DayProgress(),
        ),
        QuickStartTarget.choosePlan,
      );
    });

    test('training day not done yet -> today\'s workout', () {
      expect(
        quickStartTarget(
          hasPlan: true,
          isRestDay: false,
          today: const DayProgress(),
        ),
        QuickStartTarget.todayWorkout,
      );
    });

    test('workout already done today -> flashcard review', () {
      expect(
        quickStartTarget(
          hasPlan: true,
          isRestDay: false,
          today: const DayProgress(workouts: 1),
        ),
        QuickStartTarget.review,
      );
    });

    test('rest day -> flashcard review', () {
      expect(
        quickStartTarget(
          hasPlan: true,
          isRestDay: true,
          today: const DayProgress(),
        ),
        QuickStartTarget.review,
      );
    });
  });

  group('top bar presentation', () {
    test('avatar ring is the average of the three Daily Rings', () {
      expect(dailyRingsProgress(const DayProgress()), 0);
      final half = DayProgress(
        workouts: 1,
        wordsReviewed: kDailyLearnGoal ~/ 2,
      );
      expect(
        dailyRingsProgress(half),
        closeTo((1 + (kDailyLearnGoal ~/ 2) / kDailyLearnGoal) / 3, 1e-9),
      );
      expect(
        dailyRingsProgress(
          const DayProgress(
            workouts: 5,
            wordsReviewed: 999,
            speakAttempts: 999,
          ),
        ),
        1,
      );
    });

    test('initials from the display name', () {
      expect(nameInitials('Nguyễn Văn Tùng'), 'NT');
      expect(nameInitials('tung'), 'T');
      expect(nameInitials('  '), '?');
      expect(nameInitials('...'), '?');
    });
  });
}
