import 'package:flutter/foundation.dart';

import 'daily_progress_store.dart';
import 'daily_quests.dart';

/// Cong XP cho Daily Quest va Quest Chest qua RPC `add_learning_xp`
/// (spec #70, quyet dinh #7). Moi phan thuong co khoa theo ngay trong
/// [DayProgress.rewarded]: ghi khoa TRUOC khi goi RPC (nhieu nhat 1 lan),
/// RPC loi thi tra khoa lai de lan sau thu tiep.
class QuestRewardService {
  QuestRewardService({required this.store, required this.addXp});

  final DailyProgressStore store;

  /// Cong [amount] XP tren server (vd `LearningXpRepository.addBonusXp`).
  final Future<void> Function(int amount) addXp;

  /// Cong XP cho moi nhiem vu da xong ma chua thuong. Tra ve tong XP da
  /// cong that (0 neu khong co gi / loi mang).
  Future<int> claimPendingQuests() async {
    await store.ensureLoaded();
    var total = 0;
    for (final quest in pendingQuestRewards(store.today)) {
      if (!await store.claimReward(quest.rewardKey)) continue;
      try {
        await addXp(quest.xp);
        total += quest.xp;
      } catch (e) {
        debugPrint('Quest XP failed (${quest.name}): $e');
        await store.releaseReward(quest.rewardKey);
      }
    }
    return total;
  }

  /// Mo ruong khi du 4/4 va chua mo hom nay. Tra ve XP da cong, null neu
  /// khong mo duoc (chua du, da mo, hoac loi mang - ruong dong lai).
  Future<int?> openChest() async {
    await store.ensureLoaded();
    if (!canOpenChest(store.today)) return null;
    if (!await store.claimReward(kChestRewardKey, openChest: true)) {
      return null;
    }
    try {
      await addXp(kChestXp);
      return kChestXp;
    } catch (e) {
      debugPrint('Chest XP failed: $e');
      await store.releaseReward(kChestRewardKey, closeChest: true);
      return null;
    }
  }
}
