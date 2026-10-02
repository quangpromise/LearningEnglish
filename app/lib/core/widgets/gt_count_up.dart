import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// So "dem len" tu gia tri cu toi gia tri moi (spec #96, quyet dinh #9).
/// Lan dau chay tu [from]; doi [value] thi chay tu so dang hien toi so
/// moi. Giam chuyen dong: hien ngay gia tri cuoi.
///
/// Dung lo xo standard va cat phan vuot dich: so khong bao gio vuot qua roi
/// lui lai (vd "501" -> "500") gay hieu nham. Trinh doc man hinh luon doc
/// gia tri cuoi, khong doc tung so trung gian.
class GtCountUp extends StatelessWidget {
  const GtCountUp({
    super.key,
    required this.value,
    required this.style,
    this.from = 0,
    this.format,
    this.textAlign,
  });

  final int value;
  final int from;
  final TextStyle style;
  final String Function(int value)? format;
  final TextAlign? textAlign;

  String _text(int v) => format?.call(v) ?? '$v';

  @override
  Widget build(BuildContext context) {
    final motion = gtMotion(context, GtMotionKind.standard, GtMotionSpeed.slow);
    return Semantics(
      container: true,
      label: _text(value),
      child: ExcludeSemantics(
        // Giam chuyen dong -> thoi luong 0: hien ngay so cuoi (van giu 1
        // cay widget, bat/tat co giua chung khong dem lai tu dau).
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: from.toDouble(), end: value.toDouble()),
          duration: motion.duration,
          curve: _NoOvershoot(motion.curve),
          builder: (context, v, _) =>
              Text(_text(v.round()), style: style, textAlign: textAlign),
        ),
      ),
    );
  }
}

/// Cat phan vuot dich (> 1) cua duong cong lo xo.
class _NoOvershoot extends Curve {
  const _NoOvershoot(this.curve);

  final Curve curve;

  @override
  double transformInternal(double t) => math.min(1.0, curve.transform(t));

  @override
  bool operator ==(Object other) =>
      other is _NoOvershoot && other.curve == curve;

  @override
  int get hashCode => curve.hashCode;
}
