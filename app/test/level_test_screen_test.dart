import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_store.dart';
import 'package:learn_english_music/features/english_path/presentation/level_test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

PathUnit _unit(String id, int index) => PathUnit(
  id: id,
  index: index,
  titleEn: id,
  titleVi: id,
  words: const [],
  items: [
    for (var i = 0; i < 10; i++)
      PracticeItem(
        id: '$id-i$i',
        unitId: id,
        type: PracticeItemType.meaning,
        prompt: 'w$i',
        options: const ['a', 'b', 'c', 'd'],
        answerIndex: 0,
        sourceIds: const ['cefrj'],
      ),
  ],
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
  ],
);

// EnglishPathStore.instance la singleton: file nay chi 1 testWidgets.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('quitting mid-test still records the attempt', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: LevelTestScreen(pack: _pack, stage: CefrLevel.a1),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('1/20'), findsOneWidget);
    await tester.tap(find.text('a'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2/20'), findsOneWidget);
    // Thoat giua chung (nut X / quay lai): van tinh 1 lan lam - khong ne
    // duoc cooldown 24h - va khong loi luc huy man.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    final attempt = EnglishPathStore.instance.state.levelTests[CefrLevel.a1];
    expect(attempt, isNotNull);
    expect(attempt!.passed, isFalse);
  });
}
