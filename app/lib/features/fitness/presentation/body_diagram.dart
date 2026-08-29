import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum BodyRegion { arms, abs, legs, fullBody }

/// Hinh nguoi don gian TU VE bang CustomPainter (khong sao chep tu bat ky
/// hinh minh hoa giai phau nao) - to do vung co tuong ung voi nhom co dang
/// xem, phan con lai ve mo nhat de lam nen.
class BodyDiagram extends StatelessWidget {
  const BodyDiagram({super.key, required this.region, this.size = 120});

  final BodyRegion region;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.6,
      child: CustomPaint(painter: _BodyPainter(region: region)),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({required this.region});
  final BodyRegion region;

  static const _base = AppColors.glassBorder;
  static const _highlight = AppColors.pink;

  Color _colorFor(BodyRegion part) =>
      (region == part || region == BodyRegion.fullBody) ? _highlight : _base;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fillBase = Paint()
      ..color = _base.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // Dau
    canvas.drawCircle(Offset(w * 0.5, h * 0.09), w * 0.13, fillBase);

    // Than (nguc + bung)
    final torso = RRect.fromLTRBR(
      w * 0.32,
      h * 0.20,
      w * 0.68,
      h * 0.55,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      torso,
      Paint()
        ..color = _colorFor(BodyRegion.abs).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // 2 tay
    final armPaint = Paint()
      ..color = _colorFor(BodyRegion.arms).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.14,
        h * 0.22,
        w * 0.30,
        h * 0.52,
        const Radius.circular(8),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.70,
        h * 0.22,
        w * 0.86,
        h * 0.52,
        const Radius.circular(8),
      ),
      armPaint,
    );

    // 2 chan
    final legPaint = Paint()
      ..color = _colorFor(BodyRegion.legs).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.34,
        h * 0.56,
        w * 0.48,
        h * 0.95,
        const Radius.circular(8),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.52,
        h * 0.56,
        w * 0.66,
        h * 0.95,
        const Radius.circular(8),
      ),
      legPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.region != region;
}

BodyRegion regionForMuscleGroup(String nameEn) => switch (nameEn) {
  'Arms' => BodyRegion.arms,
  'Abs' => BodyRegion.abs,
  'Legs' => BodyRegion.legs,
  _ => BodyRegion.fullBody,
};
