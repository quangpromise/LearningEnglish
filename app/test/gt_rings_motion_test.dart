import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/today_presentation.dart';
import 'package:learn_english_music/features/today/presentation/gt_today_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _card(DayProgress day, {bool reduce = false}) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: const [GtTokens.dark]),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GtRingsCard(
                day: day,
                strip: List.filled(7, StreakCell.future),
                date: DateTime(2026, 10, 2),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  late List<MethodCall> haptics;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GtHaptics.resetForTest();
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('reduced motion: ring %, stats and arcs are final at once', (
    tester,
  ) async {
    await tester.pumpWidget(
      _card(const DayProgress(workouts: 1, wordsReviewed: 5), reduce: true),
    );
    await tester.pump();
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('5/$kDailyLearnGoal'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('counts up to the real values', (tester) async {
    await tester.pumpWidget(
      _card(const DayProgress(workouts: 1, wordsReviewed: 5)),
    );
    await tester.pumpAndSettle();
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1/$kDailyTrainGoal'), findsOneWidget);
    expect(find.text('5/$kDailyLearnGoal'), findsOneWidget);
  });

  testWidgets('first build of a full ring does not buzz', (tester) async {
    await tester.pumpWidget(
      _card(const DayProgress(workouts: 1, wordsReviewed: kDailyLearnGoal)),
    );
    await tester.pumpAndSettle();
    expect(haptics, isEmpty);
  });

  testWidgets('an arc reaching 100% buzzes once (medium)', (tester) async {
    await tester.pumpWidget(
      _card(const DayProgress(wordsReviewed: kDailyLearnGoal - 1)),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _card(const DayProgress(wordsReviewed: kDailyLearnGoal)),
    );
    await tester.pumpAndSettle();
    expect(haptics.map((c) => c.arguments), [
      'HapticFeedbackType.mediumImpact',
    ]);
    // Rebuild voi cung du lieu: khong rung lai.
    await tester.pumpWidget(
      _card(const DayProgress(wordsReviewed: kDailyLearnGoal)),
    );
    await tester.pumpAndSettle();
    expect(haptics, hasLength(1));
  });
}
