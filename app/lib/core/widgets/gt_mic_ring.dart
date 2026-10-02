import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// Vong quanh nut mic phap phong theo am luong giong noi that (spec #96).
/// Chi nghe [level] (0..1) va ve khi [active] (dang thu) - het thu thi dung
/// han. Giam chuyen dong: chi doi mau (vien tinh), khong phap phong. Cay
/// widget giu nguyen hinh dang khi bat / tat (nut ben trong khong bi dung
/// lai), vong ve tren lop rieng (khong ve lai ca man moi khung hinh).
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

  static final ValueListenable<double> _silent = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final still = gtReduceMotion(context);
    final pulsing = active && !still;
    // Vong to / nho la thay doi kich thuoc -> token standard nhanh.
    final smooth = gtMotion(context, GtMotionKind.standard, GtMotionSpeed.fast);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: active && still
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            )
          : const BoxDecoration(),
      child: RepaintBoundary(
        child: ValueListenableBuilder<double>(
          valueListenable: pulsing ? level : _silent,
          child: RepaintBoundary(child: child),
          builder: (context, target, child) => TweenAnimationBuilder<double>(
            tween: Tween(end: pulsing ? target : 0),
            duration: pulsing ? smooth.duration : Duration.zero,
            curve: smooth.curve,
            child: child,
            builder: (context, v, child) => CustomPaint(
              painter: pulsing
                  ? GtMicRingPainter(level: v, color: color)
                  : null,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 2 vong mo dan ra ngoai, rong ra theo [level]; khoang cach theo ban kinh
/// nut (nut nho -> vong sat hon).
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
      r * (1.12 + 0.18 * v),
      paint
        ..strokeWidth = r * 0.08
        ..color = color.withValues(alpha: 0.25 + 0.4 * v),
    );
    canvas.drawCircle(
      c,
      r * (1.24 + 0.36 * v),
      paint
        ..strokeWidth = r * 0.05
        ..color = color.withValues(alpha: 0.2 * v),
    );
  }

  @override
  bool shouldRepaint(GtMicRingPainter old) =>
      old.level != level || old.color != color;
}
