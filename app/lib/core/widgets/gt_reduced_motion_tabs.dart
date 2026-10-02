import 'package:flutter/material.dart';

import '../theme/gt_motion.dart';

/// [tabController] doi tab TUC THI khi bat giam chuyen dong: thanh chi bao
/// va trang khong truot (spec #96). Bat / tat giua chung thi tao lai
/// controller, giu tab dang chon. Can TickerProviderStateMixin (luc doi, 2
/// controller cung song den het khung hinh).
mixin GtReducedMotionTabs<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  /// So tab.
  int get tabCount;

  TabController? _tabs;
  bool? _tabsStill;

  /// Controller cu, cho huy sau khung hinh.
  final List<TabController> _retiredTabs = [];

  TabController get tabController => _tabs!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = gtReduceMotion(context);
    if (still == _tabsStill) return;
    _tabsStill = still;
    final old = _tabs;
    _tabs = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: old?.index ?? 0,
      animationDuration: still ? Duration.zero : null,
    );
    // TabBar / TabBarView doi sang controller moi o lan build nay; cai cu
    // huy sau khung hinh (hoac luc huy man, neu som hon).
    if (old != null) {
      _retiredTabs.add(old);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_retiredTabs.remove(old)) old.dispose();
      });
    }
  }

  @override
  void dispose() {
    for (final old in _retiredTabs) {
      old.dispose();
    }
    _retiredTabs.clear();
    _tabs?.dispose();
    super.dispose();
  }
}
