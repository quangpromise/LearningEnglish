import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'wallet_account_history_screen.dart';
import 'wallet_existing_assets_tab.dart';

/// Man Vi - Tien mat/Ngan hang ("Tai san dau tu" da tach thanh man rieng
/// WealthInvestmentScreen, mo tu the "Tong Dau tu" o Home, khong con la 1
/// tab trong man nay nua).
///
/// Lich su bien dong 1 tai khoan hien INLINE (khong con tu mo openAppPopup
/// rieng chong len) de swipe xuong/tap ngoai luon dong het ve Home dung 1
/// lan.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _HistoryArgs {
  const _HistoryArgs({
    required this.title,
    required this.accountType,
    this.bankCode,
    this.bankName,
  });
  final String title;
  final String accountType;
  final String? bankCode;
  final String? bankName;
}

class _WalletScreenState extends State<WalletScreen> {
  _HistoryArgs? _history;

  @override
  Widget build(BuildContext context) {
    final history = _history;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: history != null
            ? WalletAccountHistoryScreen(
                title: history.title,
                accountType: history.accountType,
                bankCode: history.bankCode,
                bankName: history.bankName,
                onBack: () => setState(() => _history = null),
              )
            : Column(
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
                  Expanded(
                    child: WalletExistingAssetsTab(
                      onOpenHistory:
                          ({
                            required title,
                            required accountType,
                            bankCode,
                            bankName,
                          }) => setState(() {
                            _history = _HistoryArgs(
                              title: title,
                              accountType: accountType,
                              bankCode: bankCode,
                              bankName: bankName,
                            );
                          }),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
