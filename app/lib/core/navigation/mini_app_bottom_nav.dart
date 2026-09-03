import 'package:flutter/material.dart';

import '../../features/music_player/presentation/center_media_button.dart';
import '../theme/app_theme.dart';

/// Thanh menu duoi cho 1 "app" con (Fitness/Wealth) - cung kieu pill/vien
/// tron nhu bottom nav chinh cua Hoc Tieng Anh (root_shell.dart), voi thanh
/// nhac dai (CenterMediaButton) chiem khoang trong giua 2 icon tab, mau nhan
/// theo [accentColor] cua khu vuc do (cam cho Fitness, vang cho Wealth).
class MiniAppBottomNav extends StatelessWidget {
  const MiniAppBottomNav({
    super.key,
    required this.icons,
    required this.currentIndex,
    required this.onTap,
    required this.accentColor,
    this.badgeCounts,
  });

  final List<IconData> icons;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  /// So badge hien tren tung icon, cung do dai voi [icons] - null hoac 0 o
  /// vi tri nao thi khong hien badge o do (vd danh cho tab Tin nhan).
  final List<int>? badgeCounts;

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
            for (var i = 0; i < icons.length; i++) ...[
              _NavIcon(
                icon: icons[i],
                active: i == currentIndex,
                accentColor: accentColor,
                badge: badgeCounts != null && i < badgeCounts!.length
                    ? badgeCounts![i]
                    : 0,
                onTap: () => onTap(i),
              ),
              const SizedBox(width: 6),
              // Thanh nhac chiem khoang giua CHI 1 LAN, sau icon dau tien -
              // Fitness/Wealth chi co 2 tab (Home/Tin nhan) nen day chinh la
              // "khoang trong con lai o giua Menu" theo yeu cau.
              if (i == 0) ...[
                Expanded(child: CenterMediaButton(accentColor: accentColor)),
                const SizedBox(width: 6),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.active,
    required this.accentColor,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final bool active;
  final Color accentColor;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? accentColor.withValues(alpha: 0.22)
              : Colors.transparent,
          border: active
              ? Border.all(color: accentColor.withValues(alpha: 0.6))
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? accentColor : AppColors.textMuted,
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
