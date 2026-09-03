import 'package:flutter/material.dart';

import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';

/// Khung man hinh dung chung cho tung tinh nang Wealth khi duoc mo tu 1 the
/// tren WealthHomeScreen (Chi tieu/Thu nhap/Dau tu) - moi tinh nang mo dang
/// POPUP (xem app_popup.dart) thay vi push sang man rieng, nen dung
/// PopupHeader (tieu de + nut dong, KHONG avatar - chi man Home chinh moi
/// co avatar) thay vi AppTopBar.
class WealthDetailScreen extends StatelessWidget {
  const WealthDetailScreen({
    super.key,
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupHeader(title: title),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
