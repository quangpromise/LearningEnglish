import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';
import '../theme/gt_tokens.dart';

/// Vong tick (spec #96): vong vien rong -> hinh tron mau bat len (lo xo
/// expressive nhanh) roi dau check duoc ve ra.
///
/// [progress] la dong thoi gian TUYEN TINH 0..1 cua ca hieu ung (1 = da
/// tick) - controller cua cho dung lay thoi luong o [GtTickCircle.motion].
class GtTickCircle extends StatelessWidget {
  const GtTickCircle({
    super.key,
    required this.progress,
    this.size = 28,
    this.color,
    this.checkColor,
  });

  final double progress;
  final double size;

  /// Mau hinh tron / dau check (mac dinh vang / chu tren vang).
  final Color? color;
  final Color? checkColor;

  /// Thoi luong + che do giam chuyen dong cho controller dieu khien
  /// [progress] (giam chuyen dong -> 0 ms: dat thang 1).
  static Duration motion(BuildContext context) =>
      gtMotion(context, GtMotionKind.expressive, GtMotionSpeed.slow).duration;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return CustomPaint(
      size: Size.square(size),
      painter: _TickPainter(
        progress: progress,
        fill: color ?? t.gold,
        check: checkColor ?? t.onGold,
        border: t.tx3,
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.progress,
    required this.fill,
    required this.check,
    required this.border,
  });

  final double progress;
  final Color fill;
  final Color check;
  final Color border;

  // Hinh tron bat len trong 60% dau = dung thoi gian on dinh cua lo xo
  // expressive nhanh (360 / 600 ms); dau check ve tu 25% toi 75%.
  static final _pop = gtSpringCurve(
    GtMotionKind.expressive,
    GtMotionSpeed.fast,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final r = s / 2;
    final pop = progress <= 0
        ? 0.0
        : _pop.transform((progress / 0.6).clamp(0.0, 1.0));
    final draw = Curves.easeOutCubic.transform(
      ((progress - 0.25) / 0.5).clamp(0.0, 1.0),
    );
    final shown = pop.clamp(0.0, 1.0);
    if (shown < 1) {
      canvas.drawCircle(
        c,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = border.withValues(alpha: border.a * (1 - shown)),
      );
    }
    // Ban kinh theo lo xo: vuot qua 1 mot chut roi ve dung co.
    if (pop > 0) canvas.drawCircle(c, r * pop, Paint()..color = fill);
    if (draw <= 0) return;
    final path = Path()
      ..moveTo(s * 0.29, s * 0.52)
      ..lineTo(s * 0.44, s * 0.67)
      ..lineTo(s * 0.72, s * 0.37);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * draw),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.095
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = check,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.progress != progress ||
      old.fill != fill ||
      old.check != check ||
      old.border != border;
}
