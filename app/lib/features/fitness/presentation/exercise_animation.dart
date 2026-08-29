import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/fitness_data.dart';
import 'body_diagram.dart';

/// Hinh nguoi don gian TU VE, chuyen dong LIEN TUC theo dung dang tac cua
/// bai tap (squat gap goi, plank giu yen, push-up day tay, crunch gap
/// bung...) thay vi 1 kieu nhun chung chung cho moi bai. Vung co dang tap
/// (region) van duoc to do nhu truoc. Cac chi (tay/chan) duoc ve dang vien
/// thuoc (capsule) tron deu voi 1 vet sang mo o canh tren de tao cam giac
/// hinh khoi tron, dau co gradient nhe nhu qua cau bong - van la hinh minh
/// hoa GOC, khong sao chep hinh anh/video tu bat ky app hay nguon nao khac.
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

  Color _colorFor(BodyRegion part) =>
      (_isHighlighted(part) ? color : AppColors.glassBorder);

  double _alphaFor(BodyRegion part) => _isHighlighted(part) ? 0.88 : 0.42;

  /// Ve 1 "khuc chi" (tay/chan) dang vien thuoc (capsule) - 2 dau tron deu,
  /// them 1 vet sang mo o canh tren + 1 khop tron o goc pivot de noi lien
  /// mach voi than nguoi, tao cam giac hinh khoi tron thay vi thanh dep.
  void _limb(
    Canvas canvas,
    Offset pivot,
    double angleRad,
    double length,
    double thickness,
    Color base,
    double alpha,
  ) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angleRad);
    final r = thickness / 2;
    final body = RRect.fromLTRBR(0, -r, length, r, Radius.circular(r));
    canvas.drawRRect(
      body,
      Paint()
        ..color = base.withValues(alpha: alpha)
        ..style = PaintingStyle.fill,
    );
    // Vet sang mo doc theo canh tren de goi y hinh tru tron.
    final highlight = RRect.fromLTRBR(
      length * 0.08,
      -r * 0.62,
      length * 0.92,
      -r * 0.12,
      Radius.circular(r * 0.4),
    );
    canvas.drawRRect(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
    // Khop tron o pivot de noi mach voi than/chi khac.
    canvas.drawCircle(
      pivot,
      r * 0.92,
      Paint()
        ..color = base.withValues(alpha: alpha)
        ..style = PaintingStyle.fill,
    );
  }

  void _head(Canvas canvas, Offset center, double radius) {
    final shader = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.9,
      colors: [
        Colors.white.withValues(alpha: 0.30),
        AppColors.glassBorder.withValues(alpha: 0.42),
        AppColors.glassBorder.withValues(alpha: 0.48),
      ],
      stops: const [0, 0.55, 1],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, Paint()..shader = shader);
  }

  void _groundShadow(Canvas canvas, Offset center, double width) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: width * 0.22),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
  }

  void _torso(Canvas canvas, Rect rect, Color base, double alpha) {
    // Than hoi thop eo o giua (waist taper) thay vi hinh chu nhat deu.
    final path = Path()
      ..moveTo(rect.left, rect.top + rect.height * 0.12)
      ..quadraticBezierTo(
        rect.left - rect.width * 0.03,
        rect.top + rect.height * 0.5,
        rect.left + rect.width * 0.08,
        rect.bottom - rect.height * 0.1,
      )
      ..quadraticBezierTo(
        rect.left + rect.width * 0.5,
        rect.bottom + rect.height * 0.06,
        rect.right - rect.width * 0.08,
        rect.bottom - rect.height * 0.1,
      )
      ..quadraticBezierTo(
        rect.right + rect.width * 0.03,
        rect.top + rect.height * 0.5,
        rect.right,
        rect.top + rect.height * 0.12,
      )
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top - rect.height * 0.1,
        rect.left,
        rect.top + rect.height * 0.12,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = base.withValues(alpha: alpha)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_isFloorMovement(movement)) {
      _paintFloor(canvas, size);
    } else {
      _paintStanding(canvas, size);
    }
  }

  // ---- Cac dang tap DUNG (squat, lunge, jump, raise, twist, ...) ----
  void _paintStanding(Canvas canvas, Size size) {
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
        armAngle = math.pi / 2 - 0.5 * t;
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
        bob = -h * 0.12 * t;
        legShorten = 0.20 * t;
        armAngle = math.pi / 2 - math.pi * t;
        break;
      case ExerciseMovement.raise:
        armAngle = math.pi / 2 - math.pi * t;
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

    _groundShadow(canvas, Offset(w * 0.5, h * 0.97), w * 0.5);

    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);

    // Than - xoay nhe khi twist (ve truoc de chi de len tren nhu khop vai/hong)
    canvas.save();
    final torsoCenter = Offset(w * 0.5, h * 0.375 + bob);
    canvas.translate(torsoCenter.dx, torsoCenter.dy);
    canvas.rotate(torsoTilt);
    canvas.translate(-torsoCenter.dx, -torsoCenter.dy);
    _torso(
      canvas,
      Rect.fromLTRB(w * 0.33, h * 0.20 + bob, w * 0.67, h * 0.55 + bob),
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    canvas.restore();

    // 2 chan
    if (isLunge) {
      _limb(
        canvas,
        Offset(w * 0.44, h * 0.55),
        frontLegAngle,
        h * 0.40 * frontLegLen,
        w * 0.115,
        legColor,
        legAlpha,
      );
      _limb(
        canvas,
        Offset(w * 0.56, h * 0.55),
        backLegAngle,
        h * 0.40 * backLegLen,
        w * 0.115,
        legColor,
        legAlpha,
      );
    } else {
      final legLen = h * 0.40 * (1 - legShorten);
      _limb(
        canvas,
        Offset(w * 0.42 - w * legSplay, h * 0.55),
        math.pi / 2,
        legLen,
        w * 0.125,
        legColor,
        legAlpha,
      );
      _limb(
        canvas,
        Offset(w * 0.58 + w * legSplay, h * 0.55),
        math.pi / 2,
        legLen,
        w * 0.125,
        legColor,
        legAlpha,
      );
    }

    // 2 tay
    final armLen = w * 0.20;
    _limb(
      canvas,
      Offset(w * 0.30, h * 0.24 + bob),
      armAngle,
      armLen,
      w * 0.095,
      armColor,
      armAlpha,
    );
    _limb(
      canvas,
      Offset(w * 0.70, h * 0.24 + bob),
      math.pi - armAngle,
      armLen,
      w * 0.095,
      armColor,
      armAlpha,
    );

    // Dau
    _head(canvas, Offset(w * 0.5, h * 0.09 + bob), w * 0.145);
  }

  // ---- Cac dang tap SAN (push-up, plank, crunch, bridge, climber, kick) ----
  void _paintFloor(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = h * 0.82;

    _groundShadow(canvas, Offset(w * 0.55, ground + 6), w * 0.85);

    switch (movement) {
      case ExerciseMovement.pushUp:
        _pushUpLike(canvas, w, h, ground, dip: t);
        break;
      case ExerciseMovement.plank:
        _pushUpLike(canvas, w, h, ground, dip: 0.05 * t);
        break;
      case ExerciseMovement.crunch:
        _crunch(canvas, w, h, ground);
        break;
      case ExerciseMovement.bridge:
        _bridge(canvas, w, h, ground);
        break;
      case ExerciseMovement.climber:
        _climber(canvas, w, h, ground);
        break;
      case ExerciseMovement.kick:
        _kick(canvas, w, h, ground);
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
    double ground, {
    required double dip,
  }) {
    final torsoY = ground - h * 0.22 - h * 0.10 * (1 - dip);
    final headX = w * 0.16;
    final hipX = w * 0.58;
    final footX = w * 0.92;
    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);

    final legDx = footX - hipX;
    final legDy = ground - torsoY;
    _limb(
      canvas,
      Offset(hipX, torsoY),
      math.atan2(legDy, legDx),
      math.sqrt(legDx * legDx + legDy * legDy),
      w * 0.105,
      legColor,
      legAlpha,
    );
    final armAngle = math.pi / 2 - 0.35 * (1 - dip);
    _limb(
      canvas,
      Offset(headX + w * 0.06, torsoY),
      armAngle,
      ground - torsoY,
      w * 0.095,
      armColor,
      armAlpha,
    );
    _torso(
      canvas,
      Rect.fromLTRB(
        headX + w * 0.02,
        torsoY - h * 0.07,
        hipX,
        torsoY + h * 0.07,
      ),
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    _head(canvas, Offset(headX, torsoY), w * 0.125);
  }

  /// Gap bung: phan than tren + dau nghieng len ve phia goi theo t.
  void _crunch(Canvas canvas, double w, double h, double ground) {
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);
    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);

    final hip = Offset(w * 0.55, ground - h * 0.06);
    final kneeUp = Offset(w * 0.78, ground - h * 0.20);
    _limb(canvas, hip, -0.55, w * 0.30, w * 0.115, legColor, legAlpha);
    _limb(canvas, kneeUp, 0.75, w * 0.22, w * 0.105, legColor, legAlpha);

    final liftAngle = -math.pi / 2 + (1 - 0.55 * t) * (math.pi / 2 - 0.35);
    final shoulder = hip.translate(-w * 0.02, 0);
    final torsoAngle = math.pi - (0.35 * t + 0.05);
    _limb(
      canvas,
      shoulder,
      torsoAngle,
      w * 0.30,
      w * 0.20,
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    final headOffset = Offset.fromDirection(torsoAngle, w * 0.34);
    _head(canvas, shoulder + headOffset, w * 0.115);
    _limb(
      canvas,
      shoulder + headOffset * 0.55,
      liftAngle,
      w * 0.14,
      w * 0.075,
      armColor,
      armAlpha,
    );
  }

  /// Cau hong: vai co dinh sat dat, hong nang len ha xuong theo t.
  void _bridge(Canvas canvas, double w, double h, double ground) {
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);
    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);

    final shoulder = Offset(w * 0.18, ground - h * 0.02);
    final hipLift = h * 0.16 * t;
    final hip = Offset(w * 0.50, ground - h * 0.02 - hipLift);
    final knee = Offset(w * 0.72, ground - h * 0.16);
    final foot = Offset(w * 0.82, ground);

    _head(canvas, shoulder + const Offset(-6, 0), w * 0.115);
    final angle = math.atan2(hip.dy - shoulder.dy, hip.dx - shoulder.dx);
    final len = (hip - shoulder).distance;
    _limb(
      canvas,
      shoulder,
      angle,
      len,
      w * 0.20,
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    final thighAngle = math.atan2(knee.dy - hip.dy, knee.dx - hip.dx);
    _limb(
      canvas,
      hip,
      thighAngle,
      (knee - hip).distance,
      w * 0.12,
      legColor,
      legAlpha,
    );
    final shinAngle = math.atan2(foot.dy - knee.dy, foot.dx - knee.dx);
    _limb(
      canvas,
      knee,
      shinAngle,
      (foot - knee).distance,
      w * 0.11,
      legColor,
      legAlpha,
    );
    _limb(
      canvas,
      shoulder,
      math.pi / 2 - 0.1,
      h * 0.02 + 6,
      w * 0.08,
      armColor,
      armAlpha,
    );
  }

  /// Leo nui: tu the plank cao, 1 chan luan phien keo len sat nguc.
  void _climber(Canvas canvas, double w, double h, double ground) {
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);
    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);

    final torsoY = ground - h * 0.30;
    final headX = w * 0.16;
    final hipX = w * 0.58;

    _torso(
      canvas,
      Rect.fromLTRB(
        headX + w * 0.02,
        torsoY - h * 0.07,
        hipX,
        torsoY + h * 0.07,
      ),
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    _head(canvas, Offset(headX, torsoY), w * 0.125);
    _limb(
      canvas,
      Offset(headX + w * 0.06, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.095,
      armColor,
      armAlpha,
    );

    final hipPt = Offset(hipX, torsoY);
    final tuckKnee = Offset(hipX + w * 0.10 - w * 0.20 * t, torsoY + h * 0.02);
    _limb(
      canvas,
      hipPt,
      math.atan2(tuckKnee.dy - torsoY, tuckKnee.dx - hipX),
      (tuckKnee - hipPt).distance,
      w * 0.105,
      legColor,
      legAlpha,
    );
    final extFoot = Offset(w * 0.94, ground);
    _limb(
      canvas,
      hipPt,
      math.atan2(extFoot.dy - torsoY, extFoot.dx - hipX),
      (extFoot - hipPt).distance,
      w * 0.105,
      legColor,
      legAlpha,
    );
  }

  /// Da chan ra sau: tu the boi 4 diem tua, 1 chan da thang len phia sau.
  void _kick(Canvas canvas, double w, double h, double ground) {
    final legColor = _colorFor(BodyRegion.legs);
    final legAlpha = _alphaFor(BodyRegion.legs);
    final armColor = _colorFor(BodyRegion.arms);
    final armAlpha = _alphaFor(BodyRegion.arms);

    final torsoY = ground - h * 0.20;
    final headX = w * 0.18;
    final hipX = w * 0.55;

    _torso(
      canvas,
      Rect.fromLTRB(
        headX + w * 0.02,
        torsoY - h * 0.06,
        hipX,
        torsoY + h * 0.06,
      ),
      _colorFor(BodyRegion.abs),
      _alphaFor(BodyRegion.abs),
    );
    _head(canvas, Offset(headX, torsoY), w * 0.105);
    _limb(
      canvas,
      Offset(headX + w * 0.05, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.085,
      armColor,
      armAlpha,
    );
    _limb(
      canvas,
      Offset(hipX - w * 0.05, torsoY),
      math.pi / 2,
      ground - torsoY,
      w * 0.095,
      legColor,
      legAlpha,
    );

    final kickAngle = -0.15 - 0.9 * t;
    _limb(
      canvas,
      Offset(hipX, torsoY),
      kickAngle,
      w * 0.34,
      w * 0.10,
      legColor,
      legAlpha,
    );
  }

  @override
  bool shouldRepaint(covariant _ExercisePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.region != region ||
      oldDelegate.movement != movement;
}
