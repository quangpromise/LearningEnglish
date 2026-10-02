import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/milestones.dart';

const _today = '2026-10-02';

/// Ban ghi sau khi da hien het cac Milestone vua tim thay.
MilestoneRecord _after(MilestoneCheck check) => check.celebrate.fold(
  check.base,
  (record, m) => applyMilestone(record, m, today: _today),
);

void main() {
  group('detect milestones', () {
    test('first time: only a baseline, nothing celebrated', () {
      final r = detectMilestones(
        const MilestoneRecord(),
        today: _today,
        streak: 45,
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, isEmpty);
      expect(
        r.base,
        const MilestoneRecord(
          streak: 30,
          streakOn: _today,
          bodyLevel: 2,
          rank: 1,
        ),
      );
    });

    test('a streak crossing a mark is celebrated once', () {
      const before = MilestoneRecord(
        streak: 0,
        streakOn: '2026-09-25',
        bodyLevel: 0,
        rank: 0,
      );
      final six = detectMilestones(
        before,
        today: _today,
        streak: 6,
        bodyLevel: 0,
        rank: 0,
      );
      expect(six.celebrate, isEmpty);
      expect(six.base, before);
      final seven = detectMilestones(
        _after(six),
        today: _today,
        streak: 7,
        bodyLevel: 0,
        rank: 0,
      );
      expect(seven.celebrate, [(kind: MilestoneKind.streak, value: 7)]);
      // Chua hien thi chua ghi: bi ngat giua chung thi lan sau hien lai.
      expect(seven.base.streak, 0);
      final eight = detectMilestones(
        _after(seven),
        today: _today,
        streak: 8,
        bodyLevel: 0,
        rank: 0,
      );
      expect(eight.celebrate, isEmpty);
    });

    test('several kinds come in order, only the highest streak mark', () {
      final r = detectMilestones(
        const MilestoneRecord(streak: 0, bodyLevel: 1, rank: 0),
        today: _today,
        streak: 35,
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, [
        (kind: MilestoneKind.streak, value: 30),
        (kind: MilestoneKind.bodyLevel, value: 2),
        (kind: MilestoneKind.rank, value: 1),
      ]);
      expect(r.base, const MilestoneRecord(streak: 0, bodyLevel: 1, rank: 0));
      expect(
        _after(r),
        const MilestoneRecord(
          streak: 30,
          streakOn: _today,
          bodyLevel: 2,
          rank: 1,
        ),
      );
    });

    test('a broken streak that reaches the mark again is celebrated again', () {
      var r = detectMilestones(
        const MilestoneRecord(streak: 7, streakOn: '2026-09-20'),
        today: _today,
        streak: 2,
      );
      expect(r.celebrate, isEmpty);
      expect(r.base, const MilestoneRecord(streak: 0, streakOn: _today));
      r = detectMilestones(r.base, today: '2026-10-07', streak: 7);
      expect(r.celebrate, [(kind: MilestoneKind.streak, value: 7)]);
    });

    test('a dip on the day the mark was reached does not repeat it', () {
      // Vd bo co ngay nghi sau khi doi giao an: 7 -> 6 -> 7 trong 1 ngay.
      const reached = MilestoneRecord(streak: 7, streakOn: _today);
      var r = detectMilestones(reached, today: _today, streak: 6);
      expect(r.celebrate, isEmpty);
      expect(r.base, reached);
      r = detectMilestones(r.base, today: _today, streak: 7);
      expect(r.celebrate, isEmpty);
    });

    test('rank and Body Level only celebrate going up', () {
      var r = detectMilestones(
        const MilestoneRecord(bodyLevel: 3, rank: 2),
        today: _today,
        bodyLevel: 2,
        rank: 1,
      );
      expect(r.celebrate, isEmpty);
      expect(r.base, const MilestoneRecord(bodyLevel: 3, rank: 2));
      // Len lai muc da dat: khong chuc mung lai.
      r = detectMilestones(r.base, today: _today, bodyLevel: 3, rank: 2);
      expect(r.celebrate, isEmpty);
      r = detectMilestones(r.base, today: _today, bodyLevel: 4, rank: 2);
      expect(r.celebrate, [(kind: MilestoneKind.bodyLevel, value: 4)]);
    });

    test('values that came from another device are recorded quietly', () {
      final r = detectMilestones(
        const MilestoneRecord(
          streak: 0,
          streakOn: '2026-09-20',
          bodyLevel: 1,
          rank: 0,
        ),
        today: _today,
        streak: 12,
        bodyLevel: 2,
        rank: 1,
        quiet: {MilestoneKind.streak, MilestoneKind.rank},
      );
      expect(r.celebrate, [(kind: MilestoneKind.bodyLevel, value: 2)]);
      expect(
        r.base,
        const MilestoneRecord(
          streak: 7,
          streakOn: _today,
          bodyLevel: 1,
          rank: 1,
        ),
      );
    });

    test('unknown values keep their part of the record', () {
      const record = MilestoneRecord(
        streak: 30,
        streakOn: '2026-09-01',
        bodyLevel: 2,
        rank: 1,
      );
      final r = detectMilestones(record, today: _today, streak: 31);
      expect(r.celebrate, isEmpty);
      expect(r.base, record);
      expect(detectMilestones(record, today: _today).base, record);
    });

    test('long streaks reach 100 and 365', () {
      expect(streakMarkFor(6), 0);
      expect(streakMarkFor(99), 30);
      expect(streakMarkFor(100), 100);
      expect(streakMarkFor(400), 365);
      final r = detectMilestones(
        const MilestoneRecord(streak: 30),
        today: _today,
        streak: 100,
      );
      expect(r.celebrate, [(kind: MilestoneKind.streak, value: 100)]);
    });

    test('the record survives a JSON round trip', () {
      const full = MilestoneRecord(
        streak: 7,
        streakOn: _today,
        bodyLevel: 1,
        rank: 0,
      );
      expect(MilestoneRecord.fromJson(full.toJson()), full);
      const empty = MilestoneRecord();
      expect(empty.toJson(), isEmpty);
      expect(MilestoneRecord.fromJson(empty.toJson()), empty);
    });
  });
}
