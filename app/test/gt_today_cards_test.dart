import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/today_presentation.dart';
import 'package:learn_english_music/features/today/presentation/gt_today_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _plan = TodayWorkoutPlan(
  program: const Program(
    id: 7,
    titleVi: 'Tăng cơ toàn thân 8 tuần',
    titleEn: 'Full-body muscle, 8 weeks',
    level: 'Mới bắt đầu',
    equipment: 'gym',
    sessionsPerWeek: 3,
    durationWeeks: 8,
    tags: [],
    days: [
      ProgramDay(dayOfWeek: 1, exercises: []),
      ProgramDay(
        dayOfWeek: 3,
        exercises: [
          ProgramExerciseRef(
            exerciseId: 1,
            targetSets: 4,
            targetRepsMin: 8,
            targetRepsMax: 12,
            orderIndex: 0,
          ),
          ProgramExerciseRef(
            exerciseId: 2,
            targetSets: 3,
            targetRepsMin: 8,
            targetRepsMax: 12,
            orderIndex: 1,
          ),
        ],
      ),
    ],
  ),
  day: const ProgramDay(
    dayOfWeek: 3,
    exercises: [
      ProgramExerciseRef(
        exerciseId: 1,
        targetSets: 4,
        targetRepsMin: 8,
        targetRepsMax: 12,
        orderIndex: 0,
      ),
      ProgramExerciseRef(
        exerciseId: 2,
        targetSets: 3,
        targetRepsMin: 8,
        targetRepsMax: 12,
        orderIndex: 1,
      ),
    ],
  ),
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.dark]),
        home: Scaffold(
          body: ListView(padding: const EdgeInsets.all(16), children: [child]),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('rings card shows the overall % and the three goals', (
    tester,
  ) async {
    await _pump(
      tester,
      GtRingsCard(
        day: const DayProgress(workouts: 1, wordsReviewed: 5),
        strip: List.filled(7, StreakCell.future),
        date: DateTime(2026, 9, 24),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Tập'), findsOneWidget);
    expect(find.text('Học'), findsOneWidget);
    expect(find.text('Nói'), findsOneWidget);
    expect(find.text('CN'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  for (final (state, cta) in [
    (TodayCardState.start, 'Bắt đầu tập'),
    (TodayCardState.done, 'Đã tập xong'),
    (TodayCardState.restDay, 'Ôn từ vựng'),
    (TodayCardState.noPlan, 'Chọn giáo án'),
    (TodayCardState.error, 'Chọn giáo án'),
  ]) {
    testWidgets('workout card: $state fits 360dp and shows "$cta"', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        GtWorkoutCard(
          state: state,
          plan: _plan,
          dueCount: 3,
          onTap: () => taps++,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text(cta), findsOneWidget);
      await tester.tap(find.text(cta));
      expect(taps, 1);
    });
  }

  testWidgets('workout card: meta and session chip for a training day', (
    tester,
  ) async {
    await _pump(
      tester,
      GtWorkoutCard(
        state: TodayCardState.start,
        plan: _plan,
        dueCount: 0,
        onTap: () {},
      ),
    );
    expect(find.text('Tăng cơ toàn thân 8 tuần'), findsOneWidget);
    expect(find.text('2 bài · 7 hiệp · ~10 phút'), findsOneWidget);
    expect(find.text('BUỔI 1/1 TUẦN NÀY'), findsOneWidget);
  });

  testWidgets('workout card: loading keeps its height without a button', (
    tester,
  ) async {
    await _pump(
      tester,
      GtWorkoutCard(
        state: TodayCardState.loading,
        plan: null,
        dueCount: 0,
        onTap: () {},
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(InkWell), findsNothing);
    expect(tester.getSize(find.byType(GtWorkoutCard)).height, 220);
  });
}
