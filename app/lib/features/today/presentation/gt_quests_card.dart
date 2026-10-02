import 'dart:math';

import 'package:flutter/material.dart';
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
                            ref
                                .tr('gt_quest_${quest.name}_sub')
                                .replaceFirst('{goal}', goal),
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
        ClipRect(clipper: _Band(0, progress), child: struck),
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

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    size.width * from,
    -size.height,
    size.width * to,
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

  // Nap: 0 = dong, 1 = mo. Tuyen tinh; dang lo xo ap o luc ve.
  late final AnimationController _lid = AnimationController(
    vsync: this,
    value: chestState(widget.day) == ChestState.opened ? 1 : 0,
  );

  static final _lidSpring = GtSpringCurve(
    gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.fast),
    springSettleMs(gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.fast)),
  );

  bool _opening = false;

  @override
  void didUpdateWidget(_ChestBox old) {
    super.didUpdateWidget(old);
    final was = chestState(old.day);
    final now = chestState(widget.day);
    if (now == ChestState.ready &&
        (was != ChestState.ready || old.visit != widget.visit)) {
      _shake();
    }
    if (_opening) return;
    final lid = switch (now) {
      ChestState.locked => 0.0,
      // Da mo o may khac (dong bo): nap mo san, khong dien lai.
      ChestState.opened => 1.0,
      ChestState.ready => _lid.value,
    };
    if (_lid.value != lid) _lid.value = lid;
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
    final pop = gtMotion(context, GtMotionKind.expressive, GtMotionSpeed.fast);
    final TickerFuture? lid;
    if (pop.duration == Duration.zero) {
      _lid.value = 1;
      lid = null;
    } else {
      _lid.duration = pop.duration;
      lid = _lid.forward(from: 0);
    }
    int? xp;
    Object? error;
    try {
      xp = await widget.claim();
    } catch (e) {
      error = e;
    }
    // Nap bat len xong roi moi chuc mung.
    try {
      await lid?.orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    setState(() => _opening = false);
    if (error != null || xp == null) {
      // Chua mo duoc: nap roi xuong, ruong van san sang de thu lai.
      if (lid == null) {
        _lid.value = 0;
      } else {
        _lid.reverse();
      }
      if (error != null) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(ref.tr('gt_chest_failed'))));
      }
      return;
    }
    // 0 = da nhan tren may khac: ruong mo, khong chuc mung lan nua.
    if (xp > 0) await widget.celebrate(xp);
  }

  @override
  void dispose() {
    _wiggle.dispose();
    _lid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final day = widget.day;
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
          AnimatedBuilder(
            animation: Listenable.merge([_wiggle, _lid]),
            builder: (context, _) {
              final w = _wiggle.value;
              // 2.5 lan lac, tat dan; dung yen khi khong lac.
              final angle = w == 0 || w == 1
                  ? 0.0
                  : 0.16 * sin(w * 5 * pi) * (1 - w) * (1 - w);
              return Transform.rotate(
                key: const ValueKey('gt-chest-wiggle'),
                angle: angle,
                alignment: Alignment.bottomCenter,
                child: _ChestGlyph(
                  lift: _lid.value == 0 ? 0 : _lidSpring.transform(_lid.value),
                  // Anh sang loe ra trong luc nap bat len.
                  glow: _opening ? sin(_lid.value * pi) : 0,
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
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: t.gold,
                foregroundColor: t.onGold,
                minimumSize: const Size(64, 40),
              ),
              // Bam lien tiep trong luc nap dang bat: _open tu bo qua.
              onPressed: _open,
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

/// Ruong ve bang khoi: than + khoa + nap. [lift] 0..~1.1 (lo xo) nhac nap
/// len va nghieng ra sau quanh ban le trai; [glow] 0..1 la anh sang tu
/// trong ruong.
class _ChestGlyph extends StatelessWidget {
  const _ChestGlyph({required this.lift, required this.glow});

  final double lift;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final band = t.onGold.withValues(alpha: 0.3);
    return SizedBox(
      width: 34,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (glow > 0)
            Positioned(
              left: 6,
              right: 6,
              top: 10,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: t.gold.withValues(alpha: 0.9 * glow),
                      blurRadius: 14,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 2,
            right: 2,
            bottom: 0,
            height: 17,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.gold,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                  bottom: Radius.circular(5),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            width: 6,
            bottom: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.onGold.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 3,
            height: 11,
            child: Transform.translate(
              offset: Offset(0, -5 * lift),
              child: Transform.rotate(
                key: const ValueKey('gt-chest-lid'),
                angle: -0.45 * lift,
                alignment: Alignment.bottomLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.gold,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                      bottom: Radius.circular(2),
                    ),
                    border: Border(bottom: BorderSide(color: band, width: 2)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
