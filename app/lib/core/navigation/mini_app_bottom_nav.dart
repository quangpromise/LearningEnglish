import 'package:flutter/material.dart';

import '../../features/music_player/presentation/center_media_button.dart';
import '../theme/app_theme.dart';

/// Thanh menu duoi cho 1 "app" con (Fitness/Wealth) - cung kieu pill/vien
/// tron nhu bottom nav chinh cua Hoc Tieng Anh (root_shell.dart) nhung dung
/// rieng trong 1 Scaffold cua tung khu vuc, mau nhan doi theo [accentColor]
/// cua khu vuc do (cam cho Fitness, vang cho Wealth) thay vi mau xanh mac
/// dinh.
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(icons.length, (i) {
                final active = i == currentIndex;
                final badge = badgeCounts != null && i < badgeCounts!.length
                    ? badgeCounts![i]
                    : 0;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: active ? 76 : 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? accentColor.withValues(alpha: 0.22)
                          : Colors.transparent,
                      border: active
                          ? Border.all(
                              color: accentColor.withValues(alpha: 0.6),
                            )
                          : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icons[i],
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
              }),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: const CenterMediaButton(),
          ),
        ],
      ),
    );
  }
}
