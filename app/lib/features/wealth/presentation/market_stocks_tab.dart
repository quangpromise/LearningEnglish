import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Danh sach ma quoc te TIEU BIEU co dinh (Twelve Data free tier khong ho
/// tro screener toan san) - thi truong tham khao, khong phai toan bo san
/// chung khoan. Nguoi dung muon theo doi ma khac tu them qua Vi > Tai san
/// dau tu > Co phieu.
const _kWatchSymbols = [
  'AAPL',
  'MSFT',
  'GOOGL',
  'AMZN',
  'NVDA',
  'TSLA',
  'META',
  'SPY',
];

class MarketStocksTab extends ConsumerWidget {
  const MarketStocksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(stocksIntlQuotesProvider(_kWatchSymbols));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.tr('wealth_market_stocks_note'),
          style: AppTextStyles.muted(size: 10.5),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: quotesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_quote_error'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (quotes) {
              final bySymbol = {for (final q in quotes) q.symbol: q};
              return ListView.separated(
                itemCount: _kWatchSymbols.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final symbol = _kWatchSymbols[i];
                  final quote = bySymbol[symbol];
                  final isUp = (quote?.changePercent ?? 0) >= 0;
                  final watchlist = ref.watch(assetWatchlistProvider);
                  final watchKey = 'stock:$symbol';
                  final isFavorite = watchlist.contains(watchKey);
                  return GlowBox(
                    borderRadius: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref
                              .read(assetWatchlistProvider.notifier)
                              .toggle(watchKey),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 20,
                              color: isFavorite
                                  ? AppColors.wealthAccent
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            symbol,
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                        ),
                        if (quote != null) ...[
                          Text(
                            '\$${quote.price.toStringAsFixed(2)}',
                            style: AppTextStyles.body(
                              weight: FontWeight.w700,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isUp ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: isUp ? AppColors.teal : AppColors.pink,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ] else
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
