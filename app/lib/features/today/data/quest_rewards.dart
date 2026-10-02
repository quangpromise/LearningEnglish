import 'package:flutter/foundation.dart';

import '../../stats/data/learning_xp_repository.dart';
import 'daily_progress_store.dart';
import 'daily_quests.dart';

/// Cong XP cho Daily Quest va Quest Chest (spec #70 quyet dinh #7, ADR-0005).
///
/// Chong cong trung nam O SERVER: moi phan thuong co khoa
/// `<yyyy-mm-dd>:<ten>` va `claim_learning_xp` (migration 0076) chi cong 1
/// lan cho moi khoa - an toan khi nhieu may cung nhan, RPC loi roi thu lai,
/// hay ban app cu ghi de du lieu dong bo. [DayProgress.rewarded] chi la ban
/// ghi "da xac nhan tra" de khong goi lai.
///
/// Server chua chay 0076 -> dung `add_learning_xp` cu, ghi khoa TRUOC khi
/// goi (nhieu nhat 1 lan tren may nay; loi mang thi mat phan thuong do).
class QuestRewardService {
  QuestRewardService({
    required this.store,
    required this.claimOnce,
    required this.addLegacy,
    DateTime Function()? clock,
    this.retryAfter = const Duration(minutes: 1),
  }) : _clock = clock ?? DateTime.now;

  final DailyProgressStore store;

  /// `LearningXpRepository.claimXpOnce`: XP cong o lan goi nay (0 = khoa da
  /// nhan), nem [XpRewardKeysUnavailable] neu server chua co ham.
  final Future<int> Function(String key, int amount) claimOnce;

  /// `LearningXpRepository.addBonusXp` - chi dung khi chua co 0076.
  final Future<void> Function(int amount) addLegacy;

  /// Loi (mat mang, chua dang nhap) -> tam dung thu lai trong khoang nay de
  /// khong goi RPC moi lan bo dem thay doi.
  final Duration retryAfter;

  final DateTime Function() _clock;
  final Set<String> _inFlight = {};
  DateTime? _pausedUntil;

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// Tra 1 phan thuong cua ngay [day]; tra ve XP cong o lan nay.
  Future<int> _pay(
    DateTime day,
    String key,
    int amount, {
    bool chest = false,
  }) async {
    try {
      final added = await claimOnce(
        '${DailyProgressStore.keyOf(day)}:$key',
        amount,
      );
      // Da tra (lan nay hoac truoc do) -> ghi nhan.
      await store.markRewarded(day, key, openChest: chest);
      return added;
    } on XpRewardKeysUnavailable {
      if (!await store.markRewarded(day, key, openChest: chest)) return 0;
      await addLegacy(amount);
      return amount;
    }
  }

  /// Lan nhan thuong gan nhat - cac lan goi [claimPendingQuests] xep hang.
  Future<void> _claimTail = Future.value();

  /// Cong XP cho moi nhiem vu da xong ma chua tra. Lap lai den khi het -
  /// nhiem vu xong trong luc dang tra cung duoc tra ngay. Tra ve tong XP
  /// cong that o LAN GOI NAY.
  ///
  /// Cac lan goi xep hang: lan sau chi chay khi lan truoc xong nen chi tra
  /// phan con lai - moi nhiem vu chi 1 noi tra va bao toast (Hom nay va On
  /// the goi cung luc khong hien 2 toast chong nhau).
  Future<int> claimPendingQuests() {
    final run = _claimTail.then((_) => _claimQueued());
    _claimTail = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  Future<int> _claimQueued() async {
    await store.ensureLoaded();
    final day = _today();
    var total = 0;
    while (true) {
      final paused = _pausedUntil;
      if (paused != null && _clock().isBefore(paused)) return total;
      final pending = pendingQuestRewards(store.dayOf(day));
      if (pending.isEmpty) return total;
      for (final quest in pending) {
        try {
          total += await _pay(day, quest.rewardKey, quest.xp);
        } catch (e) {
          debugPrint('Quest XP failed (${quest.name}): $e');
          _pausedUntil = _clock().add(retryAfter);
          return total;
        }
      }
    }
  }

  /// Mo ruong khi du 4/4 va chua mo hom nay. Tra ve XP cong o lan nay (0 neu
  /// da nhan tren may khac - ruong van mo), null neu chua mo duoc. Loi mang
  /// thi nem loi (ruong van san sang de thu lai).
  Future<int?> openChest() async {
    await store.ensureLoaded();
    final day = _today();
    if (!canOpenChest(store.dayOf(day))) return null;
    if (!_inFlight.add(kChestRewardKey)) return null;
    try {
      return await _pay(day, kChestRewardKey, kChestXp, chest: true);
    } finally {
      _inFlight.remove(kChestRewardKey);
    }
  }
}
