import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';

/// Gia Vang SJC/PNJ trong nuoc + gia The gioi Bac/Dong quy doi - cung nguon
/// Edge Function wealth-vn-assets dung o Vi > Tai san dau tu > Kim loai.
class MarketMetalsTab extends ConsumerWidget {
  const MarketMetalsTab({super.key});

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
        return ListView(
          children: [
            Text(
              ref.tr('wealth_market_metals_note'),
              style: AppTextStyles.muted(size: 10.5),
            ),
            const SizedBox(height: 12),
            if (snap.goldSjcBuy != null || snap.goldSjcSell != null)
              _MetalCard(
                title: ref.tr('wealth_metal_gold_sjc'),
                buy: snap.goldSjcBuy,
                sell: snap.goldSjcSell,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
            if (snap.goldPnjBuy != null || snap.goldPnjSell != null) ...[
              const SizedBox(height: 10),
              _MetalCard(
                title: ref.tr('wealth_metal_gold_pnj'),
                buy: snap.goldPnjBuy,
                sell: snap.goldPnjSell,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
            ],
            if (snap.xagVndPerLuong != null) ...[
              const SizedBox(height: 10),
              _MetalCard(
                title: ref.tr('wealth_metal_silver_world'),
                sell: snap.xagVndPerLuong,
                unit: ref.tr('wealth_metal_unit_luong'),
              ),
            ],
            if (snap.xcuVndPerKg != null) ...[
              const SizedBox(height: 10),
              _MetalCard(
                title: ref.tr('wealth_metal_copper_world'),
                sell: snap.xcuVndPerKg,
                unit: ref.tr('wealth_metal_unit_kg'),
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
    required this.title,
    this.buy,
    this.sell,
    required this.unit,
  });
  final String title;
  final double? buy;
  final double? sell;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
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
