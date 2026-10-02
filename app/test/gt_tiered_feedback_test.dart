import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/feedback/gt_feedback_tier.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/features/english_path/presentation/level_test_screen.dart';

Future<BuildContext> _host(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [GtTokens.dark]),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return ctx;
}

Future<void> _celebrate(BuildContext context, int xp) => showCelebration(
  context,
  xp: xp,
  title: 'Done',
  subtitle: 'Sub',
  ctaLabel: 'OK',
);

void main() {
  group('workout finished', () {
    testWidgets('second workout of the day: XP Toast, no Celebration', (
      tester,
    ) async {
      final context = await _host(tester);
      showTieredFeedback(
        context,
        GtFeedbackEvent.workoutFinished,
        xp: 35,
        celebration: () => _celebrate(context, 35),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('+35 XP'), findsOneWidget);
      expect(find.byType(GtCelebration), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('+35 XP'), findsNothing);
    });

    testWidgets('first workout of the day: Celebration', (tester) async {
      final context = await _host(tester);
      showTieredFeedback(
        context,
        GtFeedbackEvent.workoutFinished,
        firstToday: true,
        xp: 35,
        celebration: () => _celebrate(context, 35),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.text('+35 XP'), findsOneWidget);
    });

    testWidgets('no XP earned: no toast either', (tester) async {
      final context = await _host(tester);
      showTieredFeedback(
        context,
        GtFeedbackEvent.workoutFinished,
        xp: 0,
        celebration: () => _celebrate(context, 0),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.textContaining('XP'), findsNothing);
      expect(find.byType(GtCelebration), findsNothing);
    });
  });

  group('Level Test passed', () {
    testWidgets('Celebration with the XP actually credited', (tester) async {
      final context = await _host(tester);
      var awarded = 0;
      int? credited;
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (xp) async => awarded += xp,
        onCredited: (xp) => credited = xp,
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
      );
      // Cho nguoi dung thay cau tra loi cuoi truoc.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      expect(awarded, kLevelTestPassXp);
      expect(credited, kLevelTestPassXp);
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.text('+$kLevelTestPassXp XP'), findsOneWidget);
    });

    testWidgets('a rank-up rides along in the same Celebration (#121)', (
      tester,
    ) async {
      final context = await _host(tester);
      bool? pushedWhenRecorded;
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (_) async {},
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
        rankUp: const GtRankUp(
          fromTier: 2,
          toTier: 3,
          title: 'Lên GymTalk Rank!',
          detail: 'Bậc 3: Athlete · B1',
        ),
        // Ghi moc Rank ngay khi man da day vao (Hom nay khong hien lai).
        onCelebrationShown: () => pushedWhenRecorded = Navigator.of(
          context,
          rootNavigator: true,
        ).canPop(),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 300));
      expect(pushedWhenRecorded, isTrue);
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.byType(GtRankUpCard), findsOneWidget);
      expect(find.text('Lên GymTalk Rank!'), findsOneWidget);
    });

    testWidgets('screen closed before it shows: the Rank is not recorded', (
      tester,
    ) async {
      final context = await _host(tester);
      var recorded = false;
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (_) async {},
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
        rankUp: const GtRankUp(
          fromTier: 2,
          toTier: 3,
          title: 'Lên GymTalk Rank!',
          detail: 'Bậc 3: Athlete · B1',
        ),
        onCelebrationShown: () => recorded = true,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      // Hom nay se chuc mung Rank nhu thuong.
      expect(recorded, isFalse);
      expect(find.byType(GtCelebration), findsNothing);
    });

    testWidgets('offline: Celebration with a tick, no made-up XP', (
      tester,
    ) async {
      final context = await _host(tester);
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (_) async => throw Exception('offline'),
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.textContaining('XP'), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('a hanging XP call gives up after the timeout: tick', (
      tester,
    ) async {
      final context = await _host(tester);
      int? credited;
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (_) => Completer<void>().future,
        onCredited: (xp) => credited = xp,
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(GtCelebration), findsNothing);
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 300));
      expect(credited, 0);
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('screen closed before it shows: XP kept, no Celebration', (
      tester,
    ) async {
      final context = await _host(tester);
      var awarded = 0;
      celebrateLevelTestPass(
        context,
        xp: kLevelTestPassXp,
        award: (xp) async => awarded += xp,
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      expect(awarded, kLevelTestPassXp);
      expect(find.byType(GtCelebration), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
