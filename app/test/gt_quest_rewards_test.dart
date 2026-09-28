import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/daily_quests.dart';
import 'package:learn_english_music/features/today/data/quest_rewards.dart';
import 'package:learn_english_music/features/today/presentation/gt_quests_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  DailyProgressStore newStore() =>
      DailyProgressStore.forTest(clock: () => DateTime(2026, 9, 24, 10));

  group('QuestRewardService', () {
    test('awards each done quest once, even when claimed twice', () async {
      final store = newStore();
      final added = <int>[];
      final service = QuestRewardService(
        store: store,
        addXp: (a) async => added.add(a),
      );
      await store.addWordsReviewed(kDailyLearnGoal);
      await store.markHandsFreeDone();

      final results = await Future.wait([
        service.claimPendingQuests(),
        service.claimPendingQuests(),
      ]);
      expect(results.fold<int>(0, (a, b) => a + b), 30 + 25);
      expect(added..sort(), [25, 30]);
      expect(await service.claimPendingQuests(), 0);
      expect(store.today.rewarded, {'quest_review', 'quest_handsFree'});
    });

    test('a failed RPC releases the key so it is retried', () async {
      final store = newStore();
      var fail = true;
      final service = QuestRewardService(
        store: store,
        addXp: (a) async {
          if (fail) throw Exception('offline');
        },
      );
      await store.markTrainerChatDone();
      expect(await service.claimPendingQuests(), 0);
      expect(store.today.rewarded, isEmpty);
      fail = false;
      expect(await service.claimPendingQuests(), DailyQuestId.trainerChat.xp);
    });

    test('chest opens only at 4/4 and only once a day', () async {
      final store = newStore();
      final added = <int>[];
      final service = QuestRewardService(
        store: store,
        addXp: (a) async => added.add(a),
      );
      expect(await service.openChest(), isNull);
      await store.addWordsReviewed(kDailyLearnGoal);
      for (var i = 0; i < kDailySpeakGoal; i++) {
        await store.addSpeakAttempt();
      }
      await store.markHandsFreeDone();
      await store.markTrainerChatDone();

      final both = await Future.wait([
        service.openChest(),
        service.openChest(),
      ]);
      expect(both.whereType<int>(), [kChestXp]);
      expect(store.today.chestOpened, isTrue);
      expect(await service.openChest(), isNull);
      expect(added, [kChestXp]);
    });

    test('a failed chest RPC closes the chest again', () async {
      final store = newStore();
      final service = QuestRewardService(
        store: store,
        addXp: (a) async => throw Exception('offline'),
      );
      await store.addWordsReviewed(kDailyLearnGoal);
      for (var i = 0; i < kDailySpeakGoal; i++) {
        await store.addSpeakAttempt();
      }
      await store.markHandsFreeDone();
      await store.markTrainerChatDone();
      expect(await service.openChest(), isNull);
      expect(store.today.chestOpened, isFalse);
      expect(chestState(store.today), ChestState.ready);
    });
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [child],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('quests card: 4 rows with XP, ticks and a locked chest', (
    tester,
  ) async {
    await pump(
      tester,
      const GtQuestsCard(day: DayProgress(wordsReviewed: kDailyLearnGoal)),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('1/4'), findsOneWidget);
    for (final q in DailyQuestId.values) {
      expect(find.text('+${q.xp} XP'), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Hoàn thành 3 nhiệm vụ nữa để mở rương'), findsOneWidget);
    expect(find.text('Mở'), findsNothing);
  });

  testWidgets('quests card: open button appears at 4/4', (tester) async {
    var opened = 0;
    await pump(
      tester,
      GtQuestsCard(
        day: const DayProgress(
          wordsReviewed: kDailyLearnGoal,
          speakAttempts: kDailySpeakGoal,
          handsFree: true,
          trainerChat: true,
        ),
        onOpenChest: () => opened++,
      ),
    );
    expect(find.text('Rương đã sẵn sàng!'), findsOneWidget);
    await tester.tap(find.text('Mở'));
    expect(opened, 1);
  });

  testWidgets('celebration shows the real XP and closes', (tester) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.dark]),
        home: GtCelebration(
          xp: kChestXp,
          title: 'Done',
          subtitle: 'Sub',
          ctaLabel: 'OK',
          chips: const ['3-day streak'],
          onClose: () => closed = true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('+$kChestXp XP'), findsOneWidget);
    expect(find.text('3-day streak'), findsOneWidget);
    await tester.tap(find.text('OK'));
    expect(closed, isTrue);
  });

  testWidgets('XP toast shows +N XP then removes itself', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.dark]),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
    showXpToast(55, overlay: overlay);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('+55 XP'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('+55 XP'), findsNothing);
  });
}
