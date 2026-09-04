import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_debt_model.dart';
import 'pay_debt_sheet.dart';

/// Toan bo lich su no cua 1 nguoi (co the co nhieu khoan no rieng biet theo
/// thoi gian, ca "Dang no" lan "Nguoi khac no minh" neu qua lai 2 chieu).
class DebtPersonHistoryScreen extends ConsumerWidget {
  const DebtPersonHistoryScreen({
    super.key,
    required this.personId,
    required this.personName,
  });
  final String personId;
  final String personName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsByPersonProvider(personId));
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
                    personName,
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: debtsAsync.when(
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
                data: (debts) {
                  if (debts.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('wealth_debt_empty'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: debts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _DebtEntryCard(debt: debts[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtEntryCard extends ConsumerWidget {
  const _DebtEntryCard({required this.debt});
  final WealthDebt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(debtPaymentsProvider(debt.id));
    final directionLabel = debt.isIOwe
        ? ref.tr('wealth_debt_tab_i_owe')
        : ref.tr('wealth_debt_tab_owed_to_me');
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(directionLabel, style: AppTextStyles.muted(size: 11)),
                    Text(
                      '${formatByCurrency(debt.remainingAmount, debt.currency)} / '
                      '${formatByCurrency(debt.originalAmount, debt.currency)}',
                      style: AppTextStyles.body(weight: FontWeight.w800)
                          .copyWith(
                            color: debt.isIOwe
                                ? AppColors.pink
                                : AppColors.teal,
                          ),
                    ),
                    if (debt.note?.isNotEmpty == true)
                      Text(debt.note!, style: AppTextStyles.muted(size: 11)),
                  ],
                ),
              ),
              if (!debt.isSettled)
                PillButton(
                  label: debt.isIOwe
                      ? ref.tr('wealth_debt_pay')
                      : ref.tr('wealth_debt_collect'),
                  accentColor: debt.isIOwe ? AppColors.pink : AppColors.teal,
                  filled: false,
                  onTap: () => showPayDebtSheet(context, debt),
                ),
            ],
          ),
          paymentsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (payments) {
              if (payments.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in payments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${p.occurredAt.day.toString().padLeft(2, '0')}/'
                                '${p.occurredAt.month.toString().padLeft(2, '0')} · '
                                '${p.paymentBankName ?? ref.tr('wallet_section_cash')}',
                                style: AppTextStyles.muted(size: 11),
                              ),
                            ),
                            Text(
                              formatByCurrency(p.amount, p.currency),
                              style: AppTextStyles.muted(size: 11),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
