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
import '../data/exchange_rate_repository.dart';
import '../data/stocks_intl_repository.dart';
import 'market_metals_tab.dart';
import 'market_real_estate_tab.dart';
import 'market_stocks_tab.dart';

/// Man Market (Phase F, redesign theo yeu cau gop chung) - 2 tab o TREN
/// CUNG: "Market" (chon loai tai san bang chip ben trong: Crypto/Co phieu/
/// Kim loai hiem/Nha dat, giong cach 1 san giao dich that gop chung cac thi
/// truong) va "Watchlist" (gop TAT CA item da "theo doi" tu moi loai tai
/// san vao 1 danh sach duy nhat) - thay the cau truc cu la 4 tab rieng biet
/// (bi tran chu khi isScrollable + 4 tab dai).
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

enum _MarketCategory { crypto, stocks, metals, realEstate }

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _MarketCategory _category = _MarketCategory.crypto;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                      ref.tr('wealth_market_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Consumer(
              builder: (context, ref, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.wealthAccentGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: [
                    Tab(text: ref.tr('crypto_tab_market')),
                    Tab(text: ref.tr('crypto_tab_watchlist')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer(
                        builder: (context, ref, _) => _CategoryChipRow(
                          selected: _category,
                          onChanged: (c) => setState(() => _category = c),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildCategoryContent()),
                    ],
                  ),
                  const _UnifiedWatchlistTab(),
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
      case _MarketCategory.realEstate:
        return const MarketRealEstateTab();
    }
  }
}

/// Hang chip chon loai tai san dang xem trong tab "Market" - thay the 4 tab
/// rieng bi tran chu truoc day, chip co the xuong dong neu khong vua 1 hang.
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
      (
        _MarketCategory.realEstate,
        ref.tr('wealth_investments_real_estate_title'),
      ),
    ];
    // Vien chung boc quanh CA 4 chip - phan biet ro day la nhom "chon loai
    // thi truong" (cap tren), khac voi cac chip con rieng cua tung loai (vd
    // "Quoc te/Viet Nam" trong Chung khoan, "Vang/Bac/Dong" trong Kim loai)
    // hien o ngay ben duoi, tranh nhin gay nham la cung 1 nhom.
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.glassFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: () => onChanged(item.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
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
                child: Text(
                  item.$2,
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
        ],
      ),
    );
  }
}

/// Gop TAT CA item da "theo doi" tu moi loai tai san (Crypto qua
/// [cryptoWatchlistProvider] rieng, Co phieu/Kim loai qua
/// [assetWatchlistProvider] chung) vao 1 danh sach duy nhat, chia theo tung
/// nhom neu nhom do co it nhat 1 item.
class _UnifiedWatchlistTab extends ConsumerWidget {
  const _UnifiedWatchlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final cryptoWatchlist = ref.watch(cryptoWatchlistProvider);
    final liveCoins = ref.watch(liveCoinsProvider(currency));
    final watchedCoins = liveCoins
        .where((c) => cryptoWatchlist.contains(c.id))
        .toList();

    final assetWatchlist = ref.watch(assetWatchlistProvider);
    final watchedStockSymbols = assetWatchlist
        .where((k) => k.startsWith('stock:'))
        .map((k) => k.substring('stock:'.length))
        .toList();
    final stockQuotesAsync = ref.watch(
      stocksIntlQuotesProvider(watchedStockSymbols),
    );
    final stockQuotes = stockQuotesAsync.valueOrNull ?? [];
    final stockPriceBySymbol = {for (final q in stockQuotes) q.symbol: q};

    final watchedStockVnSymbols = assetWatchlist
        .where((k) => k.startsWith('stock_vn:'))
        .map((k) => k.substring('stock_vn:'.length))
        .toList();
    final stockVnQuotesAsync = ref.watch(
      stocksVnQuotesProvider(watchedStockVnSymbols),
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

    final watchedMetalKeys = assetWatchlist
        .where((k) => k.startsWith('metal:'))
        .toList();
    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;

    final isEmpty =
        watchedCoins.isEmpty &&
        watchedStockSymbols.isEmpty &&
        watchedStockVnSymbols.isEmpty &&
        watchedStockOkxSymbols.isEmpty &&
        watchedMetalKeys.isEmpty;

    if (isEmpty) {
      return Center(
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
    }

    return ListView(
      children: [
        if (watchedCoins.isNotEmpty) ...[
          Text('Crypto', style: AppTextStyles.heading(size: 13)),
          const SizedBox(height: 8),
          for (final coin in watchedCoins) ...[
            CryptoCoinRow(coin: coin, currency: currency),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
        if (watchedStockSymbols.isNotEmpty) ...[
          Text(
            ref.tr('wealth_investments_stocks_title'),
            style: AppTextStyles.heading(size: 13),
          ),
          const SizedBox(height: 8),
          for (final symbol in watchedStockSymbols) ...[
            _StockWatchRow(symbol: symbol, quote: stockPriceBySymbol[symbol]),
            const SizedBox(height: 8),
          ],
          for (final symbol in watchedStockVnSymbols) ...[
            _StockWatchRow(
              symbol: symbol,
              quote: stockVnPriceBySymbol[symbol],
              isVn: true,
            ),
            const SizedBox(height: 8),
          ],
          for (final stock in okxStockRows) ...[
            IntlStockRow(stock: stock),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
        if (watchedMetalKeys.isNotEmpty) ...[
          Text(
            ref.tr('wealth_investments_metal_title'),
            style: AppTextStyles.heading(size: 13),
          ),
          const SizedBox(height: 8),
          for (final key in watchedMetalKeys) ...[
            _MetalWatchRow(watchKey: key, snap: snap),
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
      case 'metal:silver':
        labelKey = 'wealth_metal_silver_world';
        price = snap?.xagVndPerLuong;
        unitKey = 'wealth_metal_unit_luong';
      default:
        labelKey = 'wealth_metal_copper_world';
        price = snap?.xcuVndPerKg;
        unitKey = 'wealth_metal_unit_kg';
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
