import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_debt_model.dart';
import 'confirm_delete.dart';
import 'edit_debt_dialog.dart';
import 'edit_debt_payment_dialog.dart';
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
                  final netOffCurrency = _findNetOffCurrency(debts);
                  return ListView.separated(
                    itemCount: debts.length + (netOffCurrency == null ? 0 : 1),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (netOffCurrency != null && i == 0) {
                        return _NetOffCard(
                          debts: debts,
                          currency: netOffCurrency,
                        );
                      }
                      final debtIndex = netOffCurrency == null ? i : i - 1;
                      return _DebtEntryCard(debt: debts[debtIndex]);
                    },
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

/// Tra ve loai tien te DAU TIEN ma nguoi nay co CA HAI chieu no (dang no +
/// nguoi khac no minh) deu con du > 0 - null neu khong co chieu nao trung
/// (vd chi no 1 chieu, hoac 2 chieu nhung khac loai tien te).
String? _findNetOffCurrency(List<WealthDebt> debts) {
  final iOweByCurrency = <String, double>{};
  final owedByCurrency = <String, double>{};
  for (final d in debts) {
    if (d.isSettled) continue;
    final map = d.isIOwe ? iOweByCurrency : owedByCurrency;
    map[d.currency] = (map[d.currency] ?? 0) + d.remainingAmount;
  }
  for (final currency in iOweByCurrency.keys) {
    if ((owedByCurrency[currency] ?? 0) > 0) return currency;
  }
  return null;
}

/// The goi y bu tru khi 1 nguoi VUA no minh VUA duoc minh no (cung 1 loai
/// tien te) - giam khoan NHO HON ve 0 (settled) va tru phan chenh lech do
/// vao khoan LON HON, khong dong den Vi (day chi la but toan bu tru tren
/// giay, khong co tien mat/chuyen khoan thuc te nao xay ra).
class _NetOffCard extends ConsumerWidget {
  const _NetOffCard({required this.debts, required this.currency});
  final List<WealthDebt> debts;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iOwe =
        debts
            .where((d) => d.isIOwe && d.currency == currency && !d.isSettled)
            .toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final owed =
        debts
            .where((d) => !d.isIOwe && d.currency == currency && !d.isSettled)
            .toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final totalIOwe = iOwe.fold<double>(0, (s, d) => s + d.remainingAmount);
    final totalOwed = owed.fold<double>(0, (s, d) => s + d.remainingAmount);
    final net = totalIOwe < totalOwed ? totalIOwe : totalOwed;
    final remainder = (totalIOwe - totalOwed).abs();
    final remainderIsIOwe = totalIOwe > totalOwed;

    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_debt_net_off_title'),
            style: AppTextStyles.body(weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('wealth_debt_net_off_desc'),
            style: AppTextStyles.muted(size: 11.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatByCurrency(net, currency)} → '
            '${formatByCurrency(remainder, currency)} '
            '(${remainderIsIOwe ? ref.tr('wealth_debt_tab_i_owe') : ref.tr('wealth_debt_tab_owed_to_me')})',
            style: AppTextStyles.body(size: 13, weight: FontWeight.w700)
                .copyWith(
                  color: remainderIsIOwe ? AppColors.pink : AppColors.teal,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_debt_net_off_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: () => _confirmAndNetOff(context, ref, iOwe, owed, net),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndNetOff(
    BuildContext context,
    WidgetRef ref,
    List<WealthDebt> iOwe,
    List<WealthDebt> owed,
    double net,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          ref.tr('wealth_debt_net_off_confirm'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          formatByCurrency(net, currency),
          style: AppTextStyles.body(),
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
    if (confirmed != true) return;
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final repo = ref.read(wealthDebtRepositoryProvider);
    var remaining = net;
    for (final d in iOwe) {
      if (remaining <= 0) break;
      final apply = remaining >= d.remainingAmount
          ? d.remainingAmount
          : remaining;
      await repo.applyPayment(userId, d.id, apply);
      remaining -= apply;
    }
    remaining = net;
    for (final d in owed) {
      if (remaining <= 0) break;
      final apply = remaining >= d.remainingAmount
          ? d.remainingAmount
          : remaining;
      await repo.applyPayment(userId, d.id, apply);
      remaining -= apply;
    }
    ref.invalidate(debtsProvider('i_owe'));
    ref.invalidate(debtsProvider('owed_to_me'));
    if (iOwe.isNotEmpty) {
      ref.invalidate(debtsByPersonProvider(iOwe.first.personId));
    } else if (owed.isNotEmpty) {
      ref.invalidate(debtsByPersonProvider(owed.first.personId));
    }
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
    return Dismissible(
      key: ValueKey(debt.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      onDismissed: (_) async {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return;
        await ref.read(wealthDebtRepositoryProvider).delete(userId, debt.id);
        // Xoa khoan no cascade xoa het wealth_debt_payments + cac dong
        // wealth_balance_entries da sinh ra tu no (qua FK ON DELETE CASCADE)
        // - PHAI invalidate luon Vi de khong hien so du cu.
        ref.invalidate(walletBalanceEntriesProvider);
        ref.invalidate(debtsProvider(debt.direction));
        ref.invalidate(debtsByPersonProvider(debt.personId));
      },
      child: GlowBox(
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
                      Row(
                        children: [
                          Text(
                            directionLabel,
                            style: AppTextStyles.muted(size: 12),
                          ),
                          Text(
                            ' · ${debt.occurredAt.day.toString().padLeft(2, '0')}/'
                            '${debt.occurredAt.month.toString().padLeft(2, '0')}/'
                            '${debt.occurredAt.year}',
                            style: AppTextStyles.muted(size: 12),
                          ),
                        ],
                      ),
                      Text(
                        '${formatByCurrency(debt.remainingAmount, debt.currency)} / '
                        '${formatByCurrency(debt.originalAmount, debt.currency)}',
                        style:
                            AppTextStyles.body(
                              size: 16,
                              weight: FontWeight.w800,
                            ).copyWith(
                              color: debt.isIOwe
                                  ? AppColors.pink
                                  : AppColors.teal,
                            ),
                      ),
                      if (debt.note?.isNotEmpty == true)
                        Text(
                          debt.note!,
                          style: AppTextStyles.muted(size: 12.5),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => showEditDebtDialog(context, ref, debt),
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
                  accentColor: debt.isIOwe ? AppColors.pink : AppColors.teal,
                  filled: false,
                  onTap: () => showPayDebtSheet(context, debt),
                ),
              ),
            ],
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
                        GestureDetector(
                          onTap: () =>
                              showEditDebtPaymentDialog(context, ref, debt, p),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${p.occurredAt.day.toString().padLeft(2, '0')}/'
                                        '${p.occurredAt.month.toString().padLeft(2, '0')} · '
                                        '${p.paymentBankName ?? ref.tr('wallet_section_cash')}',
                                        style: AppTextStyles.muted(size: 12),
                                      ),
                                      if (p.note?.isNotEmpty == true)
                                        Text(
                                          p.note!,
                                          style: AppTextStyles.body(size: 12),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatByCurrency(p.amount, p.currency),
                                  style: AppTextStyles.muted(size: 12),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.edit_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
