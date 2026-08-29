import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
import 'crypto_coin_row.dart';
import 'crypto_providers.dart';

class CryptoMarketTab extends ConsumerStatefulWidget {
  const CryptoMarketTab({super.key});

  @override
  ConsumerState<CryptoMarketTab> createState() => _CryptoMarketTabState();
}

class _CryptoMarketTabState extends ConsumerState<CryptoMarketTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final coins = ref.watch(cryptoTop100Provider(currency));

    return Column(
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
                      setState(() => _query = v.trim().toLowerCase()),
                  style: AppTextStyles.body(size: 13),
                  cursorColor: AppColors.purple,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: ref.tr('crypto_search_hint'),
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
        Expanded(child: _buildBody(coins, currency)),
      ],
    );
  }

  // Uu tien hien du lieu CU (coins.hasValue) neu da tung tai duoc thanh cong
  // truoc do, ke ca khi lan fetch gan nhat loi (vd CoinGecko rate-limit) -
  // tranh man hinh nhap nhay ve loi "khong tai duoc" chi vi 1 request bi
  // tu choi thoang qua.
  Widget _buildBody(
    AsyncValue<List<CryptoCoin>> coins,
    CryptoCurrency currency,
  ) {
    if (coins.hasValue) {
      final list = ref.watch(liveCoinsProvider(currency));
      final filtered = _query.isEmpty
          ? list
          : list
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(_query) ||
                      c.symbol.toLowerCase().contains(_query),
                )
                .toList();
      if (filtered.isEmpty) {
        return Center(
          child: Text(
            ref.tr('crypto_no_results'),
            style: AppTextStyles.muted(),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(cryptoTop100Provider(currency)),
        child: ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              CryptoCoinRow(coin: filtered[i], currency: currency),
        ),
      );
    }
    if (coins.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return _MarketError(currency: currency);
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
