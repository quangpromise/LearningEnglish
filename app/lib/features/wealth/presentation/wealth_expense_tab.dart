import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/wealth_category.dart';
import '../data/wealth_transaction_model.dart';
import 'add_transaction_sheet.dart';
import 'wealth_transaction_tile.dart';

class WealthExpenseTab extends ConsumerWidget {
  const WealthExpenseTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(wealthTransactionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: txAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_empty_expense'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (all) {
              final expenses = all
                  .where((t) => t.type == WealthTransactionType.expense)
                  .toList();
              if (expenses.isEmpty) {
                return Center(
                  child: Text(
                    ref.tr('wealth_empty_expense'),
                    style: AppTextStyles.muted(),
                  ),
                );
              }
              final total = expenses.fold<double>(
                0,
                (sum, t) => sum + t.amount,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlowBox(
                    borderRadius: 18,
                    child: Row(
                      children: [
                        Text(
                          ref.tr('wealth_total_expense'),
                          style: AppTextStyles.muted(),
                        ),
                        const Spacer(),
                        Text(
                          '${total.toStringAsFixed(0)} đ',
                          style: AppTextStyles.heading(size: 16)
                              .copyWith(color: AppColors.pink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final t = expenses[i];
                        final category = WealthExpenseCategory.fromCode(
                          t.categoryCode,
                        );
                        return WealthTransactionTile(
                          icon: category.icon,
                          label: category.labelVi(),
                          note: t.note,
                          amount: t.amount,
                          amountColor: AppColors.pink,
                          sign: '-',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: ref.tr('wealth_add_transaction'),
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            onTap: () => showAddWealthTransactionSheet(
              context,
              ref,
              WealthTransactionType.expense,
            ),
          ),
        ),
      ],
    );
  }
}
