import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_balance_entry_model.dart';
import 'add_balance_entry_sheet.dart';
import 'bank_picker_sheet.dart';
import 'confirm_delete.dart';
import 'wallet_account_history_screen.dart';

/// Tab "Tai san hien co" trong man Vi - 2 muc: Tien mat va Tien ngan hang
/// (tach rieng theo tung ngan hang, dung quyet dinh nguoi dung da chon).
class WalletExistingAssetsTab extends ConsumerWidget {
  const WalletExistingAssetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(walletBalanceEntriesProvider);
    return entriesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_load_error'), style: AppTextStyles.muted()),
      ),
      data: (entries) {
        final cashEntries = entries
            .where((e) => e.accountType == 'cash')
            .toList();
        final bankEntries = entries
            .where((e) => e.accountType == 'bank')
            .toList();
        final hidden = ref.watch(wealthPrivacyModeProvider);
        final netWorth = ref.watch(netWorthVndProvider);
        return ListView(
          children: [
            GlowBox(
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('wallet_total_assets'),
                          style: AppTextStyles.muted(size: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hidden
                              ? '•••••••'
                              : (netWorth == null
                                    ? '...'
                                    : formatVnd(netWorth)),
                          style: AppTextStyles.heading(size: 20),
                        ),
                      ],
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
            ),
            const SizedBox(height: 16),
            Text(
              ref.tr('wallet_section_cash'),
              style: AppTextStyles.heading(size: 14),
            ),
            const SizedBox(height: 10),
            _CashCard(entries: cashEntries),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  ref.tr('wallet_section_bank'),
                  style: AppTextStyles.heading(size: 14),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final bank = await showBankPickerSheet(context);
                    if (bank != null && context.mounted) {
                      await showAddBalanceEntrySheet(
                        context,
                        ref,
                        initialBank: bank,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.wealthAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (bankEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  ref.tr('wallet_empty_bank'),
                  style: AppTextStyles.muted(),
                ),
              )
            else
              ..._groupByBank(bankEntries).entries.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BankCard(label: group.key, entries: group.value),
                ),
              ),
          ],
        );
      },
    );
  }

  Map<String, List<WealthBalanceEntry>> _groupByBank(
    List<WealthBalanceEntry> entries,
  ) {
    final map = <String, List<WealthBalanceEntry>>{};
    for (final e in entries) {
      final key = e.bankName ?? e.bankCode ?? 'Khác';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }
}

class _CashCard extends ConsumerWidget {
  const _CashCard({required this.entries});
  final List<WealthBalanceEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalVnd = entries
        .where((e) => e.currency == 'VND')
        .fold<double>(0, (s, e) => s + e.amount);
    final totalUsd = entries
        .where((e) => e.currency == 'USD')
        .fold<double>(0, (s, e) => s + e.amount);
    void openHistory() => openAppPopup(
      context,
      WalletAccountHistoryScreen(
        title: ref.tr('wallet_section_cash'),
        accountType: 'cash',
      ),
    );
    return GlowBox(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: entries.isEmpty ? null : openHistory,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatVnd(totalVnd),
                        style: AppTextStyles.heading(size: 16),
                      ),
                      if (totalUsd != 0)
                        Text(formatUsd(totalUsd), style: AppTextStyles.muted()),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showAddBalanceEntrySheet(context, ref),
                child: const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.wealthAccent,
                ),
              ),
            ],
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ref.tr('wallet_empty_cash'),
                style: AppTextStyles.muted(),
              ),
            )
          else
            // Ca khoi xem truoc (toi da 5 dong) + link "xem tat ca" deu bam
            // vao la mo LICH SU DAY DU - dong rieng KHONG con tu sua/xoa
            // truc tiep tai day nua (interactive:false) de tranh nham lan
            // "tuong bam vao se mo lich su nhung lai mo sua dong do" nhu
            // nguoi dung da bao cao; sua/xoa chuyen het vao man lich su.
            GestureDetector(
              onTap: openHistory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  for (final e in entries.take(5))
                    WalletEntryRow(entry: e, interactive: false),
                  if (entries.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        ref.tr('wallet_view_all_history'),
                        style: AppTextStyles.body(
                          size: 11,
                          weight: FontWeight.w700,
                          color: AppColors.wealthAccent,
                        ),
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

class _BankCard extends ConsumerWidget {
  const _BankCard({required this.label, required this.entries});
  final String label;
  final List<WealthBalanceEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalVnd = entries
        .where((e) => e.currency == 'VND')
        .fold<double>(0, (s, e) => s + e.amount);
    final totalUsd = entries
        .where((e) => e.currency == 'USD')
        .fold<double>(0, (s, e) => s + e.amount);
    final bankCode = entries.isEmpty ? null : entries.first.bankCode;
    void openHistory() => openAppPopup(
      context,
      WalletAccountHistoryScreen(
        title: label,
        accountType: 'bank',
        bankCode: bankCode,
        bankName: label,
      ),
    );
    return GestureDetector(
      onTap: openHistory,
      child: GlowBox(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                ),
                Text(
                  formatVnd(totalVnd),
                  style: AppTextStyles.heading(size: 14),
                ),
              ],
            ),
            if (totalUsd != 0)
              Align(
                alignment: Alignment.centerRight,
                child: Text(formatUsd(totalUsd), style: AppTextStyles.muted()),
              ),
            const SizedBox(height: 8),
            // interactive:false - xem cach giai thich o _CashCard ben tren.
            for (final e in entries.take(5))
              WalletEntryRow(entry: e, interactive: false),
            if (entries.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  ref.tr('wallet_view_all_history'),
                  style: AppTextStyles.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.wealthAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalletEntryRow extends ConsumerWidget {
  const WalletEntryRow({
    super.key,
    required this.entry,
    this.interactive = true,
  });
  final WealthBalanceEntry entry;
  // false = chi xem (dung trong khoi xem truoc tren man Vi chinh) - khong
  // bam de sua, khong vuot de xoa, tranh nham lan voi bam-de-mo-lich-su cua
  // ca khoi xem truoc do.
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPositive = entry.amount >= 0;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.note?.isNotEmpty == true
                  ? entry.note!
                  : '${entry.occurredAt.day.toString().padLeft(2, '0')}/'
                        '${entry.occurredAt.month.toString().padLeft(2, '0')}',
              style: AppTextStyles.muted(size: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatByCurrency(entry.amount, entry.currency),
            style: AppTextStyles.body(
              size: 12,
              weight: FontWeight.w700,
              color: isPositive ? AppColors.teal : AppColors.pink,
            ),
          ),
        ],
      ),
    );
    if (!interactive) return content;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 16,
          color: AppColors.pink,
        ),
      ),
      onDismissed: (_) async {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return;
        switch (entry.source) {
          case 'expense' when entry.sourceTransactionId != null:
            // Xoa ca giao dich goc de dong bo voi man Chi tieu - FK cascade
            // se tu xoa dong wealth_balance_entries nay theo.
            await ref
                .read(wealthTransactionRepositoryProvider)
                .deleteTransaction(userId, entry.sourceTransactionId!);
            ref.invalidate(wealthTransactionsProvider);
          case 'debt_payment' when entry.sourceDebtPaymentId != null:
            final paymentRepo = ref.read(wealthDebtPaymentRepositoryProvider);
            final info = await paymentRepo.fetchOne(
              userId,
              entry.sourceDebtPaymentId!,
            );
            await paymentRepo.delete(userId, entry.sourceDebtPaymentId!);
            if (info != null) {
              await ref
                  .read(wealthDebtRepositoryProvider)
                  .restoreAmount(userId, info.debtId, info.amount);
            }
            ref.invalidate(debtsProvider('i_owe'));
            ref.invalidate(debtsProvider('owed_to_me'));
          case 'service_renewal'
              when entry.sourceServiceRenewalPaymentId != null:
            final serviceRepo = ref.read(recurringServiceRepositoryProvider);
            final info = await serviceRepo.fetchRenewalPaymentInfo(
              userId,
              entry.sourceServiceRenewalPaymentId!,
            );
            await serviceRepo.deleteRenewalPayment(
              userId,
              entry.sourceServiceRenewalPaymentId!,
            );
            if (info != null) {
              final remaining = await serviceRepo.countRenewalPayments(
                userId,
                info.renewalId,
              );
              if (remaining == 0) {
                await serviceRepo.deleteRenewalAndRestoreExpiry(
                  userId: userId,
                  renewalId: info.renewalId,
                  serviceId: info.serviceId,
                  previousExpiryDate: info.previousExpiryDate,
                );
              }
            }
            ref.invalidate(recurringServicesProvider);
          default:
            await ref
                .read(wealthBalanceEntryRepositoryProvider)
                .deleteEntry(userId, entry.id);
        }
        ref.invalidate(walletBalanceEntriesProvider);
      },
      child: GestureDetector(
        onTap: () => showAddBalanceEntrySheet(context, ref, existing: entry),
        child: content,
      ),
    );
  }
}
