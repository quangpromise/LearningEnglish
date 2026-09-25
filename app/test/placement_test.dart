import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/placement.dart';

/// 6 item moi Stage, dap an dung luon la option 0.
Map<CefrLevel, List<PracticeItem>> _pool({
  Iterable<CefrLevel> stages = CefrLevel.values,
}) => {
  for (final s in stages)
    s: [
      for (var i = 0; i < 6; i++)
        PracticeItem(
          id: '${s.code}-$i',
          unitId: '${s.code}-u',
          type: PracticeItemType.meaning,
          prompt: 'w$i',
          options: const ['right', 'x', 'y', 'z'],
          answerIndex: 0,
          sourceIds: const ['cefrj'],
        ),
    ],
};

var _now = DateTime(2026, 9, 25, 8);

PlacementSession _session(
  CefrLevel start, {
  Map<CefrLevel, List<PracticeItem>>? pool,
}) => PlacementSession(
  start: start,
  pool: pool ?? _pool(),
  packVersion: 'pv-1',
  random: Random(1),
  clock: () => _now = _now.add(const Duration(seconds: 5)),
);

/// Tra loi den het: moi Stage dung [correct[stage]] cau dau (mac dinh 0).
PlacementRecord _run(PlacementSession s, Map<CefrLevel, int> correct) {
  final asked = <CefrLevel, int>{};
  while (!s.isFinished) {
    final stage = s.currentStage;
    final n = asked[stage] = (asked[stage] ?? 0) + 1;
    s.answer(n <= (correct[stage] ?? 0) ? 0 : 1);
  }
  return s.record!;
}

void main() {
  group('Placement algorithm', () {
    test('brackets between a passed stage and a failed stage above it', () {
      final r = _run(_session(CefrLevel.a1), {
        CefrLevel.a1: 3,
        CefrLevel.a2: 2,
        CefrLevel.b1: 1,
      });
      expect(r.result, CefrLevel.a2);
      expect(r.stopReason, PlacementStopReason.bracketed);
      expect(r.confidence, PlacementConfidence.high);
      expect(r.answers.length, 9);
    });

    test('brackets going down: fail B1, pass A2 -> A2', () {
      final r = _run(_session(CefrLevel.b1), {CefrLevel.a2: 2});
      expect(r.result, CefrLevel.a2);
      expect(r.stopReason, PlacementStopReason.bracketed);
      expect(r.answers.length, 6);
    });

    test('pass B1, fail B2 -> B1', () {
      final r = _run(_session(CefrLevel.b1), {CefrLevel.b1: 2});
      expect(r.result, CefrLevel.b1);
      expect(r.stopReason, PlacementStopReason.bracketed);
    });

    test('A1 floor: failing A1 stops at A1', () {
      final first = _run(_session(CefrLevel.a1), {});
      expect(first.result, CefrLevel.a1);
      expect(first.stopReason, PlacementStopReason.floorA1);
      expect(first.confidence, PlacementConfidence.low);
      expect(first.answers.length, 3);

      final fromB1 = _run(_session(CefrLevel.b1), {});
      expect(fromB1.result, CefrLevel.a1);
      expect(fromB1.stopReason, PlacementStopReason.floorA1);
      expect(fromB1.confidence, PlacementConfidence.high);
      expect(fromB1.answers.length, 9);
    });

    test('C1 ceiling: passing C1 stops at C1', () {
      final all = {for (final s in CefrLevel.values) s: 3};
      final fromB1 = _run(_session(CefrLevel.b1), all);
      expect(fromB1.result, CefrLevel.c1);
      expect(fromB1.stopReason, PlacementStopReason.ceilingC1);
      expect(fromB1.confidence, PlacementConfidence.high);
      expect(fromB1.answers.length, 9);

      final fromC1 = _run(_session(CefrLevel.c1), all);
      expect(fromC1.stopReason, PlacementStopReason.ceilingC1);
      expect(fromC1.confidence, PlacementConfidence.low);
    });

    test('never asks more than 15 questions and never repeats a stage', () {
      final all = {for (final s in CefrLevel.values) s: 2};
      final r = _run(_session(CefrLevel.a1), all);
      expect(r.answers.length, 15);
      expect(r.result, CefrLevel.c1);
      for (final start in CefrLevel.values) {
        for (var mask = 0; mask < 32; mask++) {
          final correct = {
            for (final s in CefrLevel.values)
              s: (mask >> s.index) & 1 == 1 ? 3 : 0,
          };
          final rec = _run(_session(start), correct);
          expect(rec.answers.length, lessThanOrEqualTo(15));
          expect(
            rec.stageResults.length,
            rec.answers.length ~/ kPlacementItemsPerStage,
          );
        }
      }
    });

    test('2/3 passes a stage, 1/3 does not', () {
      expect(
        _run(_session(CefrLevel.a1), {
          CefrLevel.a1: 2,
        }).stageResults[CefrLevel.a1],
        isTrue,
      );
      expect(
        _run(_session(CefrLevel.a1), {
          CefrLevel.a1: 1,
        }).stageResults[CefrLevel.a1],
        isFalse,
      );
    });

    test('only asks stages that have content (pack v1 is A1 only)', () {
      final onlyA1 = _pool(stages: [CefrLevel.a1]);
      final s = _session(CefrLevel.b1, pool: onlyA1);
      expect(s.currentStage, CefrLevel.a1);
      final r = _run(s, {CefrLevel.a1: 3});
      expect(r.result, CefrLevel.a1);
      expect(r.stopReason, PlacementStopReason.noContent);
      expect(r.confidence, PlacementConfidence.low);
    });
  });

  group('Placement audit record', () {
    test('keeps every answer, stage result, reason and pack version', () {
      final s = _session(CefrLevel.a1);
      final r = _run(s, {CefrLevel.a1: 3, CefrLevel.a2: 0});
      expect(r.packVersion, 'pv-1');
      expect(r.startStage, CefrLevel.a1);
      expect(r.answers.map((a) => a.stage).toSet(), {
        CefrLevel.a1,
        CefrLevel.a2,
      });
      expect(r.answers.where((a) => a.correct).length, 3);
      expect(r.answers.map((a) => a.itemId).toSet().length, 6);
      for (final a in r.answers) {
        expect(a.itemId, startsWith(a.stage.code));
      }
      expect(r.stageResults, {CefrLevel.a1: true, CefrLevel.a2: false});
      expect(r.finishedAt.isAfter(r.startedAt), isTrue);

      final back = PlacementRecord.fromJson(jsonDecode(jsonEncode(r.toJson())));
      expect(back.result, r.result);
      expect(back.stopReason, r.stopReason);
      expect(back.confidence, r.confidence);
      expect(back.answers.length, r.answers.length);
      expect(back.stageResults, r.stageResults);
      expect(back.packVersion, 'pv-1');
    });
  });

  group('State with placement (schema v2)', () {
    test('stores the placement record and the resulting English Level', () {
      final r = _run(_session(CefrLevel.a1), {CefrLevel.a1: 3});
      final s = const EnglishPathState().withPlacement(r);
      expect(s.level, r.result);
      final back = migrateEnglishPathState(jsonDecode(jsonEncode(s.toJson())))!;
      expect(back.placement?.result, r.result);
      expect(back.level, r.result);
    });

    test('migrates v1 state without losing progress', () {
      final v1 = {
        'schemaVersion': 1,
        'level': 'A2',
        'correctItems': {
          'a1-u01': ['x'],
        },
      };
      final s = migrateEnglishPathState(v1)!;
      expect(s.level, CefrLevel.a2);
      expect(s.correctItems['a1-u01'], {'x'});
      expect(s.placement, isNull);
      expect(s.placementSkipped, isFalse);
      expect(s.toJson()['schemaVersion'], 2);
    });

    test('skipping placement is remembered without setting a level', () {
      final s = const EnglishPathState().skipPlacement();
      final back = migrateEnglishPathState(jsonDecode(jsonEncode(s.toJson())))!;
      expect(back.placementSkipped, isTrue);
      expect(back.level, isNull);
    });
  });
}
