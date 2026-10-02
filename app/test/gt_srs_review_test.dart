import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
import 'package:learn_english_music/features/srs/presentation/gt_srs_review_screen.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/daily_quests.dart';
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

/// Dich vu thuong gia: khong goi Supabase, khong co gi de tra.
QuestRewardService _noRewards() => QuestRewardService(
  store: DailyProgressStore.instance,
  claimOnce: (key, amount) async => 0,
  addLegacy: (amount) async {},
);

Widget _reduced(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    QuestRewardService? rewards,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questRewardServiceProvider.overrideWithValue(rewards ?? _noRewards()),
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

  testWidgets('flip, grade, forgotten card comes back once, done in place', (
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
    // Lat 3D: nua dau van la mat truoc.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('nang'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('nang'), findsOneWidget);

    await tester.tap(find.text('Quên'));
    // The vua cham bay ra trong luc the moi vao.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('lift'), findsOneWidget);
    expect(find.text('rest'), findsOneWidget);
    await tester.pumpAndSettle();
    // The quen duoc dua xuong cuoi -> 1/3; the cu da bay di.
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('rest'), findsOneWidget);
    expect(find.text('lift'), findsNothing);

    await tester.tap(find.text('rest'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhớ'));
    await tester.pumpAndSettle();
    expect(find.text('lift'), findsOneWidget);

    await tester.tap(find.text('lift'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Khó'));
    await tester.pumpAndSettle();
    // Xong bo the: man "xong" tai cho, khong Celebration (ADR-0008).
    expect(find.byType(GtCelebration), findsNothing);
    expect(find.text('Xong bộ thẻ!'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Bạn vừa ôn 2 thẻ từ vựng.'), findsOneWidget);
    // Nhiem vu chua dat trong test -> khong co XP Toast.
    expect(find.textContaining('XP'), findsNothing);
  });

  testWidgets('tapping a grade many times grades only the current card', (
    tester,
  ) async {
    await pump(
      tester,
      GtSrsReviewScreen(
        cards: [_card('lift', 'nang'), _card('rest', 'nghi')],
        stopVoice: () {},
      ),
    );
    await tester.tap(find.text('lift'));
    await tester.pumpAndSettle();
    // 2 lan cham truoc frame ke tiep + 1 lan khi the moi dang vao.
    await tester.tap(find.text('Nhớ'));
    await tester.tap(find.text('Nhớ'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Nhớ'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
    // The ke tiep chua lat va chua bi cham.
    expect(find.text('rest'), findsOneWidget);
    expect(find.text('nghi'), findsNothing);
  });

  testWidgets('reduced motion: no flip or fly, cards change at once', (
    tester,
  ) async {
    await pump(
      tester,
      _reduced(
        GtSrsReviewScreen(
          cards: [_card('lift', 'nang'), _card('rest', 'nghi')],
          stopVoice: () {},
        ),
      ),
    );
    await tester.tap(find.text('lift'));
    await tester.pump();
    expect(find.text('nang'), findsOneWidget);
    await tester.tap(find.text('Nhớ'));
    await tester.pump();
    expect(find.text('rest'), findsOneWidget);
    // Khong co the bay ra.
    expect(find.text('lift'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('deck done shows an XP Toast only for XP really credited', (
    tester,
  ) async {
    // Nhiem vu On the da dat tren "server" gia -> lan claim nay cong XP.
    final store = DailyProgressStore.forTest();
    await store.addWordsReviewed(kDailyLearnGoal);
    await pump(
      tester,
      GtSrsReviewScreen(cards: [_card('lift', 'nang')], stopVoice: () {}),
      rewards: QuestRewardService(
        store: store,
        claimOnce: (key, amount) async => amount,
        addLegacy: (amount) async {},
      ),
    );
    await tester.tap(find.text('lift'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhớ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('+${DailyQuestId.review.xp} XP'), findsOneWidget);
    expect(find.byType(GtCelebration), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Xong bộ thẻ!'), findsOneWidget);
  });
}
