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
import 'rank_up.dart';

/// So lieu de kiem Milestone. null = chua chac chan (chua dong bo xong lan
/// dau, dang tai, loi mang) -> giu nguyen phan do cua ban ghi.
/// [syncedOn]: ngay ('yyyy-mm-dd') dong bo thanh cong gan nhat cho tai khoan
/// nay - chi khi la hom nay moi ha moc chuoi (du lieu cu co the thieu ngay
/// lam o may khac).
typedef MilestoneInputs = ({
  int? streak,
  String? syncedOn,
  BodyLevel? body,
  CefrLevel? english,
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
    final found = detectMilestones(
      loaded,
      today: today,
      streak: inputs.streak,
      bodyLevel: body?.index,
      rank: rank,
      lowerStreak: inputs.syncedOn == today,
    );
    var record = found.base;
    if (record != loaded) await MilestoneStore.save(userId, record);
    // Len Body Level keo Rank len cung luc: 1 man (the Rank gop vao), khong
    // 2 man lien nhau (#121). Chi gop khi biet bac cu (de the doi tu bac do).
    final rankBefore = loaded.rank;
    final shows = <List<Milestone>>[];
    for (final m in found.celebrate) {
      final last = shows.isEmpty ? null : shows.last;
      if (m.kind == MilestoneKind.rank &&
          rankBefore != null &&
          last != null &&
          last.length == 1 &&
          last.first.kind == MilestoneKind.bodyLevel) {
        last.add(m);
      } else {
        shows.add([m]);
      }
    }
    for (final (i, group) in shows.indexed) {
      if (i > 0) await Future<void>.delayed(_gap);
      // Watcher bi huy (vd dang xuat): phan con lai CHUA ghi -> lan sau hien.
      if (!mounted) return;
      for (final m in group) {
        record = applyMilestone(record, m, today: today);
      }
      await MilestoneStore.save(userId, record);
      if (!mounted) return;
      final rankStep = group.length > 1 ? group[1] : null;
      await _celebrate(
        group.first,
        rankUp: rankStep == null || rankBefore == null
            ? null
            : rankUpCard(
                from: rankBefore,
                to: rankStep.value,
                tr: (key) => AppStrings.t(key, ref.read(appLanguageProvider)),
              ),
      );
    }
  }

  Future<void> _celebrate(Milestone m, {GtRankUp? rankUp}) {
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
        rankDetail(m.value, t),
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
        rankUp: rankUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
