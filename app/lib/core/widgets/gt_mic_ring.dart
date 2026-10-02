import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// Vong quanh nut mic phap phong theo am luong giong noi that (spec #96).
/// Chi ve va nghe [level] (0..1) khi [active] - het thu thi dung han. Giam
/// chuyen dong: chi doi mau (vien tinh), khong phap phong.
class GtMicRing extends StatelessWidget {
  const GtMicRing({
    super.key,
    required this.active,
    required this.level,
    required this.color,
    required this.child,
  });

  final bool active;
  final ValueListenable<double> level;
  final Color color;

  /// Nut tron o giua (vong ve quanh no).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    if (gtReduceMotion(context)) {
      return DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
        ),
        child: child,
      );
    }
    // Mau tu thu vien den ~10 lan/giay -> noi muot giua 2 mau.
    final smooth = gtMotion(context, GtMotionKind.effects, GtMotionSpeed.fast);
    return ValueListenableBuilder<double>(
      valueListenable: level,
      child: child,
      builder: (context, target, child) => TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: smooth.duration,
        curve: smooth.curve,
        child: child,
        builder: (context, v, child) => CustomPaint(
          painter: GtMicRingPainter(level: v, color: color),
          child: child,
        ),
      ),
    );
  }
}

/// 2 vong mo dan ra ngoai, rong ra theo [level].
class GtMicRingPainter extends CustomPainter {
  GtMicRingPainter({required this.level, required this.color});

  final double level;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final v = level.clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.stroke;
    canvas.drawCircle(
      c,
      r + 6 + 12 * v,
      paint
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.25 + 0.4 * v),
    );
    canvas.drawCircle(
      c,
      r + 10 + 24 * v,
      paint
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.2 * v),
    );
  }

  @override
  bool shouldRepaint(GtMicRingPainter old) =>
      old.level != level || old.color != color;
}
