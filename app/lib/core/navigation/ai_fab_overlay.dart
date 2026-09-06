import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'fab_positions.dart';
import 'nav_keys.dart';

const _kFabSize = 58.0;

/// Ten route cua dung "man Home that su" cua ca 3 khu vuc (xem
/// nav_keys.dart) - nut noi CHI hien khi dang dung mot trong 3 route nay,
/// tu dong an o moi man hinh khac (popup tinh nang, man con...) vi nhung
/// man do khong duoc dat ten (settings.name == null) nen khong khop tap nay.
const _kHomeRouteNames = {
  kEnglishHomeRouteName,
  kFitnessHomeRouteName,
  kWealthHomeRouteName,
};

/// Nut noi "AI Voice Chat" - CHI hien o dung 3 man Home chinh (Hoc Tieng
/// Anh/Fitness/Wealth, xem [_kHomeRouteNames]), an o MOI man hinh khac (popup
/// tinh nang, man con...) - chong len qua MaterialApp.builder trong main.dart
/// thay vi chi la 1 tab co dinh o thanh dieu huong duoi, de nguoi dung mo tro
/// chuyen AI ngay tu man Home bat ky luc nao ma khong vuong tay khi dang thao
/// tac trong 1 tinh nang khac. Xac dinh dang o man nao qua [topRouteObserver]
/// (KHONG dung Riverpod state tu doi trong initState/dispose cua tung man
/// hinh nua vi de bi lech dong bo, khien nut bien mat/hien sai luc neu
/// dispose khong chay dung thoi diem mong doi). An rieng them o tab Luyen
/// phat am (pronunciationTabActiveProvider, man do da dung mic + can toan bo
/// man hinh) - thuc ra da duoc an tu dong boi luat "chi hien o Home" o tren
/// (man Luyen phat am cung la 1 popup khong ten), giu lai check nay chi de
/// an toan kep, khong anh huong logic chinh.
///
/// Cham nhanh (tha ra ma khong di chuyen nhieu) se MO man AI Voice Chat;
/// nhan giu roi keo se DI CHUYEN nut den vi tri bat ky tren man hinh - vi
/// tri duoc nho lai trong suot phien mo app (khong luu qua SharedPreferences,
/// chi la tien loi tam thoi khi dang dung app).
///
/// Dung onPan* (khong dung onTap + onLongPress*) va tu phan biet cham/keo
/// bang nguong khoang cach di chuyen - onLongPress* yeu cau nguoi dung giu
/// YEN tay dung 500ms roi moi duoc phep di chuyen (LongPressGestureRecognizer
/// tu HUY neu phat hien di chuyen truoc khi het thoi gian cho), khien thao
/// tac "giu roi vuot" rat de that bai neu nguoi dung vo tinh nhich tay som -
/// cach nay tu nhien va de thanh cong hon nhieu.
class AiFabOverlay extends ConsumerStatefulWidget {
  const AiFabOverlay({super.key});

  @override
  ConsumerState<AiFabOverlay> createState() => _AiFabOverlayState();
}

class _AiFabOverlayState extends ConsumerState<AiFabOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  // null = chua tung keo, dung vi tri mac dinh (goc duoi ben phai, phia
  // tren nut Menu). Sau khi nguoi dung keo lan dau, luu toa do goc
  // tren-trai thuc te de tu do di chuyen tu do.
  Offset? _position;
  bool _dragging = false;

  // Tong khoang cach da di chuyen ke tu luc dat ngon tay xuong - vuot qua
  // nguong nay moi tinh la "dang keo" (thay vi 1 cu cham/tap thong thuong).
  double _totalMoveDistance = 0;
  static const _dragThreshold = 8.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Mo dang POPUP (bottom sheet gan full man hinh) thay vi day sang man
  // rieng - dong bo voi cach moi tinh nang khac trong app da chuyen sang
  // (xem app_popup.dart). Van giu RouteSettings(name: kAiVoiceChatRouteName)
  // - showModalBottomSheet cung day 1 Route thuc su len Navigator nen
  // topRouteObserver van nhan dien duoc de tu an nut noi ngay chinh man nay.
  //
  // BAT BUOC dung rootNavigatorKey.currentContext (KHONG dung `context` cua
  // chinh AiFabOverlay) - AiFabOverlay duoc chen vao qua
  // MaterialApp.builder's Stack(children: [?child, AiFabOverlay()]) NGANG
  // HANG (sibling) voi Navigator cua app, khong phai MOT HAU DUE cua no.
  // `context` cua AiFabOverlay vi vay KHONG tim thay Navigator/Overlay nao
  // qua Navigator.of(context)/Overlay.of(context), khien nut hoan toan vo
  // tac dung (khong nem loi thay duoc vi showModalBottomSheet chay am tham
  // that bai). rootNavigatorKey.currentContext luon la context CUA chinh
  // Navigator goc, dam bao tim duoc.
  void _open() {
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;
    showModalBottomSheet(
      context: navContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: kAiVoiceChatRouteName),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: const AiVoiceChatScreen(),
        ),
      ),
    );
  }

  Offset _defaultPosition(Size screenSize, EdgeInsets safePadding) => Offset(
    screenSize.width - _kFabSize - 22,
    screenSize.height - _kFabSize - 96 - safePadding.bottom,
  );

  void _onPanStart(Offset currentPosition) {
    // Dam bao _position co gia tri cu the (khong con null) truoc khi bat
    // dau cong don delta - tranh tinh sai neu nguoi dung keo lan dau tien
    // (luc do _position con null, dang dung vi tri mac dinh tinh toan rieng).
    _position = currentPosition;
    _totalMoveDistance = 0;
    _dragging = false;
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    _totalMoveDistance += details.delta.distance;
    final next = _position! + details.delta;
    final maxX = screenSize.width - _kFabSize;
    final maxY = screenSize.height - _kFabSize;
    setState(() {
      _position = Offset(next.dx.clamp(0, maxX), next.dy.clamp(0, maxY));
      if (_totalMoveDistance > _dragThreshold) _dragging = true;
    });
    ref.read(aiFabPositionProvider.notifier).state = _position;
    _resolveNudge(screenSize, _position!);
  }

  /// Neu nut nay vua duoc keo den qua gan Y hien tai cua Planner FAB (dinh
  /// canh phai, xem planner_fab_overlay.dart), day Planner FAB ra xa theo
  /// truc doc dung du khoang cach toi thieu - "tu day nhau" hai chieu (chieu
  /// con lai duoc xu ly tuong tu ben planner_fab_overlay.dart).
  void _resolveNudge(Size screenSize, Offset myPos) {
    final plannerY = ref.read(plannerFabYProvider);
    if (plannerY == null) return;
    const plannerFabSize = 56.0;
    final myCenter = myPos.dy + _kFabSize / 2;
    final plannerCenter = plannerY + plannerFabSize / 2;
    final gap = (myCenter - plannerCenter).abs();
    if (gap >= kFabMinGapY) return;
    final push = kFabMinGapY - gap;
    final direction = plannerCenter >= myCenter ? 1 : -1;
    final newPlannerY = (plannerY + direction * push).clamp(
      0.0,
      screenSize.height - plannerFabSize,
    );
    ref.read(plannerFabYProvider.notifier).state = newPlannerY;
  }

  void _onPanEnd(DragEndDetails details) {
    final wasDragging = _dragging;
    setState(() => _dragging = false);
    // Neu ngon tay hau nhu khong di chuyen (duoi nguong), tinh la 1 cu cham
    // binh thuong - mo man AI Voice Chat thay vi coi la vua keo xong.
    if (!wasDragging) _open();
  }

  @override
  Widget build(BuildContext context) {
    final pronunciationActive = ref.watch(pronunciationTabActiveProvider);

    // Neu Planner FAB (planner_fab_overlay.dart) vua "day" nut nay ra xa
    // (ghi truc tiep vao aiFabPositionProvider), dong bo lai vao _position
    // cuc bo de nut THAT SU di chuyen tren man hinh - khong chi doi khi
    // chinh nut nay tu keo (truong hop do da tu ghi cung 1 gia tri nen
    // dieu kien `!=` duoi day tu bo qua, khong lap vo han).
    ref.listen<Offset?>(aiFabPositionProvider, (prev, next) {
      if (next != null && next != _position) {
        setState(() => _position = next);
      }
    });

    // Mau nut doi theo "app" dang mo (Hoc Tieng Anh/Fitness/Wealth) - dong
    // bo voi mau chu dao cua tung khu vuc thay vi luon co dinh 1 mau.
    final section = ref.watch(currentAppSectionProvider);
    final (gradient, glowColor) = switch (section) {
      AppSection.fitness => (
        AppColors.fitnessAccentGradient,
        AppColors.fitnessAccent,
      ),
      AppSection.wealth => (
        AppColors.wealthAccentGradient,
        AppColors.wealthAccent,
      ),
      AppSection.learnEnglish => (AppColors.accentGradient, AppColors.purple),
    };

    return ValueListenableBuilder<String?>(
      valueListenable: topRouteObserver.currentRouteName,
      builder: (context, routeName, _) {
        final hidden =
            pronunciationActive || !_kHomeRouteNames.contains(routeName);
        if (hidden) return const SizedBox.shrink();

        final mq = MediaQuery.of(context);
        final position = _position ?? _defaultPosition(mq.size, mq.padding);
        // Dang ky vi tri hien tai (ke ca khi chua tung keo) de
        // PlannerFabOverlay biet ma tu day khi bi keo lai gan.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (ref.read(aiFabPositionProvider) != position) {
            ref.read(aiFabPositionProvider.notifier).state = position;
          }
        });

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => _onPanStart(position),
            onPanUpdate: (details) => _onPanUpdate(details, mq.size),
            onPanEnd: _onPanEnd,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = _dragging
                    ? 0.5
                    : 0.25 + (_pulseController.value * 0.25);
                return AnimatedScale(
                  scale: _dragging ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: _kFabSize,
                    height: _kFabSize,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: glow),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.4,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }
}
