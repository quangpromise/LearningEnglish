import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/gt_feedback_tier.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../english_path/data/cefr_level.dart';
import '../../fitness/data/body_level.dart';
import '../data/gymtalk_rank.dart';
import '../data/milestone_store.dart';
import '../data/milestones.dart';

/// Kiem Milestone moi - chuoi Body + Brain 7 / 30 / 100 / 365, len Body
/// Level, len GymTalk Rank (spec #96, ADR-0008) - moi lan tab Hom nay hien
/// lai ([visit] tang) hoac so lieu doi trong luc dang hien, roi hien
/// Celebration lan luot (dau tick, khong XP). Khong ve gi.
class GtMilestoneWatcher extends ConsumerStatefulWidget {
  const GtMilestoneWatcher({
    super.key,
    required this.userId,
    required this.visit,
    required this.streak,
    required this.bodyLevel,
    required this.english,
    this.delay = const Duration(milliseconds: 900),
  });

  /// null = chua dang nhap -> khong kiem.
  final String? userId;
  final int visit;
  final int streak;

  /// null = chua tai xong -> giu nguyen phan Body Level / Rank.
  final BodyLevel? bodyLevel;
  final CefrLevel english;

  /// Cho hieu ung tien do (vong, nhiem vu) chay xong truoc khi chuc mung.
  final Duration delay;

  @override
  ConsumerState<GtMilestoneWatcher> createState() => _GtMilestoneWatcherState();
}

class _GtMilestoneWatcherState extends ConsumerState<GtMilestoneWatcher> {
  Timer? _pending;
  bool _running = false;

  @override
  void didUpdateWidget(GtMilestoneWatcher old) {
    super.didUpdateWidget(old);
    // visit 0 = Hom nay chua hien lan nao.
    if (widget.visit == 0) return;
    if (old.visit != widget.visit ||
        old.streak != widget.streak ||
        old.bodyLevel != widget.bodyLevel ||
        old.english != widget.english ||
        old.userId != widget.userId) {
      _pending?.cancel();
      _pending = Timer(widget.delay, _check);
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final userId = widget.userId;
    if (userId == null || _running || !mounted) return;
    _running = true;
    try {
      final body = widget.bodyLevel;
      final found = detectMilestones(
        await MilestoneStore.load(userId),
        streak: widget.streak,
        bodyLevel: body?.index,
        rank: body == null ? null : gymTalkRank(body, widget.english).tier,
      );
      // Luu truoc khi hien: tat app giua chung cung khong chuc mung lai.
      await MilestoneStore.save(userId, found.record);
      for (final milestone in found.celebrate) {
        if (!mounted) return;
        await _celebrate(milestone);
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _celebrate(Milestone m) {
    final lang = ref.read(appLanguageProvider);
    String t(String key) => AppStrings.t(key, lang);
    String bodyName(int index) =>
        t('body_level_${BodyLevel.values[index].name}');
    final (event, title, subtitle) = switch (m.kind) {
      MilestoneKind.streak => (
        GtFeedbackEvent.streakMilestone,
        t('gt_milestone_streak_title').replaceFirst('{n}', '${m.value}'),
        t('gt_milestone_streak_sub').replaceFirst('{n}', '${m.value}'),
      ),
      MilestoneKind.bodyLevel => (
        GtFeedbackEvent.bodyLevelUp,
        t('gt_milestone_body_title'),
        t('gt_milestone_body_sub').replaceFirst('{level}', bodyName(m.value)),
      ),
      // Bac k = Body Level thu k ghep CEFR thu k (CONTEXT.md GymTalk Rank).
      MilestoneKind.rank => (
        GtFeedbackEvent.rankUp,
        t('gt_milestone_rank_title'),
        t('gt_milestone_rank_sub')
            .replaceFirst('{tier}', '${m.value + 1}')
            .replaceFirst('{body}', bodyName(m.value))
            .replaceFirst('{english}', CefrLevel.values[m.value].code),
      ),
    };
    return showTieredFeedback(
      context,
      event,
      // Milestone moi khong cong XP (spec #96 quyet dinh #12): dau tick.
      xp: 0,
      celebration: () => showCelebration(
        context,
        xp: 0,
        title: title,
        subtitle: subtitle,
        ctaLabel: t('gt_celebration_cta'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
