import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'body_diagram.dart';

/// Hinh nguoi don gian TU VE chuyen dong lien tuc (tay/chan dang ra khep
/// vao, than nguoi nhun len xuong) trong luc man hen gio dang chay - de
/// gay cam giac "dang tap" hon la chi hien 1 hinh tinh. Vung co dang tap
/// (region) duoc to do, phan con lai mo nhat - giong tinh than "highlight
/// nhom co" nhung bang hinh minh hoa GOC ve bang CustomPainter, khong sao
/// chep hinh anh/video giai phau tu bat ky app hay nguon nao khac.
class ExerciseAnimation extends StatefulWidget {
  const ExerciseAnimation({
    super.key,
    required this.color,
    this.region = BodyRegion.fullBody,
    this.size = 130,
  });
  final Color color;
  final BodyRegion region;
  final double size;

  @override
  State<ExerciseAnimation> createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size(widget.size, widget.size * 1.5),
        painter: _ExercisePainter(
          t: _controller.value,
          color: widget.color,
          region: widget.region,
        ),
      ),
    );
  }
}

class _ExercisePainter extends CustomPainter {
  _ExercisePainter({
    required this.t,
    required this.color,
    required this.region,
  });
  final double t;
  final Color color;
  final BodyRegion region;

  bool _isHighlighted(BodyRegion part) =>
      region == part || region == BodyRegion.fullBody;

  Paint _paintFor(BodyRegion part) => Paint()
    ..color = (_isHighlighted(part) ? color : AppColors.glassBorder).withValues(
      alpha: _isHighlighted(part) ? 0.85 : 0.4,
    )
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final head = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final bob = h * 0.03 * t;
    final armSpread = w * 0.1 * t;
    final legSpread = w * 0.05 * (1 - t);

    // Dau
    canvas.drawCircle(Offset(w * 0.5, h * 0.09 + bob), w * 0.14, head);

    // Than (bung/nguc - vung "abs")
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.32,
        h * 0.20 + bob,
        w * 0.68,
        h * 0.55 + bob,
        const Radius.circular(10),
      ),
      _paintFor(BodyRegion.abs),
    );

    // 2 tay - dang ra/khep vao
    final armPaint = _paintFor(BodyRegion.arms);
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.14 - armSpread,
        h * 0.22 + bob,
        w * 0.30 - armSpread,
        h * 0.50 + bob,
        const Radius.circular(8),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.70 + armSpread,
        h * 0.22 + bob,
        w * 0.86 + armSpread,
        h * 0.50 + bob,
        const Radius.circular(8),
      ),
      armPaint,
    );

    // 2 chan - dang ra/khep vao nguoc pha nhe voi tay
    final legPaint = _paintFor(BodyRegion.legs);
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.34 - legSpread,
        h * 0.56,
        w * 0.48 - legSpread,
        h * 0.95,
        const Radius.circular(8),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.52 + legSpread,
        h * 0.56,
        w * 0.66 + legSpread,
        h * 0.95,
        const Radius.circular(8),
      ),
      legPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ExercisePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.region != region;
}
