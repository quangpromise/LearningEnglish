import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// So "dem len" tu gia tri cu toi gia tri moi (spec #96, quyet dinh #9).
/// Lan dau chay tu [from]; doi [value] thi chay tu so dang hien toi so
/// moi. Giam chuyen dong: hien ngay gia tri cuoi.
///
/// Dung lo xo standard (gan nhu khong vuot) - so vuot qua roi lui lai (vd
/// "+33 XP" -> "+30 XP") de gay hieu nham.
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
    if (motion.duration == Duration.zero) {
      return Text(_text(value), style: style, textAlign: textAlign);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from.toDouble(), end: value.toDouble()),
      duration: motion.duration,
      curve: motion.curve,
      builder: (context, v, _) =>
          Text(_text(v.round()), style: style, textAlign: textAlign),
    );
  }
}
