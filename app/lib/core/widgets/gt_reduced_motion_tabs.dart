import 'package:flutter/material.dart';

import '../theme/gt_motion.dart';

/// [tabController] doi tab TUC THI khi bat giam chuyen dong: thanh chi bao
/// va trang khong truot (spec #96). Bat / tat giua chung thi tao lai
/// controller, giu tab dang chon. Dung kem TickerProviderStateMixin.
mixin GtReducedMotionTabs<T extends StatefulWidget>
    on State<T>, TickerProvider {
  /// So tab.
  int get tabCount;

  TabController? _tabs;
  bool? _tabsStill;

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
    // huy sau khung hinh.
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }
}
