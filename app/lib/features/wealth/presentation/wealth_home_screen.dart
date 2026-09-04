import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../social/presentation/conversations_screen.dart';
import 'calculator_screen.dart';
import 'debt_screen.dart';
import 'market_screen.dart';
import 'recurring_services_screen.dart';
import 'wealth_detail_screen.dart';
import 'wealth_expense_tab.dart';
import 'wallet_screen.dart';

/// Man Home cua khu vuc Quan ly tai san - the "Hello, {ten}" + tong Tien
/// mat/Ngan hang (quy doi VND, co nut an/hien) ngay duoi dong chao, roi den
/// cac the icon+ten (Vi/Chi tieu/Market) - "Thu nhap" cu da gop vao luong
/// "Nap tien" trong Vi (xem quyet dinh trong ke hoach build lai Wealth), tile
/// "Dau tu" cu chuyen vao trong Vi > tab Tai san dau tu.
class WealthHomeScreen extends ConsumerStatefulWidget {
  const WealthHomeScreen({super.key});

  @override
  ConsumerState<WealthHomeScreen> createState() => _WealthHomeScreenState();
}

class _WealthHomeScreenState extends ConsumerState<WealthHomeScreen> {
  // false = tong Tai san hien co (Tien mat+Ngan hang), true = tong Tai san
  // dau tu (Crypto+Co phieu+Kim loai+Nha dat) - cho phep switch ngay tren
  // the tong o Home thay vi phai mo Vi > tab Tai san dau tu moi xem duoc.
  bool _showInvestment = false;

  void _open(BuildContext context, String title, Widget tab) {
    openAppPopup(context, WealthDetailScreen(title: title, child: tab));
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    final hidden = ref.watch(wealthPrivacyModeProvider);
    final netWorth = ref.watch(netWorthVndProvider);
    final investmentTotal = ref.watch(totalInvestmentValueVndProvider);
    final displayValue = _showInvestment ? investmentTotal : netWorth;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              accentColor: AppColors.wealthAccent,
              unreadCount: unread,
              onMessagesTap: () =>
                  openAppPopup(context, const ConversationsScreen()),
            ),
            const SizedBox(height: 18),
            GlowBox(
              padding: const EdgeInsets.all(18),
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hidden
                              ? '•••••••'
                              : (displayValue == null
                                    ? '...'
                                    : formatVnd(displayValue)),
                          style: AppTextStyles.heading(size: 24),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showInvestment = !_showInvestment),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.glassFill,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.sync_alt_rounded,
                            color: AppColors.wealthAccent,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => ref
                            .read(wealthPrivacyModeProvider.notifier)
                            .toggle(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.glassFill,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Icon(
                            hidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.wealthAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _showInvestment
                        ? ref.tr('wealth_investments_total')
                        : ref.tr('wallet_total_assets'),
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GlowBox(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_home_category_manage'),
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 14),
                    // LayoutBuilder tinh be rong 1 the theo cong thuc "vua du
                    // 4 the/hang" - xem giai thich chi tiet trong
                    // home_screen.dart._CategorySection (Wrap+spaceBetween +
                    // width co dinh truoc day khong dam bao dung 4 the/hang).
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        const columns = 4;
                        final itemWidth =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: 14,
                          children: [
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.account_balance_wallet_rounded,
                              label: ref.tr('wallet_title'),
                              onTap: () =>
                                  openAppPopup(context, const WalletScreen()),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.receipt_long_rounded,
                              label: ref.tr('wealth_tab_expense'),
                              onTap: () => _open(
                                context,
                                ref.tr('wealth_tab_expense'),
                                const WealthExpenseTab(),
                              ),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.handshake_rounded,
                              label: ref.tr('wealth_debt_title'),
                              onTap: () =>
                                  openAppPopup(context, const DebtScreen()),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.event_repeat_rounded,
                              label: ref.tr('wealth_service_title'),
                              onTap: () => openAppPopup(
                                context,
                                const RecurringServicesScreen(),
                              ),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.show_chart_rounded,
                              label: ref.tr('wealth_market_title'),
                              onTap: () =>
                                  openAppPopup(context, const MarketScreen()),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.calculate_rounded,
                              label: ref.tr('wealth_calculator_title'),
                              onTap: () => openAppPopup(
                                context,
                                const CalculatorScreen(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WealthTile extends StatelessWidget {
  const _WealthTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(icon, color: AppColors.wealthAccent, size: 24),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: TileLabelText(label: label, maxWidth: width),
            ),
          ],
        ),
      ),
    );
  }
}
