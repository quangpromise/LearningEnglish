import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/i18n/greeting.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/english_path_providers.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/profile/data/profile_repository.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/gymtalk_sync_service.dart';
import 'package:learn_english_music/features/today/presentation/gt_today_screen.dart';
import 'package:learn_english_music/features/today/presentation/milestone_watcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Man Hom nay; [settled] = tai khoan da dong bo xong lan dau (null = chua).
/// Doi gia tri giua cac lan pump (overrideWithValue cap nhat duoc).
Widget _today({required GymTalkSettled? settled}) => ProviderScope(
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
    bodyStatsProvider.overrideWith((ref) async => const BodyStats(20, 4, 2)),
    englishLevelProvider.overrideWithValue(CefrLevel.b1),
    learningPathChoiceProvider.overrideWith((ref) async => null),
    // Giao an dang tai: the buoi tap o trang thai cho.
    todayWorkoutPlanProvider.overrideWith(
      (ref) => Completer<TodayWorkoutPlan?>().future,
    ),
    currentUserIdProvider.overrideWithValue('u1'),
    gymTalkSettledProvider.overrideWithValue(settled),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: const [GtTokens.dark]),
    home: const Scaffold(body: GtTodayScreen()),
  ),
);

MilestoneInputs _milestoneInputs(WidgetTester tester) => tester
    .widget<GtMilestoneWatcher>(
      find.byType(GtMilestoneWatcher, skipOffstage: false),
    )
    .inputs;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // 1 test duy nhat: man Hom nay dung store singleton - future tao trong zone
  // cua test truoc se treo o test sau.
  testWidgets('Today always mounts the Milestone watcher and keeps its cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_today(settled: null));
    // Doc xong store (the duoc dung lai 1 lan), Hom nay "den" (240 ms).
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    // Man 390x787: watcher van duoc dung, va khong nam trong vung cuon
    // (ListView chi dung con dang / sap hien).
    expect(
      find.byType(GtMilestoneWatcher, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byType(GtMilestoneWatcher, skipOffstage: false),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    // Chua dong bo xong lan dau: chuoi / English Level chua dung lam moc.
    expect(_milestoneInputs(tester).streak, isNull);
    expect(_milestoneInputs(tester).syncedOn, isNull);
    expect(_milestoneInputs(tester).english, isNull);
    expect(_milestoneInputs(tester).body, isNotNull);

    // Dong bo xong cho chinh tai khoan nay - hom nay.
    final today = DailyProgressStore.keyOf(DateTime.now());
    await tester.pumpWidget(_today(settled: (user: 'u1', syncedOn: today)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_milestoneInputs(tester).streak, 0);
    expect(_milestoneInputs(tester).syncedOn, today);
    expect(_milestoneInputs(tester).english, CefrLevel.b1);

    // Man cao: dung het cac the trong ListView.
    tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final rings = tester.state(find.byType(GtRingsCard));

    // Store bao doi (tien do moi): the vong giu nguyen State.
    unawaited(DailyProgressStore.instance.addWordsReviewed(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.state(find.byType(GtRingsCard)), same(rings));

    // Popup che Hom nay roi dong lai: van State cu.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('popup')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.state(find.byType(GtRingsCard)), same(rings));
    expect(
      find.byType(GtMilestoneWatcher, skipOffstage: false),
      findsOneWidget,
    );
    // Cho lan kiem Milestone + hieu ung chay xong.
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
