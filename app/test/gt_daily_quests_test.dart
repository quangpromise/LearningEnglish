import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/daily_quests.dart';

const _allDone = DayProgress(
  wordsReviewed: kDailyLearnGoal,
  speakAttempts: kDailySpeakGoal,
  handsFree: true,
  trainerChat: true,
);

void main() {
  group('quest completion', () {
    test('review follows the daily learn goal', () {
      expect(
        questDone(
          const DayProgress(wordsReviewed: kDailyLearnGoal - 1),
          DailyQuestId.review,
        ),
        isFalse,
      );
      expect(
        questDone(
          const DayProgress(wordsReviewed: kDailyLearnGoal),
          DailyQuestId.review,
        ),
        isTrue,
      );
    });

    test('pronunciation follows the daily speak goal', () {
      expect(
        questDone(
          const DayProgress(speakAttempts: kDailySpeakGoal - 1),
          DailyQuestId.pronunciation,
        ),
        isFalse,
      );
      expect(
        questDone(
          const DayProgress(speakAttempts: kDailySpeakGoal),
          DailyQuestId.pronunciation,
        ),
        isTrue,
      );
    });

    test('hands-free and trainer chat need their real events', () {
      expect(questDone(const DayProgress(), DailyQuestId.handsFree), isFalse);
      expect(
        questDone(const DayProgress(handsFree: true), DailyQuestId.handsFree),
        isTrue,
      );
      expect(
        questDone(
          const DayProgress(trainerChat: true),
          DailyQuestId.trainerChat,
        ),
        isTrue,
      );
    });

    test('counts done quests', () {
      expect(questsDoneCount(const DayProgress()), 0);
      expect(questsDoneCount(_allDone), 4);
    });

    test('every quest has a positive XP value and a distinct reward key', () {
      final keys = {for (final q in DailyQuestId.values) q.rewardKey};
      expect(keys, hasLength(DailyQuestId.values.length));
      expect(keys, isNot(contains(kChestRewardKey)));
      for (final q in DailyQuestId.values) {
        expect(q.xp, greaterThan(0));
      }
    });
  });

  group('chest', () {
    test('opens only at 4/4 and only once a day', () {
      expect(chestState(const DayProgress()), ChestState.locked);
      expect(canOpenChest(_allDone.copyWith(trainerChat: false)), isFalse);
      expect(chestState(_allDone), ChestState.ready);
      expect(canOpenChest(_allDone), isTrue);
      final opened = _allDone.copyWith(chestOpened: true);
      expect(chestState(opened), ChestState.opened);
      expect(canOpenChest(opened), isFalse);
    });

    test('quests left to unlock', () {
      expect(questsLeftForChest(const DayProgress()), 4);
      expect(questsLeftForChest(_allDone), 0);
    });
  });

  group('reward keys', () {
    test('only done, not yet rewarded quests are pending', () {
      const day = DayProgress(
        wordsReviewed: kDailyLearnGoal,
        handsFree: true,
        rewarded: {'quest_review'},
      );
      expect(pendingQuestRewards(day), [DailyQuestId.handsFree]);
    });

    test('a rewarded key is never pending again', () {
      final day = _allDone.copyWith(
        rewarded: {for (final q in DailyQuestId.values) q.rewardKey},
      );
      expect(pendingQuestRewards(day), isEmpty);
    });

    test('marking a key is idempotent', () {
      final once = const DayProgress().withRewarded('quest_review');
      final twice = once.withRewarded('quest_review');
      expect(twice.rewarded, {'quest_review'});
    });
  });

  group('sync merge (OR)', () {
    test('flags OR together and reward keys union', () {
      const a = DayProgress(
        workouts: 1,
        handsFree: true,
        rewarded: {'quest_handsFree'},
      );
      const b = DayProgress(
        wordsReviewed: 12,
        trainerChat: true,
        chestOpened: true,
        rewarded: {'chest'},
      );
      final m = DayProgress.merge(a, b);
      expect(m.workouts, 1);
      expect(m.wordsReviewed, 12);
      expect(m.handsFree, isTrue);
      expect(m.trainerChat, isTrue);
      expect(m.chestOpened, isTrue);
      expect(m.rewarded, {'quest_handsFree', 'chest'});
    });

    test('merge is commutative and idempotent', () {
      const a = DayProgress(speakAttempts: 3, rewarded: {'x'});
      const b = DayProgress(speakAttempts: 5, handsFree: true);
      expect(DayProgress.merge(a, b), DayProgress.merge(b, a));
      final m = DayProgress.merge(a, b);
      expect(DayProgress.merge(m, m), m);
    });

    test('JSON round-trip keeps quest flags and keys', () {
      final day = _allDone.copyWith(
        chestOpened: true,
        rewarded: {'chest', 'quest_review'},
      );
      expect(DayProgress.fromJson(day.toJson()), day);
    });

    test('old JSON without quest fields still loads', () {
      final day = DayProgress.fromJson({'w': 1, 'l': 3, 's': 0, 'r': false});
      expect(day.handsFree, isFalse);
      expect(day.rewarded, isEmpty);
    });
  });
}
