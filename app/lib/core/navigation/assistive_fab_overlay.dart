import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../features/planner/presentation/planner_accent.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import 'app_popup.dart';
import 'nav_keys.dart';

const _kFabSize = 56.0;
const _kRadialRadius = 92.0;
const _kHomeRouteNames = {
  kEnglishHomeRouteName,
  kFitnessHomeRouteName,
  kWealthHomeRouteName,
};

enum _RadialAction { openPlanner, openAiVoiceChat }

/// 2 loi tat hien co - CHI 2, khong nhoi them cho du so nhu ban dau (5 loi
/// tat cu bi trung chuc nang: "Them viec"/"Hom nay"/"Xem tuan" deu chi mo
/// lai dung 1 man Planner, "Loc mini-app" la tinh nang phu) - se BO SUNG
/// them loi tat MOI (that su khac nhau) vao day khi co tinh nang can, theo
/// dung gop y cua nguoi dung thay vi nhoi cho du 5 o.
const _kRadialItems = [
  (_RadialAction.openPlanner, Icons.calendar_month_rounded, 'planner_title'),
  (
    _RadialAction.openAiVoiceChat,
    Icons.auto_awesome_rounded,
    'voice_chat_title',
  ),
];

/// Nut noi kieu AssistiveTouch DUY NHAT cho toan app - gop 2 nut noi TRUNG
/// CHUC NANG truoc day (AiFabOverlay rieng + PlannerFabOverlay rieng, luon
/// de lai canh nhau tren man hinh) thanh 1 diem truy cap chung, tranh 2 nut
/// choi lan/de chong len nhau. DINH CHET vao canh phai man hinh (chi hien 1
/// NUA hinh tron), chi keo duoc theo truc DOC doc canh phai.
///
/// Cham nhanh (khong keo) bung/thu radial menu - xem [_kRadialItems]. BUG DA
/// SUA: ban dau 5 loi tat xep qua sat nhau (chi 25 do/25px ban kinh giua 2
/// tam) nen chong len nhau ro tren may that - gio chi con 2 loi tat, xep
/// cach xa nhau (60 do, ban kinh 92) nen khong con cham nhau.
///
/// Chi hien o 3 man Home chinh (dung ten route dat trong nav_keys.dart) - an
/// o moi man hinh khac (popup tinh nang...).
class AssistiveFabOverlay extends ConsumerStatefulWidget {
  const AssistiveFabOverlay({super.key});

  @override
  ConsumerState<AssistiveFabOverlay> createState() =>
      _AssistiveFabOverlayState();
}

class _AssistiveFabOverlayState extends ConsumerState<AssistiveFabOverlay> {
  bool _expanded = false;
  bool _dragging = false;
  double _totalMoveDistance = 0;
  double? _dragStartY;
  double? _y;
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
    if (_totalMoveDistance > _dragThreshold) _dragging = true;
    setState(() => _y = next);
  }

  void _onPanEnd(DragEndDetails details) {
    final wasDragging = _dragging;
    setState(() => _dragging = false);
    if (!wasDragging) setState(() => _expanded = !_expanded);
  }

  // BAT BUOC dung rootNavigatorKey.currentContext (KHONG dung `context` cua
  // chinh widget nay) - xem giai thich chi tiet trong ai_fab_overlay.dart
  // (ban cu) - widget nay cung duoc chen NGANG HANG voi Navigator qua
  // MaterialApp.builder nen `context` cua no khong tim thay Navigator/Overlay.
  void _openPlanner() {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    openAppPopup(navContext, const PlannerScreen());
  }

  void _openAiVoiceChat() {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    showModalBottomSheet(
      context: navContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: kAiVoiceChatRouteName),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.94,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          child: AiVoiceChatScreen(),
        ),
      ),
    );
  }

  void _handleAction(_RadialAction action) {
    switch (action) {
      case _RadialAction.openPlanner:
        _openPlanner();
      case _RadialAction.openAiVoiceChat:
        _openAiVoiceChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pronunciationActive = ref.watch(pronunciationTabActiveProvider);
    final section = ref.watch(currentAppSectionProvider);
    final (gradient, glowColor) = plannerAccentFor(section);

    return ValueListenableBuilder<String?>(
      valueListenable: topRouteObserver.currentRouteName,
      builder: (context, routeName, _) {
        final hidden =
            pronunciationActive || !_kHomeRouteNames.contains(routeName);
        if (hidden) return const SizedBox.shrink();

        final mq = MediaQuery.of(context);
        final y = _y ?? _defaultY(mq.size);

        return Stack(
          children: [
            if (_expanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = false),
                  // Chi lam MO NHE nen phia sau (khong toi den nhu lan dau,
                  // theo dung phong cach tham khao cua nguoi dung - vd wheel
                  // picker cua Pinterest: nen mo nhe + phu 1 lop sang mau
                  // nhat cua accent, khong phai lop den mo mit) - du de tach
                  // 2 nut radial khoi noi dung phia sau ma khong lam toi ca
                  // man hinh.
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(color: glowColor.withValues(alpha: 0.1)),
                  ),
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

  /// Xep [_kRadialItems] deu nhau tren 1 vong cung 60 do (150-210 do, 0 do =
  /// huong sang phai) mo VE TRAI vi nut goc dinh canh phai man hinh. Ban
  /// kinh 92px + khoang cach goc 60 do giua 2 muc dam bao khong chong len
  /// nhau voi kich thuoc bubble 44px (khac voi phien ban 5 muc truoc day
  /// dung khoang cach goc qua hep gay chong lan tren man hinh that).
  List<Widget> _buildRadialItems({
    required double centerY,
    required MediaQueryData mq,
    required Gradient gradient,
  }) {
    final centerX = mq.size.width - _kFabSize / 2;
    final items = <Widget>[];
    final n = _kRadialItems.length;
    for (var i = 0; i < n; i++) {
      // Trai deu quanh 180 do (thang trai) trong khoang tong 60 do.
      final angleDeg = n == 1 ? 180.0 : 150.0 + i * (60.0 / (n - 1));
      final rad = angleDeg * math.pi / 180;
      final dx = centerX + _kRadialRadius * math.cos(rad);
      final dy = centerY + _kRadialRadius * math.sin(rad);
      final (action, icon, labelKey) = _kRadialItems[i];
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    // Bo goc vuong (kieu icon app tren man Home, khac 2 FAB
                    // tron o giua) thay vi hinh tron - de nhin la 1 "app"
                    // dang duoc ban ra tu menu, khac han nut nguon vong cung.
                    borderRadius: BorderRadius.circular(16),
                    // Ca 2 nut deu dung CUNG 1 gradient theo app dang mo
                    // (bug da thay tren may that: nut phu bi hardcode mau
                    // xanh-tim cua English du dang mo tu Fitness) - khong
                    // con phan biet rieng mau cho nut "primary".
                    gradient: gradient,
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
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 64,
                  child: Text(
                    ref.tr(labelKey),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
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
