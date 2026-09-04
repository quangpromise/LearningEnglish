import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
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
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
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
                          formatVnd(total),
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
                        return Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.pink.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.pink,
                            ),
                          ),
                          onDismissed: (_) async {
                            final userId = ref
                                .read(supabaseClientProvider)
                                .auth
                                .currentUser
                                ?.id;
                            if (userId == null) return;
                            await ref
                                .read(wealthTransactionRepositoryProvider)
                                .deleteTransaction(userId, t.id);
                            ref.invalidate(walletBalanceEntriesProvider);
                            ref.invalidate(wealthTransactionsProvider);
                          },
                          child: GestureDetector(
                            onTap: () => showAddWealthTransactionSheet(
                              context,
                              ref,
                              WealthTransactionType.expense,
                              existing: t,
                            ),
                            child: WealthTransactionTile(
                              icon: category.icon,
                              label: ref.tr(category.labelKey),
                              note: t.note,
                              amount: t.amount,
                              amountColor: AppColors.pink,
                              sign: '-',
                            ),
                          ),
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
            accentGradient: AppColors.wealthAccentGradient,
            accentColor: AppColors.wealthAccent,
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
