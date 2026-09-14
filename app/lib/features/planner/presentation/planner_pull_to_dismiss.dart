import 'package:flutter/material.dart';

/// Vuot xuong de dong bottom sheet KHI noi dung ben trong co vung cuon.
///
/// showModalBottomSheet chi tu dong theo cu keo o phan KHONG cuon duoc - khi
/// ca noi dung nam trong SingleChildScrollView/ListView (form Them viec, cai
/// dat chuong...), cu vuot xuong bi vung cuon "nuot" mat nen sheet khong
/// dong duoc. Widget nay nghe OverscrollNotification: dang o DAU noi dung ma
/// van keo xuong them > [threshold] px thi dong sheet.
///
/// Vung cuon ben trong PHAI dung [ClampingScrollPhysics] - voi hieu ung nay
/// bat kieu iOS (mac dinh tren web iPhone) Flutter khong phat
/// OverscrollNotification ma chi nay noi dung len.
class PlannerPullToDismiss extends StatefulWidget {
  const PlannerPullToDismiss({
    super.key,
    required this.child,
    this.threshold = 56,
  });

  final Widget child;
  final double threshold;

  @override
  State<PlannerPullToDismiss> createState() => _PlannerPullToDismissState();
}

class _PlannerPullToDismissState extends State<PlannerPullToDismiss> {
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
