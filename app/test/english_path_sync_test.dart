import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/english_path_store.dart';
import 'package:learn_english_music/features/english_path/data/english_path_sync.dart';
import 'package:learn_english_music/features/english_path/data/level_test_result.dart';
import 'package:learn_english_music/features/english_path/data/placement.dart';
import 'package:shared_preferences/shared_preferences.dart';

LevelTestResult _test(CefrLevel s, int correct, DateTime at) => LevelTestResult(
  stage: s,
  correct: correct,
  total: 20,
  takenAt: at,
  wrongItemIds: const [],
);

PlacementRecord _placement(CefrLevel result, DateTime at) => PlacementRecord(
  packVersion: 'pv',
  startStage: CefrLevel.a1,
  result: result,
  stopReason: PlacementStopReason.bracketed,
  confidence: PlacementConfidence.high,
  answers: const [],
  stageResults: const {},
  startedAt: at,
  finishedAt: at,
);

final _d1 = DateTime.utc(2026, 9, 20);
final _d2 = DateTime.utc(2026, 9, 25);

void main() {
  group('mergeEnglishPathState', () {
    test('unions correct items and wrong items', () {
      final a = const EnglishPathState()
          .recordCorrect('u1', 'i1')
          .recordWrong('i9');
      final b = const EnglishPathState()
          .recordCorrect('u1', 'i2')
          .recordCorrect('u2', 'j1')
          .recordWrong('i8');
      final m = mergeEnglishPathState(a, b);
      expect(m.correctItems['u1'], {'i1', 'i2'});
      expect(m.correctItems['u2'], {'j1'});
      expect(m.wrongItems, {'i8', 'i9'});
    });

    test('an item fixed on one device does not come back from the other', () {
      // May A: sai i1 roi sau do tra loi dung.
      final a = const EnglishPathState()
          .recordWrong('i1')
          .recordCorrect('u1', 'i1');
      // May B: chi thay lan sai cu.
      final b = const EnglishPathState().recordWrong('i1').recordWrong('i2');
      expect(mergeEnglishPathState(a, b).wrongItems, {'i2'});
      expect(mergeEnglishPathState(b, a).wrongItems, {'i2'});
    });

    test('English Level takes the higher stage', () {
      const a = EnglishPathState(level: CefrLevel.a2);
      const b = EnglishPathState(level: CefrLevel.b1);
      expect(mergeEnglishPathState(a, b).level, CefrLevel.b1);
      expect(mergeEnglishPathState(b, a).level, CefrLevel.b1);
      expect(
        mergeEnglishPathState(a, const EnglishPathState()).level,
        CefrLevel.a2,
      );
    });

    test('Level Test and Placement take the newer record', () {
      final a = const EnglishPathState()
          .withLevelTest(_test(CefrLevel.a1, 10, _d1))
          .withPlacement(_placement(CefrLevel.a1, _d2));
      final b = const EnglishPathState()
          .withLevelTest(_test(CefrLevel.a1, 18, _d2))
          .withPlacement(_placement(CefrLevel.b1, _d1));
      final m = mergeEnglishPathState(a, b);
      expect(m.levelTests[CefrLevel.a1]!.correct, 18);
      expect(m.placement!.result, CefrLevel.a1);
    });

    test('is idempotent and order-independent', () {
      final a = const EnglishPathState(level: CefrLevel.a2)
          .recordCorrect('u1', 'i1')
          .withLevelTest(_test(CefrLevel.a1, 18, _d1));
      final b = const EnglishPathState()
          .recordCorrect('u1', 'i2')
          .skipPlacement();
      final ab = mergeEnglishPathState(a, b).toJson();
      expect(mergeEnglishPathState(b, a).toJson(), ab);
      final twice = mergeEnglishPathState(mergeEnglishPathState(a, b), b);
      expect(twice.toJson(), ab);
    });
  });

  group('EnglishPathStore remote merge', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('merges a remote state and allows upload', () async {
      final store = EnglishPathStore.forTest();
      await store.recordCorrect('u1', 'i1');
      final remote = const EnglishPathState(level: CefrLevel.b1)
          .recordCorrect('u1', 'i2')
          .toJson();
      final result = await store.mergeRemote(jsonDecode(jsonEncode(remote)));
      expect(result, RemoteMergeResult.merged);
      expect(store.state.level, CefrLevel.b1);
      expect(store.state.correctItems['u1'], {'i1', 'i2'});
      expect(store.canUpload, isTrue);
      expect(store.exportJson()['schemaVersion'], kEnglishPathSchemaVersion);
    });

    test('keeps local and never uploads over a newer remote version', () async {
      final store = EnglishPathStore.forTest();
      await store.recordCorrect('u1', 'i1');
      final result = await store.mergeRemote({
        'schemaVersion': kEnglishPathSchemaVersion + 1,
        'level': 'C1',
      });
      expect(result, RemoteMergeResult.remoteIsNewer);
      expect(store.state.correctItems['u1'], {'i1'});
      expect(store.state.level, isNull);
      expect(store.canUpload, isFalse);
    });

    test('ignores a corrupt remote and keeps uploading local', () async {
      final store = EnglishPathStore.forTest();
      await store.recordCorrect('u1', 'i1');
      expect(await store.mergeRemote('garbage'), RemoteMergeResult.ignored);
      expect(await store.mergeRemote(null), RemoteMergeResult.ignored);
      expect(store.state.correctItems['u1'], {'i1'});
      expect(store.canUpload, isTrue);
    });

    test('local state from a newer app is never uploaded', () async {
      SharedPreferences.setMockInitialValues({
        kEnglishPathPrefKey: jsonEncode({'schemaVersion': 999}),
      });
      final store = EnglishPathStore.forTest();
      await store.ensureLoaded();
      expect(store.canUpload, isFalse);
    });

    test('local state from a newer app is kept in memory too', () async {
      SharedPreferences.setMockInitialValues({
        kEnglishPathPrefKey: jsonEncode({'schemaVersion': 999}),
      });
      final store = EnglishPathStore.forTest();
      final remote = const EnglishPathState(level: CefrLevel.c1).toJson();
      expect(await store.mergeRemote(remote), RemoteMergeResult.ignored);
      expect(store.state.level, isNull);
    });

    test('clearLocal wipes progress for an account switch', () async {
      final store = EnglishPathStore.forTest();
      await store.recordCorrect('u1', 'i1');
      await store.clearLocal();
      expect(store.state.correctItems, isEmpty);
      final again = EnglishPathStore.forTest();
      await again.ensureLoaded();
      expect(again.state.correctItems, isEmpty);
    });
  });
}
