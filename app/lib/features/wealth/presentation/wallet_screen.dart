import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'wallet_existing_assets_tab.dart';

/// Man Vi - Tien mat/Ngan hang ("Tai san dau tu" da tach thanh man rieng
/// WealthInvestmentScreen, mo tu the "Tong Dau tu" o Home, khong con la 1
/// tab trong man nay nua).
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref.tr('wallet_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Expanded(child: WalletExistingAssetsTab()),
          ],
        ),
      ),
    );
  }
}
