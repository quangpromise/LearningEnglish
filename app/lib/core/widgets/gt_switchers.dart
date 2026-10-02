import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// Xep cac con dang chuyen canh tu goc tren-dau (khong can giua nhu mac
/// dinh cua AnimatedSwitcher): noi dung nam trong vung cuon, chu canh trai.
Widget _topLayout(Widget? current, List<Widget> previous) => Stack(
  alignment: AlignmentDirectional.topStart,
  children: [...previous, ?current],
);

/// Doi giua 2 noi dung (vd bang hiep <-> man nghi) bang mo cheo + thu phong
/// nhe (spec #96). [switchKey] doi thi chuyen. Giam chuyen dong: doi tuc thi.
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
    final duration = gtMotion(context, GtMotionKind.standard).duration;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: _topLayout,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(switchKey), child: child),
    );
  }
}

/// Truc chung ngang (shared axis, spec #96): [position] tang -> noi dung cu
/// truot sang trai, noi dung moi tu ben phai vao; giam -> nguoc lai. Kem mo.
/// Giam chuyen dong: doi tuc thi.
class GtSharedAxisSwitcher extends StatefulWidget {
  const GtSharedAxisSwitcher({
    super.key,
    required this.position,
    required this.child,
  });

  final int position;
  final Widget child;

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
    final duration = gtMotion(context, GtMotionKind.standard).duration;
    final current = ValueKey(widget.position);
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: _topLayout,
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
