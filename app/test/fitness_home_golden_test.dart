import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/features/fitness/data/heart_rate_model.dart';
import 'package:learn_english_music/features/fitness/data/meal_model.dart';
import 'package:learn_english_music/features/fitness/data/program_repository.dart';
import 'package:learn_english_music/features/fitness/data/workout_repository.dart';
import 'package:learn_english_music/features/fitness/presentation/fitness_home_screen.dart';
import 'package:learn_english_music/features/profile/data/profile_repository.dart';
import 'package:learn_english_music/features/wealth/data/recurring_service_model.dart';

/// Dung man Trang chu Fitness THAT (khong phai ban dung lai bang HTML) o
/// dung khung 390x787 cua anh thiet ke, roi luu ra anh de doi chieu voi
/// `docs/design/fitness-redesign/_ref.jpg`.
///
/// Chay lai anh doi chieu:
///   flutter test test/fitness_home_golden_test.dart --update-goldens
///
/// Ngoai viec chup anh, bai test nay con la chot chan chong TRAN BO CUC
/// (overflow): moi loi "RenderFlex overflowed" deu lam test that bai.
void main() {
  setUpAll(() async {
    // Vai provider chung (vd ngon ngu app) doc shared_preferences - trong
    // moi truong test khong co plugin that nen phai cam gia tri gia lap.
    SharedPreferences.setMockInitialValues({});
    // flutter_test khong tu nap font cua app - khong nap thi moi chu deu ra
    // o vuong, anh chup vo nghia.
    for (final family in ['SpaceGrotesk', 'Manrope']) {
      final loader = FontLoader(family)
        ..addFont(
          File('assets/fonts/$family.ttf')
              .readAsBytes()
              .then((b) => ByteData.view(b.buffer)),
        );
      await loader.load();
    }
    // Font icon cua Material nam trong cache cua Flutter SDK chu khong
    // trong app - khong nap thi moi icon trong anh chup deu ra o vuong.
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    final iconFont = flutterRoot == null
        ? null
        : File(
            '$flutterRoot/bin/cache/artifacts/material_fonts/'
            'materialicons-regular.otf',
          );
    if (iconFont != null && iconFont.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(iconFont.readAsBytes().then((b) => ByteData.view(b.buffer)));
      await loader.load();
    }
  });

  testWidgets('Trang chu Fitness dung dung khung 390x787, khong tran', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Toan bo du lieu that deu di qua Supabase - o day thay bang gia
          // tri co dinh de anh chup khong doi theo tai khoan dang dang nhap.
          myProfileProvider.overrideWith(
            (ref) async => const MyProfile(
              email: 'quang@example.com',
              displayName: 'Quang Hua',
              username: null,
              avatarUrl: null,
            ),
          ),
          unreadMessageCountProvider.overrideWith((ref) => Stream.value(2)),
          recurringServicesProvider.overrideWith(
            (ref) async => <RecurringService>[],
          ),
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
            (ref) async => const FitnessDashboardStats(
              streakDays: 3,
              sessionsThisWeek: 3,
              totalVolumeThisWeekKg: 7500,
              previousWeekVolumeKg: 6100,
              dailyVolumeLast7: [0, 1200, 0, 2300, 0, 1800, 2200],
            ),
          ),
          heartRateHistoryProvider.overrideWith(
            (ref) async => [
              for (var i = 0; i < 6; i++)
                HeartRateMeasurement(
                  id: '$i',
                  bpm: [78, 82, 75, 80, 77, 79][i],
                  timestamp: DateTime(2026, 9, 20, 10 + i),
                  durationSeconds: 30,
                  source: HeartRateSource.camera,
                ),
            ],
          ),
          programListProvider.overrideWith(
            (ref) => ProgramRepository().getAllPrograms(),
          ),
          activeProgramIdProvider.overrideWith((ref) async => 1),
          // Pill o thanh dau doc theo "app" dang mo - man nay luon nam
          // trong khu vuc Fitness.
          currentAppSectionProvider.overrideWith((ref) => AppSection.fitness),
        ],
        child: const MaterialApp(home: Scaffold(body: FitnessHomeScreen())),
      ),
    );
    // Cho cac provider bat dong bo (giao an doc tu file json) tra ve.
    await tester.pumpAndSettle();

    // flutter_test KHONG tu giai ma anh (moi Image.asset ve ra 1 o trong)
    // - phai nap san tung anh trong 1 vung runAsync roi ve lai khung hinh,
    // neu khong anh chup se khong co anh phong gym nao ca.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FitnessHomeScreen),
      matchesGoldenFile('goldens/fitness_home.png'),
    );
  });
}
