import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../crypto/presentation/crypto_market_tab.dart';
import '../../crypto/presentation/crypto_watchlist_tab.dart';
import 'market_metals_tab.dart';
import 'market_real_estate_tab.dart';
import 'market_stocks_tab.dart';

/// Man Market (Phase F) - 4 tab gia thi truong real-time cho 4 loai tai san
/// dau tu: Crypto (giu nguyen CoinGecko+OKX WebSocket, chi con Market+
/// Watchlist vi Portfolio da chuyen sang Vi), Chung khoan, Kim loai, Nha dat.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  isScrollable: true,
                  indicator: BoxDecoration(
                    gradient: AppColors.wealthAccentGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  tabs: [
                    const Tab(text: 'Crypto'),
                    Tab(text: ref.tr('wealth_investments_stocks_title')),
                    Tab(text: ref.tr('wealth_investments_metal_title')),
                    Tab(text: ref.tr('wealth_investments_real_estate_title')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _CryptoMarketAndWatchlist(),
                  MarketStocksTab(),
                  MarketMetalsTab(),
                  MarketRealEstateTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhung lai Market+Watchlist cua Crypto (khong co Portfolio - da chuyen
/// sang Vi) bang 1 TabBar phu nho ben trong, giu nguyen toggle USD/VND.
class _CryptoMarketAndWatchlist extends ConsumerStatefulWidget {
  const _CryptoMarketAndWatchlist();

  @override
  ConsumerState<_CryptoMarketAndWatchlist> createState() =>
      _CryptoMarketAndWatchlistState();
}

class _CryptoMarketAndWatchlistState
    extends ConsumerState<_CryptoMarketAndWatchlist>
    with SingleTickerProviderStateMixin {
  late final TabController _innerTab;

  @override
  void initState() {
    super.initState();
    _innerTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _innerTab,
          labelColor: AppColors.wealthAccent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.wealthAccent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          tabs: [
            Tab(text: ref.tr('crypto_tab_market')),
            Tab(text: ref.tr('crypto_tab_watchlist')),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: _innerTab,
            children: const [CryptoMarketTab(), CryptoWatchlistTab()],
          ),
        ),
      ],
    );
  }
}
