import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/navigation/gt_mini_player.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/english_path_providers.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/core/i18n/greeting.dart';
import 'package:learn_english_music/features/profile/data/profile_repository.dart';
import 'package:learn_english_music/features/stats/data/learning_xp_repository.dart';
import 'package:learn_english_music/features/today/data/friends_challenge_repository.dart';
import 'package:learn_english_music/features/today/presentation/gt_progress_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Loi tran bo cuc kem chuoi widget tao ra khoi bi tran.
  String overflowReport(WidgetTester tester) {
    final error = tester.takeException();
    if (error == null) return '';
    final flexes = tester.allRenderObjects
        .whereType<RenderFlex>()
        .where((r) => r.toStringShort().contains('OVERFLOWING'))
        .map((r) => '${r.toStringShort()} size=${r.size} <- ${r.debugCreator}');
    return '$error\n${flexes.join('\n')}';
  }

  final today = DateTime.now();
  DateTime daysAgo(int n) => DateTime(today.year, today.month, today.day - n);

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool weekFails = false,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
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
        // 20 buoi, chuoi 4 tuan -> Athlete; English B1 -> rank bac 3.
        bodyStatsProvider.overrideWith(
          (ref) async => const BodyStats(20, 4, 2),
        ),
        englishLevelProvider.overrideWithValue(CefrLevel.b1),
        learningPathChoiceProvider.overrideWith((ref) async => null),
        myLearningXpProvider.overrideWith(
          (ref) async => const LearningXp(
            xp: 2480,
            level: 8,
            xpInLevel: 0,
            xpToNext: 0,
            levelKey: 'x',
          ),
        ),
        weeklyActivitySecondsProvider('english').overrideWith(
          (ref) async => weekFails
              ? throw Exception('offline')
              : {daysAgo(0): 1500, daysAgo(2): 3000},
        ),
        weeklyActivitySecondsProvider('fitness')
            .overrideWith((ref) async => {daysAgo(0): 2700, daysAgo(1): 3600}),
        friendsChallengeProvider.overrideWith(
          (ref) async => const <FriendChallengeEntry>[],
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: const Scaffold(body: GtProgressScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('rank card follows ADR-0005 and the week total is real', (
    tester,
  ) async {
    await pump(tester);
    expect(overflowReport(tester), isEmpty);
    expect(find.text('Athlete · B1'), findsOneWidget);
    expect(find.textContaining('GymTalk Rank 3/5'), findsOneWidget);
    expect(find.textContaining('2480 XP'), findsOneWidget);
    // 25 + 50 phut hoc + 45 + 60 phut tap = 180 phut.
    expect(find.text('3 giờ 0 phút'), findsOneWidget);
  });

  testWidgets('week error shows a message, not a fake chart', (tester) async {
    await pump(tester, weekFails: true);
    expect(overflowReport(tester), isEmpty);
    expect(find.text('Chưa tải được hoạt động tuần'), findsOneWidget);
  });

  testWidgets('settings: About shows both authors and the build (#138)', (
    tester,
  ) async {
    await pump(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    // The Nhac nho phia tren tai xong co the cao them, day hang xuong duoi
    // man: dua hang vao giua man lan nua roi moi cham.
    final about = find.text('Giới thiệu', skipOffstage: false);
    await tester.ensureVisible(about);
    await tester.pumpAndSettle();
    await tester.ensureVisible(about);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giới thiệu'));
    await tester.pumpAndSettle();
    expect(overflowReport(tester), isEmpty);
    expect(find.text('Quang Promise'), findsOneWidget);
    expect(find.text('Tùng Micky'), findsOneWidget);
    // Build tai cho (khong co SHA cua CI).
    expect(find.text('dev'), findsOneWidget);
    // Nut giay phep o cuoi trang Gioi thieu: cuon trong trang.
    await tester.dragUntilVisible(
      find.text('Giấy phép mã nguồn mở'),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    expect(find.text('Giấy phép mã nguồn mở'), findsOneWidget);
  });

  testWidgets('settings: mini player can be turned back on', (tester) async {
    final container = await pump(tester);
    await container.read(miniPlayerVisibleProvider.notifier).set(false);
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(overflowReport(tester), isEmpty);
    await tester.tap(find.text('Mini player'));
    await tester.pumpAndSettle();
    expect(container.read(miniPlayerVisibleProvider), isTrue);
  });
}
