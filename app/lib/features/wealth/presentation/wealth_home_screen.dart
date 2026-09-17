import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../music_player/presentation/center_media_button.dart';
import '../../music_player/presentation/home_screen.dart'
    show greetingKeyForNow;
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
  // Carousel 2 the: trang 0 = Tong Vi (Tien mat+Ngan hang, mac dinh hien, to
  // het co the), trang 1 = Tong Tai san dau tu - THAY THE nut "sync_alt"
  // bam-de-doi truoc day bang thao tac VUOT (slide) giua 2 the. The dang
  // KHONG active chi ho 1 goc nho ra ("khung" de goi y co the vuot toi) va
  // AN HAN so tien/ten (xem _TotalCard.showValue) - theo yeu cau nguoi dung:
  // the Tong Vi to hon, the Dau tu khi peek chi thay khung, khong thay so.
  late final _pageController = PageController(viewportFraction: 0.86)
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
    final investmentHidden = ref.watch(investmentPrivacyModeProvider);
    final netWorth = ref.watch(netWorthVndProvider);
    final investmentTotal = ref.watch(totalInvestmentValueVndProvider);
    final (investmentPnl, investmentPnlPercent) = ref.watch(
      investmentPnlProvider,
    );
    return HomeDesignBackground(
      glow: AppColors.wealthAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(
                greeting: '${ref.tr(greetingKeyForNow())},',
                accentColor: AppColors.wealthAccent,
                unreadCount: unread,
                onMessagesTap: () =>
                    openAppPopup(context, const ConversationsScreen()),
                trailing: GestureDetector(
                  onTap: () =>
                      openAppPopup(context, const WealthSettingsScreen()),
                  child: const TopBarIconChip(icon: Icons.settings_outlined),
                ),
              ),
              const SizedBox(height: 14),
              _MessagesCard(unread: unread),
              const SizedBox(height: 14),
              SizedBox(
                height: 146,
                child: PageView(
                  controller: _pageController,
                  // padEnds:false - mac dinh PageView TU THEM le dau/cuoi de
                  // trang dau/cuoi "can doi" nhu cac trang giua (padEnds:true),
                  // khien the Tong Vi (trang 0) bi day vao giua thay vi ap sat
                  // le trai nhu mong muon - day la nguyen nhan gay khoang
                  // trong ben trai nguoi dung bao, KHONG phai loi tinh toan
                  // viewportFraction.
                  padEnds: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _TotalCard(
                        title: ref.tr('wallet_total_assets'),
                        value: netWorth,
                        hidden: hidden,
                        showValue: _pageIndex == 0,
                        placeholderIcon: Icons.account_balance_wallet_rounded,
                        onTap: () =>
                            openAppPopup(context, const WalletScreen()),
                        onToggleHidden: () => ref
                            .read(wealthPrivacyModeProvider.notifier)
                            .toggle(),
                        footer: _CardFooterRow(
                          items: [
                            (
                              Icons.payments_rounded,
                              ref.tr('wealth_home_pay_receive'),
                              () => openAppPopup(
                                context,
                                const WealthPayScreen(),
                              ),
                            ),
                            (
                              Icons.qr_code_rounded,
                              ref.tr('wealth_home_qr_code'),
                              () =>
                                  openAppPopup(context, const WealthQrScreen()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _TotalCard(
                      title: ref.tr('wealth_investments_total'),
                      value: investmentTotal,
                      hidden: investmentHidden,
                      pnl: investmentPnl,
                      pnlPercent: investmentPnlPercent,
                      showValue: _pageIndex == 1,
                      placeholderIcon: Icons.trending_up_rounded,
                      onTap: () =>
                          openAppPopup(context, const WealthInvestmentScreen()),
                      onToggleHidden: () => ref
                          .read(investmentPrivacyModeProvider.notifier)
                          .toggle(),
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
              // 4 the quan ly xep 2x2 (truoc day 4 icon nho 1 hang trong 1
              // khung chung): the to hon nen co cho cho phu de noi ro tung muc
              // lam gi, va chu tieng Viet co dau khong con bi ep xuong dong.
              Row(
                children: [
                  Expanded(
                    child: _WealthTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: ref.tr('wealth_tab_expense'),
                      subtitle: ref.tr('wealth_home_sub_expense'),
                      onTap: () => _open(
                        context,
                        ref.tr('wealth_tab_expense'),
                        const WealthExpenseTab(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WealthTile(
                      icon: Icons.credit_card_outlined,
                      label: ref.tr('wealth_debt_title'),
                      subtitle: ref.tr('wealth_home_sub_debt'),
                      onTap: () => openAppPopup(context, const DebtScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _WealthTile(
                      icon: Icons.autorenew_rounded,
                      label: ref.tr('wealth_service_title'),
                      subtitle: ref.tr('wealth_home_sub_service'),
                      onTap: () => openAppPopup(
                        context,
                        const RecurringServicesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WealthTile(
                      icon: Icons.groups_outlined,
                      label: ref.tr('wealth_split_bill_title'),
                      subtitle: ref.tr('wealth_home_sub_split'),
                      onTap: () =>
                          openAppPopup(context, const WealthSplitBillScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bao cao tach rieng khoi luoi "Quan ly" (khac ban chat - day la
              // man TONG HOP/phan tich, khong phai 1 hanh dong quan ly nhu Vi/
              // Chi tieu/No...) - theo yeu cau nguoi dung, cung giup tile noi
              // bat hon thay vi lan trong luoi icon nho.
              GestureDetector(
                onTap: () => openAppPopup(context, const WealthReportScreen()),
                child: _GoldCard(
                  child: Row(
                    children: [
                      const _GoldIconPad(icon: Icons.description_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ref.tr('wealth_report_title'),
                              style: AppTextStyles.heading(size: 14.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('wealth_home_report_sub'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                size: 9.5,
                                weight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.wealthAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Thanh nhac chuyen tu thanh Menu duoi VAO THAN TRANG (xem
              // wealth_shell.dart): man hinh ket thuc tu nhien sau widget nay,
              // khong con thanh co dinh che noi dung.
              const CenterMediaButton(accentColor: AppColors.wealthAccent),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// The kinh tong vang cua man Quan ly tai san - vien vang mong, nen toi trong.
class _GoldCard extends StatelessWidget {
  const _GoldCard({
    required this.child,
    this.padding = const EdgeInsets.all(13),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.homeCardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.wealthAccent.withValues(alpha: 0.30),
        ),
      ),
      child: child,
    );
  }
}

/// Dem sang tron sau icon - cung ngon ngu voi man Home Hoc Tieng Anh nhung
/// am mau vang thay vi xanh.
class _GoldIconPad extends StatelessWidget {
  const _GoldIconPad({required this.icon, this.size = 40});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0, -0.06),
          colors: [
            AppColors.wealthAccent.withValues(alpha: 0.26),
            AppColors.wealthAccent.withValues(alpha: 0.20),
            AppColors.wealthAccent.withValues(alpha: 0.12),
            AppColors.wealthAccent.withValues(alpha: 0),
          ],
          stops: const [0, 0.56, 0.76, 1],
        ),
        border: Border.all(
          color: AppColors.wealthAccent.withValues(alpha: 0.24),
        ),
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.wealthAccent),
    );
  }
}

/// The "Tin nhan" - dua so tin chua doc co san (unreadMessageCountProvider)
/// len thanh 1 khoi rieng thay vi chi 1 cham do tren nut. KHONG tao nguon tin
/// nhan moi nao: bam vao van mo dung man ConversationsScreen nhu truoc.
class _MessagesCard extends ConsumerWidget {
  const _MessagesCard({required this.unread});
  final int unread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => openAppPopup(context, const ConversationsScreen()),
      child: _GoldCard(
        child: Row(
          children: [
            const _GoldIconPad(icon: Icons.chat_bubble_outline_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        ref.tr('wealth_home_messages_title'),
                        style: AppTextStyles.heading(size: 14.5),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.wealthAccent.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.wealthAccent.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: Text(
                            ref
                                .tr('wealth_home_messages_badge')
                                .replaceFirst('{n}', '$unread'),
                            style: AppTextStyles.body(
                              size: 9,
                              weight: FontWeight.w800,
                              color: AppColors.wealthAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unread > 0
                        ? ref
                              .tr('wealth_home_messages_unread')
                              .replaceFirst('{n}', '$unread')
                        : ref.tr('wealth_home_messages_none'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 9.5,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.wealthAccent,
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
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GoldCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 2),
            _GoldIconPad(icon: icon, size: 38),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          size: 9,
                          weight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                  color: AppColors.wealthAccent,
                ),
              ],
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
    required this.showValue,
    required this.placeholderIcon,
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
  // false = the nay dang chi "ho ra" 1 goc nho o canh (trang khong active
  // cua carousel) - an het so tien/ten/footer, CHI con khung (nen+vien) +
  // 1 icon lon mo nhat lam goi y "co the vuot qua day" - theo yeu cau nguoi
  // dung "chi thay khung de slide qua, khong thay so tien".
  final bool showValue;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    if (!showValue) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            border: Border.all(color: AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Icon(
            placeholderIcon,
            size: 32,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          // Nen toi pha vang dam (thay glassFill trung tinh truoc day) - lam
          // 2 the Tong Vi/Tong Dau tu noi bat theo mau chu dao vang cua muc
          // Quan ly tai san, van giu chu trang/heading de doc vi lop den lam
          // nen chinh, vang chi la sac phu.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xCC000000),
              AppColors.wealthAccent.withValues(alpha: 0.4),
            ],
          ),
          border: Border.all(
            color: AppColors.wealthAccent.withValues(alpha: 0.45),
          ),
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
