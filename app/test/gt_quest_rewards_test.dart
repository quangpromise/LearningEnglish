import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/core/widgets/gt_tick_circle.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/daily_quests.dart';
import 'package:learn_english_music/features/today/data/quest_rewards.dart';
import 'package:learn_english_music/features/stats/data/learning_xp_repository.dart';
import 'package:learn_english_music/features/today/presentation/gt_quests_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gia lap `claim_learning_xp`: 1 bang khoa dung chung cho moi "may".
class _FakeServer {
  final keys = <String>{};
  var xp = 0;
  var failing = false;
  var legacyOnly = false;

  Future<int> claimOnce(String key, int amount) async {
    await Future<void>.delayed(Duration.zero);
    if (legacyOnly) throw const XpRewardKeysUnavailable();
    if (failing) throw Exception('offline');
    if (!keys.add(key)) return 0;
    xp += amount;
    return amount;
  }

  Future<void> addLegacy(int amount) async {
    if (failing) throw Exception('offline');
    xp += amount;
  }
}

final _now = DateTime(2026, 9, 24, 10);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  DailyProgressStore newStore() =>
      DailyProgressStore.forTest(clock: () => _now);

  QuestRewardService serviceFor(
    DailyProgressStore store,
    _FakeServer server, {
    DateTime Function()? clock,
  }) => QuestRewardService(
    store: store,
    claimOnce: server.claimOnce,
    addLegacy: server.addLegacy,
    clock: clock ?? () => _now,
  );

  Future<void> finishAllQuests(DailyProgressStore store) async {
    await store.addWordsReviewed(kDailyLearnGoal);
    for (var i = 0; i < kDailySpeakGoal; i++) {
      await store.addSpeakAttempt();
    }
    await store.markHandsFreeDone();
    await store.markTrainerChatDone();
  }

  group('QuestRewardService', () {
    test('pays each done quest once with a dated server key', () async {
      final store = newStore();
      final server = _FakeServer();
      final service = serviceFor(store, server);
      await store.addWordsReviewed(kDailyLearnGoal);
      await store.markHandsFreeDone();

      final results = await Future.wait([
        service.claimPendingQuests(),
        service.claimPendingQuests(),
      ]);
      // Lan goi thu 2 cho lan dau xong: chi 1 noi bao XP.
      expect(results, [30 + 25, 0]);
      expect(server.xp, 55);
      expect(server.keys, {
        '2026-09-24:quest_review',
        '2026-09-24:quest_handsFree',
      });
      expect(await service.claimPendingQuests(), 0);
      expect(store.today.rewarded, {'quest_review', 'quest_handsFree'});
    });

    test('a quest done while a claim runs is reported once', () async {
      final store = newStore();
      final server = _FakeServer();
      final service = serviceFor(store, server);
      await store.addWordsReviewed(kDailyLearnGoal);
      // Hom nay dang tra thi xong them 1 nhiem vu, On the cung goi tra.
      final today = service.claimPendingQuests();
      await store.markHandsFreeDone();
      final review = service.claimPendingQuests();
      expect(await today, 30 + 25);
      expect(await review, 0);
      expect(server.xp, 55);
    });

    test('two devices never double-pay the same quest', () async {
      final server = _FakeServer();
      final a = newStore();
      final b = newStore();
      await a.markTrainerChatDone();
      SharedPreferences.setMockInitialValues({}); // may khac
      await b.markTrainerChatDone();
      await serviceFor(a, server).claimPendingQuests();
      await serviceFor(b, server).claimPendingQuests();
      expect(server.xp, DailyQuestId.trainerChat.xp);
      // Ca 2 may deu ghi nhan da tra.
      expect(b.today.rewarded, {'quest_trainerChat'});
    });

    test(
      'a failed RPC keeps the quest pending, retried after backoff',
      () async {
        final store = newStore();
        final server = _FakeServer()..failing = true;
        var now = _now;
        final service = serviceFor(store, server, clock: () => now);
        await store.markTrainerChatDone();
        expect(await service.claimPendingQuests(), 0);
        expect(store.today.rewarded, isEmpty);
        server.failing = false;
        // Van trong thoi gian tam dung -> khong goi lai.
        expect(await service.claimPendingQuests(), 0);
        now = now.add(const Duration(minutes: 2));
        expect(await service.claimPendingQuests(), DailyQuestId.trainerChat.xp);
      },
    );

    test('a quest finished during a claim is paid in the same run', () async {
      final store = newStore();
      final server = _FakeServer();
      final service = serviceFor(store, server);
      await store.markHandsFreeDone();
      final run = service.claimPendingQuests();
      await store.markTrainerChatDone();
      expect(await run, 25 + 40);
    });

    test(
      'without migration 0076: legacy RPC, at most once per device',
      () async {
        final store = newStore();
        final server = _FakeServer()..legacyOnly = true;
        final service = serviceFor(store, server);
        await store.markHandsFreeDone();
        await Future.wait([
          service.claimPendingQuests(),
          service.claimPendingQuests(),
        ]);
        expect(server.xp, 25);
      },
    );

    test('chest opens only at 4/4 and pays once across devices', () async {
      final server = _FakeServer();
      final store = newStore();
      final service = serviceFor(store, server);
      expect(await service.openChest(), isNull);
      await finishAllQuests(store);

      final both = await Future.wait([
        service.openChest(),
        service.openChest(),
      ]);
      expect(both.whereType<int>(), [kChestXp]);
      expect(store.today.chestOpened, isTrue);
      expect(await service.openChest(), isNull);

      SharedPreferences.setMockInitialValues({}); // may khac
      final other = newStore();
      await finishAllQuests(other);
      expect(await serviceFor(other, server).openChest(), 0);
      expect(other.today.chestOpened, isTrue);
      expect(server.xp, kChestXp);
    });

    test('a failed chest RPC leaves the chest ready', () async {
      final store = newStore();
      final server = _FakeServer()..failing = true;
      await finishAllQuests(store);
      await expectLater(serviceFor(store, server).openChest(), throwsException);
      expect(chestState(store.today), ChestState.ready);
    });

    test('store sync merge keeps quest flags and paid keys', () async {
      final a = newStore();
      await a.markHandsFreeDone();
      await a.markRewarded(_now, 'quest_handsFree');
      SharedPreferences.setMockInitialValues({}); // may khac
      final b = newStore();
      await b.markTrainerChatDone();
      expect(await b.mergeRemote(a.exportJson()), isTrue);
      expect(b.today.handsFree, isTrue);
      expect(b.today.trainerChat, isTrue);
      expect(b.today.rewarded, {'quest_handsFree'});
      expect(await b.mergeRemote(a.exportJson()), isFalse);
    });
  });

  group('workout celebration (ADR-0008)', () {
    test('only the first completed workout of the day is celebrated', () async {
      var now = _now;
      final store = DailyProgressStore.forTest(clock: () => now);
      // Luu & ket thuc som: khong chuc mung, khong tieu cho cua ngay.
      expect(
        await store.claimWorkoutCelebration(completedAllSets: false),
        isFalse,
      );
      expect(
        await store.claimWorkoutCelebration(completedAllSets: true),
        isTrue,
      );
      expect(
        await store.claimWorkoutCelebration(completedAllSets: true),
        isFalse,
      );
      now = now.add(const Duration(days: 1));
      expect(
        await store.claimWorkoutCelebration(completedAllSets: true),
        isTrue,
      );
    });

    test('a workout celebrated on another device counts', () async {
      final a = newStore();
      expect(await a.claimWorkoutCelebration(completedAllSets: true), isTrue);
      SharedPreferences.setMockInitialValues({}); // may khac
      final b = newStore();
      await b.mergeRemote(a.exportJson());
      expect(await b.claimWorkoutCelebration(completedAllSets: true), isFalse);
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
    expect(
      tester
          .widgetList<GtTickCircle>(find.byType(GtTickCircle))
          .map((w) => w.progress),
      [1, 0, 0, 0],
    );
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
        onOpenChest: () async {
          opened++;
          return 0;
        },
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
    // Frame dau: toast + so dem bat dau; so dem len xong (~0.5s).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('+55 XP'), findsOneWidget);
    // Toast song 1.8s tinh tu frame dau.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.text('+55 XP'), findsNothing);
  });
}
