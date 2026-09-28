import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_providers.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/presentation/gt_learn_screen.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/music_player/presentation/home_screen.dart'
    show greetingKeyProvider;
import 'package:learn_english_music/features/profile/data/profile_repository.dart';
import 'package:learn_english_music/features/wealth/data/recurring_service_model.dart';
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

ContentPack _pack(List<PathStage> stages) => ContentPack(
  schemaVersion: 1,
  packVersion: 'test',
  contentHash: 'h',
  approval: null,
  sources: const [],
  stages: stages,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Loi tran bo cuc kem chuoi widget tao ra khoi bi tran.
  String overflowReport(WidgetTester tester) {
    final error = tester.takeException();
    if (error == null) return '';
    final flexes = tester.allRenderObjects
        .whereType<RenderFlex>()
        .where((r) => r.toStringShort().contains('OVERFLOWING'))
        .map((r) => '${r.toStringShort()} size=${r.size} <- ${r.debugCreator}');
    return '$error\n${flexes.join('\n')}';
  }

  Future<void> pump(
    WidgetTester tester,
    ContentPack pack, {
    ({int learned, int total, bool loaded}) daily = (
      learned: 3,
      total: 12,
      loaded: true,
    ),
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          greetingKeyProvider.overrideWithValue('home_greeting_morning'),
          myProfileProvider.overrideWith(
            (ref) async => const MyProfile(
              email: 'quang@example.com',
              displayName: 'Quang Hua',
              username: null,
              avatarUrl: null,
            ),
          ),
          unreadMessageCountProvider.overrideWith((ref) => Stream.value(0)),
          bodyStatsProvider.overrideWith(
            (ref) async => const BodyStats(0, 0, 0),
          ),
          learningPathChoiceProvider.overrideWith((ref) async => null),
          recurringServicesProvider.overrideWith(
            (ref) async => <RecurringService>[],
          ),
          englishLevelProvider.overrideWithValue(CefrLevel.a1),
          englishPathStateProvider.overrideWithValue(const EnglishPathState()),
          contentPackProvider.overrideWith((ref) async => pack),
          // Controller that dat thong bao/Timer -> dung tom tat co dinh.
          dailyWordsSummaryProvider.overrideWithValue(daily),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: const Scaffold(body: GtLearnScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Learn tab fits 390x787 and shows the Level Test progress', (
    tester,
  ) async {
    await pump(
      tester,
      _pack([
        PathStage(
          stage: CefrLevel.a1,
          units: [_unit('a1-u01', 1), _unit('a1-u02', 2)],
        ),
      ]),
    );
    expect(overflowReport(tester), isEmpty);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('0/2 Unit tới Level Test'), findsOneWidget);
    expect(find.text('Học 12 từ hôm nay'), findsOneWidget);
    expect(find.text('3/12 từ đã học hôm nay'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Huy cay -> huy DailyWordsController (Timer nua dem).
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no content for the stage: no progress bar', (tester) async {
    await pump(
      tester,
      _pack(const []),
      daily: (learned: 0, total: 0, loaded: false),
    );
    // Chua tai tu vung -> khong hien so "Hoc 0 tu".
    expect(find.text('Học từ mới hôm nay'), findsOneWidget);
    expect(overflowReport(tester), isEmpty);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    // Huy cay -> huy DailyWordsController (Timer nua dem).
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('scrolls to speaking and exams without overflow', (tester) async {
    await pump(tester, _pack(const []));
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(overflowReport(tester), isEmpty);
    expect(find.text('LUYỆN NÓI'), findsOneWidget);
    expect(find.text('TOEIC'), findsOneWidget);
    // Huy cay -> huy DailyWordsController (Timer nua dem).
    await tester.pumpWidget(const SizedBox());
  });
}
