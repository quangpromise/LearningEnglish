import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import 'add_balance_entry_sheet.dart';
import 'wallet_existing_assets_tab.dart';

/// Toan bo lich su bien dong cua 1 tai khoan (Tien mat hoac 1 ngan hang cu
/// the) - man Vi chinh chi xem truoc toi da 5 dong gan nhat, bam vao the
/// tong mo man nay de xem HET, tai dung [WalletEntryRow] (da co san sua/xoa)
/// cho tung dong.
class WalletAccountHistoryScreen extends ConsumerWidget {
  const WalletAccountHistoryScreen({
    super.key,
    required this.title,
    required this.accountType,
    this.bankCode,
    this.bankName,
  });
  final String title;
  final String accountType; // 'cash' | 'bank'
  final String? bankCode;
  final String? bankName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(walletBalanceEntriesProvider);
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
                  child: Text(title, style: AppTextStyles.heading(size: 18)),
                ),
                GestureDetector(
                  onTap: () => showAddBalanceEntrySheet(
                    context,
                    ref,
                    initialBank: accountType == 'bank'
                        ? VnBank(
                            code: bankCode ?? kOtherBankCode,
                            shortName: bankName ?? title,
                            name: bankName ?? title,
                            logoUrl: null,
                          )
                        : null,
                  ),
                  child: const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.wealthAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entriesAsync.when(
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
                data: (all) {
                  final entries = all.where((e) {
                    if (e.accountType != accountType) return false;
                    if (accountType != 'bank') return true;
                    return (bankCode != null && e.bankCode == bankCode) ||
                        (bankCode == null && e.bankName == bankName);
                  }).toList();
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        accountType == 'cash'
                            ? ref.tr('wallet_empty_cash')
                            : ref.tr('wallet_empty_bank'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  final totalVnd = entries
                      .where((e) => e.currency == 'VND')
                      .fold<double>(0, (s, e) => s + e.amount);
                  final totalUsd = entries
                      .where((e) => e.currency == 'USD')
                      .fold<double>(0, (s, e) => s + e.amount);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlowBox(
                        borderRadius: 18,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ref.tr('wallet_total_assets'),
                                style: AppTextStyles.muted(size: 12),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatVnd(totalVnd),
                                  style: AppTextStyles.heading(size: 16),
                                ),
                                if (totalUsd != 0)
                                  Text(
                                    formatUsd(totalUsd),
                                    style: AppTextStyles.muted(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(child: _GroupedHistoryList(entries: entries)),
                    ],
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

/// Nhom cac dong lich su theo NGAY (bo qua gio/phut) - moi nhom co 1 header
/// hien "Hom nay"/"Hom qua" hoac dd/MM/yyyy, dung de nguoi dung de theo doi
/// bien dong trong 1 ngay thay vi phai doc ngay lap lai o tung dong rieng le.
/// [entries] da duoc sap xep giam dan theo occurred_at tu repository
/// (`.order('occurred_at', ascending: false)`) nen chi can nhom giu nguyen
/// thu tu, khong can sort lai.
class _GroupedHistoryList extends ConsumerWidget {
  const _GroupedHistoryList({required this.entries});
  final List<WealthBalanceEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dayKey(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    String dayLabel(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      if (day == today) return ref.tr('wallet_history_today');
      if (day == yesterday) return ref.tr('wallet_history_yesterday');
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    final items = <Widget>[];
    String? lastKey;
    for (final entry in entries) {
      final key = dayKey(entry.occurredAt);
      if (key != lastKey) {
        if (lastKey != null) items.add(const SizedBox(height: 14));
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              dayLabel(entry.occurredAt),
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w800),
            ),
          ),
        );
        lastKey = key;
      } else {
        items.add(const SizedBox(height: 10));
      }
      items.add(WalletEntryRow(entry: entry));
    }

    return ListView(children: items);
  }
}
