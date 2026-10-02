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
      expect(find.textContaining('XP'), findsNothing);
      expect(find.byType(GtCelebration), findsNothing);
    });
  });

  group('Level Test passed', () {
    testWidgets('Celebration with the XP actually credited', (tester) async {
      final context = await _host(tester);
      var awarded = 0;
      celebrateLevelTestPass(
        context,
        awardXp: () async => awarded++,
        title: 'Up',
        subtitle: '18/20',
        ctaLabel: 'OK',
      );
      // Cho nguoi dung thay cau tra loi cuoi truoc.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      expect(awarded, 1);
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.text('+$kLevelTestPassXp XP'), findsOneWidget);
    });

    testWidgets('offline: Celebration with a tick, no made-up XP', (
      tester,
    ) async {
      final context = await _host(tester);
      celebrateLevelTestPass(
        context,
        awardXp: () async => throw Exception('offline'),
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
  });
}
