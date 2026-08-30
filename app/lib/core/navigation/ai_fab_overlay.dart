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
/// va an luon o chinh man AiVoiceChatScreen (aiVoiceChatScreenActiveProvider)
/// vi khong can nut mo lai tinh nang dang mo san.
///
/// Giu (long-press) roi keo se DI CHUYEN nut den vi tri bat ky tren man
/// hinh - vi tri duoc nho lai trong suot phien mo app (khong luu qua
/// SharedPreferences, chi la tien loi tam thoi khi dang dung app).
class AiFabOverlay extends ConsumerStatefulWidget {
  const AiFabOverlay({super.key});

  @override
  ConsumerState<AiFabOverlay> createState() => _AiFabOverlayState();
}

class _AiFabOverlayState extends ConsumerState<AiFabOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  // null = chua tung keo, dung vi tri mac dinh (goc duoi ben phai, phia
  // tren nut Menu). Sau khi nguoi dung giu-keo lan dau, luu toa do goc
  // tren-trai thuc te de tu do di chuyen tu do.
  Offset? _position;
  Offset _dragStartPosition = Offset.zero;
  bool _dragging = false;

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

  void _open() {
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const AiVoiceChatScreen()),
    );
  }

  void _onLongPressMoveUpdate(
    LongPressMoveUpdateDetails details,
    Size screenSize,
  ) {
    // offsetFromOrigin la do doi TICH LUY tu luc bat dau giu (khong phai
    // delta tung frame) - phai cong voi vi tri LUC BAT DAU keo
    // (_dragStartPosition), khong duoc cong don vao _position hien tai moi
    // frame (se bi chay lech/nhanh dan).
    final next = _dragStartPosition + details.offsetFromOrigin;
    final maxX = screenSize.width - _kFabSize;
    final maxY = screenSize.height - _kFabSize;
    setState(() {
      _position = Offset(next.dx.clamp(0, maxX), next.dy.clamp(0, maxY));
    });
  }

  @override
  Widget build(BuildContext context) {
    final hidden =
        ref.watch(pronunciationTabActiveProvider) ||
        ref.watch(aiVoiceChatScreenActiveProvider);
    if (hidden) return const SizedBox.shrink();

    final mq = MediaQuery.of(context);
    final position =
        _position ??
        Offset(
          mq.size.width - _kFabSize - 22,
          mq.size.height - _kFabSize - 96 - mq.padding.bottom,
        );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: _open,
        onLongPressStart: (_) => setState(() {
          _dragging = true;
          _dragStartPosition = position;
        }),
        onLongPressMoveUpdate: (details) =>
            _onLongPressMoveUpdate(details, mq.size),
        onLongPressEnd: (_) => setState(() => _dragging = false),
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
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: glow),
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
  }
}
