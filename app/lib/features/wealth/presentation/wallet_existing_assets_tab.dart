import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_balance_entry_model.dart';
import 'add_balance_entry_sheet.dart';
import 'bank_picker_sheet.dart';

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
        return ListView(
          children: [
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
    return GlowBox(
      padding: const EdgeInsets.all(16),
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
                    Text(
                      formatVnd(totalVnd),
                      style: AppTextStyles.heading(size: 16),
                    ),
                    if (totalUsd != 0)
                      Text(formatUsd(totalUsd), style: AppTextStyles.muted()),
                  ],
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
          else ...[
            const SizedBox(height: 10),
            for (final e in entries.take(5)) _EntryRow(entry: e),
          ],
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
    return GlowBox(
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
              Text(formatVnd(totalVnd), style: AppTextStyles.heading(size: 14)),
            ],
          ),
          if (totalUsd != 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(formatUsd(totalUsd), style: AppTextStyles.muted()),
            ),
          const SizedBox(height: 8),
          for (final e in entries.take(5)) _EntryRow(entry: e),
        ],
      ),
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry});
  final WealthBalanceEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPositive = entry.amount >= 0;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
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
        await ref
            .read(wealthBalanceEntryRepositoryProvider)
            .deleteEntry(userId, entry.id);
        ref.invalidate(walletBalanceEntriesProvider);
      },
      child: GestureDetector(
        onTap: () => showAddBalanceEntrySheet(context, ref, existing: entry),
        child: Padding(
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
        ),
      ),
    );
  }
}
