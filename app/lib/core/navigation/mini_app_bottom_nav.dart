import 'package:flutter/material.dart';

import '../../features/music_player/presentation/center_media_button.dart';
import '../theme/app_theme.dart';

/// Thanh menu duoi cho 1 "app" con (Fitness/Wealth) - CHI CON thanh nhac dai
/// (CenterMediaButton, mau theo [accentColor] tung khu vuc) chiem het chieu
/// rong. Nut Tin nhan da chuyen len headpage (AppTopBar, xem
/// fitness_home_screen.dart/wealth_home_screen.dart), thanh nay khong con
/// icon nao khac.
class MiniAppBottomNav extends StatelessWidget {
  const MiniAppBottomNav({super.key, required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xD90A0E1C),
          border: Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: CenterMediaButton(accentColor: accentColor),
      ),
    );
  }
}
