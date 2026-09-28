import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/srs/data/srs_grading.dart';

void main() {
  group('3-grade schedule (spec #70 decision)', () {
    test('forgot resets to box 0, due today (re-queued this session)', () {
      expect(nextSchedule(3, SrsGrade.forgot), (box: 0, days: 0));
    });

    test('hard keeps the box and comes back tomorrow', () {
      expect(nextSchedule(3, SrsGrade.hard), (box: 3, days: 1));
      expect(nextSchedule(0, SrsGrade.hard), (box: 0, days: 1));
    });

    test('know moves up one box with that box interval', () {
      expect(nextSchedule(0, SrsGrade.know), (box: 1, days: 1));
      expect(nextSchedule(1, SrsGrade.know), (box: 2, days: 3));
      expect(nextSchedule(3, SrsGrade.know), (box: 4, days: 16));
    });

    test('know at the top box stays at the top', () {
      expect(nextSchedule(kSrsMaxBox, SrsGrade.know), (
        box: kSrsMaxBox,
        days: kSrsIntervalsDays[kSrsMaxBox],
      ));
    });

    test('the old known/forgot API maps to know/forgot', () {
      expect(gradeFromKnown(known: true), SrsGrade.know);
      expect(gradeFromKnown(known: false), SrsGrade.forgot);
    });
  });

  group('interval label on the buttons', () {
    test('0 days -> again today, otherwise n days', () {
      expect(intervalLabel(0, today: 'Hôm nay', days: '{n} ngày'), 'Hôm nay');
      expect(intervalLabel(1, today: 'Hôm nay', days: '{n} ngày'), '1 ngày');
      expect(intervalLabel(16, today: 'Hôm nay', days: '{n} ngày'), '16 ngày');
    });
  });

  test('session re-queues forgotten cards once, at the end', () {
    final q = requeueAfterGrade(
      ['a', 'b', 'c'],
      index: 0,
      grade: SrsGrade.forgot,
    );
    expect(q, ['a', 'b', 'c', 'a']);
    expect(requeueAfterGrade(['a', 'b'], index: 0, grade: SrsGrade.hard), [
      'a',
      'b',
    ]);
    // Da quen lan 2 trong phien -> khong lap vo han.
    expect(
      requeueAfterGrade(['a', 'b', 'a'], index: 2, grade: SrsGrade.forgot),
      ['a', 'b', 'a'],
    );
  });
}
