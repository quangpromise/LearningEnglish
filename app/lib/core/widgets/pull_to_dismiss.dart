import 'package:flutter/material.dart';

/// Vuot xuong de dong bottom sheet KHI noi dung ben trong co vung cuon.
///
/// showModalBottomSheet chi tu dong theo cu keo o phan KHONG cuon duoc - khi
/// ca noi dung nam trong SingleChildScrollView/ListView (form Them viec, cai
/// dat chuong, man To do list...), cu vuot xuong bi vung cuon "nuot" mat nen
/// sheet khong dong duoc. Widget nay nghe OverscrollNotification: dang o DAU
/// noi dung ma van keo xuong them > [threshold] px thi dong sheet.
///
/// Vung cuon ben trong PHAI dung [ClampingScrollPhysics] - voi hieu ung nay
/// bat kieu iOS (mac dinh tren web iPhone) Flutter khong phat
/// OverscrollNotification ma chi nay noi dung len.
///
/// TRUOC DAY nam trong features/planner (PlannerPullToDismiss) - chuyen ra
/// core/widgets vi day la tien ich giao dien chung, khong rieng gi Planner;
/// de o feature cu thi feature khac muon dung phai import cheo sang Planner.
class PullToDismiss extends StatefulWidget {
  const PullToDismiss({super.key, required this.child, this.threshold = 56});

  final Widget child;
  final double threshold;

  @override
  State<PullToDismiss> createState() => _PullToDismissState();
}

class _PullToDismissState extends State<PullToDismiss> {
  double _pulled = 0;
  bool _closing = false;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is OverscrollNotification &&
        n.dragDetails != null &&
        n.overscroll < 0 &&
        n.metrics.pixels <= n.metrics.minScrollExtent) {
      _pulled -= n.overscroll;
      if (_pulled > widget.threshold && !_closing) {
        _closing = true;
        Navigator.of(context).maybePop();
      }
    } else if (n is ScrollEndNotification ||
        (n is ScrollUpdateNotification && n.metrics.pixels > 0)) {
      _pulled = 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: widget.child,
    );
  }
}
