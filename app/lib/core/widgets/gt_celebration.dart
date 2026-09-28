import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation/nav_keys.dart';
import '../theme/gt_tokens.dart';

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
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
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
            final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
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
                child: Text(
                  '+${widget.xp} XP',
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

/// Man chuc mung (README "Interactions"): nen den 86% + blur 8, huy hieu
/// vang "+N XP" bat len roi toa sang, tieu de, dong phu, chip, nut trang.
Future<void> showCelebration(
  BuildContext context, {
  required int xp,
  required String title,
  required String subtitle,
  required String ctaLabel,
  List<String> chips = const [],
}) {
  HapticFeedback.heavyImpact();
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
  });

  final int xp;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<String> chips;
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

  @override
  void initState() {
    super.initState();
    // Toa sang lap lai sau khi bat len xong; tat khi he thong giam chuyen
    // dong.
    _pop.forward().whenCompleteOrCancel(() {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
      _glow.repeat();
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
                  builder: (context, _) {
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
                        child: Text(
                          '+${widget.xp} XP',
                          style: GtText.ringStat(t.onGold),
                        ),
                      ),
                    );
                  },
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
