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
    final categoryTotals = allTime
        ? computeAllTimeExpenseByCategory(transactions, usdVnd: usdVnd)
        : computeExpenseByCategory(transactions, month, usdVnd: usdVnd);
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
          const SizedBox(height: 16),
          // Chi tieu theo danh muc + Dich vu dinh ky dat CHUNG 1 hang (moi
          // ben 1 nua be rong) thay vi 2 card day du rieng biet nhu truoc -
          // ca 2 deu da thu gon noi dung (bieu do/danh sach) de vua khung
          // hep hon (xem doc rieng trong tung card).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CategoryBreakdownCard(categoryTotals: categoryTotals),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RecurringServiceCard(
                    thisTotal: thisRenewalTotal,
                    prevTotal: prevRenewalTotal,
                    showDelta: !allTime,
                    months: months,
                    renewalByMonth: renewalByMonth,
                    history: sortedRenewals,
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
            ref.tr(
              showDelta
                  ? 'wealth_report_income_expense_title'
                  : 'wealth_report_income_expense_title_all_time',
            ),
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
                    if (showDelta) ...[
                      const SizedBox(height: 3),
                      _DeltaLabel(
                        current: income,
                        previous: prevIncome,
                        higherIsBad: false,
                      ),
                    ],
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
                    if (showDelta) ...[
                      const SizedBox(height: 3),
                      _DeltaLabel(
                        current: expense,
                        previous: prevExpense,
                        higherIsBad: true,
                      ),
                    ],
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
            style: AppTextStyles.heading(size: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
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
            // Bieu do tron thu gon lai (140 -> 96, ban kinh cung giam theo)
            // so voi truoc de card nay ngan bot, giup cac card duoi (Dich
            // vu dinh ky...) hien ra gan hon khi cuon, khong doi du lieu -
            // chi thu nho phan bieu do.
            SizedBox(
              height: 96,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 24,
                  sections: [
                    for (var i = 0; i < sortedEntries.length; i++)
                      PieChartSectionData(
                        value: sortedEntries[i].value,
                        color: _kCategoryColors[i % _kCategoryColors.length],
                        radius: 24,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Bo icon danh muc (trung lap voi cham mau) + gop so tien/% vao
            // 1 cot doc ben phai - the nay gio dung chung 1 hang voi the
            // Dich vu dinh ky (chi bang nua be rong man hinh) nen phai rut
            // gon moi dong xuong con: cham mau + ten danh muc (1 dong,
            // rut gon neu dai) + so tien/% xep doc ben phai.
            for (var i = 0; i < sortedEntries.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
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
                        ref.tr(sortedEntries[i].key.labelKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          size: 11,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatVnd(sortedEntries[i].value),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            size: 11,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${(sortedEntries[i].value / total * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.muted(size: 9.5),
                        ),
                      ],
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
    final lang = ref.watch(appLanguageProvider);
    final maxY = renewalByMonth.fold<double>(0, (m, v) => v > m ? v : m);
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_report_service_title'),
            style: AppTextStyles.heading(size: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            formatVnd(thisTotal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(
              size: 14,
              weight: FontWeight.w800,
              color: AppColors.wealthAccent,
            ),
          ),
          if (showDelta) ...[
            const SizedBox(height: 3),
            _DeltaLabel(
              current: thisTotal,
              previous: prevTotal,
              higherIsBad: true,
            ),
          ],
          const SizedBox(height: 12),
          // Bieu do xu huong + danh sach lich su renew duoi day deu THU
          // GON lai (thap hon, it nhan truc, gioi han so dong hien) so voi
          // truoc - card nay gio dung CHUNG 1 hang voi the Chi tieu theo
          // danh muc (chi bang nua be rong man hinh) thay vi 1 card rieng
          // day du nhu cu.
          SizedBox(
            height: 64,
            child: maxY <= 0
                ? Center(
                    child: Text(
                      ref.tr('wealth_report_no_data'),
                      style: AppTextStyles.muted(size: 10),
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
                            reservedSize: 18,
                            interval: (months.length / 4)
                                .clamp(1, double.infinity)
                                .ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
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
                            barRods: [
                              BarChartRodData(
                                toY: renewalByMonth[i],
                                color: AppColors.wealthAccent,
                                width: months.length > 8 ? 5 : 9,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            ref.tr('wealth_report_renewal_history_title'),
            style: AppTextStyles.body(size: 11.5, weight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          if (history.isEmpty)
            Text(
              ref.tr('wealth_report_no_data'),
              style: AppTextStyles.muted(size: 10),
            )
          else ...[
            // Chi hien toi da _kMaxCompactHistory muc de danh sach khong
            // qua dai trong the hep - con lai nhac qua 1 dong "+N khac".
            for (final r in history.take(_kMaxCompactHistory))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.serviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 11,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${r.occurredAt.day.toString().padLeft(2, '0')}/'
                            '${r.occurredAt.month.toString().padLeft(2, '0')}/'
                            '${r.occurredAt.year}',
                            style: AppTextStyles.muted(size: 9.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatByCurrency(r.amount, r.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        size: 11,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
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
    );
  }
}

/// So dong lich su renew toi da hien trong the "Dich vu dinh ky" - the nay
/// gio dung CHUNG 1 hang voi the Chi tieu theo danh muc (chi bang nua be
/// rong man hinh) nen phai gioi han, khong danh sach se qua dai/lam lech
/// chieu cao 2 the trong cung 1 hang.
const _kMaxCompactHistory = 4;
