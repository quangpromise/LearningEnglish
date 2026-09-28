import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
import 'package:learn_english_music/features/srs/presentation/gt_srs_review_screen.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/quest_rewards.dart';
import 'package:learn_english_music/features/today/presentation/gt_quests_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

SrsCard _card(String en, String vi) => SrsCard(
  key: en,
  en: en,
  vi: vi,
  ipa: '/$en/',
  exampleEn: 'I $en.',
  exampleVi: 'Toi $vi.',
  due: DateTime(2026, 9, 1),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Khong goi Supabase: dich vu thuong gia, khong co gi de tra.
          questRewardServiceProvider.overrideWithValue(
            QuestRewardService(
              store: DailyProgressStore.instance,
              claimOnce: (key, amount) async => 0,
              addLegacy: (amount) async {},
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: child,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('grade buttons stay disabled until the card is flipped', (
    tester,
  ) async {
    final graded = <SrsGrade>[];
    await pump(
      tester,
      Scaffold(
        body: GtGradeButtons(
          enabled: false,
          labels: const {
            SrsGrade.forgot: 'Hôm nay',
            SrsGrade.hard: '1 ngày',
            SrsGrade.know: '3 ngày',
          },
          onGrade: graded.add,
        ),
      ),
    );
    await tester.tap(find.text('Nhớ'));
    expect(graded, isEmpty);
    expect(find.text('3 ngày'), findsOneWidget);
  });

  testWidgets('flip, grade, forgotten card comes back once, then done', (
    tester,
  ) async {
    await pump(
      tester,
      GtSrsReviewScreen(
        cards: [_card('lift', 'nang'), _card('rest', 'nghi')],
        stopVoice: () {},
      ),
    );
    expect(find.text('0/2'), findsOneWidget);
    expect(find.text('lift'), findsOneWidget);
    // Nhan khoang on that cho the moi (hop 0): Quen hom nay, Kho/Nho 1 ngay.
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.text('1 ngày'), findsNWidgets(2));

    await tester.tap(find.text('lift'));
    await tester.pump();
    expect(find.text('nang'), findsOneWidget);

    await tester.tap(find.text('Quên'));
    await tester.pumpAndSettle();
    // The quen duoc dua xuong cuoi -> 1/3.
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('rest'), findsOneWidget);

    await tester.tap(find.text('rest'));
    await tester.pump();
    await tester.tap(find.text('Nhớ'));
    await tester.pumpAndSettle();
    expect(find.text('lift'), findsOneWidget);

    await tester.tap(find.text('lift'));
    await tester.pump();
    await tester.tap(find.text('Khó'));
    // Celebration co vong sang lap vo han -> pump co dinh, khong settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Xong bộ thẻ!'), findsOneWidget);
    // Nhiem vu chua dat trong test -> khong co so XP, chi dau tick.
    expect(find.textContaining('XP'), findsNothing);
    await tester.tap(find.text('Tuyệt vời'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Bạn vừa ôn 2 thẻ từ vựng.'), findsOneWidget);
  });
}
