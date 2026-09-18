import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../features/planner/presentation/planner_accent.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/todo/presentation/todo_screen.dart';
import '../../features/translation/presentation/dictionary_popup.dart';
import '../../features/wealth/presentation/calculator_screen.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import 'app_popup.dart';
import 'nav_keys.dart';

const _kFabSize = 56.0;

enum _RadialAction {
  goHome,
  openTodo,
  openPlanner,
  openAiVoiceChat,
  openCalculator,
  openTranslate,
}

/// Cac loi tat hien co TRU "Ve trang chu" - theo thu tu tren/trai/phai/duoi
/// quanh nut Home o giua bang menu vuong (xem _buildMenuPanel).
const _kGridItems = [
  (_RadialAction.openTodo, Icons.checklist_rounded, 'todo_title'),
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
  /// To do list mo dang POPUP giong moi man khac (openAppPopup) - xem
  /// features/todo/presentation/todo_screen.dart.
  void _openTodo() {
    setState(() => _expanded = false);
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    openAppPopup(navContext, const TodoScreen());
  }

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
      case _RadialAction.openTodo:
        _openTodo();
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
                    // LUON la tay nam chevron - truoc day doi sang dau X khi
                    // mo; gio dong menu bang cach cham ra ngoai (hoac cham
                    // lai chinh nut nay) nen khong can dau X nua.
                    child: const Icon(
                      Icons.chevron_left_rounded,
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
    // Neo vao MEP PHAI (khong phai giua man hinh): banh xe cong phinh ve
    // phia phai va dau gach trung tam nam sat canh phai, dung ngay canh nut
    // FAB - dat o giua man se lam cung cong "lo lung" khong dinh vao dau.
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerRight,
        child: _AssistiveRail(
          glowColor: glowColor,
          gradient: gradient,
          onAction: _handleAction,
          onDismiss: () => setState(() => _expanded = false),
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
    required this.onDismiss,
  });

  final Color glowColor;
  final Gradient gradient;
  final void Function(_RadialAction) onAction;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_AssistiveRail> createState() => _AssistiveRailState();
}

/// Banh xe CONG (thay cho thanh doc phang truoc day) - theo anh thiet ke
/// nguoi dung gui: cac muc chay theo 1 cung tron phinh ve phia mep phai, muc
/// cang xa tam cang bi day sang TRAI + mo dan + nho lai; nhan chu nam ben
/// TRAI icon; sat mep phai co 1 "dau gach trung tam" danh dau vi tri chon.
///
/// Dung [ListWheelScrollView] voi `offAxisFraction` (chinh no tao do cong
/// ngang) thay vi tu tinh toa do tung muc: co san quan tinh cuon, hieu ung
/// phoi canh, va `FixedExtentScrollPhysics` tu HIT dung 1 muc vao giua - dung
/// y "scroll icon den dau gach trung tam thi icon do sang".
class _AssistiveRailState extends ConsumerState<_AssistiveRail> {
  static const _itemExtent = 76.0;
  static const _railWidth = 250.0;

  late final FixedExtentScrollController _controller =
      FixedExtentScrollController();
  int _centred = 0;

  static const _items = <(_RadialAction, IconData, String)>[
    (_RadialAction.goHome, Icons.home_rounded, 'assistive_menu_home'),
    ..._kGridItems,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cham vao 1 muc: neu no CHUA o giua thi cuon no vao giua truoc (de nguoi
  /// dung thay ro minh dang chon gi), dung o giua roi moi chay hanh dong -
  /// tranh bam nham muc ben canh khi danh sach dang nghieng.
  void _tap(int index) {
    if (index == _centred) {
      widget.onAction(_items[index].$1);
      return;
    }
    _controller.animateToItem(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height - 150;
    final railHeight = (_itemExtent * _items.length).clamp(
      _itemExtent * 3,
      maxHeight,
    );

    return SizedBox(
      width: _railWidth,
      height: railHeight,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Cham vao khoang TRONG trong vung banh xe (khong trung nhan/icon)
          // thi dong menu. Phai nam DUOI banh xe trong Stack de cac muc o
          // tren van an tay cham cua chung; ListWheelScrollView khong nuot
          // su kien CHAM (no chi tranh cu KEO) nen cham vao cho trong se roi
          // xuong lop nay.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismiss,
            ),
          ),
          // Duong cung mo lam "ray" cho cac muc chay theo - trong anh goc no
          // la 1 net xam rat nhat, chi du goi y quy dao chu khong noi bat.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ArcGuidePainter(
                  color: widget.glowColor.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: _itemExtent,
            // Am = day cac muc o xa tam sang TRAI (cung phinh sang phai).
            offAxisFraction: -1.15,
            diameterRatio: 1.35,
            perspective: 0.0022,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) => setState(() => _centred = i),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _items.length,
              builder: (context, i) => _item(_items[i], i),
            ),
          ),
          // Dau gach trung tam sat mep phai - moc danh dau "muc nao dang duoc
          // chon", to mau accent de an khop voi muc dang sang.
          IgnorePointer(
            child: Container(
              width: 34,
              height: 11,
              decoration: BoxDecoration(
                color: widget.glowColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withValues(alpha: 0.6),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item((_RadialAction, IconData, String) entry, int index) {
    final (_, icon, labelKey) = entry;
    final selected = index == _centred;
    // deferToChild (KHONG phai opaque): chi an tay cham khi trung dung nhan
    // hoac icon. Voi opaque thi ca khoang TRONG ben trai nhan cung tinh la
    // chon muc do, nen khong con cho nao de cham ra ngoai ma dong menu.
    return GestureDetector(
      onTap: () => _tap(index),
      behavior: HitTestBehavior.deferToChild,
      child: Padding(
        // Chua cho cho dau gach trung tam o sat mep phai.
        padding: const EdgeInsets.only(right: 44),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Nhan chu ben TRAI icon: muc dang chon co vien bao quanh dang
            // vien thuoc, cac muc khac chi la chu xam mo.
            Flexible(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1 : 0.45,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 12 : 0,
                    vertical: selected ? 6 : 0,
                  ),
                  decoration: selected
                      ? BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.glowColor.withValues(alpha: 0.55),
                          ),
                        )
                      : null,
                  child: Text(
                    ref.tr(labelKey),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: selected ? 13 : 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? Colors.white : Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // O icon bo tron (squircle) - muc dang o dau gach trung tam SANG
            // theo tone app: nen pha accent, vien accent, icon mau accent,
            // them quang sang; cac muc khac chim xuong nen kinh xam.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 56 : 46,
              height: selected ? 56 : 46,
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        widget.glowColor.withValues(alpha: 0.22),
                        const Color(0xCC0B0F16),
                      )
                    : const Color(0x730E1219),
                borderRadius: BorderRadius.circular(selected ? 20 : 16),
                border: Border.all(
                  color: selected
                      ? widget.glowColor
                      : Colors.white.withValues(alpha: 0.10),
                  width: selected ? 1.8 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: widget.glowColor.withValues(alpha: 0.55),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: selected ? 27 : 22,
                color: selected
                    ? widget.glowColor
                    : Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Net cung mo chay doc mep phai - cung huong cong voi banh xe nen cac muc
/// trong nhu dang "truot tren ray".
class _ArcGuidePainter extends CustomPainter {
  const _ArcGuidePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final h = size.height;
    final path = Path()
      ..moveTo(size.width - 6, 0)
      ..quadraticBezierTo(size.width - 78, h / 2, size.width - 6, h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArcGuidePainter old) => old.color != color;
}
