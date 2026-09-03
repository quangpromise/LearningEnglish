import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'nav_keys.dart';

const _kFabSize = 58.0;

/// Nut noi "AI Voice Chat" - hien tren MOI man hinh cua app (chong len qua
/// MaterialApp.builder trong main.dart) thay vi chi la 1 tab co dinh o
/// thanh dieu huong duoi, de nguoi dung mo tro chuyen AI bat ky luc nao.
/// An rieng o tab Luyen phat am (pronunciationTabActiveProvider) vi man do
/// da dung mic + can toan bo man hinh cho luyen tap, nut noi de chong/vuong;
/// va an luon o chinh man AiVoiceChatScreen - xac dinh qua [topRouteObserver]
/// (KHONG dung Riverpod state tu doi trong initState/dispose cua chinh man
/// hinh do nua vi de bi lech dong bo, khien nut bien mat luon sau khi quay
/// lai neu dispose khong chay dung thoi diem mong doi).
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
    // Fitness/Wealth: nut noi AI Voice Chat van hien tren MOI man hinh cua
    // 2 khu vuc nay (theo yeu cau) - CHI an o tab Luyen phat am (co mic
    // rieng, tranh chong nhau) va o chinh man AI Voice Chat.

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
            pronunciationActive || routeName == kAiVoiceChatRouteName;
        if (hidden) return const SizedBox.shrink();

        final mq = MediaQuery.of(context);
        final position = _position ?? _defaultPosition(mq.size, mq.padding);

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
