import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_haptics.dart';
import '../../../core/theme/gt_motion.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../../core/widgets/gt_tick_circle.dart';
import '../../ai_voice_chat/data/voice_chat_scenario.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../speaking/presentation/hands_free_drill_screen.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../data/daily_progress_store.dart';
import '../data/daily_quests.dart';
import '../data/quest_rewards.dart';

/// Dich vu cong XP nhiem vu/ruong qua `add_learning_xp` (ADR-0005).
final questRewardServiceProvider = Provider<QuestRewardService>((ref) {
  final repo = ref.read(learningXpRepositoryProvider);
  return QuestRewardService(
    store: DailyProgressStore.instance,
    claimOnce: (key, amount) async {
      final added = await repo.claimXpOnce(key, amount);
      if (added > 0) ref.invalidate(myLearningXpProvider);
      return added;
    },
    addLegacy: (amount) async {
      await repo.addBonusXp(amount);
      ref.invalidate(myLearningXpProvider);
    },
  );
});

/// The "Nhiem vu hang ngay" (README §5): 4 dong nhiem vu + hop ruong.
/// Nhiem vu vua xong: dau tick ve ra + gach ngang tieu de + rung; ruong
/// san sang lac 1 lan, bam Mo thi nap bat len roi moi chuc mung (spec #96).
class GtQuestsCard extends ConsumerWidget {
  const GtQuestsCard({
    super.key,
    required this.day,
    this.visit = 0,
    this.onOpenChest,
  });

  final DayProgress day;

  /// Lan hien thu may cua tab Hom nay (xem GtWhenOnScreen) - ruong con san
  /// sang thi lac 1 lan moi khi so nay tang.
  final int visit;

  /// Nhan ruong: XP vua cong (0 = da nhan o may khac, null = chua mo
  /// duoc); nem loi khi mang hong. Mac dinh qua [questRewardServiceProvider].
  final Future<int?> Function()? onOpenChest;

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
              key: ValueKey(q),
              quest: q,
              done: questDone(day, q),
              onTap: () => openQuest(context, q),
            ),
          const SizedBox(height: 12),
          _ChestBox(
            day: day,
            visit: visit,
            claim:
                onOpenChest ??
                () => ref.read(questRewardServiceProvider).openChest(),
            celebrate: (xp) => _celebrate(context, ref, xp),
          ),
        ],
      ),
    );
  }

  Future<void> _celebrate(BuildContext context, WidgetRef ref, int xp) {
    return showCelebration(
      context,
      xp: xp,
      title: ref.tr('gt_chest_celebration_title'),
      subtitle: ref.tr('gt_chest_celebration_sub'),
      ctaLabel: ref.tr('gt_celebration_cta'),
      // Da rung luc nap bat len.
      haptic: false,
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

class _QuestRow extends ConsumerStatefulWidget {
  const _QuestRow({
    super.key,
    required this.quest,
    required this.done,
    required this.onTap,
  });

  final DailyQuestId quest;
  final bool done;
  final VoidCallback onTap;

  @override
  ConsumerState<_QuestRow> createState() => _QuestRowState();

  static int _goalOf(DailyQuestId q) => switch (q) {
    DailyQuestId.review => kDailyLearnGoal,
    DailyQuestId.pronunciation => kDailySpeakGoal,
    DailyQuestId.handsFree => 1,
    DailyQuestId.trainerChat => kTrainerChatQuestTurns,
  };
}

class _QuestRowState extends ConsumerState<_QuestRow>
    with SingleTickerProviderStateMixin {
  // 0 = chua xong, 1 = da xong. Nhiem vu xong tu truoc khi mo man: dung o 1,
  // khong chay lai.
  late final AnimationController _done = AnimationController(
    vsync: this,
    value: widget.done ? 1 : 0,
  );

  @override
  void didUpdateWidget(_QuestRow old) {
    super.didUpdateWidget(old);
    if (widget.done == old.done) return;
    if (!widget.done) {
      // Sang ngay moi.
      _done.value = 0;
      return;
    }
    GtHaptics.play(GtHapticEvent.questCompleted);
    final duration = GtTickCircle.motion(context);
    if (duration == Duration.zero) {
      _done.value = 1;
    } else {
      _done
        ..duration = duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _done.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final quest = widget.quest;
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
    final goal = '${_QuestRow._goalOf(quest)}';
    final title = ref
        .tr('gt_quest_${quest.name}_title')
        .replaceFirst('{goal}', goal);
    final subtitle = ref
        .tr('gt_quest_${quest.name}_sub')
        .replaceFirst('{goal}', goal);
    return Semantics(
      button: true,
      checked: widget.done,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AnimatedBuilder(
            animation: _done,
            builder: (context, _) {
              final p = _done.value;
              // Gach ngang chay qua tieu de trong 60% cuoi.
              final strike = Curves.easeInOutCubic.transform(
                ((p - 0.4) / 0.6).clamp(0.0, 1.0),
              );
              return Row(
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
                      opacity: 1 - 0.45 * strike,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StrikeTitle(
                            text: title,
                            style: GtText.rowTitle(t.tx),
                            strikeColor: t.tx2,
                            progress: strike,
                          ),
                          Text(
                            subtitle,
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
                    style: GtText.body(
                      t.gold,
                      size: 13,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GtTickCircle(progress: p),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tieu de 1 dong voi vet gach ngang chay tu trai sang phai theo
/// [progress]: phan da gach la ban co lineThrough, phan con lai la ban
/// thuong - 2 ban trung khit nhau nen vet gach nam dung vi tri cua font.
class _StrikeTitle extends StatelessWidget {
  const _StrikeTitle({
    required this.text,
    required this.style,
    required this.strikeColor,
    required this.progress,
  });

  final String text;
  final TextStyle style;
  final Color strikeColor;
  final double progress;

  Text _text(TextStyle style) =>
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

  @override
  Widget build(BuildContext context) {
    final plain = _text(style);
    if (progress <= 0) return plain;
    final struck = _text(
      style.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: strikeColor,
      ),
    );
    if (progress >= 1) return struck;
    return Stack(
      children: [
        ClipRect(clipper: _Band(progress, 1), child: plain),
        // 1 tieu de cho trinh doc man hinh, khong doc 2 lan.
        ExcludeSemantics(
          child: ClipRect(clipper: _Band(0, progress), child: struck),
        ),
      ],
    );
  }
}

/// Dai doc tu [from] toi [to] (ti le chieu ngang); du tren / duoi de khong
/// cat dau tieng Viet.
class _Band extends CustomClipper<Rect> {
  const _Band(this.from, this.to);

  final double from;
  final double to;

  // Mep ngoai (0 / 1) mo rong them: khong cat phan chu nho ra ngoai hop.
  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    from <= 0 ? -size.width : size.width * from,
    -size.height,
    to >= 1 ? size.width * 2 : size.width * to,
    size.height * 2,
  );

  @override
  bool shouldReclip(_Band old) => old.from != from || old.to != to;
}

class _ChestBox extends ConsumerStatefulWidget {
  const _ChestBox({
    required this.day,
    required this.visit,
    required this.claim,
    required this.celebrate,
  });

  final DayProgress day;
  final int visit;
  final Future<int?> Function() claim;
  final Future<void> Function(int xp) celebrate;

  @override
  ConsumerState<_ChestBox> createState() => _ChestBoxState();
}

class _ChestBoxState extends ConsumerState<_ChestBox>
    with TickerProviderStateMixin {
  // Lac 1 lan (khong lap) khi vua san sang / moi lan quay lai Hom nay.
  late final AnimationController _wiggle = AnimationController(vsync: this);

  // Bam Mo: icon phong to + xoay roi ve cho cu (0 -> 1, dang "bump").
  late final AnimationController _pop = AnimationController(vsync: this);

  bool _opening = false;

  /// Vua nhan ruong o day: hien "da mo" ngay ca khi so lieu dang giu (Hom
  /// nay bi Celebration che) chua kip cap nhat.
  bool _claimed = false;

  @override
  void didUpdateWidget(_ChestBox old) {
    super.didUpdateWidget(old);
    final was = chestState(old.day);
    final now = chestState(widget.day);
    if (now != ChestState.ready) _claimed = false;
    // Lan hien dau sau khi the duoc dung lai (visit 1: mo app, dong bo) khong
    // phai "quay lai" -> khong lac.
    if (now == ChestState.ready &&
        !_claimed &&
        (was != ChestState.ready ||
            (old.visit != widget.visit && widget.visit > 1))) {
      _shake();
    }
  }

  void _shake() {
    final duration = gtMotion(
      context,
      GtMotionKind.expressive,
      GtMotionSpeed.slow,
    ).duration;
    if (duration == Duration.zero || _opening) return;
    _wiggle
      ..duration = duration
      ..forward(from: 0);
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    GtHaptics.play(GtHapticEvent.chestOpened);
    _wiggle.value = 0;
    final motion = gtMotion(
      context,
      GtMotionKind.expressive,
      GtMotionSpeed.fast,
    );
    TickerFuture? popping;
    if (motion.duration != Duration.zero) {
      _pop.duration = motion.duration;
      popping = _pop.forward(from: 0);
    }
    int? xp;
    Object? error;
    try {
      xp = await widget.claim();
    } catch (e) {
      error = e;
    }
    // Icon bat xong roi moi chuc mung.
    try {
      await popping?.orCancel;
    } on TickerCanceled {
      // Bi huy (vd the bi dung lai): van xu ly ket qua neu con mounted.
    }
    if (!mounted) return;
    _pop.value = 0;
    final claimed = error == null && xp != null;
    setState(() {
      _opening = false;
      _claimed = claimed;
    });
    if (!claimed) {
      // Chua mo duoc: ruong van san sang de thu lai.
      if (error != null) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(ref.tr('gt_chest_failed'))));
      }
      return;
    }
    // Ve "da mo" 1 frame truoc khi Celebration phu len.
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    // 0 = da nhan tren may khac: ruong mo, khong chuc mung lan nua.
    if (xp! > 0) await widget.celebrate(xp);
  }

  @override
  void dispose() {
    _wiggle.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final day = widget.day;
    final state = _claimed ? ChestState.opened : chestState(day);
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
          AnimatedBuilder(
            animation: Listenable.merge([_wiggle, _pop]),
            builder: (context, _) {
              final w = _wiggle.value;
              // 2.5 lan lac, tat dan; dung yen khi khong lac.
              final wiggle = w == 0 || w == 1
                  ? 0.0
                  : 0.16 * sin(w * 5 * pi) * (1 - w) * (1 - w);
              final v = _pop.value;
              // Phong to + xoay roi ve cho cu (README §5: icon redeem).
              final bump = v == 0 || v == 1 ? 0.0 : sin(v * pi);
              return Transform.rotate(
                key: const ValueKey('gt-chest-wiggle'),
                angle: wiggle,
                alignment: Alignment.bottomCenter,
                child: SizedBox.square(
                  dimension: 28,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Anh sang toa ra luc bat - gradient, khong blur.
                      if (bump > 0)
                        Positioned(
                          left: -14,
                          top: -14,
                          right: -14,
                          bottom: -14,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  t.gold.withValues(alpha: 0.5 * bump),
                                  t.gold.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Transform.rotate(
                        key: const ValueKey('gt-chest-pop'),
                        angle: -0.3 * bump,
                        child: Transform.scale(
                          scale: 1 + 0.35 * bump,
                          child: Icon(
                            Icons.redeem_rounded,
                            color: t.gold,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
            // Bam lien tiep trong luc dang mo: bo qua (khong gon song).
            IgnorePointer(
              ignoring: _opening,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: t.gold,
                  foregroundColor: t.onGold,
                  minimumSize: const Size(64, 40),
                ),
                onPressed: _open,
                child: Text(
                  ref.tr('gt_chest_open'),
                  style: GtText.rowTitle(t.onGold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
