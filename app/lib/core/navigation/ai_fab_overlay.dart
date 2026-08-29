import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'nav_keys.dart';

/// Nut noi "AI Voice Chat" - hien tren MOI man hinh cua app (chong len qua
/// MaterialApp.builder trong main.dart) thay vi chi la 1 tab co dinh o
/// thanh dieu huong duoi, de nguoi dung mo tro chuyen AI bat ky luc nao.
/// An rieng o tab Luyen phat am (pronunciationTabActiveProvider) vi man do
/// da dung mic + can toan bo man hinh cho luyen tap, nut noi de chong/vuong.
class AiFabOverlay extends ConsumerStatefulWidget {
  const AiFabOverlay({super.key});

  @override
  ConsumerState<AiFabOverlay> createState() => _AiFabOverlayState();
}

class _AiFabOverlayState extends ConsumerState<AiFabOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

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

  @override
  Widget build(BuildContext context) {
    final hidden = ref.watch(pronunciationTabActiveProvider);
    if (hidden) return const SizedBox.shrink();

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      right: 22,
      bottom: 96 + bottomInset,
      child: GestureDetector(
        onTap: _open,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glow = 0.25 + (_pulseController.value * 0.25);
            return Container(
              width: 58,
              height: 58,
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
