import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
import 'crypto_providers.dart';

class CryptoMarketTab extends ConsumerWidget {
  const CryptoMarketTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final coins = ref.watch(cryptoTop100Provider(currency));

    return coins.when(
      data: (list) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(cryptoTop100Provider(currency)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 48,
            ),
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              columnSpacing: 20,
              headingTextStyle: AppTextStyles.muted(size: 11),
              columns: [
                const DataColumn(label: Text('#')),
                const DataColumn(label: Text('Coin')),
                DataColumn(label: Text(ref.tr('crypto_col_price'))),
                DataColumn(label: Text(ref.tr('crypto_col_change'))),
                DataColumn(label: Text(ref.tr('crypto_col_market_cap'))),
                DataColumn(label: Text(ref.tr('crypto_col_supply'))),
              ],
              rows: list
                  .map((c) => _coinRow(c, currency))
                  .toList(growable: false),
            ),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _MarketError(currency: currency),
    );
  }

  DataRow _coinRow(CryptoCoin c, CryptoCurrency currency) {
    final isUp = c.change24hPercent >= 0;
    final changeColor = isUp ? AppColors.teal : AppColors.pink;
    return DataRow(
      cells: [
        DataCell(Text('${c.rank}', style: AppTextStyles.muted(size: 12))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.network(
                  c.imageUrl,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, _, _) => Container(
                    width: 22,
                    height: 22,
                    color: AppColors.glassFill,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                  Text(c.symbol, style: AppTextStyles.muted(size: 11)),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            formatCryptoPrice(c.price, currency),
            style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
          ),
        ),
        DataCell(
          Text(
            '${isUp ? '+' : ''}${c.change24hPercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: changeColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        DataCell(
          Text(
            formatCryptoCompact(c.marketCap, currency),
            style: AppTextStyles.muted(size: 12),
          ),
        ),
        DataCell(
          Text(
            formatSupply(c.circulatingSupply, c.symbol),
            style: AppTextStyles.muted(size: 12),
          ),
        ),
      ],
    );
  }
}

class _MarketError extends ConsumerWidget {
  const _MarketError({required this.currency});
  final CryptoCurrency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 10),
          Text(ref.tr('crypto_error'), style: AppTextStyles.muted()),
          const SizedBox(height: 14),
          PillButton(
            label: ref.tr('crypto_retry'),
            onTap: () => ref.invalidate(cryptoTop100Provider(currency)),
          ),
        ],
      ),
    );
  }
}
