import 'package:flutter/material.dart';

import '../../../core/navigation/app_top_bar.dart';
import '../../../core/theme/app_theme.dart';

/// Khung man hinh dung chung cho tung tinh nang Wealth khi duoc mo tu 1 the
/// tren WealthHomeScreen (Chi tieu/Thu nhap/Dau tu) - truoc day 3 noi dung
/// nay la 3 tab ngang hang trong 1 IndexedStack, gio moi cai la 1 man rieng
/// duoc PUSH (giong cach Fitness/Hoc Tieng Anh to chuc tinh nang thanh cac
/// the tren Home), nen can 1 AppTopBar(showBackButton) + khung Column+Expanded
/// giong het cac man tinh nang khac.
class WealthDetailScreen extends StatelessWidget {
  const WealthDetailScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(
              showBackButton: true,
              accentColor: AppColors.wealthAccent,
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
