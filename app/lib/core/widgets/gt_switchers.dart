import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// Xep cac con dang chuyen canh theo [alignment] (mac dinh goc tren-dau:
/// noi dung nam trong vung cuon, chu canh trai). Con dang ra khong nhan
/// cham va khong vao cay semantics; moi con boc cung 1 kieu, giu key cua
/// no, de element (va state) khong bi dung lai khi chuyen tu "hien tai"
/// sang "dang ra".
AnimatedSwitcherLayoutBuilder _layout(AlignmentGeometry alignment) =>
    (current, previous) => Stack(
      alignment: alignment,
      children: [
        for (final child in previous) _guard(child, leaving: true),
        if (current != null) _guard(current, leaving: false),
      ],
    );

Widget _guard(Widget child, {required bool leaving}) => IgnorePointer(
  key: child.key,
  ignoring: leaving,
  child: ExcludeSemantics(excluding: leaving, child: child),
);

/// Kieu "fade through" (M3): noi dung cu GIU NGUYEN nua dau thoi gian (vd o
/// tick vua nay kip hien) roi moi ra, noi dung moi vao o nua sau.
({Curve enter, Curve leave, Duration duration}) _fadeThrough(
  BuildContext context,
) {
  final motion = gtMotion(context, GtMotionKind.standard, GtMotionSpeed.slow);
  return (
    duration: motion.duration,
    // Con dang ra chay nguoc 1 -> 0: Interval(0, .5) = giu o 1 trong nua
    // dau (t tu 1 xuong .5), roi ra NHANH (easeIn chay nguoc = doc dung
    // ngay dau) de khong chong len con dang vao (lo xo, cham dan).
    leave: const Interval(0, 0.5, curve: Curves.easeInCubic),
    enter: Interval(0.5, 1, curve: motion.curve),
  );
}

Widget _fadeScale(Widget child, Animation<double> animation) => FadeTransition(
  opacity: animation,
  child: ScaleTransition(
    alignment: Alignment.topCenter,
    scale: Tween(begin: 0.96, end: 1.0).animate(animation),
    child: child,
  ),
);

/// Doi giua 2 noi dung (vd bang hiep <-> man nghi) bang mo + thu phong nhe
/// kieu fade through (spec #96). [switchKey] doi thi chuyen. Giam chuyen
/// dong: doi tuc thi.
class GtFadeScaleSwitcher extends StatelessWidget {
  const GtFadeScaleSwitcher({
    super.key,
    required this.switchKey,
    required this.child,
  });

  final Object switchKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = _fadeThrough(context);
    return AnimatedSwitcher(
      duration: fade.duration,
      switchInCurve: fade.enter,
      switchOutCurve: fade.leave,
      layoutBuilder: _layout(AlignmentDirectional.topStart),
      transitionBuilder: _fadeScale,
      child: KeyedSubtree(key: ValueKey(switchKey), child: child),
    );
  }
}

/// Truc chung ngang (shared axis, spec #96): [position] tang -> noi dung cu
/// truot sang trai, noi dung moi tu ben phai vao; giam -> nguoc lai. Kem mo,
/// kieu fade through. [alignment]: canh cac con khac chieu cao luc chuyen
/// (vd ten bai o day header -> bottomStart). Giam chuyen dong: doi tuc thi.
class GtSharedAxisSwitcher extends StatefulWidget {
  const GtSharedAxisSwitcher({
    super.key,
    required this.position,
    required this.child,
    this.alignment = AlignmentDirectional.topStart,
  });

  final int position;
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  State<GtSharedAxisSwitcher> createState() => _GtSharedAxisSwitcherState();
}

class _GtSharedAxisSwitcherState extends State<GtSharedAxisSwitcher> {
  /// 1 = di toi (sang phai), -1 = lui lai.
  var _direction = 1;

  @override
  void didUpdateWidget(GtSharedAxisSwitcher old) {
    super.didUpdateWidget(old);
    if (old.position != widget.position) {
      _direction = widget.position > old.position ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fade = _fadeThrough(context);
    final current = ValueKey(widget.position);
    return AnimatedSwitcher(
      duration: fade.duration,
      switchInCurve: fade.enter,
      switchOutCurve: fade.leave,
      layoutBuilder: _layout(widget.alignment),
      transitionBuilder: (child, animation) {
        // Con dang vao: tu phia truoc toi; con dang ra (hoat anh chay
        // nguoc 1 -> 0): lui ve phia sau.
        final entering = child.key == current;
        final dx = (entering ? 0.12 : -0.12) * _direction;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: Offset(dx, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: current, child: widget.child),
    );
  }
}
