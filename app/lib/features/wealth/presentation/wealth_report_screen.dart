import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/recurring_service_model.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_custom_category_model.dart';
import '../data/wealth_report_data.dart';
import '../data/wealth_transaction_model.dart';

const _kTrendMonths = 6;

const _monthNamesVi = [
  'Th 1',
  'Th 2',
  'Th 3',
  'Th 4',
  'Th 5',
  'Th 6',
  'Th 7',
  'Th 8',
  'Th 9',
  'Th 10',
  'Th 11',
  'Th 12',
];
const _monthNamesEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _shortMonthLabel(DateTime d, AppLanguage lang) =>
    (lang == AppLanguage.en ? _monthNamesEn : _monthNamesVi)[d.month - 1];

String _fullMonthLabel(DateTime d, AppLanguage lang) => lang == AppLanguage.en
    ? '${_monthNamesEn[d.month - 1]} ${d.year}'
    : '${_monthNamesVi[d.month - 1]}, ${d.year}';

/// Mau cho cac muc trong bieu do tron chi tieu theo danh muc (theo thu tu
/// so tien giam dan) - them mau cho danh muc tuy chinh, chi lap lai khi co
/// hon 12 danh muc.
const _kCategoryColors = [
  Color(0xFFFF6B9D), // pink
  Color(0xFF5B8CFF), // blue
  Color(0xFFFFB23C), // amber
  Color(0xFF5BE0D0), // teal
  Color(0xFF9B6BFF), // purple
  Color(0xFFD4AF37), // gold
  Color(0xFFF0883D), // orange
  Color(0xFF7ED957), // green
  Color(0xFFE05BD0), // magenta
  Color(0xFF4FC3F7), // sky
  Color(0xFFC0835A), // brown
  Color(0xFF8B93A7), // gray
];

/// Man "Bao cao" cua Quan ly tai san - bieu do so sanh Thu/Chi theo thang,
/// phan loai chi tieu theo danh muc, va rieng Dich vu dinh ky: tong renew
/// thang nay so voi thang truoc + lich su renew day du. Du lieu tong hop
/// PHIA CLIENT tu wealthTransactionsProvider/serviceRenewalsProvider (dung
/// tinh than "Phase 1 don gian" da co, khong them bang/RPC moi) - xem
/// wealth_report_data.dart cho cac ham tinh toan thuan.
class WealthReportScreen extends ConsumerStatefulWidget {
  const WealthReportScreen({super.key});

  @override
  ConsumerState<WealthReportScreen> createState() => _WealthReportScreenState();
}

class _WealthReportScreenState extends ConsumerState<WealthReportScreen> {
  late DateTime _month;
  // Che do xem "Tat ca" - gop TOAN BO lich su thay vi loc theo 1 thang cu
  // the (_month). Bam mui ten < > chuyen thang se TU DONG tat che do nay
  // (xem _changeMonth) vi luc do nguoi dung ro rang muon quay lai xem theo
  // tung thang.
  bool _allTime = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int delta) {
    final total = _month.year * 12 + (_month.month - 1) + delta;
    setState(() {
      _month = DateTime(total ~/ 12, total % 12 + 1, 1);
      _allTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(wealthTransactionsProvider);
    final renewalsAsync = ref.watch(serviceRenewalsProvider);
    final balanceEntriesAsync = ref.watch(walletBalanceEntriesProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                    ref.tr('wealth_report_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeMonth(-1),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _fullMonthLabel(_month, ref.watch(appLanguageProvider)),
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _changeMonth(1),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.wealthAccent,
                    ),
                  ),
                  const Spacer(),
                  // Bam vao de xem tong CONG DON toan bo lich su thay vi
                  // loc theo 1 thang cu the - bam lai (hoac bam < >) de
                  // quay ve xem theo tung thang (xem _changeMonth).
                  GestureDetector(
                    onTap: () => setState(() => _allTime = !_allTime),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _allTime
                            ? AppColors.wealthAccent.withValues(alpha: 0.22)
                            : AppColors.glassFill,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _allTime
                              ? AppColors.wealthAccent
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        ref.tr('wealth_report_all_time'),
                        style: AppTextStyles.body(
                          size: 11.5,
                          weight: FontWeight.w700,
                          color: _allTime
                              ? AppColors.wealthAccent
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('wealth_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (transactions) => renewalsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.wealthAccent,
                    ),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      ref.tr('wealth_load_error'),
                      style: AppTextStyles.muted(),
                    ),
                  ),
                  data: (renewals) => balanceEntriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.wealthAccent,
                      ),
                    ),
                    error: (_, _) => Center(
                      child: Text(
                        ref.tr('wealth_load_error'),
                        style: AppTextStyles.muted(),
                      ),
                    ),
                    data: (balanceEntries) => _ReportBody(
                      month: _month,
                      allTime: _allTime,
                      transactions: transactions,
                      renewals: renewals,
                      balanceEntries: balanceEntries,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({
    required this.month,
    required this.allTime,
    required this.transactions,
    required this.renewals,
    required this.balanceEntries,
  });

  final DateTime month;
  // Che do xem "Tat ca" (xem WealthReportScreen._allTime) - cac tong hop
  // duoi day gop TOAN BO lich su thay vi loc theo [month], va khong con so
  // sanh "vs thang truoc" (khong co y nghia khi da la tong cong don).
  final bool allTime;
  final List<WealthTransaction> transactions;
  final List<ServiceRenewalRecord> renewals;
  final List<WealthBalanceEntry> balanceEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUsd =
        transactions.any((t) => t.currency == 'USD') ||
        renewals.any((r) => r.currency == 'USD') ||
        balanceEntries.any((e) => e.currency == 'USD');
    double? usdVnd;
    if (hasUsd) {
      final vnAssets = ref.watch(wealthVnAssetsProvider);
      if (vnAssets.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.wealthAccent),
        );
      }
      usdVnd = vnAssets.valueOrNull?.usdVnd;
    }

    final months = allTime
        ? allMonthsRange(transactions, balanceEntries, renewals)
        : lastNMonths(month, _kTrendMonths);
    final prevMonth = DateTime(month.year, month.month - 1, 1);

    final thisExpense = allTime
        ? computeAllTimeTotals(transactions, usdVnd: usdVnd).expense
        : computeMonthlyTotals(transactions, month, usdVnd: usdVnd).expense;
    final prevExpense = allTime
        ? 0.0
        : computeMonthlyTotals(transactions, prevMonth, usdVnd: usdVnd).expense;
    // "Thu nhap" lay tu tien THAT vao Cash/Ngan hang (moi dong balance_entries
    // duong), KHONG lay tu wealth_transactions.type=income (tab Thu nhap) -
    // nguoi dung phai tu khai bao rieng va de quen cap nhat, khien so lech
    // voi tien thuc te nhan duoc (xem wealth_report_data.dart).
    final thisIncome = allTime
        ? computeAllTimeWalletInflow(balanceEntries, usdVnd: usdVnd)
        : computeMonthlyWalletInflow(balanceEntries, month, usdVnd: usdVnd);
    final prevIncome = allTime
        ? 0.0
        : computeMonthlyWalletInflow(balanceEntries, prevMonth, usdVnd: usdVnd);
    final customCategories =
        ref.watch(wealthCustomCategoriesProvider).valueOrNull ??
        const <WealthCustomCategory>[];
    // Chua tai xong danh sach danh muc tuy chinh -> khong kiem tra (null),
    // tranh lo gop tam cac danh muc do vao "Khac" roi nhay lai.
    final customIds = ref.watch(wealthCustomCategoriesProvider).hasValue
        ? customCategories.map((c) => c.id).toSet()
        : null;
    final categoryTotals = allTime
        ? computeAllTimeExpenseByCategory(
            transactions,
            usdVnd: usdVnd,
            customCategoryIds: customIds,
          )
        : computeExpenseByCategory(
            transactions,
            month,
            usdVnd: usdVnd,
            customCategoryIds: customIds,
          );
    final thisRenewalTotal = allTime
        ? computeAllTimeServiceRenewalTotal(renewals, usdVnd: usdVnd)
        : computeMonthlyServiceRenewalTotal(renewals, month, usdVnd: usdVnd);
    final prevRenewalTotal = allTime
        ? 0.0
        : computeMonthlyServiceRenewalTotal(
            renewals,
            prevMonth,
            usdVnd: usdVnd,
          );

    final incomeByMonth = [
      for (final m in months)
        computeMonthlyWalletInflow(balanceEntries, m, usdVnd: usdVnd),
    ];
    final expenseByMonth = [
      for (final m in months)
        computeMonthlyTotals(transactions, m, usdVnd: usdVnd).expense,
    ];
    final renewalByMonth = [
      for (final m in months)
        computeMonthlyServiceRenewalTotal(renewals, m, usdVnd: usdVnd),
    ];

    final sortedRenewals = List<ServiceRenewalRecord>.from(renewals)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IncomeExpenseCard(
            income: thisIncome,
            expense: thisExpense,
            prevIncome: prevIncome,
            prevExpense: prevExpense,
            showDelta: !allTime,
            months: months,
            incomeByMonth: incomeByMonth,
            expenseByMonth: expenseByMonth,
          ),
          // 3 the moi the 1 hang, noi dung ben trong dan NGANG (bieu do 1
          // ben, so lieu/danh sach 1 ben) va da thu gon de vua 1 man hinh.
          const SizedBox(height: 10),
          _CategoryBreakdownCard(
            categoryTotals: categoryTotals,
            customCategories: customCategories,
          ),
          const SizedBox(height: 10),
          _RecurringServiceCard(
            thisTotal: thisRenewalTotal,
            prevTotal: prevRenewalTotal,
            showDelta: !allTime,
            months: months,
            renewalByMonth: renewalByMonth,
            history: sortedRenewals,
          ),
        ],
      ),
    );
  }
}

/// Chenh lech % giua 2 gia tri - null neu khong the tinh (ca 2 deu 0).
double? _percentDelta(double current, double previous) {
  if (previous == 0) return null;
  return (current - previous) / previous * 100;
}

class _DeltaLabel extends ConsumerWidget {
  const _DeltaLabel({
    required this.current,
    required this.previous,
    required this.higherIsBad,
  });

  final double current;
  final double previous;

  /// true = tang la xau (chi tieu/renew tang), false = tang la tot (thu
  /// nhap tang) - quyet dinh mau pink/teal.
  final bool higherIsBad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = _percentDelta(current, previous);
    if (percent == null) {
      return Text(
        ref.tr('wealth_report_no_previous_data'),
        style: AppTextStyles.muted(size: 10.5),
      );
    }
    final increased = percent >= 0;
    final bad = increased == higherIsBad;
    final color = bad ? AppColors.pink : AppColors.teal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          increased ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '${percent.abs().toStringAsFixed(1)}% ${ref.tr('wealth_report_vs_last_month')}',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

/// Padding + bo goc chung cho ca 3 the bao cao - gon hon mac dinh cua
/// GlowBox de 3 the vua 1 man hinh.
const _kCardPadding = EdgeInsets.fromLTRB(14, 12, 14, 12);
const _kCardRadius = 18.0;

Widget _cardTitle(String text) => Text(
  text,
  style: AppTextStyles.heading(size: 13),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
);

/// Bieu do cot theo thang dung chung cho the Thu/Chi va Dich vu dinh ky -
/// moi phan tu [series] la 1 day gia tri (cung do dai [months]) + mau cot.
class _MonthBarChart extends ConsumerWidget {
  const _MonthBarChart({
    required this.months,
    required this.series,
    required this.height,
  });

  final List<DateTime> months;
  final List<(List<double>, Color)> series;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final maxY = series
        .expand((s) => s.$1)
        .fold<double>(0, (m, v) => v > m ? v : m);
    final rodWidth = months.length > 8 ? 4.0 : (series.length > 1 ? 6.0 : 9.0);
    return SizedBox(
      height: height,
      child: maxY <= 0
          ? Center(
              child: Text(
                ref.tr('wealth_report_no_data'),
                style: AppTextStyles.muted(size: 10),
              ),
            )
          : BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                // Mac dinh fl_chart hien so THO khong dinh dang (vd
                // "6175036.0") khi giu tay tren 1 cot - dinh dang lai bang
                // formatVnd() giong moi noi khac hien tien trong app.
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          formatVnd(rod.toY),
                          const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 16,
                      interval: (months.length / 6)
                          .clamp(1, double.infinity)
                          .ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            _shortMonthLabel(months[i], lang),
                            style: AppTextStyles.muted(size: 8.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < months.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        for (final (values, color) in series)
                          BarChartRodData(
                            toY: values[i],
                            color: color,
                            width: rodWidth,
                            borderRadius: BorderRadius.circular(3),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

/// 1 so lieu (nhan + so tien + % so voi thang truoc) - dung trong cot trai
/// cua the Thu/Chi va Dich vu dinh ky.
class _Figure extends ConsumerWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.color,
    required this.showDelta,
    required this.previous,
    required this.higherIsBad,
  });

  final String label;
  final double value;
  final Color color;
  final bool showDelta;
  final double previous;
  final bool higherIsBad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted(size: 10.5)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatVnd(value),
            style: AppTextStyles.body(
              size: 14,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        if (showDelta)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _DeltaLabel(
              current: value,
              previous: previous,
              higherIsBad: higherIsBad,
            ),
          ),
      ],
    );
  }
}

/// The Thu/Chi - bo cuc NGANG: so lieu Thu nhap/Chi tieu xep doc ben trai,
/// bieu do cot theo thang ben phai.
class _IncomeExpenseCard extends ConsumerWidget {
  const _IncomeExpenseCard({
    required this.income,
    required this.expense,
    required this.prevIncome,
    required this.prevExpense,
    required this.showDelta,
    required this.months,
    required this.incomeByMonth,
    required this.expenseByMonth,
  });

  final double income;
  final double expense;
  final double prevIncome;
  final double prevExpense;
  // false o che do "Tat ca" (xem WealthReportScreen._allTime) - so sanh "vs
  // thang truoc" khong co y nghia khi da la tong cong don ca lich su.
  final bool showDelta;
  final List<DateTime> months;
  final List<double> incomeByMonth;
  final List<double> expenseByMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      padding: _kCardPadding,
      borderRadius: _kCardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            ref.tr(
              showDelta
                  ? 'wealth_report_income_expense_title'
                  : 'wealth_report_income_expense_title_all_time',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Figure(
                      label: ref.tr('wealth_tab_income'),
                      value: income,
                      color: AppColors.teal,
                      showDelta: showDelta,
                      previous: prevIncome,
                      higherIsBad: false,
                    ),
                    const SizedBox(height: 8),
                    _Figure(
                      label: ref.tr('wealth_tab_expense'),
                      value: expense,
                      color: AppColors.pink,
                      showDelta: showDelta,
                      previous: prevExpense,
                      higherIsBad: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _MonthBarChart(
                  months: months,
                  height: 96,
                  series: [
                    (incomeByMonth, AppColors.teal),
                    (expenseByMonth, AppColors.pink),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// So danh muc hien san trong chu giai the Chi tieu theo danh muc - con lai
/// gom vao 1 dong "+N muc khac" bam de xem day du (giu 3 the vua 1 man).
const _kCategoryPreviewCount = 4;

/// The Chi tieu theo danh muc - bo cuc NGANG: bieu do tron ben trai, chu
/// giai (ten + so tien + %) ben phai.
class _CategoryBreakdownCard extends ConsumerStatefulWidget {
  const _CategoryBreakdownCard({
    required this.categoryTotals,
    required this.customCategories,
  });

  /// Ma danh muc -> tong tien (xem computeExpenseByCategory) - gom ca danh
  /// muc tuy chinh thanh muc rieng.
  final Map<String, double> categoryTotals;
  final List<WealthCustomCategory> customCategories;

  @override
  ConsumerState<_CategoryBreakdownCard> createState() =>
      _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState
    extends ConsumerState<_CategoryBreakdownCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.categoryTotals.values.fold<double>(0, (s, v) => s + v);
    final sortedEntries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final hidden = sortedEntries.length - _kCategoryPreviewCount;
    final visibleCount = _expanded || hidden <= 0
        ? sortedEntries.length
        : _kCategoryPreviewCount;

    return GlowBox(
      padding: _kCardPadding,
      borderRadius: _kCardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(ref.tr('wealth_report_category_title')),
          const SizedBox(height: 8),
          if (total <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  ref.tr('wealth_report_no_data'),
                  style: AppTextStyles.muted(size: 11),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 22,
                      sections: [
                        for (var i = 0; i < sortedEntries.length; i++)
                          PieChartSectionData(
                            value: sortedEntries[i].value,
                            color:
                                _kCategoryColors[i % _kCategoryColors.length],
                            radius: 20,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < visibleCount; i++)
                        _legendRow(i, sortedEntries[i], total),
                      if (hidden > 0)
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                _expanded
                                    ? ref.tr('wealth_report_show_less')
                                    : ref
                                          .tr(
                                            'wealth_report_renewal_history_more',
                                          )
                                          .replaceFirst('{n}', '$hidden'),
                                style: AppTextStyles.body(
                                  size: 10.5,
                                  weight: FontWeight.w700,
                                  color: AppColors.wealthAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legendRow(int i, MapEntry<String, double> entry, double total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _kCategoryColors[i % _kCategoryColors.length],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              resolveExpenseCategoryDisplay(
                ref,
                entry.key,
                widget.customCategories,
              ).$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 11, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formatVnd(entry.value),
            style: AppTextStyles.body(size: 11, weight: FontWeight.w700),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${(entry.value / total * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.muted(size: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Dich vu dinh ky - bo cuc NGANG: tong renew + bieu do cot nho ben
/// trai, vai lan renew gan nhat ben phai.
class _RecurringServiceCard extends ConsumerWidget {
  const _RecurringServiceCard({
    required this.thisTotal,
    required this.prevTotal,
    required this.showDelta,
    required this.months,
    required this.renewalByMonth,
    required this.history,
  });

  final double thisTotal;
  final double prevTotal;
  final bool showDelta;
  final List<DateTime> months;
  final List<double> renewalByMonth;
  final List<ServiceRenewalRecord> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      padding: _kCardPadding,
      borderRadius: _kCardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(ref.tr('wealth_report_service_title')),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Figure(
                      label: ref.tr('wealth_report_renewal_total'),
                      value: thisTotal,
                      color: AppColors.wealthAccent,
                      showDelta: showDelta,
                      previous: prevTotal,
                      higherIsBad: true,
                    ),
                    const SizedBox(height: 6),
                    _MonthBarChart(
                      months: months,
                      height: 52,
                      series: [(renewalByMonth, AppColors.wealthAccent)],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_report_renewal_history_title'),
                      style: AppTextStyles.muted(size: 10.5),
                    ),
                    const SizedBox(height: 4),
                    if (history.isEmpty)
                      Text(
                        ref.tr('wealth_report_no_data'),
                        style: AppTextStyles.muted(size: 10),
                      )
                    else ...[
                      for (final r in history.take(_kMaxCompactHistory))
                        _historyRow(r),
                      if (history.length > _kMaxCompactHistory)
                        Text(
                          ref
                              .tr('wealth_report_renewal_history_more')
                              .replaceFirst(
                                '{n}',
                                '${history.length - _kMaxCompactHistory}',
                              ),
                          style: AppTextStyles.muted(size: 10),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyRow(ServiceRenewalRecord r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${r.occurredAt.day.toString().padLeft(2, '0')}/'
              '${r.occurredAt.month.toString().padLeft(2, '0')} '
              '${r.serviceName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 10.5, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            formatByCurrency(r.amount, r.currency),
            style: AppTextStyles.body(size: 10.5, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// So dong lich su renew toi da hien trong the "Dich vu dinh ky" - con lai
/// nhac qua 1 dong "+N muc khac" (giu 3 the vua 1 man hinh).
const _kMaxCompactHistory = 3;
