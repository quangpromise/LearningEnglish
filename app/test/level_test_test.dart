import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/level_test.dart';

PathUnit _unit(String stage, int u, {int items = 10}) => PathUnit(
  id: '$stage-u$u',
  index: u,
  titleEn: 't',
  titleVi: 't',
  words: const [],
  items: [
    for (var i = 0; i < items; i++)
      PracticeItem(
        id: '$stage-u$u-i$i',
        unitId: '$stage-u$u',
        type: PracticeItemType.meaning,
        prompt: 'p',
        options: const ['a', 'b', 'c', 'd'],
        answerIndex: 0,
        sourceIds: const ['cefrj'],
      ),
  ],
);

ContentPack _pack() => ContentPack(
  schemaVersion: 1,
  packVersion: 'pv',
  contentHash: 'h',
  approval: null,
  sources: const [],
  stages: [
    PathStage(
      stage: CefrLevel.a1,
      units: [_unit('a1', 1), _unit('a1', 2), _unit('a1', 3)],
    ),
    PathStage(stage: CefrLevel.a2, units: [_unit('a2', 1)]),
  ],
);

/// Moi Unit cua A1 da hoan thanh (8/10 item dung).
EnglishPathState _a1Done() {
  var s = const EnglishPathState(level: CefrLevel.a1);
  for (final u in [1, 2, 3]) {
    for (var i = 0; i < 8; i++) {
      s = s.recordCorrect('a1-u$u', 'a1-u$u-i$i');
    }
  }
  return s;
}

final _t0 = DateTime(2026, 9, 25, 10);

LevelTestResult _result(
  CefrLevel stage,
  int correct, {
  int total = 20,
  DateTime? at,
}) => scoreLevelTest(
  stage: stage,
  items: [
    for (var i = 0; i < total; i++)
      PracticeItem(
        id: 'q$i',
        unitId: 'u',
        type: PracticeItemType.meaning,
        prompt: 'p',
        options: const ['a', 'b'],
        answerIndex: 0,
        sourceIds: const ['cefrj'],
      ),
  ],
  answers: [for (var i = 0; i < total; i++) i < correct ? 0 : 1],
  takenAt: at ?? _t0,
);

void main() {
  group('Opening the Level Test', () {
    test('opens only when every unit of the stage is complete', () {
      final pack = _pack();
      expect(
        levelTestStatus(
          pack,
          const EnglishPathState(level: CefrLevel.a1),
          _t0,
          stage: CefrLevel.a1,
        ),
        LevelTestStatus.locked,
      );
      expect(
        levelTestStatus(pack, _a1Done(), _t0, stage: CefrLevel.a1),
        LevelTestStatus.ready,
      );
    });

    test('has 20 questions spread over every unit of the stage', () {
      final items = buildLevelTest(_pack(), CefrLevel.a1, Random(3));
      expect(items.length, kLevelTestQuestions);
      expect(items.map((i) => i.id).toSet().length, kLevelTestQuestions);
      expect(items.map((i) => i.unitId).toSet(), {'a1-u1', 'a1-u2', 'a1-u3'});
    });

    test('uses every item when the stage has fewer than 20', () {
      final items = buildLevelTest(_pack(), CefrLevel.a2, Random(3));
      expect(items.length, 10);
    });
  });

  group('Scoring', () {
    test('passes at 80% (16/20), fails at 15/20', () {
      expect(_result(CefrLevel.a1, 16).passed, isTrue);
      expect(_result(CefrLevel.a1, 15).passed, isFalse);
    });

    test('keeps the ids of wrong answers for the review session', () {
      final r = _result(CefrLevel.a1, 17);
      expect(r.wrongItemIds, ['q17', 'q18', 'q19']);
    });

    test('passing moves the learner to the next stage', () {
      final s = _a1Done().withLevelTest(_result(CefrLevel.a1, 18));
      expect(s.level, CefrLevel.a2);
      expect(s.levelTests[CefrLevel.a1]!.passed, isTrue);
    });

    test('passing C1 keeps the learner at C1 and ends the path', () {
      const s = EnglishPathState(level: CefrLevel.c1);
      expect(passedFinalStage(s), isFalse);
      final done = s.withLevelTest(_result(CefrLevel.c1, 20));
      expect(done.level, CefrLevel.c1);
      expect(passedFinalStage(done), isTrue);
    });

    test('quitting mid-test counts unanswered questions as wrong', () {
      final r = scoreLevelTest(
        stage: CefrLevel.a1,
        items: buildLevelTest(_pack(), CefrLevel.a1, Random(1)),
        answers: [0, 0, 0],
        takenAt: _t0,
      );
      expect(r.correct, 3);
      expect(r.total, 20);
      expect(r.passed, isFalse);
      expect(r.wrongItemIds.length, 17);
    });

    test('failing keeps the level and starts a 24 h cooldown', () {
      final pack = _pack();
      final s = _a1Done().withLevelTest(_result(CefrLevel.a1, 10, at: _t0));
      expect(s.level, CefrLevel.a1);
      final almost = _t0.add(const Duration(hours: 23, minutes: 59));
      expect(
        levelTestStatus(pack, s, almost, stage: CefrLevel.a1),
        LevelTestStatus.coolingDown,
      );
      expect(retryAt(s, CefrLevel.a1), _t0.add(kLevelTestCooldown));
      final later = _t0.add(const Duration(hours: 24));
      expect(
        levelTestStatus(pack, s, later, stage: CefrLevel.a1),
        LevelTestStatus.ready,
      );
    });
  });

  group('Estimated Band', () {
    double? band(CefrLevel s, int c, int t) => estimatedBandFor(s, c, t);

    test('anchors per stage at 80%, 90% and 100%', () {
      expect(band(CefrLevel.b1, 16, 20), 4.5);
      expect(band(CefrLevel.b1, 18, 20), 4.5);
      expect(band(CefrLevel.b1, 20, 20), 5.0);
      expect(band(CefrLevel.b2, 16, 20), 5.5);
      expect(band(CefrLevel.b2, 18, 20), 6.0);
      expect(band(CefrLevel.b2, 20, 20), 6.5);
      expect(band(CefrLevel.c1, 16, 20), 7.0);
      expect(band(CefrLevel.c1, 20, 20), 7.5);
    });

    test('rounds DOWN to 0.5 on exact fractions (no floating point)', () {
      expect(band(CefrLevel.b2, 899, 1000), 5.5);
      expect(band(CefrLevel.b2, 900, 1000), 6.0);
      expect(band(CefrLevel.b2, 999, 1000), 6.0);
      expect(band(CefrLevel.b2, 1000, 1000), 6.5);
      expect(band(CefrLevel.b1, 999, 1000), 4.5);
      expect(band(CefrLevel.c1, 999, 1000), 7.0);
    });

    test('no band below 80% or for A1/A2', () {
      expect(band(CefrLevel.b2, 15, 20), isNull);
      expect(band(CefrLevel.b2, 799, 1000), isNull);
      expect(band(CefrLevel.a1, 20, 20), isNull);
      expect(band(CefrLevel.a2, 20, 20), isNull);
    });

    test('a passed B1+ result carries its band', () {
      expect(_result(CefrLevel.b2, 18).estimatedBand, 6.0);
      expect(_result(CefrLevel.a2, 20).estimatedBand, isNull);
    });
  });

  test('level test results survive the state round-trip (schema v3)', () {
    final s = _a1Done().withLevelTest(_result(CefrLevel.a1, 10, at: _t0));
    final json = jsonDecode(jsonEncode(s.toJson()));
    expect(json['schemaVersion'], kEnglishPathSchemaVersion);
    final back = migrateEnglishPathState(json)!;
    final r = back.levelTests[CefrLevel.a1]!;
    expect(r.passed, isFalse);
    expect(r.correct, 10);
    expect(r.takenAt, _t0);
    expect(r.wrongItemIds.length, 10);
  });
}
