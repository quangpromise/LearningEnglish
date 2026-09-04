import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_debt_model.dart';
import '../data/wealth_transaction_model.dart';

/// Man Tong quan (Dashboard) - gop lai so lieu chinh cua TAT CA tinh nang
/// Quan ly tai san TRU Market va Calculator (2 cai do khong co "so lieu tich
/// luy" de tong hop): Tong tai san (hien co + dau tu + lai/lo), Chi tieu/Thu
/// nhap thang nay, Cong no 2 chieu, Dich vu dinh ky sap het han. Chi doc du
/// lieu tu cac provider da co san (khong tao bang/logic moi), giup nguoi
/// dung thay TOAN CANH ma khong phai mo tung man rieng.
enum _Period { day, week, month }

class WealthDashboardScreen extends ConsumerStatefulWidget {
  const WealthDashboardScreen({super.key});

  @override
  ConsumerState<WealthDashboardScreen> createState() =>
      _WealthDashboardScreenState();
}

class _WealthDashboardScreenState extends ConsumerState<WealthDashboardScreen> {
  _Period _period = _Period.month;

  /// Ngay bat dau cua khoang thoi gian dang chon (Ngay=hom nay 00:00, Tuan=
  /// thu Hai cua tuan chua hom nay, Thang=ngay 1 cua thang hien tai) - loc
  /// giao dich co occurredAt >= moc nay (va < ngay mai/tuan sau/thang sau).
  (DateTime, DateTime) _periodRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case _Period.day:
        return (today, today.add(const Duration(days: 1)));
      case _Period.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return (start, start.add(const Duration(days: 7)));
      case _Period.month:
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1);
        return (start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hidden = ref.watch(wealthPrivacyModeProvider);
    final netWorth = ref.watch(netWorthVndProvider);
    final investmentTotal = ref.watch(totalInvestmentValueVndProvider);
    final (investmentPnl, investmentPnlPercent) = ref.watch(
      investmentPnlProvider,
    );

    final now = DateTime.now();
    final (rangeStart, rangeEnd) = _periodRange(now);
    final transactions =
        ref.watch(wealthTransactionsProvider).valueOrNull ?? [];
    final inRange = transactions.where(
      (t) =>
          !t.occurredAt.isBefore(rangeStart) && t.occurredAt.isBefore(rangeEnd),
    );
    final expenseThisMonth = inRange
        .where((t) => t.type == WealthTransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    final incomeThisMonth = inRange
        .where((t) => t.type == WealthTransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);

    final iOweDebts = ref.watch(debtsProvider('i_owe')).valueOrNull ?? [];
    final owedToMeDebts =
        ref.watch(debtsProvider('owed_to_me')).valueOrNull ?? [];
    final totalIOwe = _sumRemainingVnd(iOweDebts);
    final totalOwedToMe = _sumRemainingVnd(owedToMeDebts);

    final services = ref.watch(recurringServicesProvider).valueOrNull ?? [];
    final expiringSoon = services.where((s) => s.isExpiringSoon).toList();
    final nearest = services.isEmpty
        ? null
        : services.reduce((a, b) => a.daysLeft < b.daysLeft ? a : b);

    String display(num v) => hidden ? '•••••••' : formatVnd(v);

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
                    ref.tr('wealth_dashboard_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ref.read(wealthPrivacyModeProvider.notifier).toggle(),
                  child: Icon(
                    hidden
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  GlowBox(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('wealth_dashboard_net_worth'),
                          style: AppTextStyles.muted(size: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          netWorth == null ? '...' : display(netWorth),
                          style: AppTextStyles.heading(size: 22),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr('wallet_total_assets'),
                                value: display(netWorth ?? 0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr('wealth_investments_total'),
                                value: display(investmentTotal),
                                changeText: hidden || investmentPnl == 0
                                    ? null
                                    : '${investmentPnl >= 0 ? '+' : ''}${investmentPnlPercent == null ? '' : '${investmentPnlPercent.toStringAsFixed(1)}%'}',
                                changeColor: investmentPnl >= 0
                                    ? AppColors.teal
                                    : AppColors.pink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final p in _Period.values) ...[
                        _PeriodChip(
                          label: ref.tr(switch (p) {
                            _Period.day => 'wealth_dashboard_period_day',
                            _Period.week => 'wealth_dashboard_period_week',
                            _Period.month => 'wealth_dashboard_period_month',
                          }),
                          selected: _period == p,
                          onTap: () => setState(() => _period = p),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_downward_rounded,
                          iconColor: AppColors.pink,
                          label: ref.tr('wealth_dashboard_expense_month'),
                          value: display(expenseThisMonth),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_upward_rounded,
                          iconColor: AppColors.teal,
                          label: ref.tr('wealth_dashboard_income_month'),
                          value: display(incomeThisMonth),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GlowBox(
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('wealth_dashboard_debt_summary'),
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr('wealth_debt_tab_i_owe'),
                                value: display(totalIOwe),
                                valueColor: AppColors.pink,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr('wealth_debt_tab_owed_to_me'),
                                value: display(totalOwedToMe),
                                valueColor: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlowBox(
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('wealth_dashboard_services_summary'),
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr(
                                  'wealth_dashboard_services_active',
                                ),
                                value: '${services.length}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: ref.tr(
                                  'wealth_dashboard_services_expiring',
                                ),
                                value: '${expiringSoon.length}',
                                valueColor: expiringSoon.isEmpty
                                    ? null
                                    : AppColors.pink,
                              ),
                            ),
                          ],
                        ),
                        if (nearest != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${ref.tr('wealth_dashboard_nearest_expiry')}: '
                            '${nearest.name} · '
                            '${nearest.daysLeft < 0 ? ref.tr('wealth_service_overdue') : '${nearest.daysLeft} ${ref.tr('wealth_service_days_left')}'}',
                            style: AppTextStyles.muted(size: 11.5).copyWith(
                              color: nearest.isExpiringSoon
                                  ? AppColors.pink
                                  : null,
                            ),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              ref.tr('wealth_dashboard_no_services'),
                              style: AppTextStyles.muted(size: 11.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _sumRemainingVnd(List<WealthDebt> debts) => debts
      .where((d) => d.currency == 'VND')
      .fold<double>(0, (s, d) => s + d.remainingAmount);
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? AppColors.wealthAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.muted(size: 11)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.valueColor,
    this.changeText,
    this.changeColor,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final String? changeText;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted(size: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body(
            size: 15,
            weight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        if (changeText != null)
          Text(
            changeText!,
            style: AppTextStyles.muted(size: 11)
                .copyWith(color: changeColor, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}
