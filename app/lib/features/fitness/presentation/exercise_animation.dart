import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/fitness_data.dart';
import 'body_diagram.dart';

/// Hinh nguoi don gian TU VE, chuyen dong LIEN TUC theo dung dang tac cua
/// bai tap (squat gap goi, plank giu yen, push-up day tay, crunch gap
/// bung...) thay vi 1 kieu nhun chung chung cho moi bai. Vung co dang tap
/// (region) van duoc to do nhu truoc. Day la animation GOC ve bang
/// CustomPainter, khong sao chep hinh anh/video minh hoa tu bat ky app hay
/// nguon nao khac - chi mo phong don gian dang chuyen dong dac trung.
class ExerciseAnimation extends StatefulWidget {
  const ExerciseAnimation({
    super.key,
    required this.color,
    this.region = BodyRegion.fullBody,
    this.movement = ExerciseMovement.raise,
    this.size = 130,
  });
  final Color color;
  final BodyRegion region;
  final ExerciseMovement movement;
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
      duration: const Duration(milliseconds: 900),
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
          movement: widget.movement,
        ),
      ),
    );
  }
}

bool _isFloorMovement(ExerciseMovement m) => switch (m) {
  ExerciseMovement.pushUp ||
  ExerciseMovement.plank ||
  ExerciseMovement.crunch ||
  ExerciseMovement.bridge ||
  ExerciseMovement.climber ||
  ExerciseMovement.kick => true,
  _ => false,
};

class _ExercisePainter extends CustomPainter {
  _ExercisePainter({
    required this.t,
    required this.color,
    required this.region,
    required this.movement,
  });
  final double t;
  final Color color;
  final BodyRegion region;
  final ExerciseMovement movement;

  bool _isHighlighted(BodyRegion part) =>
      region == part || region == BodyRegion.fullBody;

  Paint _paintFor(BodyRegion part) => Paint()
    ..color = (_isHighlighted(part) ? color : AppColors.glassBorder).withValues(
      alpha: _isHighlighted(part) ? 0.85 : 0.4,
    )
    ..style = PaintingStyle.fill;

  void _limb(
    Canvas canvas,
    Offset pivot,
    double angleRad,
    double length,
    double thickness,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angleRad);
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        -thickness / 2,
        length,
        thickness / 2,
        Radius.circular(thickness / 2),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final headPaint = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final torsoPaint = _paintFor(BodyRegion.abs);
    final armPaint = _paintFor(BodyRegion.arms);
    final legPaint = _paintFor(BodyRegion.legs);

    if (_isFloorMovement(movement)) {
      _paintFloor(canvas, size, headPaint, torsoPaint, armPaint, legPaint);
    } else {
      _paintStanding(canvas, size, headPaint, torsoPaint, armPaint, legPaint);
    }
  }

  // ---- Cac dang tap DUNG (squat, lunge, jump, raise, twist, ...) ----
  void _paintStanding(
    Canvas canvas,
    Size size,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final w = size.width;
    final h = size.height;

    double bob = 0;
    double armAngle = math.pi / 2; // huong xuong
    double legSplay = 0;
    double legShorten = 0;
    double torsoTilt = 0;
    double frontLegAngle = math.pi / 2;
    double backLegAngle = math.pi / 2;
    double frontLegLen = 1;
    double backLegLen = 1;
    final isLunge = movement == ExerciseMovement.lunge;

    switch (movement) {
      case ExerciseMovement.squat:
        bob = h * 0.10 * t;
        legSplay = 0.05 * t;
        legShorten = 0.30 * t;
        armAngle = math.pi / 2 - 0.5 * t; // tay dua ra truoc giu thang bang
        break;
      case ExerciseMovement.lunge:
        frontLegAngle = math.pi / 2 - 0.35;
        backLegAngle = math.pi / 2 + 0.45;
        frontLegLen = 1 - 0.15 * t;
        backLegLen = 1 - 0.30 * t;
        bob = h * 0.06 * t;
        armAngle = math.pi / 2 - 0.3 * t;
        break;
      case ExerciseMovement.jump:
        bob = -h * 0.12 * t; // bat len khoi mat dat
        legShorten = 0.20 * t;
        armAngle = math.pi / 2 - math.pi * t; // vung tay len qua dau
        break;
      case ExerciseMovement.raise:
        armAngle = math.pi / 2 - math.pi * t; // tu buong thong len qua dau
        bob = h * 0.01 * t;
        break;
      case ExerciseMovement.twist:
        torsoTilt = (t - 0.5) * 0.7;
        armAngle = math.pi / 2 - 0.25;
        break;
      default:
        bob = h * 0.03 * t;
        armAngle = math.pi / 2 - 0.15 * t;
    }

    // Dau
    canvas.drawCircle(Offset(w * 0.5, h * 0.09 + bob), w * 0.14, headPaint);

    // Than - xoay nhe khi twist
    canvas.save();
    final torsoCenter = Offset(w * 0.5, h * 0.375 + bob);
    canvas.translate(torsoCenter.dx, torsoCenter.dy);
    canvas.rotate(torsoTilt);
    canvas.translate(-torsoCenter.dx, -torsoCenter.dy);
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.32,
        h * 0.20 + bob,
        w * 0.68,
        h * 0.55 + bob,
        const Radius.circular(10),
      ),
      torsoPaint,
    );
    canvas.restore();

    // 2 tay - doi xung, huong xac dinh boi armAngle (0 = phai, pi/2 = xuong)
    final armLen = w * 0.20;
    _limb(
      canvas,
      Offset(w * 0.30, h * 0.24 + bob),
      armAngle,
      armLen,
      w * 0.09,
      armPaint,
    );
    _limb(
      canvas,
      Offset(w * 0.70, h * 0.24 + bob),
      math.pi - armAngle,
      armLen,
      w * 0.09,
      armPaint,
    );

    // 2 chan
    if (isLunge) {
      _limb(
        canvas,
        Offset(w * 0.44, h * 0.55),
        frontLegAngle,
        h * 0.40 * frontLegLen,
        w * 0.11,
        legPaint,
      );
      _limb(
        canvas,
        Offset(w * 0.56, h * 0.55),
        backLegAngle,
        h * 0.40 * backLegLen,
        w * 0.11,
        legPaint,
      );
    } else {
      final legLen = h * 0.40 * (1 - legShorten);
      _limb(
        canvas,
        Offset(w * 0.42 - w * legSplay, h * 0.55),
        math.pi / 2,
        legLen,
        w * 0.12,
        legPaint,
      );
      _limb(
        canvas,
        Offset(w * 0.58 + w * legSplay, h * 0.55),
        math.pi / 2,
        legLen,
        w * 0.12,
        legPaint,
      );
    }
  }

  // ---- Cac dang tap SAN (push-up, plank, crunch, bridge, climber, kick) ----
  void _paintFloor(
    Canvas canvas,
    Size size,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final w = size.width;
    final h = size.height;
    final ground = h * 0.82;

    switch (movement) {
      case ExerciseMovement.pushUp:
        _pushUpLike(
          canvas,
          w,
          h,
          ground,
          headPaint,
          torsoPaint,
          armPaint,
          legPaint,
          dip: t,
        );
        break;
      case ExerciseMovement.plank:
        _pushUpLike(
          canvas,
          w,
          h,
          ground,
          headPaint,
          torsoPaint,
          armPaint,
          legPaint,
          dip: 0.05 * t,
        );
        break;
      case ExerciseMovement.crunch:
        _crunch(
          canvas,
          w,
          h,
          ground,
          headPaint,
          torsoPaint,
          armPaint,
          legPaint,
        );
        break;
      case ExerciseMovement.bridge:
        _bridge(
          canvas,
          w,
          h,
          ground,
          headPaint,
          torsoPaint,
          armPaint,
          legPaint,
        );
        break;
      case ExerciseMovement.climber:
        _climber(
          canvas,
          w,
          h,
          ground,
          headPaint,
          torsoPaint,
          armPaint,
          legPaint,
        );
        break;
      case ExerciseMovement.kick:
        _kick(canvas, w, h, ground, headPaint, torsoPaint, armPaint, legPaint);
        break;
      default:
        break;
    }
  }

  /// Tu the chong day: than nguoi nam sap, do cao thay doi theo `dip`
  /// (0 = tay thang cao nhat, 1 = khuyu tay gap thap nhat).
  void _pushUpLike(
    Canvas canvas,
    double w,
    double h,
    double ground,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint, {
    required double dip,
  }) {
    final torsoY = ground - h * 0.22 - h * 0.10 * (1 - dip);
    final headX = w * 0.16;
    final hipX = w * 0.58;
    final footX = w * 0.92;

    // Chan - tu hong toi ban chan cham dat
    _limb(
      canvas,
      Offset(hipX, torsoY),
      math.atan2(ground - torsoY, footX - hipX),
      math
          .sqrt(math.pow(footX - hipX, 2) + math.pow(ground - torsoY, 2))
          .toDouble(),
      w * 0.10,
      legPaint,
    );
    // Tay - chong tu vai xuong san, goc doi theo dip (thang hon khi dip=0)
    final armAngle = math.pi / 2 - 0.35 * (1 - dip);
    _limb(
      canvas,
      Offset(headX + w * 0.06, torsoY),
      armAngle,
      ground - torsoY,
      w * 0.09,
      armPaint,
    );
    // Dau
    canvas.drawCircle(Offset(headX, torsoY), w * 0.12, headPaint);
    // Than
    canvas.drawRRect(
      RRect.fromLTRBR(
        headX + w * 0.02,
        torsoY - h * 0.07,
        hipX,
        torsoY + h * 0.07,
        const Radius.circular(10),
      ),
      torsoPaint,
    );
  }

  /// Gap bung: phan than tren + dau nghieng len ve phia goi theo t.
  void _crunch(
    Canvas canvas,
    double w,
    double h,
    double ground,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final hip = Offset(w * 0.55, ground - h * 0.06);
    final kneeUp = Offset(w * 0.78, ground - h * 0.20);
    final footDown = Offset(w * 0.95, ground - h * 0.02);
    // Chan gap goi co dinh (mo phong ngoi gap goi)
    _limb(canvas, hip, -0.55, w * 0.30, w * 0.11, legPaint);
    _limb(canvas, kneeUp, 0.75, w * 0.22, w * 0.10, legPaint);
    canvas.drawCircle(footDown, w * 0.02, legPaint);

    // Than tren nghieng len theo t (0 = nam san, 1 = ngoi day 1 phan)
    final liftAngle = -math.pi / 2 + (1 - 0.55 * t) * (math.pi / 2 - 0.35);
    final shoulder = hip.translate(-w * 0.02, 0);
    _limb(
      canvas,
      shoulder,
      math.pi - (0.35 * t + 0.05),
      w * 0.30,
      w * 0.16,
      torsoPaint,
    );
    final headOffset = Offset.fromDirection(
      math.pi - (0.35 * t + 0.05),
      w * 0.34,
    );
    canvas.drawCircle(shoulder + headOffset, w * 0.11, headPaint);
    // Tay dat nhe truoc nguc
    _limb(
      canvas,
      shoulder + headOffset * 0.55,
      liftAngle,
      w * 0.14,
      w * 0.07,
      armPaint,
    );
  }

  /// Cau hong: vai co dinh sat dat, hong nang len ha xuong theo t.
  void _bridge(
    Canvas canvas,
    double w,
    double h,
    double ground,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final shoulder = Offset(w * 0.18, ground - h * 0.02);
    final hipLift = h * 0.16 * t;
    final hip = Offset(w * 0.50, ground - h * 0.02 - hipLift);
    final knee = Offset(w * 0.72, ground - h * 0.16);
    final foot = Offset(w * 0.82, ground);

    canvas.drawCircle(shoulder + const Offset(-6, 0), w * 0.11, headPaint);
    // Than tu vai den hong (nang len ha xuong)
    final angle = math.atan2(hip.dy - shoulder.dy, hip.dx - shoulder.dx);
    final len = (hip - shoulder).distance;
    _limb(canvas, shoulder, angle, len, w * 0.16, torsoPaint);
    // Dui tu hong den goi, cang tu goi xuong ban chan (co dinh cham dat)
    final thighAngle = math.atan2(knee.dy - hip.dy, knee.dx - hip.dx);
    _limb(canvas, hip, thighAngle, (knee - hip).distance, w * 0.12, legPaint);
    final shinAngle = math.atan2(foot.dy - knee.dy, foot.dx - knee.dx);
    _limb(canvas, knee, shinAngle, (foot - knee).distance, w * 0.11, legPaint);
    // Tay ap sat san lam diem tua
    _limb(
      canvas,
      shoulder,
      math.pi / 2 - 0.1,
      h * 0.02 + 6,
      w * 0.08,
      armPaint,
    );
  }

  /// Leo nui: tu the plank cao, 1 chan luan phien keo len sat nguc.
  void _climber(
    Canvas canvas,
    double w,
    double h,
    double ground,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final torsoY = ground - h * 0.30;
    final headX = w * 0.16;
    final hipX = w * 0.58;

    canvas.drawCircle(Offset(headX, torsoY), w * 0.12, headPaint);
    canvas.drawRRect(
      RRect.fromLTRBR(
        headX + w * 0.02,
        torsoY - h * 0.07,
        hipX,
        torsoY + h * 0.07,
        const Radius.circular(10),
      ),
      torsoPaint,
    );
    // Tay chong thang
    _limb(
      canvas,
      Offset(headX + w * 0.06, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.09,
      armPaint,
    );

    // Chan 1: keo goi vao sat nguc (theo t), chan 2: duoi thang ve sau
    final tuckKnee = Offset(hipX + w * 0.10 - w * 0.20 * t, torsoY + h * 0.02);
    _limb(
      canvas,
      Offset(hipX, torsoY),
      math.atan2(tuckKnee.dy - torsoY, tuckKnee.dx - hipX),
      (tuckKnee - Offset(hipX, torsoY)).distance,
      w * 0.10,
      legPaint,
    );
    final extFoot = Offset(w * 0.94, ground);
    _limb(
      canvas,
      Offset(hipX, torsoY),
      math.atan2(extFoot.dy - torsoY, extFoot.dx - hipX),
      (extFoot - Offset(hipX, torsoY)).distance,
      w * 0.10,
      legPaint,
    );
  }

  /// Da chan ra sau: tu the boi 4 diem tua, 1 chan da thang len phia sau.
  void _kick(
    Canvas canvas,
    double w,
    double h,
    double ground,
    Paint headPaint,
    Paint torsoPaint,
    Paint armPaint,
    Paint legPaint,
  ) {
    final torsoY = ground - h * 0.20;
    final headX = w * 0.18;
    final hipX = w * 0.55;

    canvas.drawCircle(Offset(headX, torsoY), w * 0.11, headPaint);
    canvas.drawRRect(
      RRect.fromLTRBR(
        headX + w * 0.02,
        torsoY - h * 0.06,
        hipX,
        torsoY + h * 0.06,
        const Radius.circular(9),
      ),
      torsoPaint,
    );
    // Tay + chan tua (co dinh)
    _limb(
      canvas,
      Offset(headX + w * 0.05, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.08,
      armPaint,
    );
    _limb(
      canvas,
      Offset(hipX - w * 0.05, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.09,
      legPaint,
    );

    // Chan da: tu hong da len ra sau-tren theo t
    final kickAngle = -0.15 - 0.9 * t; // cang len cao khi t tang
    _limb(
      canvas,
      Offset(hipX, torsoY),
      kickAngle,
      w * 0.34,
      w * 0.10,
      legPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ExercisePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.region != region ||
      oldDelegate.movement != movement;
}
