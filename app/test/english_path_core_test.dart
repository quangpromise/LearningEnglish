import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_progress.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/english_path_store.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

PracticeItem _item(String unitId, int i) => PracticeItem(
  id: '$unitId-i$i',
  unitId: unitId,
  type: PracticeItemType.meaning,
  prompt: 'w$i',
  options: const ['a', 'b', 'c', 'd'],
  answerIndex: 0,
  sourceIds: const ['cefrj'],
);

PathUnit _unit(String id, int index, {int items = 10}) => PathUnit(
  id: id,
  index: index,
  titleEn: id,
  titleVi: id,
  words: const [],
  items: [for (var i = 0; i < items; i++) _item(id, i)],
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
      units: [_unit('a1-u01', 1), _unit('a1-u02', 2)],
    ),
    PathStage(stage: CefrLevel.a2, units: [_unit('a2-u01', 1)]),
  ],
);

EnglishPathState _withCorrect(String unitId, Iterable<int> items) {
  var s = const EnglishPathState();
  for (final i in items) {
    s = s.recordCorrect(unitId, '$unitId-i$i');
  }
  return s;
}

void main() {
  group('Unit progress', () {
    final unit = _pack.stages.first.units.first;

    test('counts each item answered correctly at least once', () {
      final s = _withCorrect('a1-u01', [0, 1, 1, 2]);
      expect(unitProgress(unit, s), closeTo(0.3, 1e-9));
    });

    test('is complete at exactly 80%, not at 70%', () {
      expect(isUnitComplete(unit, _withCorrect('a1-u01', _range(7))), isFalse);
      expect(isUnitComplete(unit, _withCorrect('a1-u01', _range(8))), isTrue);
    });

    test('boundary on a real 15-item unit: 12/15 done, 11/15 not', () {
      final unit15 = _unit('a1-u09', 9, items: 15);
      expect(
        isUnitComplete(unit15, _withCorrect('a1-u09', _range(11))),
        isFalse,
      );
      expect(
        isUnitComplete(unit15, _withCorrect('a1-u09', _range(12))),
        isTrue,
      );
    });

    test('does not need correct answers in a row', () {
      // Sai giua chung khong lam mat cac cau da dung truoc do.
      var s = _withCorrect('a1-u01', _range(5));
      s = s.recordCorrect('a1-u01', 'a1-u01-i5');
      s = s.recordCorrect('a1-u01', 'a1-u01-i6');
      s = s.recordCorrect('a1-u01', 'a1-u01-i7');
      expect(isUnitComplete(unit, s), isTrue);
    });

    test('ignores correct answers from other units', () {
      final s = _withCorrect('a1-u02', _range(10));
      expect(unitProgress(unit, s), 0);
    });
  });

  group('Next unit', () {
    test('is the first incomplete unit of the current stage', () {
      expect(
        nextUnit(_pack, CefrLevel.a1, const EnglishPathState())?.id,
        'a1-u01',
      );
      final s = _withCorrect('a1-u01', _range(8));
      expect(nextUnit(_pack, CefrLevel.a1, s)?.id, 'a1-u02');
    });

    test('is null when every unit of the stage is complete', () {
      var s = _withCorrect('a1-u01', _range(8));
      for (final i in _range(10)) {
        s = s.recordCorrect('a1-u02', 'a1-u02-i$i');
      }
      expect(nextUnit(_pack, CefrLevel.a1, s), isNull);
      expect(allUnitsComplete(_pack, CefrLevel.a1, s), isTrue);
    });

    test('is null for a stage the pack has no content for', () {
      expect(nextUnit(_pack, CefrLevel.c1, const EnglishPathState()), isNull);
      expect(
        allUnitsComplete(_pack, CefrLevel.c1, const EnglishPathState()),
        isFalse,
      );
    });
  });

  test('session puts not-yet-correct items first', () {
    final unit = _pack.stages.first.units.first;
    final s = _withCorrect('a1-u01', [0, 1]);
    final order = sessionItems(unit, s).map((i) => i.id).toList();
    expect(order.length, 10);
    expect(order.take(8), isNot(contains('a1-u01-i0')));
    expect(order.skip(8), containsAll(['a1-u01-i0', 'a1-u01-i1']));
  });

  group('English Level', () {
    test('persona only decides the starting stage', () {
      expect(defaultLevelForPersona(null), CefrLevel.a1);
      expect(defaultLevelForPersona(LearningPersona.beginner), CefrLevel.a1);
      for (final p in [
        LearningPersona.dailyConversation,
        LearningPersona.grammarOverhaul,
      ]) {
        expect(defaultLevelForPersona(p), CefrLevel.a2);
      }
      for (final p in [
        LearningPersona.officeEnglish,
        LearningPersona.toeicPrep,
        LearningPersona.ieltsPrep,
      ]) {
        expect(defaultLevelForPersona(p), CefrLevel.b1);
      }
    });

    test('a stored English Level wins over the persona default', () {
      const s = EnglishPathState(level: CefrLevel.b2);
      expect(effectiveLevel(s, LearningPersona.beginner), CefrLevel.b2);
      expect(
        effectiveLevel(const EnglishPathState(), LearningPersona.ieltsPrep),
        CefrLevel.b1,
      );
    });
  });

  group('State schema', () {
    test('round-trips through JSON with a schemaVersion', () {
      final s = _withCorrect('a1-u01', [0, 3]).copyWith(level: CefrLevel.a2);
      final json = s.toJson();
      expect(json['schemaVersion'], kEnglishPathSchemaVersion);
      final back = migrateEnglishPathState(jsonDecode(jsonEncode(json)));
      expect(back, isNotNull);
      expect(back!.level, CefrLevel.a2);
      expect(back.correctItems['a1-u01'], {'a1-u01-i0', 'a1-u01-i3'});
    });

    test('ignores a newer or unknown schema version', () {
      expect(migrateEnglishPathState({'schemaVersion': 999}), isNull);
      expect(migrateEnglishPathState({'schemaVersion': 'x'}), isNull);
      expect(migrateEnglishPathState('garbage'), isNull);
    });

    test('missing version is treated as broken, not as v1', () {
      expect(migrateEnglishPathState({'level': 'A1'}), isNull);
      expect(isFromNewerVersion({'level': 'A1'}), isFalse);
    });

    test('only a higher integer version counts as written by a newer app', () {
      expect(isFromNewerVersion({'schemaVersion': 999}), isTrue);
      expect(isFromNewerVersion({'schemaVersion': 1}), isFalse);
      expect(isFromNewerVersion('garbage'), isFalse);
    });
  });

  group('EnglishPathStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('persists correct answers and level', () async {
      final store = EnglishPathStore.forTest();
      await store.ensureLoaded();
      await store.recordCorrect('a1-u01', 'a1-u01-i0');
      await store.setLevel(CefrLevel.a2);

      final again = EnglishPathStore.forTest();
      await again.ensureLoaded();
      expect(again.state.level, CefrLevel.a2);
      expect(again.state.correctItems['a1-u01'], {'a1-u01-i0'});
    });

    test('resets corrupt local data but keeps a backup copy', () async {
      SharedPreferences.setMockInitialValues({kEnglishPathPrefKey: '{oops'});
      final store = EnglishPathStore.forTest();
      await store.ensureLoaded();
      await store.recordCorrect('a1-u01', 'a1-u01-i0');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kEnglishPathCorruptBackupKey), '{oops');
      final again = EnglishPathStore.forTest();
      await again.ensureLoaded();
      expect(again.state.correctItems['a1-u01'], {'a1-u01-i0'});
    });

    test('never overwrites state written by a newer app version', () async {
      final newer = jsonEncode({'schemaVersion': 999, 'future': true});
      SharedPreferences.setMockInitialValues({kEnglishPathPrefKey: newer});
      final store = EnglishPathStore.forTest();
      await store.ensureLoaded();
      expect(store.state.level, isNull);
      await store.recordCorrect('a1-u01', 'a1-u01-i0');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kEnglishPathPrefKey), newer);
    });
  });
}

Iterable<int> _range(int n) => Iterable<int>.generate(n);
