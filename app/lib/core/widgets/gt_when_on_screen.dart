import 'dart:async';

import 'package:flutter/widgets.dart';

/// Cho popup dong xong truoc khi cap nhat (bottom sheet M3 truot xuong trong
/// 200 ms).
const kGtOnScreenSettle = Duration(milliseconds: 240);

/// Giu nguyen [value] dang hien trong luc khu vuc bi che (popup / dialog /
/// tab khac) va chi cap nhat lai [settle] sau khi khu vuc hien lai - de hieu
/// ung "vua xong" (vong cham 100%, nhiem vu xong...) chay luc nguoi dung
/// nhin thay, thay vi chay khuat duoi popup noi viec do vua xay ra. Dang
/// hien thi cap nhat ngay.
///
/// [builder] nhan them `visit`: tang 1 moi lan khu vuc hien lai (ca lan dau),
/// cung luc voi lan cap nhat do - cho hieu ung "moi lan quay lai".
class GtWhenOnScreen<T> extends StatefulWidget {
  const GtWhenOnScreen({
    super.key,
    required this.value,
    required this.onScreen,
    required this.builder,
    this.settle = kGtOnScreenSettle,
  });

  final T value;
  final bool onScreen;
  final Duration settle;
  final Widget Function(BuildContext context, T value, int visit) builder;

  @override
  State<GtWhenOnScreen<T>> createState() => _GtWhenOnScreenState<T>();
}

class _GtWhenOnScreenState<T> extends State<GtWhenOnScreen<T>> {
  late T _shown = widget.value;
  var _visit = 0;
  Timer? _arriving;

  @override
  void initState() {
    super.initState();
    if (widget.onScreen) _arrive();
  }

  @override
  void didUpdateWidget(GtWhenOnScreen<T> old) {
    super.didUpdateWidget(old);
    if (!widget.onScreen) {
      // Bi che lai truoc khi kip "den": bo lan den do.
      _arriving?.cancel();
      _arriving = null;
    } else if (!old.onScreen) {
      _arrive();
    } else if (_arriving == null) {
      _shown = widget.value;
    }
  }

  void _arrive() {
    _arriving?.cancel();
    _arriving = Timer(widget.settle, () {
      if (!mounted) return;
      setState(() {
        _arriving = null;
        _shown = widget.value;
        _visit++;
      });
    });
  }

  @override
  void dispose() {
    _arriving?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _shown, _visit);
}
