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

enum _IncomeFilter { all, active, passive }

class WealthIncomeTab extends ConsumerStatefulWidget {
  const WealthIncomeTab({super.key});

  @override
  ConsumerState<WealthIncomeTab> createState() => _WealthIncomeTabState();
}

class _WealthIncomeTabState extends ConsumerState<WealthIncomeTab> {
  _IncomeFilter _filter = _IncomeFilter.all;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(wealthTransactionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _FilterChip(
              label: ref.tr('wealth_filter_all'),
              selected: _filter == _IncomeFilter.all,
              onTap: () => setState(() => _filter = _IncomeFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: ref.tr('wealth_filter_active'),
              selected: _filter == _IncomeFilter.active,
              onTap: () => setState(() => _filter = _IncomeFilter.active),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: ref.tr('wealth_filter_passive'),
              selected: _filter == _IncomeFilter.passive,
              onTap: () => setState(() => _filter = _IncomeFilter.passive),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: txAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_empty_income'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (all) {
              var incomes = all
                  .where((t) => t.type == WealthTransactionType.income)
                  .toList();
              if (_filter == _IncomeFilter.active) {
                incomes = incomes.where((t) => !t.isPassiveIncome).toList();
              } else if (_filter == _IncomeFilter.passive) {
                incomes = incomes.where((t) => t.isPassiveIncome).toList();
              }
              if (incomes.isEmpty) {
                return Center(
                  child: Text(
                    ref.tr('wealth_empty_income'),
                    style: AppTextStyles.muted(),
                  ),
                );
              }
              final total = incomes.fold<double>(0, (sum, t) => sum + t.amount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlowBox(
                    borderRadius: 18,
                    child: Row(
                      children: [
                        Text(
                          ref.tr('wealth_total_income'),
                          style: AppTextStyles.muted(),
                        ),
                        const Spacer(),
                        Text(
                          formatVnd(total),
                          style: AppTextStyles.heading(size: 16)
                              .copyWith(color: AppColors.teal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: incomes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final t = incomes[i];
                        final category = WealthIncomeCategory.fromCode(
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
                            ref.invalidate(wealthTransactionsProvider);
                          },
                          child: GestureDetector(
                            onTap: () => showAddWealthTransactionSheet(
                              context,
                              ref,
                              WealthTransactionType.income,
                              existing: t,
                            ),
                            child: WealthTransactionTile(
                              icon: category.icon,
                              label: ref.tr(category.labelKey),
                              note: t.note,
                              amount: t.amount,
                              amountColor: AppColors.teal,
                              sign: '+',
                              trailing: _KindBadge(passive: category.isPassive),
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
              WealthTransactionType.income,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
              ? AppColors.teal.withValues(alpha: 0.2)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? AppColors.teal : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.passive});
  final bool passive;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          ref.tr(passive ? 'wealth_filter_passive' : 'wealth_filter_active'),
          style: AppTextStyles.muted(size: 9.5),
        ),
      ),
    );
  }
}
