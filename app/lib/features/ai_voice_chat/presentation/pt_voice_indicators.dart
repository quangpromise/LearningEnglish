import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/theme/gt_motion.dart';

/// 3 cham "tho" khi PT AI dang nghi (spec #96, MO-09) - lap trong luc con
/// nghi, dung ngay khi bi go khoi cay (het nghi / roi man). Giam chuyen
/// dong: 3 cham dung yen.
class GtThinkingDots extends StatefulWidget {
  const GtThinkingDots({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  /// Chu ky 1 nhip tho (vong lap, khong phai chuyen canh nen khong theo token).
  static const period = Duration(milliseconds: 1200);

  @override
  State<GtThinkingDots> createState() => _GtThinkingDotsState();
}

class _GtThinkingDotsState extends State<GtThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: GtThinkingDots.period,
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!gtReduceMotion(context)) _breath.repeat();
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: widget.size * 0.6),
            () {
              // Moi cham tre 0.18 chu ky -> song tho chay qua 3 cham.
              final phase = (_breath.value - i * 0.18) * 2 * math.pi;
              final pulse = _breath.isAnimating
                  ? 0.5 + 0.5 * math.sin(phase)
                  : 1.0;
              return Opacity(
                opacity: 0.35 + 0.65 * pulse,
                child: Transform.scale(
                  scale: 0.75 + 0.25 * pulse,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }
}

/// Thanh song giong PT AI: 5 thanh cao theo muc am [level] (0..1) cua giong
/// AI - chi dat khi PT dang noi. Giam chuyen dong: thanh dung yen.
class GtVoiceBars extends StatelessWidget {
  const GtVoiceBars({
    super.key,
    required this.level,
    required this.color,
    this.height = 22,
  });

  final ValueListenable<double> level;
  final Color color;
  final double height;

  /// Thanh giua cao nhat, 2 ben thap dan.
  static const _shape = [0.45, 0.8, 1.0, 0.7, 0.5];

  Widget _bars(double v) => SizedBox(
    height: height,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final (i, s) in _shape.indexed) ...[
          if (i > 0) const SizedBox(width: 3),
          Container(
            key: ValueKey('gt-voice-bar-$i'),
            width: 4,
            height: 4 + (height - 4) * s * v.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (gtReduceMotion(context)) return _bars(0.5);
    final smooth = gtMotion(context, GtMotionKind.effects, GtMotionSpeed.fast);
    return ValueListenableBuilder<double>(
      valueListenable: level,
      builder: (context, target, _) => TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: smooth.duration,
        curve: smooth.curve,
        builder: (context, v, _) => _bars(v),
      ),
    );
  }
}
