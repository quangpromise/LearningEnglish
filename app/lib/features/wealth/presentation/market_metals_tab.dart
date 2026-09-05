import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../crypto/presentation/crypto_providers.dart';

/// Gia Vang SJC/PNJ trong nuoc + gia Vang quoc te (XAUT tu OKX) quy doi VND.
/// KHONG con Bac/Dong - da bo hoan toan vi khong tim duoc nguon mien phi hop
/// le ve dieu khoan thuong mai cho ca 2 kim loai nay (Twelve Data free tier
/// khong ho tro Bac, khong co Dong; cac nguon khac co ca 2 deu cam thuong
/// mai o goi mien phi) - xem docs/research-wealth-stock-apis.md.
class MarketMetalsTab extends ConsumerWidget {
  const MarketMetalsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(wealthVnAssetsProvider);
    final xautAsync = ref.watch(okxXautTickerProvider);
    return snapAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_quote_error'), style: AppTextStyles.muted()),
      ),
      data: (snap) {
        return ListView(
          children: [
            Text(
              ref.tr('wealth_market_metals_note'),
              style: AppTextStyles.muted(size: 10.5),
            ),
            const SizedBox(height: 12),
            if (snap.goldSjcBuy != null || snap.goldSjcSell != null)
              _MetalCard(
                watchKey: 'metal:gold_sjc',
                title: ref.tr('wealth_metal_gold_sjc'),
                buy: snap.goldSjcBuy,
                sell: snap.goldSjcSell,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
            if (snap.goldPnjBuy != null || snap.goldPnjSell != null) ...[
              const SizedBox(height: 10),
              _MetalCard(
                watchKey: 'metal:gold_pnj',
                title: ref.tr('wealth_metal_gold_pnj'),
                buy: snap.goldPnjBuy,
                sell: snap.goldPnjSell,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
            ],
            if (xautAsync.valueOrNull?.price != null &&
                snap.usdVnd != null) ...[
              const SizedBox(height: 10),
              _MetalCard(
                watchKey: 'metal:xaut',
                title: ref.tr('wealth_metal_gold_xaut'),
                sell:
                    xautAsync.valueOrNull!.price /
                    kTroyOunceToLuong *
                    snap.usdVnd!,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
              const SizedBox(height: 4),
              Text(
                ref.tr('wealth_metal_xaut_note'),
                style: AppTextStyles.muted(size: 9.5),
              ),
            ],
            if (snap.usdVnd != null) ...[
              const SizedBox(height: 16),
              Text(
                '${ref.tr('wealth_market_usd_vnd')}: ${formatVnd(snap.usdVnd!)}',
                style: AppTextStyles.muted(size: 11),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetalCard extends ConsumerWidget {
  const _MetalCard({
    required this.watchKey,
    required this.title,
    this.buy,
    this.sell,
    required this.unit,
  });
  final String watchKey;
  final String title;
  final double? buy;
  final double? sell;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(assetWatchlistProvider).contains(watchKey);
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
            child: Text(
              title,
              style: AppTextStyles.body(weight: FontWeight.w800),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (sell != null)
                Text(
                  '${formatVnd(sell!)}/$unit',
                  style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
                ),
              if (buy != null)
                Text(
                  '${ref.tr('wealth_metal_buy_price')}: ${formatVnd(buy!)}',
                  style: AppTextStyles.muted(size: 10.5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
