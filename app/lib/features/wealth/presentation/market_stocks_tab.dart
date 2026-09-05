import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Danh sach ma quoc te TIEU BIEU co dinh (Twelve Data free tier khong ho
/// tro screener toan san) - thi truong tham khao, khong phai toan bo san
/// chung khoan. Nguoi dung muon theo doi ma khac tu them qua Vi > Tai san
/// dau tu > Co phieu.
const _kWatchSymbolsIntl = [
  'AAPL',
  'MSFT',
  'GOOGL',
  'AMZN',
  'NVDA',
  'TSLA',
  'META',
  'SPY',
];

/// Danh sach blue-chip VN (san HOSE) TIEU BIEU co dinh - gia lay tu chinh
/// API cong khai cua HOSE (xem supabase/functions/stocks-vn), la gia khop
/// lenh gan nhat/dong cua phien gan nhat, KHONG phai real-time chuan giao
/// dich - chi mang tinh tham khao.
const _kWatchSymbolsVn = [
  'VNM',
  'VIC',
  'VHM',
  'VCB',
  'BID',
  'CTG',
  'HPG',
  'FPT',
  'MSN',
  'MWG',
  'GAS',
  'VJC',
  'VRE',
  'TCB',
  'MBB',
  'SSI',
];

enum _StockMarket { intl, vn }

class MarketStocksTab extends ConsumerStatefulWidget {
  const MarketStocksTab({super.key});

  @override
  ConsumerState<MarketStocksTab> createState() => _MarketStocksTabState();
}

class _MarketStocksTabState extends ConsumerState<MarketStocksTab> {
  _StockMarket _market = _StockMarket.intl;

  @override
  Widget build(BuildContext context) {
    final isVn = _market == _StockMarket.vn;
    final symbols = isVn ? _kWatchSymbolsVn : _kWatchSymbolsIntl;
    final quotesAsync = isVn
        ? ref.watch(stocksVnQuotesProvider(symbols))
        : ref.watch(stocksIntlQuotesProvider(symbols));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MarketChip(
              label: ref.tr('wealth_market_stocks_intl'),
              selected: !isVn,
              onTap: () => setState(() => _market = _StockMarket.intl),
            ),
            const SizedBox(width: 8),
            _MarketChip(
              label: ref.tr('wealth_market_stocks_vn'),
              selected: isVn,
              onTap: () => setState(() => _market = _StockMarket.vn),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isVn
              ? ref.tr('wealth_market_stocks_vn_note')
              : ref.tr('wealth_market_stocks_note'),
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
                itemCount: symbols.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final symbol = symbols[i];
                  final quote = bySymbol[symbol];
                  final isUp = (quote?.changePercent ?? 0) >= 0;
                  final watchlist = ref.watch(assetWatchlistProvider);
                  final watchKey = isVn ? 'stock_vn:$symbol' : 'stock:$symbol';
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
                            isVn
                                ? '${quote.price.toStringAsFixed(0)}đ'
                                : '\$${quote.price.toStringAsFixed(2)}',
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

class _MarketChip extends StatelessWidget {
  const _MarketChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.wealthAccentGradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12.5,
            weight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
