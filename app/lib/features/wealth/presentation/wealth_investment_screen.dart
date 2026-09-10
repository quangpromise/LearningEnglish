import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'wallet_investment_assets_tab.dart';

/// Man Dau tu rieng biet - truoc day noi dung nay la 1 tab ben trong man Vi
/// ("Tai san dau tu"), gio tach thanh man rieng mo tu the "Tong Dau tu" o
/// carousel dau man Home Quan ly tai san (xem wealth_home_screen.dart) -
/// theo yeu cau nguoi dung tach biet Dau tu khoi Vi.
class WealthInvestmentScreen extends ConsumerWidget {
  const WealthInvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    ref.tr('wealth_investments_total'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Expanded(child: WalletInvestmentAssetsTab()),
          ],
        ),
      ),
    );
  }
}
