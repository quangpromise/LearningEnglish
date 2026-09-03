import 'package:flutter/material.dart';

import '../../features/music_player/presentation/center_media_button.dart';

/// Thanh menu duoi cho 1 "app" con (Fitness/Wealth) - CHI CON thanh nhac dai
/// (CenterMediaButton, mau theo [accentColor] tung khu vuc) chiem het chieu
/// rong. Nut Tin nhan da chuyen len headpage (AppTopBar, xem
/// fitness_home_screen.dart/wealth_home_screen.dart). CenterMediaButton tu
/// ve pill day du (full size nhu Menu cu) - khong con boc them 1 Container
/// trang tri rieng o day nua (truoc day tao ra 2 lop pill long nhau, lech
/// kich thuoc so voi Menu cu).
class MiniAppBottomNav extends StatelessWidget {
  const MiniAppBottomNav({super.key, required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: CenterMediaButton(accentColor: accentColor),
    );
  }
}
