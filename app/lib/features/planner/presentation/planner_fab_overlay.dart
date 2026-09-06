import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/fab_positions.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import 'planner_accent.dart';
import 'planner_filter_sheet.dart';
import 'planner_providers.dart';
import 'planner_screen.dart';

const _kFabSize = 56.0;
const _kHomeRouteNames = {
  kEnglishHomeRouteName,
  kFitnessHomeRouteName,
  kWealthHomeRouteName,
};

enum _RadialAction { openPlanner, addTask, today, viewWeek, filter }

const _kRadialItems = [
  (_RadialAction.openPlanner, Icons.calendar_month_rounded, 'planner_title'),
  (_RadialAction.addTask, Icons.add_rounded, 'planner_add_task'),
  (_RadialAction.today, Icons.today_rounded, 'planner_today'),
  (_RadialAction.viewWeek, Icons.view_week_rounded, 'planner_view_week'),
  (_RadialAction.filter, Icons.filter_alt_rounded, 'planner_filter_apps'),
];

/// Nut noi "Lap ke hoach" kieu AssistiveTouch - DINH CHET vao canh phai man
/// hinh (chi hien dung 1 NUA hinh tron, xem [_kFabSize]/right offset), chi
/// keo duoc theo truc DOC doc canh phai (khong tach khoi canh). Neu FAB AI
/// Voice Chat (ai_fab_overlay.dart, tu do 2 chieu) bi keo lai gan, 2 nut TU
/// DAY NHAU ra qua [aiFabPositionProvider]/[plannerFabYProvider] (xem
/// core/navigation/fab_positions.dart) - quyet dinh da chot voi nguoi dung,
/// xem docs/research-planner-app-ux.md.
///
/// Cham nhanh (khong keo) bung/thu radial menu 5 loi tat CO DINH (giong nhau
/// tren ca 3 mini-app) xep vong cung mo ve TRAI vi nut dinh canh phai. Chi
/// hien o 3 man Home chinh (dung ten route da dat cho ai_fab_overlay.dart) -
/// an o moi man hinh khac (popup tinh nang...) giong dung AiFabOverlay.
class PlannerFabOverlay extends ConsumerStatefulWidget {
  const PlannerFabOverlay({super.key});

  @override
  ConsumerState<PlannerFabOverlay> createState() => _PlannerFabOverlayState();
}

class _PlannerFabOverlayState extends ConsumerState<PlannerFabOverlay> {
  bool _expanded = false;
  bool _dragging = false;
  double _totalMoveDistance = 0;
  double? _dragStartY;
  static const _dragThreshold = 8.0;

  double _defaultY(Size screenSize) => screenSize.height / 2 - _kFabSize / 2;

  void _onPanStart(double currentY) {
    _dragStartY = currentY;
    _totalMoveDistance = 0;
    _dragging = false;
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets safe,
  ) {
    _totalMoveDistance += details.delta.distance;
    final next = (_dragStartY! + details.delta.dy).clamp(
      safe.top + 8,
      screenSize.height - safe.bottom - _kFabSize - 8,
    );
    _dragStartY = next;
    ref.read(plannerFabYProvider.notifier).state = next;
    if (_totalMoveDistance > _dragThreshold) {
      setState(() => _dragging = true);
    }
    _resolveNudge(screenSize, next);
  }

  void _onPanEnd(DragEndDetails details) {
    final wasDragging = _dragging;
    setState(() => _dragging = false);
    if (!wasDragging) setState(() => _expanded = !_expanded);
  }

  /// Neu FAB nay vua duoc keo den qua gan vi tri hien tai cua AI FAB, day AI
  /// FAB ra xa theo truc doc dung du khoang cach toi thieu - "tu day nhau"
  /// hai chieu (chieu con lai duoc xu ly tuong tu trong ai_fab_overlay.dart).
  void _resolveNudge(Size screenSize, double myY) {
    final aiPos = ref.read(aiFabPositionProvider);
    if (aiPos == null) return;
    const aiFabSize = 58.0;
    final myCenter = myY + _kFabSize / 2;
    final aiCenter = aiPos.dy + aiFabSize / 2;
    final gap = (myCenter - aiCenter).abs();
    if (gap >= kFabMinGapY) return;
    final push = kFabMinGapY - gap;
    final direction = aiCenter >= myCenter ? 1 : -1;
    final newAiY = (aiPos.dy + direction * push).clamp(
      0.0,
      screenSize.height - aiFabSize,
    );
    ref.read(aiFabPositionProvider.notifier).state = Offset(aiPos.dx, newAiY);
  }

  void _openPlanner({bool autoOpenAddSheet = false}) {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    openAppPopup(navContext, PlannerScreen(autoOpenAddSheet: autoOpenAddSheet));
  }

  void _handleAction(_RadialAction action) {
    switch (action) {
      case _RadialAction.openPlanner:
        _openPlanner();
      case _RadialAction.addTask:
        _openPlanner(autoOpenAddSheet: true);
      case _RadialAction.today:
        final now = DateTime.now();
        ref.read(plannerSelectedDateProvider.notifier).state = DateTime(
          now.year,
          now.month,
          now.day,
        );
        _openPlanner();
      case _RadialAction.viewWeek:
        _openPlanner();
      case _RadialAction.filter:
        setState(() => _expanded = false);
        final navContext = rootNavigatorKey.currentContext;
        if (navContext != null) showPlannerFilterSheet(navContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(currentAppSectionProvider);
    final (gradient, glowColor) = plannerAccentFor(section);

    return ValueListenableBuilder<String?>(
      valueListenable: topRouteObserver.currentRouteName,
      builder: (context, routeName, _) {
        if (!_kHomeRouteNames.contains(routeName)) {
          return const SizedBox.shrink();
        }

        final mq = MediaQuery.of(context);
        final y = ref.watch(plannerFabYProvider) ?? _defaultY(mq.size);
        // Dang ky vi tri cua chinh minh de AiFabOverlay biet ma day nguoc lai.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (ref.read(plannerFabYProvider) == null) {
            ref.read(plannerFabYProvider.notifier).state = y;
          }
        });

        return Stack(
          children: [
            if (_expanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = false),
                  child: const SizedBox.shrink(),
                ),
              ),
            if (_expanded)
              ..._buildRadialItems(
                centerY: y + _kFabSize / 2,
                mq: mq,
                gradient: gradient,
              ),
            Positioned(
              right: -_kFabSize / 2,
              top: y,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => _onPanStart(y),
                onPanUpdate: (d) => _onPanUpdate(d, mq.size, mq.padding),
                onPanEnd: _onPanEnd,
                child: AnimatedScale(
                  scale: _dragging ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: _kFabSize,
                    height: _kFabSize,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(-6, 0),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.4,
                      ),
                    ),
                    // Le trai de icon nam trong nua hinh tron con hien tren
                    // man hinh (nua kia bi che boi canh phai).
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    child: Icon(
                      _expanded
                          ? Icons.close_rounded
                          : Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Xep 5 loi tat theo vong cung 140deg (140-240 do, 0 do = huong sang
  /// phai) - mo VE TRAI vi nut goc dinh canh phai man hinh, dung toa do goc
  /// TREN-TRAI cua man hinh (Positioned left/top) lam quy chieu.
  List<Widget> _buildRadialItems({
    required double centerY,
    required MediaQueryData mq,
    required Gradient gradient,
  }) {
    final centerX = mq.size.width - _kFabSize / 2;
    const radius = 92.0;
    final items = <Widget>[];
    for (var i = 0; i < _kRadialItems.length; i++) {
      final angleDeg = 140.0 + i * 25.0;
      final rad = angleDeg * math.pi / 180;
      final dx = centerX + radius * math.cos(rad);
      final dy = centerY + radius * math.sin(rad);
      final (action, icon, labelKey) = _kRadialItems[i];
      final primary = i == 0;
      items.add(
        Positioned(
          left: dx - 26,
          top: dy - 30,
          child: GestureDetector(
            onTap: () => _handleAction(action),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: primary ? gradient : null,
                    color: primary ? null : const Color(0xEB141C2C),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    ref.tr(labelKey),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }
}
