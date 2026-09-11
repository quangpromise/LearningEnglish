import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../crypto/data/okx_service.dart';
import '../../crypto/presentation/crypto_coin_row.dart';
import '../../crypto/presentation/crypto_market_tab.dart';
import '../../crypto/presentation/crypto_providers.dart';
import '../../crypto/presentation/okx_only_coin_row.dart';
import '../data/asset_watchlist_repository.dart';
import '../data/exchange_rate_repository.dart';
import '../data/stocks_intl_repository.dart';
import 'market_currency_tab.dart';
import 'market_metals_tab.dart';
import 'market_stocks_tab.dart';

/// Man Market/Watchlist (Phase F+) - TACH THANH 2 MAN DOC LAP (khong con
/// TabBar chuyen qua lai giua Market/Watchlist nhu truoc): [initialTabIndex]
/// 0 = chi hien Market (chon loai tai san bang chip: Crypto/Co phieu/Kim
/// loai hiem/Ngoai te), 1 = chi hien Watchlist (gop TAT CA item da "theo
/// doi" tu moi loai tai san) - moi man mo tu 1 nut rieng o Home
/// (wealth_home_screen.dart: "Market" va "Theo doi"), KHONG can chuyen qua
/// lai trong cung 1 man nua.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, this.initialTabIndex = 0});

  /// 0 = chi hien Market, 1 = chi hien Watchlist.
  final int initialTabIndex;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

enum _MarketCategory { crypto, stocks, metals, currency }

class _MarketScreenState extends State<MarketScreen> {
  _MarketCategory _category = _MarketCategory.crypto;

  bool get _isWatchlist => widget.initialTabIndex == 1;

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
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
                    child: Text(
                      _isWatchlist
                          ? ref.tr('crypto_tab_watchlist')
                          : ref.tr('wealth_market_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isWatchlist
                  ? const _WatchlistTab()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryChipRow(
                          selected: _category,
                          onChanged: (c) => setState(() => _category = c),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildCategoryContent()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (_category) {
      case _MarketCategory.crypto:
        return const CryptoMarketTab();
      case _MarketCategory.stocks:
        return const MarketStocksTab();
      case _MarketCategory.metals:
        return const MarketMetalsTab();
      case _MarketCategory.currency:
        return const MarketCurrencyTab();
    }
  }
}

/// Hang chip chon loai tai san dang xem trong Market - dung Row+Expanded+
/// FittedBox (khong phai Wrap) de LUON vua DUNG 1 hang du nhan dai ("Foreign
/// currency"), tu dong giam co chu neu khong gian qua hep, giong cach
/// _WatchlistTab da lam cho hang category cua no.
class _CategoryChipRow extends ConsumerWidget {
  const _CategoryChipRow({required this.selected, required this.onChanged});
  final _MarketCategory selected;
  final ValueChanged<_MarketCategory> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (_MarketCategory.crypto, 'Crypto'),
      (_MarketCategory.stocks, ref.tr('wealth_investments_stocks_title')),
      (_MarketCategory.metals, ref.tr('wealth_investments_metal_title')),
      (_MarketCategory.currency, ref.tr('wealth_investments_currency_title')),
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glassFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final item in items) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(item.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected == item.$1
                        ? AppColors.wealthAccent.withValues(alpha: 0.22)
                        : AppColors.glassFill,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected == item.$1
                          ? AppColors.wealthAccent
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.$2,
                      maxLines: 1,
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: selected == item.$1
                            ? AppColors.wealthAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (item != items.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

enum _WatchlistCategory { crypto, metals, currency, stocks }

/// Watchlist chia 3 tab rieng (Crypto/Kim loai hiem/Co phieu) thay vi gop
/// chung 1 danh sach dai - de tim 1 muc cu the nhanh hon khi theo doi nhieu
/// loai tai san cung luc.
class _WatchlistTab extends StatefulWidget {
  const _WatchlistTab();

  @override
  State<_WatchlistTab> createState() => _WatchlistTabState();
}

class _WatchlistTabState extends State<_WatchlistTab> {
  _WatchlistCategory _category = _WatchlistCategory.crypto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final items = [
              (_WatchlistCategory.crypto, 'Crypto'),
              (
                _WatchlistCategory.metals,
                ref.tr('wealth_investments_metal_title'),
              ),
              (
                _WatchlistCategory.currency,
                ref.tr('wealth_investments_currency_title'),
              ),
              (_WatchlistCategory.stocks, ref.tr('wealth_watchlist_stocks')),
            ];
            // Row + Expanded (khong phai Wrap) - luon vua DUNG 1 hang du
            // nhan dai ("Rare metals"), tu dong chia deu be rong thay vi
            // xuong dong; giam padding/co chu + cho phep tu giam co chu
            // (FittedBox) khi khong gian qua hep tren man nho.
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassFill.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  for (final item in items) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _category = item.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _category == item.$1
                                ? AppColors.wealthAccent.withValues(alpha: 0.22)
                                : AppColors.glassFill,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _category == item.$1
                                  ? AppColors.wealthAccent
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.$2,
                              maxLines: 1,
                              style: AppTextStyles.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: _category == item.$1
                                    ? AppColors.wealthAccent
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (item != items.last) const SizedBox(width: 6),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (_category) {
            _WatchlistCategory.crypto => const _CryptoWatchlistSection(),
            _WatchlistCategory.metals => const _MetalsWatchlistSection(),
            _WatchlistCategory.currency => const _CurrencyWatchlistSection(),
            _WatchlistCategory.stocks => const _StocksWatchlistSection(),
          },
        ),
      ],
    );
  }
}

Widget _emptyWatchlist(WidgetRef ref) => Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_border_rounded,
          color: AppColors.textMuted,
          size: 40,
        ),
        const SizedBox(height: 10),
        Text(
          ref.tr('crypto_watchlist_empty'),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(),
        ),
      ],
    ),
  ),
);

class _CryptoWatchlistSection extends ConsumerWidget {
  const _CryptoWatchlistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final cryptoWatchlist = ref.watch(cryptoWatchlistProvider);
    final liveCoins = ref.watch(liveCoinsProvider(currency));
    final watchedCoins = liveCoins
        .where((c) => cryptoWatchlist.contains(c.id))
        .toList();

    final okxWatchedSymbols = cryptoWatchlist
        .where((k) => k.startsWith('okx:'))
        .map((k) => k.substring('okx:'.length))
        .toSet();
    final okxWatchedRows = okxWatchedSymbols.isEmpty
        ? const <OkxTickerRow>[]
        : (ref.watch(okxAllTickersProvider).valueOrNull ?? [])
              .where((r) => okxWatchedSymbols.contains(r.symbol))
              .toList();

    if (watchedCoins.isEmpty && okxWatchedRows.isEmpty) {
      return _emptyWatchlist(ref);
    }
    return ListView.separated(
      itemCount: watchedCoins.length + okxWatchedRows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i < watchedCoins.length) {
          return CryptoCoinRow(coin: watchedCoins[i], currency: currency);
        }
        return OkxOnlyCoinRow(row: okxWatchedRows[i - watchedCoins.length]);
      },
    );
  }
}

class _MetalsWatchlistSection extends ConsumerWidget {
  const _MetalsWatchlistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetWatchlist = ref.watch(assetWatchlistProvider);
    final watchedMetalKeys = assetWatchlist
        .where((k) => k.startsWith('metal:'))
        .toList();
    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;

    if (watchedMetalKeys.isEmpty) return _emptyWatchlist(ref);
    return ListView.separated(
      itemCount: watchedMetalKeys.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _MetalWatchRow(watchKey: watchedMetalKeys[i], snap: snap),
    );
  }
}

class _CurrencyWatchlistSection extends ConsumerWidget {
  const _CurrencyWatchlistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetWatchlist = ref.watch(assetWatchlistProvider);
    final watchedCodes = assetWatchlist
        .where((k) => k.startsWith('currency:'))
        .map((k) => k.substring('currency:'.length))
        .toList();
    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;

    if (watchedCodes.isEmpty) return _emptyWatchlist(ref);
    return ListView.separated(
      itemCount: watchedCodes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _CurrencyWatchRow(code: watchedCodes[i], snap: snap),
    );
  }
}

class _CurrencyWatchRow extends ConsumerWidget {
  const _CurrencyWatchRow({required this.code, required this.snap});
  final String code;
  final WealthVnAssetSnapshot? snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rate = snap?.rateFor(code);
    final price = rate?.buyTransfer ?? rate?.buyCash ?? rate?.sell;
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref
                .read(assetWatchlistProvider.notifier)
                .toggle('currency:$code'),
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.star_rounded,
                size: 20,
                color: AppColors.wealthAccent,
              ),
            ),
          ),
          Expanded(
            child: Text(
              code,
              style: AppTextStyles.body(weight: FontWeight.w800),
            ),
          ),
          if (price != null)
            Text(
              formatVnd(price),
              style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
            )
          else
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _StocksWatchlistSection extends ConsumerStatefulWidget {
  const _StocksWatchlistSection();

  @override
  ConsumerState<_StocksWatchlistSection> createState() =>
      _StocksWatchlistSectionState();
}

class _StocksWatchlistSectionState
    extends ConsumerState<_StocksWatchlistSection> {
  // Cac key da goi syncAdd trong phien nay - "vun lai" nhung ma da theo doi
  // TU TRUOC KHI co tinh nang Thong bao gia (xem cung ly do o
  // CryptoWatchlistTab._syncedSymbols).
  final _syncedKeys = <String>{};

  void _backfillServerSync(Set<String> assetWatchlist) {
    for (final key in assetWatchlist) {
      if ((key.startsWith('stock_okx:') || key.startsWith('stock_vn:')) &&
          _syncedKeys.add(key)) {
        AssetWatchlistRepository.syncAdd(key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetWatchlist = ref.watch(assetWatchlistProvider);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _backfillServerSync(assetWatchlist),
    );
    final watchedStockSymbols = assetWatchlist
        .where((k) => k.startsWith('stock:'))
        .map((k) => k.substring('stock:'.length))
        .toList();
    final stockQuotesAsync = ref.watch(
      stocksIntlQuotesProvider(watchedStockSymbols.join(',')),
    );
    final stockQuotes = stockQuotesAsync.valueOrNull ?? [];
    final stockPriceBySymbol = {for (final q in stockQuotes) q.symbol: q};

    final watchedStockVnSymbols = assetWatchlist
        .where((k) => k.startsWith('stock_vn:'))
        .map((k) => k.substring('stock_vn:'.length))
        .toList();
    final stockVnQuotesAsync = ref.watch(
      stocksVnQuotesProvider(watchedStockVnSymbols.join(',')),
    );
    final stockVnQuotes = stockVnQuotesAsync.valueOrNull ?? [];
    final stockVnPriceBySymbol = {for (final q in stockVnQuotes) q.symbol: q};

    final watchedStockOkxSymbols = assetWatchlist
        .where((k) => k.startsWith('stock_okx:'))
        .map((k) => k.substring('stock_okx:'.length))
        .toSet();
    final okxStockRows = watchedStockOkxSymbols.isEmpty
        ? const <OkxTokenizedStock>[]
        : (ref.watch(okxTokenizedStocksProvider).valueOrNull ?? [])
              .where((s) => watchedStockOkxSymbols.contains(s.symbol))
              .toList();

    final total =
        watchedStockSymbols.length +
        watchedStockVnSymbols.length +
        okxStockRows.length;
    if (total == 0) return _emptyWatchlist(ref);

    // Phan tach ro Viet Nam / Quoc te bang 2 nhom co tieu de rieng (KHONG
    // phai 2 tab con - theo yeu cau "phan tach rieng, khong theo tab") -
    // Quoc te gom ca Twelve Data (stock:) lan OKX tokenized (stock_okx:).
    return ListView(
      children: [
        if (watchedStockVnSymbols.isNotEmpty) ...[
          Text(
            ref.tr('wealth_watchlist_stocks_vn'),
            style: AppTextStyles.heading(size: 13),
          ),
          const SizedBox(height: 8),
          for (final symbol in watchedStockVnSymbols) ...[
            _StockWatchRow(
              symbol: symbol,
              quote: stockVnPriceBySymbol[symbol],
              isVn: true,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
        if (watchedStockSymbols.isNotEmpty || okxStockRows.isNotEmpty) ...[
          Text(
            ref.tr('wealth_watchlist_stocks_intl'),
            style: AppTextStyles.heading(size: 13),
          ),
          const SizedBox(height: 8),
          for (final symbol in watchedStockSymbols) ...[
            _StockWatchRow(symbol: symbol, quote: stockPriceBySymbol[symbol]),
            const SizedBox(height: 8),
          ],
          for (final stock in okxStockRows) ...[
            IntlStockRow(stock: stock),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _StockWatchRow extends ConsumerWidget {
  const _StockWatchRow({
    required this.symbol,
    required this.quote,
    this.isVn = false,
  });
  final String symbol;
  final StockQuote? quote;
  final bool isVn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = (quote?.changePercent ?? 0) >= 0;
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref
                .read(assetWatchlistProvider.notifier)
                .toggle(isVn ? 'stock_vn:$symbol' : 'stock:$symbol'),
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.star_rounded,
                size: 20,
                color: AppColors.wealthAccent,
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
                  ? '${quote!.price.toStringAsFixed(0)}đ'
                  : '\$${quote!.price.toStringAsFixed(2)}',
              style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              '${isUp ? '+' : ''}${quote!.changePercent.toStringAsFixed(2)}%',
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
  }
}

class _MetalWatchRow extends ConsumerWidget {
  const _MetalWatchRow({required this.watchKey, required this.snap});
  final String watchKey;
  final WealthVnAssetSnapshot? snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String labelKey;
    double? price;
    String unitKey;
    switch (watchKey) {
      case 'metal:gold_sjc':
        labelKey = 'wealth_metal_gold_sjc';
        price = snap?.goldSjcSell;
        unitKey = 'wealth_metal_unit_luong';
      case 'metal:gold_pnj':
        labelKey = 'wealth_metal_gold_pnj';
        price = snap?.goldPnjSell;
        unitKey = 'wealth_metal_unit_luong';
      default:
        // 'metal:xaut' - gia Tether Gold (XAUT) tu OKX quy doi VND, xem
        // market_metals_tab.dart. Khong con Bac/Dong (da bo hoan toan vi
        // khong tim duoc nguon mien phi hop le ve dieu khoan thuong mai cho
        // ca 2 kim loai nay - xem docs/research-wealth-stock-apis.md).
        final xautUsdPerOz = ref
            .watch(okxXautTickerProvider)
            .valueOrNull
            ?.price;
        final usdVnd = snap?.usdVnd;
        labelKey = 'wealth_metal_gold_xaut';
        price = (xautUsdPerOz != null && usdVnd != null)
            ? xautUsdPerOz / kTroyOunceToLuong * usdVnd
            : null;
        unitKey = 'wealth_metal_unit_luong';
    }
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                ref.read(assetWatchlistProvider.notifier).toggle(watchKey),
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.star_rounded,
                size: 20,
                color: AppColors.wealthAccent,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ref.tr(labelKey),
              style: AppTextStyles.body(weight: FontWeight.w800),
            ),
          ),
          if (price != null)
            Text(
              '${formatVnd(price)}/${ref.tr(unitKey)}',
              style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
            )
          else
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
