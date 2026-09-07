import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/recurring_service_model.dart';
import '../data/wealth_category.dart';
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

/// Mau co dinh cho 8 danh muc chi tieu (WealthExpenseCategory) - du 8 mau
/// khac biet ro rang cho bieu do tron, khong trung mau nao.
const _kCategoryColors = [
  Color(0xFFFF6B9D), // pink
  Color(0xFF5B8CFF), // blue
  Color(0xFFFFB23C), // amber
  Color(0xFF5BE0D0), // teal
  Color(0xFF9B6BFF), // purple
  Color(0xFFD4AF37), // gold
  Color(0xFFF0883D), // orange
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int delta) {
    final total = _month.year * 12 + (_month.month - 1) + delta;
    setState(() => _month = DateTime(total ~/ 12, total % 12 + 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(wealthTransactionsProvider);
    final renewalsAsync = ref.watch(serviceRenewalsProvider);

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
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                  data: (renewals) => _ReportBody(
                    month: _month,
                    transactions: transactions,
                    renewals: renewals,
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
    required this.transactions,
    required this.renewals,
  });

  final DateTime month;
  final List<WealthTransaction> transactions;
  final List<ServiceRenewalRecord> renewals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUsd =
        transactions.any((t) => t.currency == 'USD') ||
        renewals.any((r) => r.currency == 'USD');
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

    final months = lastNMonths(month, _kTrendMonths);
    final prevMonth = DateTime(month.year, month.month - 1, 1);

    final thisTotals = computeMonthlyTotals(
      transactions,
      month,
      usdVnd: usdVnd,
    );
    final prevTotals = computeMonthlyTotals(
      transactions,
      prevMonth,
      usdVnd: usdVnd,
    );
    final categoryTotals = computeExpenseByCategory(
      transactions,
      month,
      usdVnd: usdVnd,
    );
    final thisRenewalTotal = computeMonthlyServiceRenewalTotal(
      renewals,
      month,
      usdVnd: usdVnd,
    );
    final prevRenewalTotal = computeMonthlyServiceRenewalTotal(
      renewals,
      prevMonth,
      usdVnd: usdVnd,
    );

    final incomeByMonth = [
      for (final m in months)
        computeMonthlyTotals(transactions, m, usdVnd: usdVnd).income,
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
            income: thisTotals.income,
            expense: thisTotals.expense,
            prevIncome: prevTotals.income,
            prevExpense: prevTotals.expense,
            months: months,
            incomeByMonth: incomeByMonth,
            expenseByMonth: expenseByMonth,
          ),
          const SizedBox(height: 16),
          _CategoryBreakdownCard(categoryTotals: categoryTotals),
          const SizedBox(height: 16),
          _RecurringServiceCard(
            thisTotal: thisRenewalTotal,
            prevTotal: prevRenewalTotal,
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

class _IncomeExpenseCard extends ConsumerWidget {
  const _IncomeExpenseCard({
    required this.income,
    required this.expense,
    required this.prevIncome,
    required this.prevExpense,
    required this.months,
    required this.incomeByMonth,
    required this.expenseByMonth,
  });

  final double income;
  final double expense;
  final double prevIncome;
  final double prevExpense;
  final List<DateTime> months;
  final List<double> incomeByMonth;
  final List<double> expenseByMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final maxY = [
      ...incomeByMonth,
      ...expenseByMonth,
    ].fold<double>(0, (m, v) => v > m ? v : m);
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_report_income_expense_title'),
            style: AppTextStyles.heading(size: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_tab_income'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatVnd(income),
                      style: AppTextStyles.body(
                        size: 15,
                        weight: FontWeight.w800,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _DeltaLabel(
                      current: income,
                      previous: prevIncome,
                      higherIsBad: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_tab_expense'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatVnd(expense),
                      style: AppTextStyles.body(
                        size: 15,
                        weight: FontWeight.w800,
                        color: AppColors.pink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _DeltaLabel(
                      current: expense,
                      previous: prevExpense,
                      higherIsBad: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: maxY <= 0
                ? Center(
                    child: Text(
                      ref.tr('wealth_report_no_data'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
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
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _shortMonthLabel(months[i], lang),
                                  style: AppTextStyles.muted(size: 9.5),
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
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: incomeByMonth[i],
                                color: AppColors.teal,
                                width: 7,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              BarChartRodData(
                                toY: expenseByMonth[i],
                                color: AppColors.pink,
                                width: 7,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends ConsumerWidget {
  const _CategoryBreakdownCard({required this.categoryTotals});
  final Map<WealthExpenseCategory, double> categoryTotals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = categoryTotals.values.fold<double>(0, (s, v) => s + v);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_report_category_title'),
            style: AppTextStyles.heading(size: 14),
          ),
          const SizedBox(height: 14),
          if (total <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  ref.tr('wealth_report_no_data'),
                  style: AppTextStyles.muted(size: 11),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 34,
                  sections: [
                    for (var i = 0; i < sortedEntries.length; i++)
                      PieChartSectionData(
                        value: sortedEntries[i].value,
                        color: _kCategoryColors[i % _kCategoryColors.length],
                        radius: 36,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < sortedEntries.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _kCategoryColors[i % _kCategoryColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      sortedEntries[i].key.icon,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ref.tr(sortedEntries[i].key.labelKey),
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatVnd(sortedEntries[i].value),
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(sortedEntries[i].value / total * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.muted(size: 11),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RecurringServiceCard extends ConsumerWidget {
  const _RecurringServiceCard({
    required this.thisTotal,
    required this.prevTotal,
    required this.months,
    required this.renewalByMonth,
    required this.history,
  });

  final double thisTotal;
  final double prevTotal;
  final List<DateTime> months;
  final List<double> renewalByMonth;
  final List<ServiceRenewalRecord> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final maxY = renewalByMonth.fold<double>(0, (m, v) => v > m ? v : m);
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_report_service_title'),
            style: AppTextStyles.heading(size: 14),
          ),
          const SizedBox(height: 10),
          Text(
            formatVnd(thisTotal),
            style: AppTextStyles.body(
              size: 15,
              weight: FontWeight.w800,
              color: AppColors.wealthAccent,
            ),
          ),
          const SizedBox(height: 3),
          _DeltaLabel(
            current: thisTotal,
            previous: prevTotal,
            higherIsBad: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: maxY <= 0
                ? Center(
                    child: Text(
                      ref.tr('wealth_report_no_data'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
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
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _shortMonthLabel(months[i], lang),
                                  style: AppTextStyles.muted(size: 9.5),
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
                            barRods: [
                              BarChartRodData(
                                toY: renewalByMonth[i],
                                color: AppColors.wealthAccent,
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr('wealth_report_renewal_history_title'),
            style: AppTextStyles.body(size: 12.5, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            Text(
              ref.tr('wealth_report_no_data'),
              style: AppTextStyles.muted(size: 11),
            )
          else
            for (final r in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.serviceName,
                            style: AppTextStyles.body(
                              size: 12.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${r.occurredAt.day.toString().padLeft(2, '0')}/'
                            '${r.occurredAt.month.toString().padLeft(2, '0')}/'
                            '${r.occurredAt.year}',
                            style: AppTextStyles.muted(size: 10.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatByCurrency(r.amount, r.currency),
                      style: AppTextStyles.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
