import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/gt_haptics.dart';
import '../../../core/theme/gt_motion.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../../core/widgets/gt_count_up.dart';
import '../../today/data/daily_progress_store.dart';
import '../../today/presentation/gt_quests_card.dart';
import '../data/srs_store.dart';

/// On the ban redesign (spec #70, #78; README §10): the lon lat 3D, 3 nut
/// Quen / Kho / Nho kem khoang on that, the bay ra theo muc cham, thanh tien
/// do chay muot. Het bo the -> man "xong" tai cho (so the dem len) + XP
/// Toast neu vua cong XP nhiem vu - khong Celebration (ADR-0008). Mo qua
/// `SrsReviewScreen`.
class GtSrsReviewScreen extends ConsumerStatefulWidget {
  const GtSrsReviewScreen({
    super.key,
    this.maxCards = 20,
    this.cards,
    this.stopVoice,
    this.progress,
  });

  final int maxCards;

  /// Noi ghi tien do ngay (mac dinh [DailyProgressStore.instance]); test
  /// truyen store rieng.
  final DailyProgressStore? progress;

  /// Dung giong doc (mac dinh [TutorialVoice]); test truyen ham rong vi
  /// TutorialVoice dung plugin am thanh.
  final void Function()? stopVoice;

  /// The co san (test); null -> the den han trong [SrsStore].
  final List<SrsCard>? cards;

  @override
  ConsumerState<GtSrsReviewScreen> createState() => _GtSrsReviewScreenState();
}

/// 1 the vua cham dang bay ra.
class _Flying {
  _Flying(this.card, this.grade, this.controller);

  final SrsCard card;
  final SrsGrade grade;
  final AnimationController controller;
}

class _GtSrsReviewScreenState extends ConsumerState<GtSrsReviewScreen>
    with TickerProviderStateMixin {
  List<SrsCard>? _queue;
  int _index = 0;

  /// Da cham vao the (bat dau lat).
  bool _flipped = false;

  /// Lat xong: nut cham sang va moi nhan cham.
  bool _revealed = false;
  bool _finished = false;

  late final AnimationController _flip = AnimationController(vsync: this);
  Curve _flipCurve = Curves.linear;
  final List<_Flying> _flying = [];

  @override
  void initState() {
    super.initState();
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
    _flip.dispose();
    for (final f in _flying) {
      f.controller.dispose();
    }
    super.dispose();
  }

  /// Lat the theo truc doc (~320 ms, lo xo standard); giam chuyen dong: hien
  /// mat sau ngay.
  void _flipCard() {
    if (_flipped) return;
    final motion = gtMotion(context, GtMotionKind.standard);
    setState(() => _flipped = true);
    if (motion.duration == Duration.zero) {
      _flip.value = 1;
      setState(() => _revealed = true);
      return;
    }
    _flipCurve = motion.curve;
    _flip.duration = motion.duration;
    final flipping = _index;
    _flip.forward(from: 0).whenCompleteOrCancel(() {
      // Van la the do (chua doi the giua chung).
      if (mounted && _index == flipping && _flipped) {
        setState(() => _revealed = true);
      }
    });
  }

  Future<void> _grade(SrsGrade grade) async {
    final queue = _queue;
    if (queue == null ||
        !acceptsGrade(
          index: _index,
          length: queue.length,
          revealed: _revealed,
        )) {
      return;
    }
    final card = queue[_index];
    _stopVoice();
    GtHaptics.play(GtHapticEvent.cardGraded);
    SrsStore.instance.grade(card.key, grade, now: DateTime.now());
    final next = requeueAfterGrade(queue, index: _index, grade: grade);
    // "Quen" lan dau trong phien: gap lai o cuoi -> khong tinh 2 lan.
    final repeat = queue.take(_index).any((c) => c.key == card.key);
    _flyOut(card, grade);
    setState(() {
      _queue = next;
      _index++;
      _flipped = false;
      _revealed = false;
      _flip.value = 0;
    });
    if (!repeat) {
      await (widget.progress ?? DailyProgressStore.instance).addWordsReviewed();
    }
    if (_index >= next.length) await _finish();
  }

  /// The vua cham bay ra theo muc cham; giam chuyen dong: doi the tuc thi.
  void _flyOut(SrsCard card, SrsGrade grade) {
    final duration = gtMotion(context, GtMotionKind.standard).duration;
    if (duration == Duration.zero) return;
    final controller = AnimationController(vsync: this, duration: duration);
    final flying = _Flying(card, grade, controller);
    _flying.add(flying);
    controller.forward().whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() => _flying.remove(flying));
      controller.dispose();
    });
  }

  /// So the khac nhau da on (the quen gap lai khong tinh 2 lan).
  int _uniqueCount(List<SrsCard> queue) =>
      queue.map((c) => c.key).toSet().length;

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    // Nhiem vu "On the" co the vua dat -> tra XP (khoa chong trung o server).
    // Chi bao XP ma CHINH lan goi nay vua cong: neu man Hom nay da tra (va
    // da hien toast) giua phien thi o day = 0, khong bao lai.
    final xp = await ref
        .read(questRewardServiceProvider)
        .claimPendingQuests()
        .catchError((Object _) => 0);
    if (!mounted) return;
    showXpToast(xp, overlay: Overlay.maybeOf(context, rootOverlay: true));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final queue = _queue;
    final total = queue?.length ?? 0;
    final bar = gtMotion(context, GtMotionKind.standard);
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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: total == 0 ? 0 : _index / total),
                        duration: bar.duration,
                        curve: bar.curve,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          minHeight: 8,
                          color: t.blue,
                          backgroundColor: t.s2,
                        ),
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
    final done = _index >= queue.length;
    final current = done
        ? _DeckDone(
            count: _uniqueCount(queue),
            onClose: () => Navigator.of(context).maybePop(),
          )
        : _currentCard(queue[_index]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: current),
                for (final f in _flying)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _FlyingCard(flying: f, size: box.biggest),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!done) ...[
          const SizedBox(height: 16),
          GtGradeButtons(
            enabled: _revealed,
            labels: {
              for (final g in SrsGrade.values)
                g: intervalLabel(
                  SrsStore.instance.nextIntervalDays(queue[_index], g),
                  today: ref.tr('gt_srs_interval_today'),
                  days: ref.tr('gt_srs_interval_days'),
                ),
            },
            onGrade: _grade,
          ),
        ],
      ],
    );
  }

  /// The hien tai: phong nhe vao (tru the dau), lat 3D khi cham.
  Widget _currentCard(SrsCard card) {
    final enter = gtMotion(
      context,
      GtMotionKind.expressive,
      GtMotionSpeed.fast,
    );
    return TweenAnimationBuilder<double>(
      key: ValueKey(_index),
      tween: Tween(begin: _index == 0 ? 1 : 0, end: 1),
      duration: enter.duration,
      curve: enter.curve,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.94 + 0.06 * v, child: child),
      ),
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = _flipCurve.transform(_flip.value) * pi;
          final back = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(back ? angle - pi : angle),
            child: GtFlashcard(card: card, flipped: back, onFlip: _flipCard),
          );
        },
      ),
    );
  }
}

/// The vua cham bay ra: Quen trai (do), Kho xuong (vang), Nho phai (ngoc),
/// nhuom mau muc cham va mo dan.
class _FlyingCard extends StatelessWidget {
  const _FlyingCard({required this.flying, required this.size});

  final _Flying flying;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final dir = flyDirection(flying.grade);
    final tint = switch (flying.grade) {
      SrsGrade.forgot => t.red,
      SrsGrade.hard => t.gold,
      SrsGrade.know => t.teal,
    };
    final card = GtFlashcard(card: flying.card, flipped: true, onFlip: () {});
    return AnimatedBuilder(
      animation: flying.controller,
      builder: (context, child) {
        // Roi di: tang toc dan.
        final p = Curves.easeInCubic.transform(flying.controller.value);
        return Transform.translate(
          offset: Offset(
            dir.dx * size.width * 1.15 * p,
            dir.dy * size.height * 0.9 * p,
          ),
          child: Transform.rotate(
            angle: dir.dx * 0.22 * p,
            child: Opacity(
              opacity: 1 - p,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.35 * p),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: card,
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
/// lat the xong roi sang dan len.
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
    final fade = gtMotion(context, GtMotionKind.effects);
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.35,
      duration: fade.duration,
      curve: fade.curve,
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

/// Man "xong bo the" tai cho (ADR-0008): dau tick, tieu de, so the dem len.
class _DeckDone extends ConsumerWidget {
  const _DeckDone({required this.count, required this.onClose});

  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: t.gold, size: 56),
          const SizedBox(height: 14),
          Text(
            ref.tr('gt_srs_done_title'),
            textAlign: TextAlign.center,
            style: GtText.cardTitle(t.tx),
          ),
          const SizedBox(height: 6),
          GtCountUp(
            value: count,
            format: (n) => ref.tr('gt_srs_done_sub').replaceFirst('{n}', '$n'),
            textAlign: TextAlign.center,
            style: GtText.body(t.tx2),
          ),
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
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

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
        ],
      ),
    );
  }
}
