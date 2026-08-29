import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
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
              _CoinRow(coin: filtered[i], currency: currency),
        ),
      );
    }
    if (coins.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return _MarketError(currency: currency);
  }
}

/// 1 dong coin gon trong 2 dong chu - CA 4 chi so (Gia, 24h%, Von hoa,
/// Luong luu hanh) deu nam trong be rong man hinh, khong can cuon ngang -
/// thay the cho DataTable truoc day (buoc phai cuon ngang moi thay het cot).
class _CoinRow extends StatelessWidget {
  const _CoinRow({required this.coin, required this.currency});
  final CryptoCoin coin;
  final CryptoCurrency currency;

  @override
  Widget build(BuildContext context) {
    final isUp = coin.change24hPercent >= 0;
    final changeColor = isUp ? AppColors.teal : AppColors.pink;
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16,
            child: Text('${coin.rank}', style: AppTextStyles.muted(size: 10)),
          ),
          const SizedBox(width: 4),
          ClipOval(
            child: Image.network(
              coin.imageUrl,
              width: 24,
              height: 24,
              errorBuilder: (_, _, _) =>
                  Container(width: 24, height: 24, color: AppColors.glassFill),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          weight: FontWeight.w800,
                          size: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatCryptoPrice(coin.price, currency),
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        size: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${coin.symbol} · ${formatCryptoCompact(coin.marketCap, currency)} · ${formatSupply(coin.circulatingSupply, coin.symbol)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(size: 9.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isUp ? '+' : ''}${coin.change24hPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
