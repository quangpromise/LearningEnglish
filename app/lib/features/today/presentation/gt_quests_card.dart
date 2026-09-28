import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../ai_voice_chat/data/voice_chat_scenario.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../speaking/presentation/hands_free_drill_screen.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../data/daily_progress_store.dart';
import '../data/daily_quests.dart';
import '../data/quest_rewards.dart';

/// Dich vu cong XP nhiem vu/ruong qua `add_learning_xp` (ADR-0005).
final questRewardServiceProvider = Provider<QuestRewardService>(
  (ref) => QuestRewardService(
    store: DailyProgressStore.instance,
    addXp: (amount) async {
      await ref.read(learningXpRepositoryProvider).addBonusXp(amount);
      ref.invalidate(myLearningXpProvider);
    },
  ),
);

/// The "Nhiem vu hang ngay" (README §5): 4 dong nhiem vu + hop ruong.
class GtQuestsCard extends ConsumerWidget {
  const GtQuestsCard({super.key, required this.day, this.onOpenChest});

  final DayProgress day;

  /// Mo ruong (null -> dung [questRewardServiceProvider] + Celebration).
  final VoidCallback? onOpenChest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final done = questsDoneCount(day);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.tr('gt_quests_title'),
                  style: GtText.cardTitle(t.tx),
                ),
              ),
              Text(
                '$done/${DailyQuestId.values.length}',
                style: GtText.body(t.tx2, weight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final q in DailyQuestId.values)
            _QuestRow(
              quest: q,
              done: questDone(day, q),
              onTap: () => openQuest(context, q),
            ),
          const SizedBox(height: 12),
          _ChestBox(
            day: day,
            onOpen: onOpenChest ?? () => _openChest(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _openChest(BuildContext context, WidgetRef ref) async {
    final xp = await ref.read(questRewardServiceProvider).openChest();
    if (xp == null || !context.mounted) return;
    await showCelebration(
      context,
      xp: xp,
      title: ref.tr('gt_chest_celebration_title'),
      subtitle: ref.tr('gt_chest_celebration_sub'),
      ctaLabel: ref.tr('gt_celebration_cta'),
      chips: [
        ref
            .tr('gt_celebration_streak_chip')
            .replaceFirst(
              '{days}',
              '${DailyProgressStore.instance.bodyBrainStreak}',
            ),
      ],
    );
  }
}

/// Mo man ung voi nhiem vu (giu dung routeName chiem mic nhu man cu).
void openQuest(BuildContext context, DailyQuestId quest) {
  switch (quest) {
    case DailyQuestId.review:
      openAppPopup(context, const SrsReviewScreen());
    case DailyQuestId.pronunciation:
      openAppPopup(
        context,
        const PronunciationScreen(),
        routeName: kPronunciationRouteName,
      );
    case DailyQuestId.handsFree:
      openAppPopup(
        context,
        const HandsFreeDrillScreen(),
        routeName: kPronunciationRouteName,
      );
    case DailyQuestId.trainerChat:
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        routeSettings: const RouteSettings(name: kAiVoiceChatRouteName),
        builder: (_) => const FractionallySizedBox(
          heightFactor: 0.94,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            child: AiVoiceChatScreen(
              scenario: VoiceChatScenario.personalTrainer,
            ),
          ),
        ),
      );
  }
}

class _QuestRow extends ConsumerWidget {
  const _QuestRow({
    required this.quest,
    required this.done,
    required this.onTap,
  });

  final DailyQuestId quest;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final (icon, accent, tint) = switch (quest) {
      DailyQuestId.review => (Icons.style_rounded, t.blue, t.blueT),
      DailyQuestId.pronunciation => (
        Icons.record_voice_over_rounded,
        t.teal,
        t.tealT,
      ),
      DailyQuestId.handsFree => (Icons.headphones_rounded, t.teal, t.tealT),
      DailyQuestId.trainerChat => (
        Icons.sports_gymnastics_rounded,
        t.red,
        t.redT,
      ),
    };
    final title = ref
        .tr('gt_quest_${quest.name}_title')
        .replaceFirst('{goal}', '${_goalOf(quest)}');
    return Semantics(
      button: true,
      checked: done,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: done ? 0.55 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GtText.rowTitle(t.tx).copyWith(
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: t.tx2,
                        ),
                      ),
                      Text(
                        ref
                            .tr('gt_quest_${quest.name}_sub')
                            .replaceFirst('{goal}', '${_goalOf(quest)}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GtText.body(t.tx2, size: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${quest.xp} XP',
                style: GtText.body(t.gold, size: 13, weight: FontWeight.w800),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? t.gold : null,
                  border: done ? null : Border.all(color: t.tx3, width: 2),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 18, color: t.onGold)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _goalOf(DailyQuestId q) => switch (q) {
    DailyQuestId.review => kDailyLearnGoal,
    DailyQuestId.pronunciation => kDailySpeakGoal,
    DailyQuestId.handsFree => 1,
    DailyQuestId.trainerChat => kTrainerChatQuestTurns,
  };
}

class _ChestBox extends ConsumerWidget {
  const _ChestBox({required this.day, required this.onOpen});

  final DayProgress day;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final state = chestState(day);
    final total = DailyQuestId.values.length;
    final label = switch (state) {
      ChestState.locked =>
        ref
            .tr('gt_chest_locked')
            .replaceFirst('{n}', '${questsLeftForChest(day)}'),
      ChestState.ready => ref.tr('gt_chest_ready'),
      ChestState.opened => ref.tr('gt_chest_opened'),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.goldT,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.redeem_rounded, color: t.gold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.body(t.tx, size: 13, weight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (total - questsLeftForChest(day)) / total,
                    minHeight: 8,
                    color: t.gold,
                    backgroundColor: t.gold.withValues(alpha: 0.18),
                  ),
                ),
              ],
            ),
          ),
          if (state == ChestState.ready) ...[
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: t.gold,
                foregroundColor: t.onGold,
                minimumSize: const Size(64, 40),
              ),
              onPressed: onOpen,
              child: Text(
                ref.tr('gt_chest_open'),
                style: GtText.rowTitle(t.onGold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
