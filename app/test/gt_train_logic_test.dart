import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/fitness/data/train_presentation.dart';

void main() {
  group('weekly volume change', () {
    test('percent vs last week, rounded', () {
      expect(volumeChangePercent(7500, 6100), 23);
      expect(volumeChangePercent(6100, 7500), -19);
      expect(volumeChangePercent(1000, 1000), 0);
    });

    test('no comparison without a previous week', () {
      expect(volumeChangePercent(1200, 0), isNull);
      expect(volumeChangePercent(0, 0), isNull);
    });

    test('tonnes with one decimal under 10 t', () {
      expect(formatTonnes(7500), '7.5');
      expect(formatTonnes(0), '0');
      expect(formatTonnes(12400), '12');
    });
  });

  group('progress to the next Body Level', () {
    test('rookie with nothing done is 0', () {
      expect(bodyLevelProgress(const BodyStats(0, 0, 0)), 0);
    });

    test('limited by the slower of sessions and week streak', () {
      // Regular -> Athlete: 6..20 buoi, 2..4 tuan.
      // 13 buoi = 50%, 3 tuan = 50%.
      expect(bodyLevelProgress(const BodyStats(13, 3, 1)), closeTo(0.5, 1e-9));
      // 20 buoi (100%) nhung chi 2 tuan (0%) -> 0.
      expect(bodyLevelProgress(const BodyStats(20, 2, 0)), 0);
    });

    test('beast is full', () {
      expect(bodyLevelProgress(const BodyStats(200, 30, 5)), 1);
    });
  });

  test('segment bar: done sessions fill, capped at the goal', () {
    expect(sessionSegments(done: 3, goal: 4), [true, true, true, false]);
    expect(sessionSegments(done: 6, goal: 4), [true, true, true, true]);
    expect(sessionSegments(done: 0, goal: 0), isEmpty);
  });
}
