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

/// Cac loi tat hien co TRU "Ve trang chu" - theo thu tu tren/trai/phai/duoi
/// quanh nut Home o giua bang menu vuong (xem _buildMenuPanel).
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
/// giua man hinh - bang HINH VUONG, nut "Ve trang chu" o giua, 4 loi tat
/// ([_kGridItems]) xung quanh - xem [_buildMenuPanel].
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

  /// Bang menu dang THANH DOC (thay cho luoi vuong 3x3 truoc day) - theo anh
  /// thiet ke nguoi dung gui: 1 vien nang doc bo tron het co, ben trong la
  /// cac nut tron xep doc kem nhan, muc dang o GIUA thanh duoc lam noi (to
  /// hon, to mau nhan, co quang sang), tren/duoi co mui ten cuon.
  ///
  /// Mau nhan lay theo tung app (gradient/glowColor truyen tu ngoai) nen mo
  /// tu Hoc Tieng Anh ra xanh, tu Quan ly tai san ra vang, tu Fitness ra cam.
  Widget _buildMenuPanel({
    required Gradient gradient,
    required Color glowColor,
  }) {
    return Positioned.fill(
      child: Center(
        child: _AssistiveRail(
          glowColor: glowColor,
          gradient: gradient,
          onAction: _handleAction,
        ),
      ),
    );
  }
}

/// Thanh doc chua cac loi tat - tach thanh widget rieng vi no can tu quan ly
/// ScrollController (de biet muc nao dang o giua ma lam noi len).
class _AssistiveRail extends ConsumerStatefulWidget {
  const _AssistiveRail({
    required this.glowColor,
    required this.gradient,
    required this.onAction,
  });

  final Color glowColor;
  final Gradient gradient;
  final void Function(_RadialAction) onAction;

  @override
  ConsumerState<_AssistiveRail> createState() => _AssistiveRailState();
}

class _AssistiveRailState extends ConsumerState<_AssistiveRail> {
  static const _itemExtent = 80.0;

  late final ScrollController _controller = ScrollController()
    ..addListener(_onScroll);
  double _offset = 0;

  /// Home dung dau, roi den cac loi tat - truoc day Home la 1 nut rieng o
  /// giua luoi, gio la 1 muc nhu cac muc khac trong thanh.
  static const _items = <(_RadialAction, IconData, String)>[
    (_RadialAction.goHome, Icons.home_rounded, 'assistive_menu_home'),
    ..._kGridItems,
  ];

  void _onScroll() {
    if (!mounted) return;
    setState(() => _offset = _controller.position.pixels);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nudge(int direction) {
    final target = (_offset + direction * _itemExtent).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hep lai (132 -> 104) cho de nhin, va DAI ra vua du chua het cac muc
    // nen binh thuong khong phai cuon; chi khi man qua thap moi phai cuon.
    const railWidth = 104.0;
    final maxHeight = MediaQuery.sizeOf(context).height - 180;
    final railHeight = (_itemExtent * _items.length).clamp(
      _itemExtent * 2,
      maxHeight,
    );
    final scrollable = _itemExtent * _items.length > railHeight + 0.5;
    // Muc nam gan TAM thanh nhat se duoc lam noi.
    final centred = ((_offset + railHeight / 2) / _itemExtent - 0.5)
        .round()
        .clamp(0, _items.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (scrollable) ...[
          _chevron(Icons.keyboard_arrow_up_rounded, () => _nudge(-1)),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(railWidth / 2),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: railWidth,
              height: railHeight,
              decoration: BoxDecoration(
                color: const Color(0xE6070A12),
                borderRadius: BorderRadius.circular(railWidth / 2),
                border: Border.all(
                  color: widget.glowColor.withValues(alpha: 0.55),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withValues(alpha: 0.35),
                    blurRadius: 34,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListView.builder(
                controller: _controller,
                physics: scrollable
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemExtent: _itemExtent,
                itemCount: _items.length,
                itemBuilder: (context, i) =>
                    _item(_items[i], selected: i == centred),
              ),
            ),
          ),
        ),
        if (scrollable) ...[
          const SizedBox(height: 6),
          _chevron(Icons.keyboard_arrow_down_rounded, () => _nudge(1)),
        ],
      ],
    );
  }

  Widget _chevron(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        child: Icon(icon, size: 30, color: widget.glowColor),
      ),
    );
  }

  Widget _item(
    (_RadialAction, IconData, String) entry, {
    required bool selected,
  }) {
    final (action, icon, labelKey) = entry;
    final size = selected ? 58.0 : 48.0;
    return GestureDetector(
      onTap: () => widget.onAction(action),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: selected ? widget.gradient : null,
              color: selected ? null : const Color(0xFF1B2029),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.10),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: 0.65),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: selected ? 27 : 23, color: Colors.white),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 96,
            child: Text(
              ref.tr(labelKey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: selected ? 10.5 : 9.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.62),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
