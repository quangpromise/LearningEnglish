import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../crypto/data/okx_service.dart';
import '../../crypto/presentation/crypto_coin_detail_screen.dart';
import '../../crypto/presentation/crypto_providers.dart';

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
              : ref.tr('wealth_market_stocks_okx_note'),
          style: AppTextStyles.muted(size: 10.5),
        ),
        const SizedBox(height: 10),
        Expanded(child: isVn ? const _VnStocksList() : const _IntlStocksList()),
      ],
    );
  }
}

/// Danh sach chung khoan VN (16 blue-chip co dinh) - giu nguyen cach lay gia
/// cu (Edge Function stocks-vn, tung ma rieng le).
class _VnStocksList extends ConsumerWidget {
  const _VnStocksList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(
      stocksVnQuotesProvider(_kWatchSymbolsVn.join(',')),
    );
    return quotesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_quote_error'), style: AppTextStyles.muted()),
      ),
      data: (quotes) {
        final bySymbol = {for (final q in quotes) q.symbol: q};
        // Sap theo tradingValue (tong gia tri khop lenh trong phien) GIAM
        // DAN - PROXY cho quy mo giao dich, KHONG PHAI von hoa thi truong
        // that (HOSE khong cong bo so co phieu luu hanh qua API nay).
        final orderedSymbols = List<String>.from(_kWatchSymbolsVn)
          ..sort((a, b) {
            final va = bySymbol[a]?.tradingValue ?? -1;
            final vb = bySymbol[b]?.tradingValue ?? -1;
            return vb.compareTo(va);
          });
        return ListView.separated(
          itemCount: orderedSymbols.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final symbol = orderedSymbols[i];
            final quote = bySymbol[symbol];
            final isUp = (quote?.changePercent ?? 0) >= 0;
            final watchlist = ref.watch(assetWatchlistProvider);
            final watchKey = 'stock_vn:$symbol';
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol,
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                        if (quote?.tradingValue != null)
                          Text(
                            '${ref.tr('wealth_market_trading_value')}: '
                            '${_formatVndCompact(quote!.tradingValue!)}',
                            style: AppTextStyles.muted(size: 10),
                          ),
                      ],
                    ),
                  ),
                  if (quote != null) ...[
                    Text(
                      '${quote.price.toStringAsFixed(0)}đ',
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
    );
  }
}

/// Toan bo "co phieu tokenized" (xStocks) tren OKX, sap theo thanh khoan 24h
/// giam dan (proxy cho "quy mo" - token nay khong co von hoa thi truong
/// chinh thuc) - co tim kiem, favorite, bam vao mo chart real-time giong
/// crypto (dung lai CryptoCoinDetailScreen, chi khac ky hieu OKX co tien to
/// "X").
class _IntlStocksList extends ConsumerStatefulWidget {
  const _IntlStocksList();

  @override
  ConsumerState<_IntlStocksList> createState() => _IntlStocksListState();
}

class _IntlStocksListState extends ConsumerState<_IntlStocksList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(okxTokenizedStocksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowBox(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          borderRadius: 999,
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toUpperCase()),
                  style: AppTextStyles.body(size: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: ref.tr('wealth_market_stocks_search_hint'),
                    hintStyle: AppTextStyles.muted(size: 13),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: stocksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_quote_error'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (stocks) {
              final filtered = _query.isEmpty
                  ? stocks
                  : stocks.where((s) => s.symbol.contains(_query)).toList();
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    ref.tr('crypto_no_results'),
                    style: AppTextStyles.muted(),
                  ),
                );
              }
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => IntlStockRow(stock: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class IntlStockRow extends ConsumerWidget {
  const IntlStockRow({super.key, required this.stock});
  final OkxTokenizedStock stock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = stock.changePercent24h >= 0;
    final watchlist = ref.watch(assetWatchlistProvider);
    final watchKey = 'stock_okx:${stock.symbol}';
    final isFavorite = watchlist.contains(watchKey);
    return GestureDetector(
      onTap: () => openAppPopup(
        context,
        CryptoCoinDetailScreen(
          symbol: stock.okxSymbol,
          name: stock.symbol,
          fallbackPrice: stock.price,
          fallbackChangePercent: stock.changePercent24h,
        ),
      ),
      child: GlowBox(
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
                    stock.symbol,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  Text(
                    '${ref.tr('wealth_market_trading_value')}: '
                    '${_formatUsdCompact(stock.volume24hUsd)}',
                    style: AppTextStyles.muted(size: 10),
                  ),
                ],
              ),
            ),
            Text(
              '\$${stock.price.toStringAsFixed(stock.price >= 1 ? 2 : 4)}',
              style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              '${isUp ? '+' : ''}${stock.changePercent24h.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isUp ? AppColors.teal : AppColors.pink,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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

/// Rut gon so VND lon (vd 1234567890 -> "1.2 ty") - dung de hien thi
/// tradingValue (PROXY thanh khoan, khong phai von hoa).
String _formatVndCompact(double v) {
  if (v >= 1e12) return '${(v / 1e12).toStringAsFixed(1)} nghìn tỷ';
  if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)} tỷ';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(0)} triệu';
  return v.toStringAsFixed(0);
}

/// Rut gon so USD lon - dung de hien thi volume24hUsd (PROXY thanh khoan
/// tren OKX, khong phai von hoa thi truong that).
String _formatUsdCompact(double v) {
  if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
  return '\$${v.toStringAsFixed(0)}';
}
