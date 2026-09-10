import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../social/presentation/conversations_screen.dart';
import 'debt_screen.dart';
import 'market_screen.dart';
import 'recurring_services_screen.dart';
import 'wealth_detail_screen.dart';
import 'wealth_investment_screen.dart';
import 'wealth_pay_screen.dart';
import 'wealth_qr_screen.dart';
import 'wealth_report_screen.dart';
import 'wealth_settings_screen.dart';
import 'wealth_split_bill_screen.dart';
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
  // Carousel 2 the: trang 0 = Tong Vi (Tien mat+Ngan hang, mac dinh hien),
  // trang 1 = Tong Tai san dau tu (Crypto+Co phieu+Kim loai+Nha dat) - THAY
  // THE nut "sync_alt" bam-de-doi truoc day bang thao tac VUOT (slide) giua
  // 2 the, voi 1/3 goc phai cua the Dau tu ho ra san (viewportFraction 0.7)
  // de goi y con the thu 2 co the vuot toi - theo dung yeu cau nguoi dung.
  late final _pageController = PageController(viewportFraction: 0.7)
    ..addListener(_onPageScroll);
  int _pageIndex = 0;

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _pageIndex) setState(() => _pageIndex = page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _open(BuildContext context, String title, Widget tab) {
    openAppPopup(context, WealthDetailScreen(title: title, child: tab));
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    final hidden = ref.watch(wealthPrivacyModeProvider);
    final netWorth = ref.watch(netWorthVndProvider);
    final investmentTotal = ref.watch(totalInvestmentValueVndProvider);
    final (investmentPnl, investmentPnlPercent) = ref.watch(
      investmentPnlProvider,
    );
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
              trailing: GestureDetector(
                onTap: () =>
                    openAppPopup(context, const WealthSettingsScreen()),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.glassFill,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 146,
              child: PageView(
                controller: _pageController,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _TotalCard(
                      title: ref.tr('wallet_total_assets'),
                      value: netWorth,
                      hidden: hidden,
                      onTap: () => openAppPopup(context, const WalletScreen()),
                      onToggleHidden: () =>
                          ref.read(wealthPrivacyModeProvider.notifier).toggle(),
                      footer: _CardFooterRow(
                        items: [
                          (
                            Icons.payments_rounded,
                            ref.tr('wealth_home_pay_receive'),
                            () =>
                                openAppPopup(context, const WealthPayScreen()),
                          ),
                          (
                            Icons.qr_code_rounded,
                            ref.tr('wealth_home_qr_code'),
                            () => openAppPopup(context, const WealthQrScreen()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _TotalCard(
                    title: ref.tr('wealth_investments_total'),
                    value: investmentTotal,
                    hidden: hidden,
                    pnl: investmentPnl,
                    pnlPercent: investmentPnlPercent,
                    onTap: () =>
                        openAppPopup(context, const WealthInvestmentScreen()),
                    onToggleHidden: () =>
                        ref.read(wealthPrivacyModeProvider.notifier).toggle(),
                    footer: _CardFooterRow(
                      items: [
                        (
                          Icons.show_chart_rounded,
                          ref.tr('wealth_market_title'),
                          () => openAppPopup(context, const MarketScreen()),
                        ),
                        (
                          Icons.star_rounded,
                          ref.tr('crypto_tab_watchlist'),
                          () => openAppPopup(
                            context,
                            const MarketScreen(initialTabIndex: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 2; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _pageIndex == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _pageIndex == i
                          ? AppColors.wealthAccent
                          : AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
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
                              icon: Icons.call_split_rounded,
                              label: ref.tr('wealth_split_bill_title'),
                              onTap: () => openAppPopup(
                                context,
                                const WealthSplitBillScreen(),
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
            const SizedBox(height: 16),
            // Bao cao tach rieng khoi luoi "Quan ly" (khac ban chat - day la
            // man TONG HOP/phan tich, khong phai 1 hanh dong quan ly nhu Vi/
            // Chi tieu/No...) - theo yeu cau nguoi dung, cung giup tile noi
            // bat hon thay vi lan trong luoi icon nho.
            GestureDetector(
              onTap: () => openAppPopup(context, const WealthReportScreen()),
              child: GlowBox(
                borderRadius: 22,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.wealthAccent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.wealthAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        ref.tr('wealth_report_title'),
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
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

/// 1 the trong carousel tong tai san (Vi/Dau tu) o dau man Home - vien+goc
/// bo tron dung ClipRRect (khong phai GlowBox) de [footer] co the ke SAT
/// canh duoi, phu het chieu rong voi mau nen khac 1 chut (giong mau tham
/// khao nguoi dung gui: dai "SINH LỜI MỖI NGÀY >" o day the).
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.title,
    required this.value,
    required this.hidden,
    required this.onToggleHidden,
    required this.footer,
    required this.onTap,
    this.pnl,
    this.pnlPercent,
  });
  final String title;
  final double? value;
  final bool hidden;
  final VoidCallback onToggleHidden;
  final Widget footer;
  final VoidCallback onTap;
  final double? pnl;
  final double? pnlPercent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vung bam mo man Vi/Dau tu CHI boc tieu de+so tien+PNL
                  // (KHONG boc ca icon mat) - de tranh 2 GestureDetector long
                  // nhau cung nhan 1 lan cham (Flutter kich hoat CA HAI onTap
                  // khi chong nhau truc tiep), khien bam vao mat vua an/hien
                  // so tien VUA mo luon man chi tiet ngoai y muon.
                  Expanded(
                    child: GestureDetector(
                      onTap: onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.muted(size: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hidden
                                ? '•••••••'
                                : (value == null ? '...' : formatVnd(value!)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading(size: 21),
                          ),
                          if (!hidden && pnl != null && pnl != 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${pnl! >= 0 ? '+' : ''}${formatVnd(pnl!)}'
                              '${pnlPercent == null ? '' : ' (${pnlPercent! >= 0 ? '+' : ''}${pnlPercent!.toStringAsFixed(1)}%)'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                size: 11.5,
                                weight: FontWeight.w700,
                                color: pnl! >= 0
                                    ? AppColors.teal
                                    : AppColors.pink,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleHidden,
                    child: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.wealthAccent,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }
}

/// Dai hanh dong dinh o day 1 [_TotalCard] - 1 muc (vd "Xem chi tiet Vi") de
/// full-width, hoac 2 muc (vd "Market" | "Theo doi") chia doi bang 1 duong
/// ke doc o giua - moi muc co nhan + chevron, giong dai "SINH LỜI MỖI NGÀY >"
/// trong anh tham khao nguoi dung gui.
class _CardFooterRow extends StatelessWidget {
  const _CardFooterRow({required this.items});
  final List<(IconData, String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 18, color: AppColors.glassBorder),
            Expanded(
              child: InkWell(
                onTap: items[i].$3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].$1,
                        size: 14,
                        color: AppColors.wealthAccent,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          items[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AppColors.wealthAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
