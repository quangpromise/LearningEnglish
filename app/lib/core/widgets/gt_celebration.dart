import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../feedback/gt_feedback_tier.dart';
import '../navigation/nav_keys.dart';
import '../theme/gt_haptics.dart';
import '../theme/gt_motion.dart';
import '../theme/gt_tokens.dart';
import 'gt_count_up.dart';

/// Toast XP dung chung (README "Interactions"): vien vang o dinh, "+N XP",
/// 1.8s truot xuong 12px + hien dan, giu, mo dan. Chi goi voi XP DA cong
/// that tren server.
void showXpToast(int xp, {OverlayState? overlay}) {
  if (xp <= 0) return;
  final state = overlay ?? rootNavigatorKey.currentState?.overlay;
  if (state == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _XpToast(
      xp: xp,
      onDone: () {
        entry.remove();
        entry.dispose();
      },
    ),
  );
  state.insert(entry);
}

class _XpToast extends StatefulWidget {
  const _XpToast({required this.xp, required this.onDone});
  final int xp;
  final VoidCallback onDone;

  @override
  State<_XpToast> createState() => _XpToastState();
}

class _XpToastState extends State<_XpToast>
    with SingleTickerProviderStateMixin {
  // `preserve`: controller nay DEM THOI GIAN hien toast - mac dinh no bi
  // rut ~20 lan khi Android tat hieu ung, toast se bien mat gan nhu ngay.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
    animationBehavior: AnimationBehavior.preserve,
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final top = MediaQuery.paddingOf(context).top + 14;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final v = _c.value;
            // 0-15%: vao; 15-80%: giu; 80-100%: ra.
            final opacity = v < 0.15
                ? v / 0.15
                : v > 0.8
                ? (1 - v) / 0.2
                : 1.0;
            // Giam chuyen dong: chi hien/mo, khong truot.
            final still = gtReduceMotion(context);
            final dy = still || v >= 0.15 ? 0.0 : -12 * (1 - v / 0.15);
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.translate(offset: Offset(0, dy), child: child),
            );
          },
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: GtCountUp(
                  value: widget.xp,
                  format: (v) => '+$v XP',
                  style: GtText.cardTitle(t.onGold).copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// GymTalk Rank vua tang CUNG khoanh khac duoc chuc mung (qua Level Test,
/// len Body Level): hien thanh the trong chinh man chuc mung do - 1
/// khoanh khac 1 Celebration (#121). [fromTier] / [toTier]: bac hien thi
/// (1..5).
@immutable
class GtRankUp {
  const GtRankUp({
    required this.fromTier,
    required this.toTier,
    required this.title,
    required this.detail,
  });

  final int fromTier;
  final int toTier;

  /// Vd "Len GymTalk Rank!".
  final String title;

  /// Vd "Bac 3: Athlete · B1".
  final String detail;
}

/// Man chuc mung (README "Interactions"): nen den 86% + blur 8, huy hieu
/// vang "+N XP" bat len roi toa sang, tieu de, dong phu, [rankUp], chip, nut
/// trang. [haptic] = false khi noi goi da rung cho chinh khoanh khac nay (vd
/// nap ruong bat len ngay truoc do) - khong rung 2 lan lien tiep.
Future<void> showCelebration(
  BuildContext context, {
  required int xp,
  required String title,
  required String subtitle,
  required String ctaLabel,
  List<String> chips = const [],
  GtRankUp? rankUp,
  bool haptic = true,
}) {
  if (haptic) GtHaptics.play(GtHapticEvent.celebration);
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, _) => GtCelebration(
      xp: xp,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      chips: chips,
      rankUp: rankUp,
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}

class GtCelebration extends StatefulWidget {
  const GtCelebration({
    super.key,
    required this.xp,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onClose,
    this.chips = const [],
    this.rankUp,
  });

  final int xp;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<String> chips;
  final GtRankUp? rankUp;
  final VoidCallback onClose;

  @override
  State<GtCelebration> createState() => _GtCelebrationState();
}

class _GtCelebrationState extends State<GtCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Giam chuyen dong: huy hieu hien ngay, khong bat len, khong toa sang
    // lap lai (doc co o day vi initState chua doc duoc MediaQuery/View).
    if (gtReduceMotion(context)) {
      _pop.value = 1;
      return;
    }
    _pop.forward().whenCompleteOrCancel(() {
      if (mounted) _glow.repeat();
    });
  }

  @override
  void dispose() {
    _pop.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    // cubic-bezier(.2,1.4,.4,1): vuot qua 1 roi ve 1.
    const popCurve = Cubic(0.2, 1.4, 0.4, 1);
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.86),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                AnimatedBuilder(
                  animation: Listenable.merge([_pop, _glow]),
                  builder: (context, child) {
                    final s = 0.4 + 0.6 * popCurve.transform(_pop.value);
                    final g = sin(_glow.value * pi);
                    return Transform.scale(
                      scale: s,
                      child: Container(
                        width: 150,
                        height: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [t.gold, t.gold.withValues(alpha: 0.55)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.gold.withValues(alpha: 0.25 + 0.3 * g),
                              blurRadius: 24 + 24 * g,
                              spreadRadius: 4 + 8 * g,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  // Ngoai builder: toa sang lap moi frame khong build lai so.
                  // Khong co XP that (vd nhiem vu da nhan truoc do) -> dau
                  // tick, khong bia so.
                  child: widget.xp > 0
                      ? GtCountUp(
                          value: widget.xp,
                          format: (v) => '+$v XP',
                          style: GtText.ringStat(t.onGold),
                        )
                      : Icon(Icons.check_rounded, color: t.onGold, size: 64),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GtText.heroTitle(Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GtText.body(const Color(0xFFB9BDC4), size: 16),
                ),
                if (widget.rankUp case final rankUp?) ...[
                  const SizedBox(height: 24),
                  GtRankUpCard(rankUp: rankUp),
                ],
                if (widget.chips.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final c in widget.chips)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            c,
                            style: GtText.body(Colors.white, size: 13),
                          ),
                        ),
                    ],
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B0C0E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: widget.onClose,
                    child: Text(
                      widget.ctaLabel,
                      style: GtText.rowTitle(const Color(0xFF0B0C0E)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Len GymTalk Rank" trong man chuc mung: truot len ngay sau huy hieu
/// chinh, roi so bac tren huy hieu Rank doi tu cu sang moi (cu truot len, moi
/// tu duoi len) kem vong sang lan ra (khong blur) va 1 nhip rung nhe. Giam
/// chuyen dong: hien ngay bac moi, khong truot, khong rung them.
class GtRankUpCard extends StatefulWidget {
  const GtRankUpCard({
    super.key,
    required this.rankUp,
    this.enterAfter = const Duration(milliseconds: 450),
    this.flipAfter = const Duration(milliseconds: 950),
  });

  final GtRankUp rankUp;

  /// Luc the bat dau truot len (sau khi huy hieu chinh gan bat xong).
  final Duration enterAfter;

  /// Luc so bac doi sang bac moi.
  final Duration flipAfter;

  @override
  State<GtRankUpCard> createState() => _GtRankUpCardState();
}

class _GtRankUpCardState extends State<GtRankUpCard>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Timer? _enterTimer;
  Timer? _flipTimer;
  bool _started = false;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _still = gtReduceMotion(context);
    if (_still) {
      _enter.value = 1;
      _flip.value = 1;
      return;
    }
    _enterTimer = Timer(widget.enterAfter, () {
      if (mounted) _enter.forward();
    });
    _flipTimer = Timer(widget.flipAfter, () {
      if (!mounted) return;
      GtHaptics.play(GtHapticEvent.rankUp);
      _flip.forward();
    });
  }

  @override
  void dispose() {
    _enterTimer?.cancel();
    _flipTimer?.cancel();
    _enter.dispose();
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final enter = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    final tierStyle = GtText.cardTitle(t.gold).copyWith(
      fontSize: 22,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(enter),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // So bac chi de nhin - dong chu ben canh da noi bac moi.
              ExcludeSemantics(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: AnimatedBuilder(
                    animation: _flip,
                    builder: (context, _) => CustomPaint(
                      painter: _RankHaloPainter(
                        progress: _still ? 0 : _flip.value,
                        color: t.gold,
                      ),
                      child: Transform.scale(
                        scale: _still ? 1 : _bump(_flip.value),
                        child: _badge(t, tierStyle),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.rankUp.title,
                      style: GtText.rowTitle(Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.rankUp.detail,
                      style: GtText.body(const Color(0xFFB9BDC4), size: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phong to nhe roi ve (1 -> 1.18 -> 1) trong luc doi bac.
  static double _bump(double v) =>
      1 + 0.18 * sin(pi * ((v - 0.25) / 0.75).clamp(0.0, 1.0));

  Widget _badge(GtTokens t, TextStyle style) {
    final rankUp = widget.rankUp;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      color: t.gold.withValues(alpha: 0.14),
      border: Border.all(color: t.gold, width: 2.5),
    );
    if (_still) {
      return DecoratedBox(
        decoration: decoration,
        child: Center(child: Text('${rankUp.toTier}', style: style)),
      );
    }
    // Bac cu truot len va mo; bac moi tu duoi len.
    final swap = Curves.easeInOutCubic.transform(
      (_flip.value / 0.45).clamp(0.0, 1.0),
    );
    return DecoratedBox(
      decoration: decoration,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -20 * swap),
              child: Opacity(
                opacity: 1 - swap,
                child: Text('${rankUp.fromTier}', style: style),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 20 * (1 - swap)),
              child: Opacity(
                opacity: swap,
                child: Text('${rankUp.toTier}', style: style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vong sang lan ra quanh huy hieu Rank khi doi bac (net ve, khong blur).
class _RankHaloPainter extends CustomPainter {
  _RankHaloPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.3) return;
    final p = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
    final r = size.shortestSide / 2 * (1 + 0.6 * Curves.easeOut.transform(p));
    canvas.drawCircle(
      size.center(Offset.zero),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 + 2.5 * (1 - p)
        ..color = color.withValues(alpha: 0.6 * (1 - p)),
    );
  }

  @override
  bool shouldRepaint(_RankHaloPainter old) =>
      old.progress != progress || old.color != color;
}

/// Hien phan hoi dung tang cua [event] (ADR-0008): Milestone ->
/// [celebration]; viec thuong ngay -> XP Toast voi [xp] that (0 thi khong
/// hien gi); tang tai cho do noi goi tu lo.
Future<void> showTieredFeedback(
  BuildContext context,
  GtFeedbackEvent event, {
  required int xp,
  required Future<void> Function() celebration,
  bool firstToday = false,
}) async {
  switch (feedbackTier(event, firstToday: firstToday)) {
    case GtFeedbackTier.celebration:
      await celebration();
    case GtFeedbackTier.toast:
      showXpToast(xp, overlay: Overlay.maybeOf(context, rootOverlay: true));
    case GtFeedbackTier.inline:
      break;
  }
}
