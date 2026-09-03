import 'package:flutter/material.dart';

import '../../features/music_player/presentation/center_media_button.dart';
import '../theme/app_theme.dart';

/// Thanh menu duoi cho 1 "app" con (Fitness/Wealth) - CHI CON 1 man Home
/// that su (moi tinh nang khac mo popup, xem app_popup.dart), nen thanh nay
/// khong con nut Home nua: chi con thanh nhac dai (CenterMediaButton, mau
/// theo [accentColor] tung khu vuc) + 1 nut Tin nhan mo popup.
class MiniAppBottomNav extends StatelessWidget {
  const MiniAppBottomNav({
    super.key,
    required this.accentColor,
    required this.onMessagesTap,
    this.unreadCount = 0,
  });

  final Color accentColor;
  final VoidCallback onMessagesTap;
  final int unreadCount;

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
        child: Row(
          children: [
            Expanded(child: CenterMediaButton(accentColor: accentColor)),
            const SizedBox(width: 6),
            _MessagesIcon(badge: unreadCount, onTap: onMessagesTap),
          ],
        ),
      ),
    );
  }
}

class _MessagesIcon extends StatelessWidget {
  const _MessagesIcon({required this.onTap, this.badge = 0});
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.chat_bubble_rounded,
              size: 22,
              color: AppColors.textMuted,
            ),
            if (badge > 0)
              Positioned(
                right: -4,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xD90A0E1C),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
