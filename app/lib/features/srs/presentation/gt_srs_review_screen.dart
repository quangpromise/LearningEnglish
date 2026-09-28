import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../today/data/daily_progress_store.dart';
import '../../today/data/daily_quests.dart';
import '../../today/presentation/gt_quests_card.dart';
import '../data/srs_store.dart';

/// On the ban redesign (spec #70, #78; README §10): the lon lat duoc, 3 nut
/// Quen / Kho / Nho kem khoang on that, thanh tien do. Het bo the -> cong
/// XP nhiem vu (neu vua dat) va Celebration. Mo qua `SrsReviewScreen`.
class GtSrsReviewScreen extends ConsumerStatefulWidget {
  const GtSrsReviewScreen({
    super.key,
    this.maxCards = 20,
    this.cards,
    this.stopVoice,
  });

  final int maxCards;

  /// Dung giong doc (mac dinh [TutorialVoice]); test truyen ham rong vi
  /// TutorialVoice dung plugin am thanh.
  final void Function()? stopVoice;

  /// The co san (test); null -> the den han trong [SrsStore].
  final List<SrsCard>? cards;

  @override
  ConsumerState<GtSrsReviewScreen> createState() => _GtSrsReviewScreenState();
}

class _GtSrsReviewScreenState extends ConsumerState<GtSrsReviewScreen> {
  List<SrsCard>? _queue;
  int _index = 0;
  bool _flipped = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _reviewPaidBefore = DailyProgressStore.instance.today.rewarded.contains(
      DailyQuestId.review.rewardKey,
    );
    final given = widget.cards;
    if (given != null) {
      _queue = given;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    await SrsStore.instance.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _queue = SrsStore.instance
          .dueCards(DateTime.now())
          .take(widget.maxCards)
          .toList();
    });
  }

  void _stopVoice() => (widget.stopVoice ?? TutorialVoice.shared.stop)();

  @override
  void dispose() {
    _stopVoice();
    super.dispose();
  }

  /// Nhiem vu "On the" da duoc tra truoc phien nay chua - de chi chuc mung
  /// XP ma CHINH phien nay vua mo.
  late final bool _reviewPaidBefore;

  Future<void> _grade(SrsGrade grade) async {
    final queue = _queue;
    // Chi cham khi the dang hien da lat (chan cham dup truoc frame moi).
    if (queue == null || _index >= queue.length || !_flipped) return;
    final card = queue[_index];
    _stopVoice();
    SrsStore.instance.grade(card.key, grade, now: DateTime.now());
    final next = requeueAfterGrade(queue, index: _index, grade: grade);
    // "Quen" lan dau trong phien: gap lai o cuoi -> khong tinh 2 lan.
    final repeat = queue.take(_index).any((c) => c.key == card.key);
    setState(() {
      _queue = next;
      _index++;
      _flipped = false;
    });
    if (!repeat) await DailyProgressStore.instance.addWordsReviewed();
    if (_index >= next.length) await _finish(_uniqueCount(next));
  }

  /// So the khac nhau da on (the quen gap lai khong tinh 2 lan).
  int _uniqueCount(List<SrsCard> queue) =>
      queue.map((c) => c.key).toSet().length;

  Future<void> _finish(int count) async {
    if (_finished) return;
    _finished = true;
    // Nhiem vu "On the" co the vua dat -> tra XP (khoa chong trung o server;
    // man Hom nay co the da tra giua phien). Chi hien XP cua nhiem vu nay va
    // chi khi no duoc tra trong phien nay - khong gop XP nhiem vu khac.
    await ref
        .read(questRewardServiceProvider)
        .claimPendingQuests()
        .catchError((Object _) => 0);
    if (!mounted) return;
    final paidNow =
        !_reviewPaidBefore &&
        DailyProgressStore.instance.today.rewarded.contains(
          DailyQuestId.review.rewardKey,
        );
    await showCelebration(
      context,
      xp: paidNow ? DailyQuestId.review.xp : 0,
      title: ref.tr('gt_srs_done_title'),
      subtitle: ref.tr('gt_srs_done_sub').replaceFirst('{n}', '$count'),
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
    // "Tuyet voi" -> ve man truoc (Hom nay).
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final queue = _queue;
    final total = queue?.length ?? 0;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.close_rounded, color: t.tx),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : _index / total,
                        minHeight: 8,
                        color: t.blue,
                        backgroundColor: t.s2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_index.clamp(0, total)}/$total',
                    style: GtText.body(t.tx2, weight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _body(queue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(List<SrsCard>? queue) {
    final t = context.gt;
    if (queue == null) {
      return Center(child: CircularProgressIndicator(color: t.blue));
    }
    if (queue.isEmpty) {
      return _Message(
        icon: Icons.celebration_rounded,
        title: ref.tr('srs_review_empty_title'),
        body: ref.tr('srs_review_empty_body'),
      );
    }
    if (_index >= queue.length) {
      return _Message(
        icon: Icons.check_circle_rounded,
        title: ref.tr('srs_review_done_title'),
        body: ref
            .tr('gt_srs_done_sub')
            .replaceFirst('{n}', '${_uniqueCount(queue)}'),
        onClose: () => Navigator.of(context).maybePop(),
      );
    }
    final card = queue[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GtFlashcard(
            card: card,
            flipped: _flipped,
            onFlip: () => setState(() => _flipped = true),
          ),
        ),
        const SizedBox(height: 16),
        GtGradeButtons(
          enabled: _flipped,
          labels: {
            for (final g in SrsGrade.values)
              g: intervalLabel(
                SrsStore.instance.nextIntervalDays(card, g),
                today: ref.tr('gt_srs_interval_today'),
                days: ref.tr('gt_srs_interval_days'),
              ),
          },
          onGrade: _grade,
        ),
      ],
    );
  }
}

/// The lon (README §10): tu 46, IPA, cham de lat -> nghia xanh + vi du.
class GtFlashcard extends ConsumerWidget {
  const GtFlashcard({
    super.key,
    required this.card,
    required this.flipped,
    required this.onFlip,
  });

  final SrsCard card;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Semantics(
      button: !flipped,
      label: flipped ? null : ref.tr('gt_srs_tap_to_flip'),
      child: GestureDetector(
        onTap: flipped ? null : onFlip,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: t.s1,
            borderRadius: BorderRadius.circular(32),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref.tr('gt_srs_overline'), style: GtText.overline(t.tx3)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        card.en,
                        style: GtText.bigStat(t.tx).copyWith(fontSize: 46),
                      ),
                    ),
                    IconButton(
                      tooltip: ref.tr('gt_srs_listen'),
                      onPressed: () => TutorialVoice.shared.speak(card.en),
                      icon: Icon(Icons.volume_up_rounded, color: t.blue),
                    ),
                  ],
                ),
                if (card.ipa.isNotEmpty)
                  Text(card.ipa, style: GtText.body(t.tx2, size: 17)),
                const SizedBox(height: 20),
                if (!flipped)
                  Text(
                    ref.tr('gt_srs_tap_to_flip'),
                    style: GtText.body(t.tx3, size: 13),
                  )
                else ...[
                  Divider(color: t.bd),
                  const SizedBox(height: 12),
                  Text(
                    card.vi,
                    style: GtText.cardTitle(t.blue).copyWith(fontSize: 26),
                  ),
                  if (card.exampleEn.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(card.exampleEn, style: GtText.body(t.tx, size: 16)),
                  ],
                  if (card.exampleVi.isNotEmpty)
                    Text(card.exampleVi, style: GtText.body(t.tx2, size: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 nut cham (64h, bo 20): Quen do, Kho vang, Nho ngoc; mo 35% cho toi khi
/// lat the.
class GtGradeButtons extends ConsumerWidget {
  const GtGradeButtons({
    super.key,
    required this.enabled,
    required this.labels,
    required this.onGrade,
  });

  final bool enabled;
  final Map<SrsGrade, String> labels;
  final ValueChanged<SrsGrade> onGrade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final specs = [
      (SrsGrade.forgot, 'gt_srs_forgot', t.red, t.redT),
      (SrsGrade.hard, 'gt_srs_hard', t.gold, t.goldT),
      (SrsGrade.know, 'gt_srs_know', t.teal, t.tealT),
    ];
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Row(
        children: [
          for (final (i, (grade, key, fg, bg)) in specs.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: enabled ? () => onGrade(grade) : null,
                  child: SizedBox(
                    height: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ref.tr(key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GtText.rowTitle(fg),
                        ),
                        Text(
                          labels[grade] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GtText.body(t.tx2, size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.onClose,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: t.gold, size: 56),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GtText.cardTitle(t.tx),
          ),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: GtText.body(t.tx2)),
          if (onClose != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: t.inv,
                foregroundColor: t.onInv,
              ),
              onPressed: onClose,
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ],
      ),
    );
  }
}
