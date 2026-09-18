import 'dart:ui' as ui;

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
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_report_data.dart';
import '../data/wealth_transaction_model.dart';
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
    return WealthDesignBackground(
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
              // The "Tin nhan" rieng da BO theo yeu cau - tin nhan van vao
              // duoc bang nut chat tren thanh dau man (co cham bao chua doc).
              SizedBox(
                height: 178,
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
              _OverviewCard(
                onTap: () => openAppPopup(context, const WealthReportScreen()),
              ),
              const SizedBox(height: 14),
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
                      // Nut "Xem tat ca" dang vien vang bo tron - ban thiet ke
                      // chot dung nut nay thay cho moi dau mui ten nho.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.wealthAccent.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ref.tr('wealth_home_report_all'),
                              style: AppTextStyles.body(
                                size: 10,
                                weight: FontWeight.w800,
                                color: AppColors.wealthAccent,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: AppColors.wealthAccent,
                            ),
                          ],
                        ),
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

/// The "Tong quan tai chinh" theo ban thiet ke chot - duong bieu dien 6 thang
/// gan nhat + 2 o Thu nhap/Chi tieu cua thang nay.
///
/// KHONG co so lieu bia: tat ca tinh tu chinh du lieu man Bao cao dang dung
/// (wealthTransactionsProvider + walletBalanceEntriesProvider, qua cac ham
/// thuan trong wealth_report_data.dart), nen 2 man luon khop nhau. "Thu nhap"
/// lay tu tien THAT vao Vi chu khong phai tab Thu nhap tu khai bao - xem giai
/// thich trong computeMonthlyWalletInflow.
class _OverviewCard extends ConsumerWidget {
  const _OverviewCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions =
        ref.watch(wealthTransactionsProvider).valueOrNull ??
        const <WealthTransaction>[];
    final entries =
        ref.watch(walletBalanceEntriesProvider).valueOrNull ??
        const <WealthBalanceEntry>[];

    // Chi doi ty gia khi thuc su co khoan USD - tranh bat 1 request mang
    // khong can thiet ngay khi mo Home.
    final hasUsd =
        transactions.any((t) => t.currency == 'USD') ||
        entries.any((e) => e.currency == 'USD');
    final usdVnd = hasUsd
        ? ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd
        : null;

    final now = DateTime.now();
    final months = lastNMonths(DateTime(now.year, now.month, 1), 6);
    final nets = <double>[];
    for (final m in months) {
      final expense = computeMonthlyTotals(
        transactions,
        m,
        usdVnd: usdVnd,
      ).expense;
      final income = computeMonthlyWalletInflow(entries, m, usdVnd: usdVnd);
      nets.add(income - expense);
    }

    final thisMonth = months.last;
    final prevMonth = months[months.length - 2];
    final income = computeMonthlyWalletInflow(
      entries,
      thisMonth,
      usdVnd: usdVnd,
    );
    final prevIncome = computeMonthlyWalletInflow(
      entries,
      prevMonth,
      usdVnd: usdVnd,
    );
    final expense = computeMonthlyTotals(
      transactions,
      thisMonth,
      usdVnd: usdVnd,
    ).expense;
    final prevExpense = computeMonthlyTotals(
      transactions,
      prevMonth,
      usdVnd: usdVnd,
    ).expense;

    final hasData = nets.any((n) => n != 0);

    return GestureDetector(
      onTap: onTap,
      child: _GoldCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const _GoldIconPad(icon: Icons.insights_rounded, size: 38),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ref.tr('wealth_home_overview_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ref.tr('wealth_home_overview_sub'),
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
              ],
            ),
            const SizedBox(height: 12),
            if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  ref.tr('wealth_home_overview_empty'),
                  style: AppTextStyles.body(
                    size: 10.5,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 58,
                width: double.infinity,
                child: CustomPaint(painter: _SparklinePainter(nets)),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: ref.tr('wealth_tab_income'),
                    value: income,
                    previous: prevIncome,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: ref.tr('wealth_tab_expense'),
                    value: expense,
                    previous: prevExpense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 o so lieu trong [_OverviewCard] - so tien thang nay + % lech so voi
/// thang truoc (xanh mui ten len / do mui ten xuong).
class _StatChip extends ConsumerWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.previous,
  });
  final String label;
  final double value;
  final double previous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Thang truoc bang 0 thi khong co goc de tinh % (chia cho 0) - an phan
    // tram di thay vi hien 1 con so vo nghia kieu "+100%".
    final percent = previous == 0 ? null : (value - previous) / previous * 100;
    final up = (percent ?? 0) >= 0;
    final color = up ? AppColors.teal : AppColors.pink;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.wealthAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(
              size: 9.5,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatVnd(value),
              maxLines: 1,
              style: AppTextStyles.heading(size: 14),
            ),
          ),
          if (percent != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  up
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 11,
                  color: color,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${up ? '+' : ''}${percent.toStringAsFixed(0)}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 9.5,
                      weight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Duong bieu dien gon (khong truc, khong nhan) cho 6 thang gan nhat.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var min = values.reduce((a, b) => a < b ? a : b);
    var max = values.reduce((a, b) => a > b ? a : b);
    // Moi thang bang nhau -> khoang gia tri = 0, chia se ra vo cuc; noi rong
    // ra 1 chut de duong nam giua khung thay vi dinh sat canh tren.
    if (max - min < 1) {
      min -= 1;
      max += 1;
    }

    final dx = size.width / (values.length - 1);
    double yOf(double v) => size.height - (v - min) / (max - min) * size.height;
    final points = [
      for (var i = 0; i < values.length; i++) Offset(i * dx, yOf(values[i])),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    // To mo phan duoi duong cho giong ban thiet ke.
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, size.height), [
          AppColors.wealthAccent.withValues(alpha: 0.22),
          AppColors.wealthAccent.withValues(alpha: 0),
        ]),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.wealthAccent,
    );
    for (final p in points) {
      canvas.drawCircle(p, 2.2, Paint()..color = AppColors.wealthAccent);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
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
                      // Ten muc mau VANG (ban thiet ke chot) - truoc day de
                      // trang nen luoi 4 the nhin giong man Hoc Tieng Anh.
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 13)
                            .copyWith(color: AppColors.wealthAccent),
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
          // Ban thiet ke chot: the la nen DEN SAU voi vien vang mong, KHONG
          // phai khoi vang dac - anh dong xu vang o nua phai va con so mau
          // vang moi la diem nhan. Truoc day to gradient vang len ca the lam
          // man hinh bi "chay vang" khac han thiet ke.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0B06), Color(0xFF060505)],
          ),
          border: Border.all(
            color: AppColors.wealthAccent.withValues(alpha: 0.45),
          ),
        ),
        child: Stack(
          children: [
            // Anh dong xu vang neo o canh phai, mo dan ve trai de khong cat
            // ngang chu - dung ShaderMask thay vi de anh vuong goc nhu cu.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 168,
              child: IgnorePointer(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x00000000), Color(0xFF000000)],
                    stops: [0.0, 0.45],
                  ).createShader(rect),
                  child: Image.asset(
                    'assets/wealth/home_coins.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // max + Spacer: dai hanh dong luon dinh SAT DAY the du so tien
            // dai ngan the nao - truoc day the cao co dinh 146 con noi dung
            // tu do nen bi tran (vach soc vang-den) o cuoi.
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Chua chu hep lai (le phai 150) de khong chay de len anh
                // dong xu ben phai - dai hanh dong ben duoi van full-width.
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 150, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon con mat nam NGAY CANH tieu de nhu ban thiet ke,
                      // nhung van la GestureDetector RIENG nam ngoai vung bam
                      // mo man chi tiet - neu long nhau thi 1 lan cham se kich
                      // hoat CA HAI (an/hien so tien VA mo man), loi cu da gap.
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: onTap,
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.muted(size: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          GestureDetector(
                            onTap: onToggleHidden,
                            child: Icon(
                              hidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.wealthAccent,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // So tien mau VANG - diem nhan chinh cua ban
                            // thiet ke (truoc day de trang nen the trong nhat).
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                hidden
                                    ? '•••••••'
                                    : (value == null
                                          ? '...'
                                          : formatVnd(value!)),
                                maxLines: 1,
                                style: AppTextStyles.heading(size: 25)
                                    .copyWith(color: AppColors.wealthAccent),
                              ),
                            ),
                            if (!hidden && pnl != null && pnl != 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    pnl! >= 0
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    size: 14,
                                    color: pnl! >= 0
                                        ? AppColors.teal
                                        : AppColors.pink,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
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
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                footer,
              ],
            ),
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
