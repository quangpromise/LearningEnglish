import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/milestone_store.dart';
import 'package:learn_english_music/features/today/data/milestones.dart';
import 'package:learn_english_music/features/today/presentation/milestone_watcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _watcher({
  String? userId = 'u1',
  required int visit,
  required int streak,
  BodyLevel? body,
  CefrLevel english = CefrLevel.a1,
}) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: const [GtTokens.dark]),
    home: Scaffold(
      body: GtMilestoneWatcher(
        userId: userId,
        visit: visit,
        streak: streak,
        bodyLevel: body,
        english: english,
      ),
    ),
  ),
);

/// Mo watcher (visit 0) roi "quay lai Hom nay" (visit 1) voi so lieu moi.
Future<void> _arrive(
  WidgetTester tester, {
  String? userId = 'u1',
  required int streak,
  BodyLevel? body,
  CefrLevel english = CefrLevel.a1,
}) async {
  await tester.pumpWidget(
    _watcher(userId: userId, visit: 0, streak: 0, english: english),
  );
  await tester.pumpWidget(
    _watcher(
      userId: userId,
      visit: 1,
      streak: streak,
      body: body,
      english: english,
    ),
  );
  // Cho hieu ung tien do (900 ms) + doc/ghi ban ghi + dialog vao.
  await tester.pump(const Duration(milliseconds: 950));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _close(WidgetTester tester) async {
  await tester.tap(find.text('Tuyệt vời'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('milestone record', () {
    test('kept per account', () async {
      await MilestoneStore.save('a', const MilestoneRecord(streak: 30));
      expect(await MilestoneStore.load('a'), const MilestoneRecord(streak: 30));
      expect(await MilestoneStore.load('b'), const MilestoneRecord());
    });

    test('streaks longer than 60 days are counted (100 / 365)', () async {
      var now = DateTime(2026, 1, 1, 9);
      final store = DailyProgressStore.forTest(clock: () => now);
      for (var i = 0; i < 120; i++) {
        await store.addWordsReviewed(kDailyLearnGoal);
        await store.markRestDay(true);
        now = now.add(const Duration(days: 1));
      }
      now = now.subtract(const Duration(days: 1));
      expect(store.bodyBrainStreak, 120);
    });
  });

  group('watcher', () {
    testWidgets('first time on this device: baseline only, no Celebration', (
      tester,
    ) async {
      await _arrive(tester, streak: 12, body: BodyLevel.regular);
      expect(find.byType(GtCelebration), findsNothing);
      expect(
        await MilestoneStore.load('u1'),
        const MilestoneRecord(streak: 7, bodyLevel: 1, rank: 0),
      );
    });

    testWidgets('a 7-day streak: Celebration with a tick, no XP', (
      tester,
    ) async {
      await MilestoneStore.save(
        'u1',
        const MilestoneRecord(streak: 0, bodyLevel: 0, rank: 0),
      );
      await _arrive(tester, streak: 7, body: BodyLevel.rookie);
      expect(find.byType(GtCelebration), findsOneWidget);
      expect(find.text('Chuỗi 7 ngày!'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.textContaining('XP'), findsNothing);
      await _close(tester);
      expect(find.byType(GtCelebration), findsNothing);
    });

    testWidgets('several milestones at once are shown one after another', (
      tester,
    ) async {
      await MilestoneStore.save(
        'u1',
        const MilestoneRecord(streak: 0, bodyLevel: 0, rank: 0),
      );
      await _arrive(
        tester,
        streak: 30,
        body: BodyLevel.regular,
        english: CefrLevel.a2,
      );
      final titles = <String>[];
      for (var i = 0; i < 4; i++) {
        expect(find.byType(GtCelebration), findsOneWidget, reason: '#$i');
        titles.add(
          tester.widget<GtCelebration>(find.byType(GtCelebration)).title,
        );
        await _close(tester);
      }
      expect(titles, [
        'Chuỗi 7 ngày!',
        'Chuỗi 30 ngày!',
        'Lên Body Level!',
        'Lên GymTalk Rank!',
      ]);
      expect(find.byType(GtCelebration), findsNothing);
    });

    testWidgets('signed out: nothing is checked', (tester) async {
      await MilestoneStore.save('u1', const MilestoneRecord(streak: 0));
      await _arrive(tester, userId: null, streak: 7);
      expect(find.byType(GtCelebration), findsNothing);
      expect(await MilestoneStore.load('u1'), const MilestoneRecord(streak: 0));
    });
  });
}
