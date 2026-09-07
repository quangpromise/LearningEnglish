import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/exchange_rate_repository.dart';

/// Ty gia TAT CA ngoai te Vietcombank thoi gian thuc (Mua tien mat/Mua
/// chuyen khoan/Ban ra) - cung 1 nguon voi Vang o MarketMetalsTab
/// (wealthVnAssetsProvider), chi khac phan hien thi.
class MarketCurrencyTab extends ConsumerWidget {
  const MarketCurrencyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(wealthVnAssetsProvider);
    return snapAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_quote_error'), style: AppTextStyles.muted()),
      ),
      data: (snap) {
        if (snap.rates.isEmpty) {
          return Center(
            child: Text(
              ref.tr('wealth_currency_rates_loading'),
              style: AppTextStyles.muted(),
            ),
          );
        }
        return ListView(
          children: [
            Text(
              ref.tr('wealth_currency_bank_note'),
              style: AppTextStyles.muted(size: 10.5),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < snap.rates.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _CurrencyCard(rate: snap.rates[i]),
            ],
          ],
        );
      },
    );
  }
}

class _CurrencyCard extends ConsumerWidget {
  const _CurrencyCard({required this.rate});
  final ForeignCurrencyRate rate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchKey = 'currency:${rate.code}';
    final isFavorite = ref.watch(assetWatchlistProvider).contains(watchKey);
    final price = rate.buyTransfer ?? rate.buyCash ?? rate.sell;
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                ref.read(assetWatchlistProvider.notifier).toggle(watchKey),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                size: 20,
                color: isFavorite
                    ? AppColors.wealthAccent
                    : AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.code,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                Text(rate.name, style: AppTextStyles.muted(size: 10.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price != null)
                Text(
                  formatVnd(price),
                  style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
                ),
              if (rate.sell != null)
                Text(
                  '${ref.tr('wealth_currency_rate_sell')}: ${formatVnd(rate.sell!)}',
                  style: AppTextStyles.muted(size: 10.5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
