import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/learn_presentation.dart';
import 'package:learn_english_music/features/english_path/data/level_test_result.dart';

PracticeItem _item(String unitId, int i) => PracticeItem(
  id: '$unitId-i$i',
  unitId: unitId,
  type: PracticeItemType.meaning,
  prompt: 'w$i',
  options: const ['a', 'b', 'c', 'd'],
  answerIndex: 0,
  sourceIds: const ['cefrj'],
);

PathUnit _unit(String id, int index) => PathUnit(
  id: id,
  index: index,
  titleEn: id,
  titleVi: id,
  words: const [],
  items: [for (var i = 0; i < 10; i++) _item(id, i)],
);

final _pack = ContentPack(
  schemaVersion: 1,
  packVersion: 'test',
  contentHash: 'h',
  approval: null,
  sources: const [],
  stages: [
    PathStage(
      stage: CefrLevel.a1,
      units: [_unit('a1-u01', 1), _unit('a1-u02', 2), _unit('a1-u03', 3)],
    ),
  ],
);

EnglishPathState _correct(Map<String, int> perUnit) {
  var s = const EnglishPathState();
  for (final e in perUnit.entries) {
    for (var i = 0; i < e.value; i++) {
      s = s.recordCorrect(e.key, '${e.key}-i$i');
    }
  }
  return s;
}

void main() {
  group('progress to the Level Test', () {
    test('counts completed units of the current stage', () {
      final p = levelTestProgress(
        _pack,
        CefrLevel.a1,
        _correct({'a1-u01': 10, 'a1-u02': 8, 'a1-u03': 3}),
      )!;
      expect(p.done, 2);
      expect(p.total, 3);
      expect(p.ready, isFalse);
      // Unit dang hoc tinh phan le: (2 + 0.3) / 3.
      expect(p.fraction, closeTo(2.3 / 3, 1e-9));
    });

    test('ready when every unit is complete', () {
      final p = levelTestProgress(
        _pack,
        CefrLevel.a1,
        _correct({'a1-u01': 10, 'a1-u02': 10, 'a1-u03': 9}),
      )!;
      expect(p.ready, isTrue);
      expect(p.fraction, 1);
    });

    test('card state follows the Level Test status', () {
      final now = DateTime(2026, 9, 28, 10);
      final allDone = _correct({'a1-u01': 10, 'a1-u02': 10, 'a1-u03': 10});
      expect(
        levelCardState(_pack, CefrLevel.a1, const EnglishPathState(), now),
        LevelCardState.learning,
      );
      expect(
        levelCardState(_pack, CefrLevel.a1, allDone, now),
        LevelCardState.testReady,
      );
      // Truot 1 gio truoc -> dang cho lam lai, khong bao "lam Level Test".
      final failed = allDone.withLevelTest(
        LevelTestResult(
          stage: CefrLevel.a1,
          correct: 1,
          total: 10,
          takenAt: now.subtract(const Duration(hours: 1)),
          wrongItemIds: const [],
        ),
      );
      expect(
        levelCardState(_pack, CefrLevel.a1, failed, now),
        LevelCardState.coolingDown,
      );
      expect(
        levelCardState(null, CefrLevel.a1, allDone, now),
        LevelCardState.noContent,
      );
      expect(
        levelCardState(_pack, CefrLevel.b2, allDone, now),
        LevelCardState.noContent,
      );
      // Da qua Level Test C1 -> het lo trinh.
      final finished = const EnglishPathState().withLevelTest(
        LevelTestResult(
          stage: CefrLevel.c1,
          correct: 10,
          total: 10,
          takenAt: now,
          wrongItemIds: const [],
        ),
      );
      expect(
        levelCardState(_pack, CefrLevel.c1, finished, now),
        LevelCardState.allDone,
      );
    });

    test('no content for the stage -> null (no fake bar)', () {
      expect(
        levelTestProgress(_pack, CefrLevel.b2, const EnglishPathState()),
        isNull,
      );
    });
  });
}
