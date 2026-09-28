import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/learn_presentation.dart';

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

    test('no content for the stage -> null (no fake bar)', () {
      expect(
        levelTestProgress(_pack, CefrLevel.b2, const EnglishPathState()),
        isNull,
      );
    });
  });
}
