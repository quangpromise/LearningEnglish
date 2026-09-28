import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/heart_rate_model.dart';
import 'package:learn_english_music/features/fitness/data/meal_model.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/fitness/data/program_repository.dart';
import 'package:learn_english_music/features/fitness/data/workout_repository.dart';
import 'package:learn_english_music/features/fitness/presentation/gt_train_screen.dart';
import 'package:learn_english_music/features/music_player/presentation/home_screen.dart'
    show greetingKeyProvider;
import 'package:learn_english_music/features/profile/data/profile_repository.dart';
import 'package:learn_english_music/features/wealth/data/recurring_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thay golden Trang chu Fitness cu (spec #70, #75): man Tap moi o khung
/// 390x787 khong tran bo cuc, so lieu lay tu provider that (o day gia lap).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Giao an 1 voi ngay tap (hoac nghi) co dinh - khong phu thuoc thu
  /// trong tuan luc chay test.
  Future<TodayWorkoutPlan> planFor({required bool restDay}) async {
    final programs = await ProgramRepository().getAllPrograms();
    final p = programs.firstWhere((p) => p.id == 1);
    final days = p.days.where((d) => d.isRestDay == restDay);
    return TodayWorkoutPlan(
      program: p,
      day: days.isEmpty
          ? const ProgramDay(dayOfWeek: 7, exercises: [])
          : days.first,
    );
  }

  List<Override> overrides({
    double lastWeekKg = 6100,
    bool measured = true,
    bool restDay = false,
  }) => [
    todayWorkoutPlanProvider.overrideWith((ref) => planFor(restDay: restDay)),
    // Danh sach bai tap that nam tren Supabase -> rong (ten hien '…').
    exerciseListProvider.overrideWith((ref) async => const <Exercise>[]),
    recurringServicesProvider.overrideWith((ref) async => <RecurringService>[]),
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
    bodyStatsProvider.overrideWith((ref) async => const BodyStats(13, 3, 1)),
    todayMealsProvider.overrideWith(
      (ref) async => const [
        Meal(
          id: 1,
          slot: MealSlot.breakfast,
          name: 'Ức gà áp chảo',
          kcal: 512,
          proteinG: 40,
          carbG: 20,
          fatG: 12,
        ),
      ],
    ),
    fitnessDashboardStatsProvider.overrideWith(
      (ref) async => FitnessDashboardStats(
        streakDays: 3,
        sessionsThisWeek: 3,
        totalVolumeThisWeekKg: 7500,
        previousWeekVolumeKg: lastWeekKg,
        dailyVolumeLast7: const [0, 1200, 0, 2300, 0, 1800, 2200],
      ),
    ),
    heartRateHistoryProvider.overrideWith(
      (ref) async => [
        if (measured)
          HeartRateMeasurement(
            id: '1',
            bpm: 78,
            timestamp: DateTime(2026, 9, 20, 10),
            durationSeconds: 30,
            source: HeartRateSource.camera,
          ),
      ],
    ),
    programListProvider.overrideWith(
      (ref) => ProgramRepository().getAllPrograms(),
    ),
    activeProgramIdProvider.overrideWith((ref) async => 1),
    learningPathChoiceProvider.overrideWith((ref) async => null),
  ];

  /// Loi tran bo cuc kem chuoi widget tao ra khoi bi tran - de CI chi dung
  /// cho can sua thay vi chi "overflowed by N pixels".
  String overflowReport(WidgetTester tester) {
    final error = tester.takeException();
    if (error == null) return '';
    final flexes = tester.allRenderObjects
        .whereType<RenderFlex>()
        .where((r) => r.toStringShort().contains('OVERFLOWING'))
        .map((r) => '${r.toStringShort()} size=${r.size} <- ${r.debugCreator}');
    return '$error\n${flexes.join('\n')}';
  }

  Future<void> pump(WidgetTester tester, List<Override> o) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: o,
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: const Scaffold(body: GtTrainScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Train tab fits 390x787 with real-shaped data', (tester) async {
    await pump(tester, overrides());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n'));
    expect(find.text('CẤP CƠ THỂ · REGULAR'), findsOneWidget);
    // 13 buoi, 3 tuan -> thieu 7 buoi va 1 tuan lien tiep (ADR-0005).
    expect(
      find.text('Lên Athlete · 50% · còn 7 buổi · 1 tuần liên tiếp'),
      findsOneWidget,
    );
    expect(find.text('Bắt đầu tập'), findsOneWidget);
    expect(find.text('+23% so với tuần trước'), findsOneWidget);
    // Gia tri + don vi nam trong cung 1 Text.rich.
    expect(find.textContaining('7.5'), findsOneWidget);
    expect(find.textContaining('78 bpm'), findsOneWidget);
    expect(find.textContaining('512 kcal'), findsOneWidget);
  });

  testWidgets('no previous week and no measurement: no fake numbers', (
    tester,
  ) async {
    await pump(tester, overrides(lastWeekKg: 0, measured: false));
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n'));
    expect(find.textContaining('so với tuần trước'), findsNothing);
    expect(find.textContaining('-- bpm'), findsOneWidget);
  });

  testWidgets('scrolls to the programs and shortcuts without overflow', (
    tester,
  ) async {
    await pump(tester, overrides());
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n'));
    expect(find.text('Giáo án'), findsOneWidget);
    expect(find.text('Cộng đồng'), findsOneWidget);
  });

  testWidgets('rest day: review CTA instead of start', (tester) async {
    await pump(tester, overrides(restDay: true));
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n'));
    expect(find.text('Ôn từ vựng'), findsOneWidget);
    expect(find.text('Bắt đầu tập'), findsNothing);
  });
}
