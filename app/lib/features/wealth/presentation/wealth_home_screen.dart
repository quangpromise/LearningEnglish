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
  late final _pageController = PageController(viewportFraction: 0.95)
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
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 2),
        // The Tong tai san TU GIAN de lap het cho con trong -> thanh nhac luon
        // ket thuc sat day man, khong con khoang trong thua.
        //
        // 453.8 = tong chieu cao cac khoi CON LAI, do bang bo chup
        // (tool/render): ca man cao 595.8pt khi the tong cao 142pt.
        // Lam kieu nay thi man cao bao nhieu cung tu vua, khong phai chinh
        // tay theo tung may nhu truoc.
        child: LayoutBuilder(
          builder: (context, constraints) {
            const otherContent = 453.8;
            final heroHeight = (constraints.maxHeight - otherContent).clamp(
              142.0,
              240.0,
            );
            // ClipRect + Column chiem TRON chieu cao (truoc day la
            // SingleChildScrollView khoa cuon): trong scroll view chieu cao la
            // VO HAN nen Spacer khong hoat dong, phan thua cua may man cao bi
            // don het xuong day thanh 1 mang trong duoi thanh nhac.
            return ClipRect(
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
                      child: const TopBarIconChip(
                        icon: Icons.settings_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  // The "Tin nhan" rieng da BO theo yeu cau - tin nhan van vao
                  // duoc bang nut chat tren thanh dau man (co cham bao chua doc).
                  SizedBox(
                    height: heroHeight,
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
                            placeholderIcon:
                                Icons.account_balance_wallet_rounded,
                            onTap: () =>
                                openAppPopup(context, const WalletScreen()),
                            onToggleHidden: () => ref
                                .read(wealthPrivacyModeProvider.notifier)
                                .toggle(),
                            footer: _CardFooterRow(
                              items: [
                                (
                                  'assets/wealth/ic_wallet_sm.png',
                                  Icons.payments_rounded,
                                  ref.tr('wealth_home_pay_receive'),
                                  ref.tr('wealth_home_pay_receive_sub'),
                                  () => openAppPopup(
                                    context,
                                    const WealthPayScreen(),
                                  ),
                                ),
                                (
                                  'assets/wealth/ic_qr.png',
                                  Icons.qr_code_rounded,
                                  ref.tr('wealth_home_qr_code'),
                                  ref.tr('wealth_home_qr_code_sub'),
                                  () => openAppPopup(
                                    context,
                                    const WealthQrScreen(),
                                  ),
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
                          onTap: () => openAppPopup(
                            context,
                            const WealthInvestmentScreen(),
                          ),
                          onToggleHidden: () => ref
                              .read(investmentPrivacyModeProvider.notifier)
                              .toggle(),
                          footer: _CardFooterRow(
                            items: [
                              (
                                null,
                                Icons.show_chart_rounded,
                                ref.tr('wealth_market_title'),
                                ref.tr('wealth_home_market_sub'),
                                () =>
                                    openAppPopup(context, const MarketScreen()),
                              ),
                              (
                                null,
                                Icons.star_rounded,
                                ref.tr('crypto_tab_watchlist'),
                                ref.tr('wealth_home_watchlist_sub'),
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
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 8),
                  // Spacer: chia DEU phan chieu cao thua cho cac khe giua cac
                  // khoi (thay vi de dom lai 1 cuc o day man). May vua khit
                  // thi Spacer = 0pt, bo cuc giu nguyen nhu truoc.
                  const Spacer(),
                  // 4 muc xep 1 HANG nhu anh thiet ke (truoc day 2x2): ngoai
                  // viec giong ban chot, xep 1 hang cat bot ~105pt chieu cao -
                  // day la thay doi chinh giup ca man vua DUNG 1 MAN HINH, khong
                  // phai cuon xuong moi thay het.
                  Row(
                    children: [
                      for (final t in [
                        (
                          'assets/wealth/ic_wallet.png',
                          null,
                          ref.tr('wealth_tab_expense'),
                          ref.tr('wealth_home_sub_expense'),
                          () => _open(
                            context,
                            ref.tr('wealth_tab_expense'),
                            const WealthExpenseTab(),
                          ),
                        ),
                        (
                          'assets/wealth/ic_card.png',
                          null,
                          ref.tr('wealth_debt_title'),
                          ref.tr('wealth_home_sub_debt'),
                          () => openAppPopup(context, const DebtScreen()),
                        ),
                        (
                          'assets/wealth/ic_arrows.png',
                          null,
                          ref.tr('wealth_service_title'),
                          ref.tr('wealth_home_sub_service'),
                          () => openAppPopup(
                            context,
                            const RecurringServicesScreen(),
                          ),
                        ),
                        (
                          // Quay lai anh hoa don 3D: cung chat lieu voi 3 icon
                          // con lai (khoi 3D co phoi canh, do day, anh kim).
                          // Ban mui ten chi la hieu ung vat noi tren net phang
                          // nen soi ky van lech chat.
                          'assets/wealth/ic_doc.png',
                          null,
                          ref.tr('wealth_home_tile_split'),
                          ref.tr('wealth_home_sub_split'),
                          () => openAppPopup(
                            context,
                            const WealthSplitBillScreen(),
                          ),
                        ),
                      ].indexed)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: t.$1 == 0 ? 0 : 7),
                            child: _WealthTile(
                              asset: t.$2.$1,
                              fallbackIcon: t.$2.$2,
                              label: t.$2.$3,
                              subtitle: t.$2.$4,
                              onTap: t.$2.$5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Spacer(),
                  _OverviewCard(
                    onTap: () =>
                        openAppPopup(context, const WealthReportScreen()),
                  ),
                  // The "Bao cao" rieng da BO: bam vao no mo dung man Bao cao
                  // ma the "Tong quan tai chinh" ben tren da mo, lai trung ca
                  // noi dung hien thi - de ca hai la thua.
                  const SizedBox(height: 8),
                  const Spacer(),
                  // Thanh nhac chuyen tu thanh Menu duoi VAO THAN TRANG (xem
                  // wealth_shell.dart): man hinh ket thuc tu nhien sau widget nay,
                  // khong con thanh co dinh che noi dung.
                  const CenterMediaButton(
                    accentColor: AppColors.wealthAccent,
                    discAsset: 'assets/home/ic_vinyl.png',
                  ),
                ],
              ),
            );
          },
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

    // % tong the = lech cua (thu - chi) thang nay so voi thang truoc - dung
    // cho badge o goc phai header nhu anh goc.
    final thisNet = nets.last;
    final prevNet = nets[nets.length - 2];
    final netPercent = prevNet == 0
        ? null
        : (thisNet - prevNet) / prevNet.abs() * 100;

    return GestureDetector(
      onTap: onTap,
      child: _GoldCard(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
        child: LayoutBuilder(
          builder: (context, c) {
            // Anh goc: bieu do + cac o so lieu chi chiem khoang 62% be ngang
            // ben TRAI, phan con lai danh cho khoi 3D cot vang. Truoc day ta
            // keo bieu do full-width va bo han khoi 3D nen nhin khac han.
            final leftWidth = c.maxWidth * 0.62;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Khoi 3D cot vang neo goc duoi-phai, mo dan sang trai de
                // khong lo canh anh vuong tren nen the.
                Positioned(
                  right: -4,
                  bottom: -6,
                  width: c.maxWidth * 0.36,
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0x00000000), Color(0xFF000000)],
                        stops: [0.0, 0.35],
                      ).createShader(rect),
                      child: Image.asset(
                        'assets/wealth/overview_bars.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _GoldIconPad(
                          asset: 'assets/wealth/ic_bars.png',
                          size: 38,
                        ),
                        const SizedBox(width: 10),
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
                        if (netPercent != null)
                          _TrendBadge(percent: netPercent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!hasData)
                      SizedBox(
                        width: leftWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            ref.tr('wealth_home_overview_empty'),
                            style: AppTextStyles.body(
                              size: 10,
                              weight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 50,
                        width: leftWidth,
                        child: CustomPaint(painter: _SparklinePainter(nets)),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: leftWidth,
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              label: ref.tr('wealth_tab_income'),
                              value: income,
                              previous: prevIncome,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatChip(
                              label: ref.tr('wealth_tab_expense'),
                              value: expense,
                              previous: prevExpense,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Badge "% so voi thang truoc" o goc phai header the Tong quan - vien bo
/// tron, mui ten + phan tram mau xanh (do tu anh goc: #45DFAD), dong phu xam
/// sang ben duoi.
class _TrendBadge extends ConsumerWidget {
  const _TrendBadge({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final up = percent >= 0;
    final color = up ? AppColors.wealthUp : AppColors.pink;
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(13),
        // Vien #1A2127 ~ trang 11% (khong phai 16% nhu cac the).
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 3),
              Text(
                '${up ? '+' : ''}${percent.toStringAsFixed(1)}%',
                style: AppTextStyles.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            ref.tr('wealth_report_vs_last_month'),
            style: AppTextStyles.body(
              size: 8,
              weight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
    final color = up ? AppColors.wealthUp : AppColors.pink;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        // Anh goc: long o TOI HON nen the (#05080D so voi #060D13) va vien
        // rat mo (#13181E ~ trang 7%). Ban truoc to nen SANG hon the (trang
        // 4%) va vien trang 16% - sang gap doi, nen cac o bi noi cuc len.
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
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

/// Duong bieu dien cho 6 thang gan nhat.
///
/// Cach ve do TRUC TIEP tu anh thiet ke goc (quet doc qua duong o nhieu cot):
///   - loi duong RAT MANH nhung rat sang: chi 3-4px o mat do 3.9 => ~0.9pt
///   - kem 1 QUANG SANG mo rong 16-27px => ~4-7pt (day la thu tao cam giac
///     duong "phat sang"; ban truoc ve 1 net day 1.8pt khong quang nen nhin
///     duc va bet)
///   - duoi duong co vung to vang am nhat dan: +6px #553E1C, +14px #382916,
///     +26px gan bang mau nen
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0) return;
    var min = values.reduce((a, b) => a < b ? a : b);
    var max = values.reduce((a, b) => a > b ? a : b);
    if (max - min < 1) {
      min -= 1;
      max += 1;
    }

    // Chua 5px tren/duoi de doan nam ngang khong dan sat mep khung.
    const pad = 5.0;
    final h = size.height - pad * 2;
    final dx = size.width / (values.length - 1);
    double yOf(double v) => pad + h - (v - min) / (max - min) * h;
    final points = [
      for (var i = 0; i < values.length; i++) Offset(i * dx, yOf(values[i])),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final q in points.skip(1)) {
      path.lineTo(q.dx, q.dy);
    }

    // 1. Vung to duoi duong - dam ngay duoi net roi tat nhanh.
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [
            AppColors.wealthChartLine.withValues(alpha: 0.34),
            AppColors.wealthChartLine.withValues(alpha: 0.05),
            AppColors.wealthChartLine.withValues(alpha: 0),
          ],
          [0.0, 0.45, 1.0],
        ),
    );

    // 2. Hai lop quang sang mo dan, roi 3. loi duong manh gan trang.
    for (final (width, blur, alpha) in [(3.4, 5.0, 0.30), (2.0, 2.0, 0.55)]) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
          ..color = AppColors.wealthChartLine.withValues(alpha: alpha),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFBD9),
    );

    // 4. Cham moc - nho va sang, khong to nhu ban truoc (2.2 -> 1.6).
    for (final q in points) {
      canvas.drawCircle(q, 1.6, Paint()..color = const Color(0xFFFFFDE8));
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        // Vien cung la GRADIENT nhu the Tong tai san, chi la xam->xam thay vi
        // vang->xam: do duoc canh TRAI #414449 (trang 25%) sang hon canh PHAI
        // #2A2F35 (trang 16%) va canh TREN #1E2126 toi nhat. Ban truoc dung 1
        // mau deu 4 canh nen canh trai bi thieu do sang.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.17),
            Colors.white.withValues(alpha: 0.13),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(0.7),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // PHAI la mau DUC. Lop ngoai to gradient trang phu KIN the (do la
          // cach lam vien gradient), neu lop trong con trong suot thi gradient
          // do xuyen qua va ca the xam sang len - dung loi da gap.
          // #050C12 = trung binh long the do tu anh thiet ke goc
          // (#040B11 / #05090E / #060D13 / #050D15).
          color: const Color(0xFF050C12),
          borderRadius: BorderRadius.circular(17.3),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Dem sang tron sau icon - cung ngon ngu voi man Home Hoc Tieng Anh nhung
/// am mau vang thay vi xanh.
class _GoldIconPad extends StatelessWidget {
  const _GoldIconPad({this.icon, this.asset, this.size = 40})
    : assert(icon != null || asset != null);

  final IconData? icon;

  /// Icon vang 3D cat tu chinh anh thiet ke goc. Kieu icon nay (khoi 3D co
  /// chuyen sang, do bong, vien kim loai) khong dung net vector phang cua
  /// Material ve lai duoc, nen dung thang anh - nguoi dung xac nhan anh goc
  /// la cua ho. Anh da gom san nen tron toi nen dat trong ClipOval la khop.
  final String? asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return ClipOval(
        child: Image.asset(
          asset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      );
    }
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
    required this.asset,
    required this.fallbackIcon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  /// Anh icon vang 3D cat tu ban thiet ke; null thi ve [fallbackIcon].
  final String? asset;
  final IconData? fallbackIcon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GoldCard(
        padding: const EdgeInsets.fromLTRB(9, 8, 7, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _GoldIconPad(asset: asset, icon: fallbackIcon, size: 34),
            const SizedBox(height: 8),
            // The chi con ~1/4 be ngang nen ten dung FittedBox thu nho vua
            // khung thay vi cat bang "..." - "Dich vu dinh ky" dai hon han
            // "No" nhung van phai doc duoc du.
            SizedBox(
              width: double.infinity,
              height: 13,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.heading(size: 11)
                      .copyWith(color: AppColors.wealthAccent),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 8,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 13,
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
    // Vien la GRADIENT, khong dong mau - do quanh chu vi the trong anh goc:
    //   canh TRAI  : vang sang #E7DF9B..#F4E5A0 (L ~ 220)
    //   canh PHAI  : xam toi   #2B2F34          (L ~  47)
    //   tren/duoi  : xam toi, chi sang vang o phan gan GOC TRAI
    // Ban truoc to vang sang DEU 4 canh nen 3 canh con lai qua sang. Vien
    // that chi day 1px (~0.46pt o mat do 2.156) nen dung 0.7 thay vi 1.
    // Flutter khong cho Border.all nhan gradient => dung 1 lop ngoai to
    // gradient + padding mong, lop trong la than the.
    //
    // CA THE la 1 vung bam mo man chi tiet (Vi/Dau tu): truoc day chi co
    // DUNG chu tieu de va cum so tien nhan cham, bam vao khoang trong hay
    // anh dong xu thi khong an gi - nguoi dung phai nham dung con so. Cac
    // nut CON co san ben trong (icon con mat, 2 muc o dai duoi) van giu
    // hanh dong rieng: GestureDetector long ben trong luon THANG dau truong
    // cu chi truoc cai boc ngoai, nen 1 cham chi kich hoat dung 1 cai.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFF2E8AE),
              Color(0xFFE3D393),
              Color(0xFF3A4046),
              Color(0xFF2F353B),
            ],
            stops: [0.0, 0.05, 0.22, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(0.7),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21.3),
          child: Container(
            decoration: const BoxDecoration(
              // Nen DEN SAU - anh dong xu vang o nua phai va con so mau vang moi
              // la diem nhan, than the khong phai khoi vang dac.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0B06), Color(0xFF060505)],
              ),
            ),
            // StackFit.expand + cac con deu Positioned: KHONG dung flex
            // (Spacer/Expanded) trong Stack nua. Ban truoc dung Column
            // mainAxisSize.max + Spacer o day va bi tran 99922px - Stack truyen
            // rang buoc LONG (loose) xuong con, nen Spacer khong co chieu cao huu
            // han de an theo va Column phinh ra vo han.
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Anh dong xu vang neo o canh phai, mo dan ve trai de khong cat
                // ngang chu - dung ShaderMask thay vi de anh vuong goc nhu cu.
                // bottom: 46 - anh dong xu DUNG NGAY TREN dai hanh dong, dung
                // nhu anh goc (anh ket thuc truoc dai "Nap/Rut | Ma QR"). Truoc
                // day anh phu het chieu cao the nen nam ngay sau chu, lam 2 nut
                // do rat kho doc.
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 66,
                  width: 196,
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
                // Khoi chu neo tren, dai hanh dong neo day - moi cai 1 Positioned
                // rieng thay vi 1 Column co Spacer.
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 168, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon con mat nam NGAY CANH tieu de nhu ban thiet ke.
                        // No van phai la GestureDetector RIENG (long ben trong
                        // vung bam cua ca the): cham vao mat chi an/hien so
                        // tien, KHONG mo man chi tiet.
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.muted(size: 12),
                              ),
                            ),
                            const SizedBox(width: 7),
                            GestureDetector(
                              onTap: onToggleHidden,
                              // opaque + vien dem quanh icon: ca the gio la 1
                              // vung bam mo Vi, neu icon nay chi nhan cham
                              // DUNG net ve (deferToChild) thi cham lech vai
                              // pixel se mo Vi thay vi an/hien so tien.
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  hidden
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.wealthAccent,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Column(
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
                                    .copyWith(color: AppColors.wealthAmount),
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
                                        ? AppColors.wealthUp
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
                                            ? AppColors.wealthUp
                                            : AppColors.pink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(left: 10, right: 10, bottom: 10, child: footer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dai hanh dong o day [_TotalCard] - theo anh thiet ke goc day la 1 PANEL
/// BO TRON THUT VAO trong the (khong phai 1 dai full-bleed sat mep nhu ban
/// truoc), moi muc gom icon vang + ten (chu TRANG) + mo ta + mui ten, hai muc
/// ngan cach bang 1 duong ke doc.
class _CardFooterRow extends StatelessWidget {
  const _CardFooterRow({required this.items});

  /// (duong dan icon vang hoac null, icon du phong, ten, mo ta, hanh dong)
  final List<(String?, IconData, String, String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.wealthCardBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 26,
                color: AppColors.wealthCardBorder,
              ),
            Expanded(
              child: GestureDetector(
                onTap: items[i].$5,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 7, 8),
                  child: Row(
                    children: [
                      if (items[i].$1 != null)
                        ClipOval(
                          child: Image.asset(
                            items[i].$1!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        )
                      else
                        Icon(
                          items[i].$2,
                          size: 18,
                          color: AppColors.wealthAccent,
                        ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Chu TRANG - do tu anh goc (#FFFFFF). De mau vang
                            // thi nam de len anh dong xu vang, doc khong ra.
                            Text(
                              items[i].$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                size: 11.5,
                                weight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              items[i].$4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                size: 8,
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
                        color: AppColors.textSecondary,
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
