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

  // Moi cham tre 0.18 chu ky -> song tho chay qua 3 cham.
  late final _pulses = [for (var i = 0; i < 3; i++) _Pulse(_breath, i * 0.18)];
  var _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Doc lai moi lan: bat / tat giam chuyen dong trong luc dang nghi.
    _still = gtReduceMotion(context);
    if (_still) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  Widget _dot(int i) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );
    if (_still) return dot;
    final pulse = _pulses[i];
    return FadeTransition(
      opacity: pulse.drive(Tween(begin: 0.35, end: 1.0)),
      child: ScaleTransition(
        scale: pulse.drive(Tween(begin: 0.75, end: 1.0)),
        child: dot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lop ve rieng: nhip tho khong ve lai ca man.
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: widget.size * 0.6),
            _dot(i),
          ],
        ],
      ),
    );
  }
}

/// Nhip tho 0..1 cua 1 cham, lech [offset] chu ky so voi [parent].
class _Pulse extends Animation<double> with AnimationWithParentMixin<double> {
  _Pulse(this.parent, this.offset);

  @override
  final Animation<double> parent;
  final double offset;

  @override
  double get value =>
      0.5 + 0.5 * math.sin((parent.value - offset) * 2 * math.pi);
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
    // Lop ve rieng: thanh song doi moi khung hinh khong ve lai ca man.
    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: level,
        builder: (context, target, _) => TweenAnimationBuilder<double>(
          tween: Tween(end: target),
          duration: smooth.duration,
          curve: smooth.curve,
          builder: (context, v, _) => _bars(v),
        ),
      ),
    );
  }
}
