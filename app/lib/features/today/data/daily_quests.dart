import 'daily_progress_store.dart';

/// 4 Daily Quest co dinh (spec #70, quyet dinh #8). XP theo README §5.
enum DailyQuestId {
  review(30),
  pronunciation(20),
  handsFree(25),
  trainerChat(40);

  const DailyQuestId(this.xp);

  /// XP thuong 1 lan/ngay khi hoan thanh.
  final int xp;

  /// Khoa thuong luu trong [DayProgress.rewarded].
  String get rewardKey => 'quest_$name';
}

/// Thuong khi mo Quest Chest (4/4 nhiem vu).
const kChestXp = 100;
const kChestRewardKey = 'chest';

/// So luot nguoi dung noi voi PT AI de tinh la xong nhiem vu.
const kTrainerChatQuestTurns = 3;

/// Nhiem vu da xong theo hoat dong that trong ngay.
bool questDone(DayProgress day, DailyQuestId quest) => switch (quest) {
  DailyQuestId.review => day.learnDone,
  DailyQuestId.pronunciation => day.speakDone,
  DailyQuestId.handsFree => day.handsFree,
  DailyQuestId.trainerChat => day.trainerChat,
};

int questsDoneCount(DayProgress day) =>
    DailyQuestId.values.where((q) => questDone(day, q)).length;

/// Nhiem vu da xong nhung chua cong XP (theo thu tu co dinh).
List<DailyQuestId> pendingQuestRewards(DayProgress day) => [
  for (final q in DailyQuestId.values)
    if (questDone(day, q) && !day.rewarded.contains(q.rewardKey)) q,
];

enum ChestState { locked, ready, opened }

ChestState chestState(DayProgress day) {
  if (day.chestOpened) return ChestState.opened;
  return questsDoneCount(day) == DailyQuestId.values.length
      ? ChestState.ready
      : ChestState.locked;
}

bool canOpenChest(DayProgress day) => chestState(day) == ChestState.ready;

int questsLeftForChest(DayProgress day) =>
    DailyQuestId.values.length - questsDoneCount(day);
