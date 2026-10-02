import 'package:flutter/material.dart';

import '../../../core/theme/gt_haptics.dart';
import '../../../core/theme/gt_motion.dart';
import '../../../core/theme/gt_tokens.dart';

/// O tick hiep 44dp (README §9): cham -> bao [onTap]; hiep duoc ghi that
/// (onTap tra true) thi o to do ngay, nay bang lo xo expressive va rung nhe
/// (spec #96). Bi bo qua (vd cham dup trong 700 ms) thi khong doi gi.
///
/// O "da tick" giu trong state: khi hiep do mo man nghi, bang hiep cu mo
/// dan ra van thay dung o vua tick.
class GtSetTick extends StatefulWidget {
  const GtSetTick({
    super.key,
    required this.done,
    required this.active,
    required this.onTap,
    required this.label,
  });

  final bool done;
  final bool active;

  /// Ghi hiep; true = da ghi that.
  final bool Function() onTap;
  final String label;

  @override
  State<GtSetTick> createState() => _GtSetTickState();
}

class _GtSetTickState extends State<GtSetTick>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    value: 1,
  );

  static final _spring = GtSpringCurve(
    gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.fast),
    springSettleMs(gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.fast)),
  );

  /// Vua cham, controller chua kip ghi hiep.
  bool _ticked = false;

  @override
  void didUpdateWidget(GtSetTick old) {
    super.didUpdateWidget(old);
    // Sang hiep khac / hiep da ghi xong: bo trang thai tam.
    if (widget.done || old.active != widget.active) _ticked = false;
  }

  void _tap() {
    if (!widget.active || widget.done || _ticked) return;
    if (!widget.onTap()) return;
    setState(() => _ticked = true);
    GtHaptics.play(GtHapticEvent.setTicked);
    final duration = gtMotion(
      context,
      GtMotionKind.expressive,
      GtMotionSpeed.fast,
    ).duration;
    if (duration != Duration.zero) {
      _pop
        ..duration = duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final done = widget.done || _ticked;
    final active = widget.active && !done;
    return Semantics(
      button: active,
      checked: done,
      label: widget.label,
      child: GestureDetector(
        onTap: active ? _tap : null,
        child: AnimatedBuilder(
          animation: _pop,
          builder: (context, child) => Transform.scale(
            scale: 0.8 + 0.2 * _spring.transform(_pop.value),
            child: child,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? t.red : (active ? t.s2 : null),
              borderRadius: BorderRadius.circular(14),
              border: done
                  ? null
                  : Border.all(color: active ? t.red : t.bd, width: 2),
            ),
            child: Icon(
              Icons.check_rounded,
              color: done ? t.onRed : (active ? t.red : t.tx3),
            ),
          ),
        ),
      ),
    );
  }
}
