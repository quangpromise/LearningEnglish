import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../features/planner/presentation/planner_accent.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/translation/presentation/dictionary_popup.dart';
import '../../features/wealth/presentation/calculator_screen.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'app_popup.dart';
import 'nav_keys.dart';

const _kFabSize = 56.0;

enum _RadialAction {
  goHome,
  openPlanner,
  openAiVoiceChat,
  openCalculator,
  openTranslate,
}

/// Cac loi tat hien co TRU "Ve trang chu" - rieng Home duoc xep thanh 1 nut
/// LON, doc lap o duoi cung cua bang menu (xem _buildMenuPanel), giong bo
/// cuc menu AssistiveTouch that cua iOS (luoi cac muc phia tren + Home rieng
/// phia duoi) thay vi xep tat ca thanh 1 cung tron nhu truoc.
const _kGridItems = [
  (_RadialAction.openPlanner, Icons.calendar_month_rounded, 'planner_title'),
  (
    _RadialAction.openAiVoiceChat,
    Icons.auto_awesome_rounded,
    'voice_chat_title',
  ),
  (
    _RadialAction.openCalculator,
    Icons.calculate_rounded,
    'wealth_calculator_title',
  ),
  (
    _RadialAction.openTranslate,
    Icons.translate_rounded,
    'assistive_menu_translate',
  ),
];

/// Nut noi kieu AssistiveTouch DUY NHAT cho toan app - gop 2 nut noi TRUNG
/// CHUC NANG truoc day (AiFabOverlay rieng + PlannerFabOverlay rieng, luon
/// de lai canh nhau tren man hinh) thanh 1 diem truy cap chung, tranh 2 nut
/// choi lan/de chong len nhau. DINH CHET vao canh phai man hinh (chi hien 1
/// NUA hinh tron), chi keo duoc theo truc DOC doc canh phai.
///
/// Cham nhanh (khong keo) bung/thu 1 bang menu kinh mo (frosted glass) noi
/// giua man hinh - luoi 2x2 cac loi tat ([_kGridItems]) + rieng nut "Ve
/// trang chu" to hon o duoi cung, dung bo cuc menu AssistiveTouch that cua
/// iOS - xem [_buildMenuPanel].
///
/// Hien o TAT CA man hinh (truoc day chi hien o 3 man Home chinh, an o moi
/// man hinh khac - doi theo yeu cau nguoi dung de dung duoc loi tat "Ve
/// trang chu" tu bat ky dau) - CHI an khi dang ghi am luyen phat am
/// ([pronunciationTabActiveProvider]) hoac dang o man AI Voice Chat (tranh
/// noi tren giao dien cuoc goi).
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

  /// Ve dung man Home cua khu vuc (app) dang mo - dua theo ten route da dat
  /// san cho 3 man Home (xem nav_keys.dart) + [currentAppSectionProvider]
  /// de biet dang o khu vuc nao, popUntil se tu dong dong het moi popup/man
  /// hinh con da mo phia tren (openAppPopup deu KHONG dat ten route).
  void _goHome() {
    setState(() => _expanded = false);
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    final homeRouteName = switch (ref.read(currentAppSectionProvider)) {
      AppSection.learnEnglish => kEnglishHomeRouteName,
      AppSection.fitness => kFitnessHomeRouteName,
      AppSection.wealth => kWealthHomeRouteName,
    };
    nav.popUntil((route) => route.settings.name == homeRouteName);
  }

  void _openCalculator() {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    openCalculatorPopup(navContext);
  }

  /// Cung popup tra tu dien 2 chieu Anh<->Viet dang mo tu icon o man Home
  /// (xem home_screen.dart/DictionaryPopup) - gio mo them duoc tu bat ky dau
  /// qua menu AssistiveTouch.
  void _openTranslate() {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    showModalBottomSheet(
      context: navContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DictionaryPopup(),
    );
  }

  void _handleAction(_RadialAction action) {
    switch (action) {
      case _RadialAction.goHome:
        _goHome();
      case _RadialAction.openPlanner:
        _openPlanner();
      case _RadialAction.openAiVoiceChat:
        _openAiVoiceChat();
      case _RadialAction.openCalculator:
        _openCalculator();
      case _RadialAction.openTranslate:
        _openTranslate();
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
            pronunciationActive || routeName == kAiVoiceChatRouteName;
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
              _buildMenuPanel(gradient: gradient, glowColor: glowColor),
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

  /// Bang menu kieu AssistiveTouch that cua iOS: 1 the kinh mo (frosted
  /// glass) noi giua man hinh, chua luoi 2x2 cac loi tat ([_kGridItems]) +
  /// rieng nut "Ve trang chu" to hon nam DOC LAP o duoi cung - dung layout
  /// co dinh (khong bam theo vi tri FAB nhu ban cu) de khong bao gio bi tran
  /// man hinh du FAB dang o dau tren canh phai.
  Widget _buildMenuPanel({
    required Gradient gradient,
    required Color glowColor,
  }) {
    const panelWidth = 260.0;
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, -0.15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: panelWidth,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGridRow(_kGridItems.sublist(0, 2), gradient),
                  const SizedBox(height: 20),
                  _buildGridRow(_kGridItems.sublist(2, 4), gradient),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppColors.glassBorder),
                  const SizedBox(height: 16),
                  _buildHomeButton(gradient, glowColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow(
    List<(_RadialAction, IconData, String)> items,
    Gradient gradient,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map((item) => _buildMenuItem(item.$1, item.$2, item.$3, gradient))
          .toList(),
    );
  }

  Widget _buildMenuItem(
    _RadialAction action,
    IconData icon,
    String labelKey,
    Gradient gradient,
  ) {
    return GestureDetector(
      onTap: () => _handleAction(action),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Ca cac nut deu dung CUNG 1 gradient theo app dang mo (bug da
              // thay tren may that: nut phu bi hardcode mau xanh-tim cua
              // English du dang mo tu Fitness) - khong con phan biet rieng
              // mau cho nut "primary".
              gradient: gradient,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 74,
            child: Text(
              ref.tr(labelKey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nut "Ve trang chu" - xep rieng, TO HON cac muc luoi phia tren va nam o
  /// duoi cung cua bang menu, dung bo cuc voi anh man hinh AssistiveTouch
  /// that cua iOS nguoi dung gui lam mau.
  Widget _buildHomeButton(Gradient gradient, Color glowColor) {
    return GestureDetector(
      onTap: () => _handleAction(_RadialAction.goHome),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.home_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ref.tr('assistive_menu_home'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
