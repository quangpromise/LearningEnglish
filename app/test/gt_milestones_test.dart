import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/milestones.dart';

void main() {
  group('detect milestones', () {
    test('first time: only a baseline, nothing celebrated', () {
      final r = detectMilestones(
        const MilestoneRecord(),
        streak: 45,
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, isEmpty);
      expect(
        r.record,
        const MilestoneRecord(streak: 30, bodyLevel: 2, rank: 1),
      );
    });

    test('a streak crossing a mark is celebrated once', () {
      const before = MilestoneRecord(streak: 0, bodyLevel: 0, rank: 0);
      final six = detectMilestones(before, streak: 6, bodyLevel: 0, rank: 0);
      expect(six.celebrate, isEmpty);
      final seven = detectMilestones(
        six.record,
        streak: 7,
        bodyLevel: 0,
        rank: 0,
      );
      expect(seven.celebrate, [(kind: MilestoneKind.streak, value: 7)]);
      final eight = detectMilestones(
        seven.record,
        streak: 8,
        bodyLevel: 0,
        rank: 0,
      );
      expect(eight.celebrate, isEmpty);
    });

    test('several milestones at once come in order', () {
      final r = detectMilestones(
        const MilestoneRecord(streak: 0, bodyLevel: 1, rank: 0),
        streak: 30,
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, [
        (kind: MilestoneKind.streak, value: 7),
        (kind: MilestoneKind.streak, value: 30),
        (kind: MilestoneKind.bodyLevel, value: 2),
        (kind: MilestoneKind.rank, value: 1),
      ]);
    });

    test('a broken streak that reaches the mark again is celebrated again', () {
      var r = detectMilestones(const MilestoneRecord(streak: 7), streak: 2);
      expect(r.celebrate, isEmpty);
      expect(r.record.streak, 0);
      r = detectMilestones(r.record, streak: 7);
      expect(r.celebrate, [(kind: MilestoneKind.streak, value: 7)]);
    });

    test('rank and Body Level only celebrate going up', () {
      var r = detectMilestones(
        const MilestoneRecord(bodyLevel: 3, rank: 2),
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, isEmpty);
      expect(r.record, const MilestoneRecord(bodyLevel: 3, rank: 2));
      // Len lai muc da dat: khong chuc mung lai.
      r = detectMilestones(r.record, bodyLevel: 3, rank: 2);
      expect(r.celebrate, isEmpty);
      r = detectMilestones(r.record, bodyLevel: 4, rank: 2);
      expect(r.celebrate, [(kind: MilestoneKind.bodyLevel, value: 4)]);
    });

    test('unknown values keep their part of the record', () {
      final r = detectMilestones(
        const MilestoneRecord(streak: 30, bodyLevel: 2, rank: 1),
        streak: 31,
      );
      expect(r.celebrate, isEmpty);
      expect(
        r.record,
        const MilestoneRecord(streak: 30, bodyLevel: 2, rank: 1),
      );
    });

    test('long streaks reach 100 and 365', () {
      expect(streakMarkFor(99), 30);
      expect(streakMarkFor(100), 100);
      expect(streakMarkFor(400), 365);
      final r = detectMilestones(
        const MilestoneRecord(streak: 30),
        streak: 100,
      );
      expect(r.celebrate, [(kind: MilestoneKind.streak, value: 100)]);
    });

    test('the record survives a JSON round trip', () {
      const full = MilestoneRecord(streak: 7, bodyLevel: 1, rank: 0);
      expect(MilestoneRecord.fromJson(full.toJson()), full);
      const empty = MilestoneRecord();
      expect(empty.toJson(), isEmpty);
      expect(MilestoneRecord.fromJson(empty.toJson()), empty);
    });
  });
}
