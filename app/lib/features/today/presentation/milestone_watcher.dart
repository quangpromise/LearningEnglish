import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/gt_feedback_tier.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../english_path/data/cefr_level.dart';
import '../../fitness/data/body_level.dart';
import '../data/daily_progress_store.dart';
import '../data/gymtalk_rank.dart';
import '../data/milestone_store.dart';
import '../data/milestones.dart';

/// So lieu de kiem Milestone. null = chua chac chan (chua dong bo xong lan
/// dau, dang tai, loi mang) -> giu nguyen phan do cua ban ghi.
/// [dailyRevision] / [pathRevision]: tang khi so lieu 3 vong / lo trinh den
/// tu NGOAI may nay (dong bo tai khoan).
typedef MilestoneInputs = ({
  int? streak,
  BodyLevel? body,
  CefrLevel? english,
  int dailyRevision,
  int pathRevision,
});

/// Kiem Milestone moi - chuoi Body + Brain 7 / 30 / 100 / 365, len Body
/// Level, len GymTalk Rank (spec #96, ADR-0008) - moi lan tab Hom nay hien
/// lai ([visit] tang) hoac so lieu doi trong luc dang hien, roi hien
/// Celebration lan luot (dau tick, khong XP). Khong ve gi.
class GtMilestoneWatcher extends ConsumerStatefulWidget {
  const GtMilestoneWatcher({
    super.key,
    required this.userId,
    required this.visit,
    required this.onScreen,
    required this.inputs,
    this.delay = const Duration(milliseconds: 900),
    this.clock = DateTime.now,
  });

  /// null = chua dang nhap -> khong kiem.
  final String? userId;
  final int visit;

  /// Hom nay dang that su hien. Bi che (popup, tab khac) -> bo lan kiem
  /// dang cho; lan quay lai sau kiem lai.
  final bool onScreen;
  final MilestoneInputs inputs;

  /// Cho hieu ung tien do (vong, nhiem vu) chay xong truoc khi chuc mung.
  final Duration delay;
  final DateTime Function() clock;

  @override
  ConsumerState<GtMilestoneWatcher> createState() => _GtMilestoneWatcherState();
}

class _GtMilestoneWatcherState extends ConsumerState<GtMilestoneWatcher> {
  /// Doi man Celebration truoc dong han (200 ms) roi moi hien man sau: 2 lop
  /// nen mo khong chong len nhau.
  static const _gap = Duration(milliseconds: 220);

  Timer? _pending;
  bool _running = false;
  bool _again = false;

  /// `revision` 2 nguon o lan kiem truoc (null = chua kiem trong phien nay):
  /// doi tu do toi nay = so lieu moi den tu may khac -> ghi nhan, khong chuc
  /// mung.
  int? _dailySeen;
  int? _pathSeen;

  @override
  void didUpdateWidget(GtMilestoneWatcher old) {
    super.didUpdateWidget(old);
    if (!widget.onScreen) {
      _pending?.cancel();
      _pending = null;
      return;
    }
    // visit 0 = Hom nay chua hien lan nao.
    if (widget.visit == 0) return;
    if (old.visit != widget.visit ||
        old.inputs != widget.inputs ||
        old.userId != widget.userId) {
      _schedule();
    }
  }

  void _schedule() {
    _pending?.cancel();
    _pending = Timer(widget.delay, _check);
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    _pending = null;
    if (_running) {
      // Dang hien dot truoc: kiem lai ngay sau.
      _again = true;
      return;
    }
    final userId = widget.userId;
    if (userId == null || !mounted || !widget.onScreen) return;
    _running = true;
    try {
      await _run(userId);
    } finally {
      _running = false;
      if (_again && mounted) {
        _again = false;
        _schedule();
      }
    }
  }

  Future<void> _run(String userId) async {
    final inputs = widget.inputs;
    final today = DailyProgressStore.keyOf(widget.clock());
    final body = inputs.body;
    final english = inputs.english;
    final rank = body == null || english == null
        ? null
        : gymTalkRank(body, english).tier;
    final loaded = await MilestoneStore.load(userId);
    // Bi che / doi tai khoan trong luc doc: de lan quay lai sau.
    if (!mounted || !widget.onScreen || widget.userId != userId) return;
    final quiet = {
      if (inputs.streak != null &&
          _dailySeen != null &&
          _dailySeen != inputs.dailyRevision)
        MilestoneKind.streak,
      if (rank != null && _pathSeen != null && _pathSeen != inputs.pathRevision)
        MilestoneKind.rank,
    };
    if (inputs.streak != null) _dailySeen = inputs.dailyRevision;
    if (rank != null) _pathSeen = inputs.pathRevision;
    final found = detectMilestones(
      loaded,
      today: today,
      streak: inputs.streak,
      bodyLevel: body?.index,
      rank: rank,
      quiet: quiet,
    );
    var record = found.base;
    if (record != loaded) await MilestoneStore.save(userId, record);
    for (final (i, milestone) in found.celebrate.indexed) {
      if (i > 0) await Future<void>.delayed(_gap);
      // Watcher bi huy (vd dang xuat): phan con lai CHUA ghi -> lan sau hien.
      if (!mounted) return;
      record = applyMilestone(record, milestone, today: today);
      await MilestoneStore.save(userId, record);
      if (!mounted) return;
      await _celebrate(milestone);
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
