import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/core/widgets/gt_tick_circle.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/daily_quests.dart';
import 'package:learn_english_music/features/today/data/today_presentation.dart';
import 'package:learn_english_music/features/today/presentation/gt_quests_card.dart';
import 'package:learn_english_music/features/today/presentation/gt_today_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _none = DayProgress();
const _review = DayProgress(wordsReviewed: kDailyLearnGoal);
const _three = DayProgress(
  wordsReviewed: kDailyLearnGoal,
  speakAttempts: kDailySpeakGoal,
  handsFree: true,
);
const _four = DayProgress(
  wordsReviewed: kDailyLearnGoal,
  speakAttempts: kDailySpeakGoal,
  handsFree: true,
  trainerChat: true,
);

Widget _card(
  DayProgress day, {
  int visit = 0,
  Future<int?> Function()? open,
  bool reduce = false,
}) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: const [GtTokens.dark]),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [GtQuestsCard(day: day, visit: visit, onOpenChest: open)],
          ),
        ),
      ),
    ),
  ),
);

List<double> _ticks(WidgetTester tester) => [
  for (final w in tester.widgetList<GtTickCircle>(find.byType(GtTickCircle)))
    w.progress,
];

int _struck(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .where((t) => t.style?.decoration == TextDecoration.lineThrough)
    .length;

bool _turned(WidgetTester tester, String key) =>
    tester.widget<Transform>(find.byKey(ValueKey(key))).transform !=
    Matrix4.identity();

bool _wiggling(WidgetTester tester) => _turned(tester, 'gt-chest-wiggle');

bool _popping(WidgetTester tester) => _turned(tester, 'gt-chest-pop');

void main() {
  late List<Object?> haptics;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GtHaptics.resetForTest();
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('quest completed', () {
    testWidgets('ticks, strikes the title through and buzzes once', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_card(_none));
      expect(_ticks(tester), [0, 0, 0, 0]);
      await tester.pumpWidget(_card(_review));
      await tester.pump(const Duration(milliseconds: 150));
      expect(_ticks(tester).first, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(_ticks(tester), [1, 0, 0, 0]);
      expect(_struck(tester), 1);
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quests done before the screen opened do not replay', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_four));
      expect(_ticks(tester), [1, 1, 1, 1]);
      expect(_struck(tester), 4);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump();
      expect(haptics, isEmpty);
    });

    testWidgets('reduced motion: final state at once, still buzzes', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_none, reduce: true));
      await tester.pumpWidget(_card(_review, reduce: true));
      expect(_ticks(tester), [1, 0, 0, 0]);
      expect(_struck(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump();
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
    });

    testWidgets('a new day clears the tick without animating', (tester) async {
      await tester.pumpWidget(_card(_review));
      await tester.pumpWidget(_card(_none));
      expect(_ticks(tester), [0, 0, 0, 0]);
      expect(_struck(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('quest chest', () {
    testWidgets('shakes once when it becomes ready, then stays still', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_three));
      expect(_wiggling(tester), isFalse);
      await tester.pumpWidget(_card(_four));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_wiggling(tester), isTrue);
      await tester.pump(const Duration(milliseconds: 700));
      expect(_wiggling(tester), isFalse);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('shakes again on each return while ready, not while locked', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_four, visit: 1));
      expect(_wiggling(tester), isFalse);
      await tester.pumpWidget(_card(_four, visit: 2));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_wiggling(tester), isTrue);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpWidget(_card(_three, visit: 3));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_wiggling(tester), isFalse);
    });

    testWidgets('the first visit after the card is rebuilt is not a return', (
      tester,
    ) async {
      // Mo app / dong bo dung lai the: visit chay lai tu 0 -> 1.
      await tester.pumpWidget(_card(_four));
      await tester.pumpWidget(_card(_four, visit: 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_wiggling(tester), isFalse);
    });

    testWidgets('reduced motion: no shake', (tester) async {
      await tester.pumpWidget(_card(_three, visit: 1, reduce: true));
      await tester.pumpWidget(_card(_four, visit: 2, reduce: true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_wiggling(tester), isFalse);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('open: the icon pops first, then one celebration buzz-free', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_four, open: () async => kChestXp));
      expect(_popping(tester), isFalse);
      await tester.tap(find.text('Mở'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_popping(tester), isTrue);
      expect(find.byType(GtCelebration), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsOneWidget);
      // Chi 1 lan rung manh (luc bam), Celebration khong rung them.
      expect(haptics, ['HapticFeedbackType.heavyImpact']);
    });

    testWidgets('a claim slower than the pop still shows the chest opened', (
      tester,
    ) async {
      final claim = Completer<int?>();
      await tester.pumpWidget(_card(_four, open: () => claim.future));
      await tester.tap(find.text('Mở'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // Icon da ve cho cu, van cho server.
      expect(_popping(tester), isFalse);
      claim.complete(kChestXp);
      await tester.pump();
      // "Da mo" ngay du so lieu ngay (dang giu) chua cap nhat.
      expect(find.text('Mở'), findsNothing);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsOneWidget);
    });

    testWidgets('double tap while opening claims once', (tester) async {
      var claims = 0;
      await tester.pumpWidget(
        _card(
          _four,
          open: () async {
            claims++;
            return 0;
          },
        ),
      );
      await tester.tap(find.text('Mở'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Mở'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(claims, 1);
    });

    testWidgets('a failed open leaves the chest ready to retry', (
      tester,
    ) async {
      var tries = 0;
      await tester.pumpWidget(
        _card(
          _four,
          open: () async {
            tries++;
            throw Exception('offline');
          },
        ),
      );
      await tester.tap(find.text('Mở'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(GtCelebration), findsNothing);
      expect(_popping(tester), isFalse);
      await tester.tap(find.text('Mở'));
      expect(tries, 2);
      await tester.pumpAndSettle();
    });

    testWidgets('claimed on another device: opened, no celebration', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_four, open: () async => 0));
      await tester.tap(find.text('Mở'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GtCelebration), findsNothing);
      expect(find.text('Mở'), findsNothing);
    });

    testWidgets('an opened chest is still, with no Open button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _card(
          const DayProgress(
            wordsReviewed: kDailyLearnGoal,
            speakAttempts: kDailySpeakGoal,
            handsFree: true,
            trainerChat: true,
            chestOpened: true,
          ),
        ),
      );
      expect(_popping(tester), isFalse);
      expect(find.text('Mở'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  testWidgets('a quest and its ring arc finishing together buzz once', (
    tester,
  ) async {
    Widget today(DayProgress day) => ProviderScope(
      child: MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.dark]),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GtRingsCard(
                day: day,
                strip: List.filled(7, StreakCell.future),
                date: DateTime(2026, 10, 2),
              ),
              GtQuestsCard(day: day),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      today(const DayProgress(wordsReviewed: kDailyLearnGoal - 1)),
    );
    await tester.pumpAndSettle();
    // The on thu 10: nhiem vu On the xong + cung Hoc day ~0.2 s sau.
    await tester.pumpWidget(
      today(const DayProgress(wordsReviewed: kDailyLearnGoal)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
  });
}
