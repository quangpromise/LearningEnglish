import 'package:flutter/widgets.dart';

import '../theme/gt_motion.dart';

/// Nhu IndexedStack - moi tab giu nguyen trang thai (vi tri cuon...) - nhung
/// doi tab bang mo cheo ngan (~150 ms, effects nhanh; spec #96). Giam chuyen
/// dong: doi tuc thi.
///
/// Tab khuat: khong ve (do mo 0), khong nhan cham, khong nhan focus, va
/// hoat anh ben trong tam dung (TickerMode).
class GtFadeIndexedStack extends StatelessWidget {
  const GtFadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final fade = gtMotion(context, GtMotionKind.effects, GtMotionSpeed.fast);
    final duration = gtReduceMotion(context) ? Duration.zero : fade.duration;
    return Stack(
      children: [
        for (final (i, child) in children.indexed)
          IgnorePointer(
            ignoring: i != index,
            child: ExcludeFocus(
              excluding: i != index,
              child: AnimatedOpacity(
                opacity: i == index ? 1 : 0,
                duration: duration,
                curve: fade.curve,
                // Trong AnimatedOpacity: tab cu van mo dan ra duoc trong luc
                // hoat anh ben trong no da dung.
                child: TickerMode(enabled: i == index, child: child),
              ),
            ),
          ),
      ],
    );
  }
}
