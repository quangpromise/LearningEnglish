import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_debt_model.dart';
import 'add_debt_sheet.dart';
import 'debt_person_history_screen.dart';
import 'pay_debt_sheet.dart';

/// Man No (Phase E) - 2 tab "Dang no" (minh no nguoi khac) va "Nguoi khac no
/// minh". So sach doc lap, KHONG cong vao tong tai san o Home/Vi (xem ke
/// hoach build lai Wealth - liability/receivable khac ban chat voi tai san
/// dang co/dau tu).
class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
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
                      ref.tr('wealth_debt_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Consumer(
              builder: (context, ref, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.wealthAccentGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  tabs: [
                    Tab(text: ref.tr('wealth_debt_tab_i_owe')),
                    Tab(text: ref.tr('wealth_debt_tab_owed_to_me')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _DebtList(direction: 'i_owe'),
                  _DebtList(direction: 'owed_to_me'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtList extends ConsumerWidget {
  const _DebtList({required this.direction});
  final String direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider(direction));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: debtsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
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
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                itemCount: debts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _DebtTile(debt: debts[i]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: ref.tr('wealth_debt_add'),
            accentGradient: AppColors.wealthAccentGradient,
            accentColor: AppColors.wealthAccent,
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            onTap: () => showAddDebtSheet(context, direction),
          ),
        ),
      ],
    );
  }
}

class _DebtTile extends ConsumerWidget {
  const _DebtTile({required this.debt});
  final WealthDebt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      onDismissed: (_) async {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return;
        await ref.read(wealthDebtRepositoryProvider).delete(userId, debt.id);
        ref.invalidate(debtsProvider(debt.direction));
      },
      child: GlowBox(
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      if (debt.note?.isNotEmpty == true)
                        Text(debt.note!, style: AppTextStyles.muted(size: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatByCurrency(debt.remainingAmount, debt.currency),
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                    if (debt.isSettled)
                      Text(
                        ref.tr('wealth_debt_settled'),
                        style: AppTextStyles.muted(size: 10.5),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DebtPersonHistoryScreen(
                        personId: debt.personId,
                        personName: debt.personName,
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditDebtDialog(context, ref, debt),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (!debt.isSettled) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: debt.isIOwe
                      ? ref.tr('wealth_debt_pay')
                      : ref.tr('wealth_debt_collect'),
                  accentColor: AppColors.wealthAccent,
                  filled: false,
                  onTap: () => showPayDebtSheet(context, debt),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sua note luon duoc, sua SO TIEN GOC chi khi chua co lan tra nao
/// (remaining_amount == original_amount) - tranh lam sai lech so du da tru
/// dan qua cac lan tra truoc do.
Future<void> _showEditDebtDialog(
  BuildContext context,
  WidgetRef ref,
  WealthDebt debt,
) async {
  final noteController = TextEditingController(text: debt.note ?? '');
  final canEditAmount = debt.remainingAmount == debt.originalAmount;
  final amountController = TextEditingController(
    text: debt.originalAmount.toStringAsFixed(0),
  );
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bgMid,
      title: Text(debt.personName, style: AppTextStyles.heading(size: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEditAmount)
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: ref.tr('wallet_amount_hint'),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            style: AppTextStyles.body(),
            decoration: InputDecoration(hintText: ref.tr('wallet_note_hint')),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(ref.tr('common_cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(ref.tr('common_confirm')),
        ),
      ],
    ),
  );
  if (result != true) return;
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return;
  final newAmount = canEditAmount
      ? double.tryParse(amountController.text.trim().replaceAll(',', '.'))
      : null;
  await ref
      .read(wealthDebtRepositoryProvider)
      .updateNoteAndAmount(
        userId,
        debt.id,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        amount: newAmount != null && newAmount > 0 ? newAmount : null,
      );
  ref.invalidate(debtsProvider(debt.direction));
  ref.invalidate(debtsByPersonProvider(debt.personId));
}
