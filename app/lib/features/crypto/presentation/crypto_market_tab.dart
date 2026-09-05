import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
import '../data/okx_service.dart';
import 'crypto_coin_row.dart';
import 'crypto_providers.dart';
import 'okx_only_coin_row.dart';

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
      // Ngoai top 100 von hoa (CoinGecko), tim them trong TOAN BO cap USDT
      // tren OKX khi nguoi dung go tim kiem - vd "PEPE"/"WIF" khong lot top
      // 100 nhung van niem yet tren OKX. Khong co ten day du/logo (chi ma) -
      // hien o 1 nhom rieng "Ket qua khac" ben duoi ket qua top 100.
      final extraOkx = _query.isEmpty
          ? const <OkxTickerRow>[]
          : (ref.watch(okxAllTickersProvider).valueOrNull ?? [])
                .where(
                  (r) =>
                      r.symbol.toLowerCase().contains(_query) &&
                      !filtered.any((c) => c.symbol == r.symbol),
                )
                .take(30)
                .toList();

      if (filtered.isEmpty && extraOkx.isEmpty) {
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
          itemCount:
              filtered.length + (extraOkx.isEmpty ? 0 : extraOkx.length + 1),
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i < filtered.length) {
              return CryptoCoinRow(coin: filtered[i], currency: currency);
            }
            final j = i - filtered.length;
            if (j == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  ref.tr('crypto_other_results'),
                  style: AppTextStyles.muted(size: 11),
                ),
              );
            }
            return OkxOnlyCoinRow(row: extraOkx[j - 1]);
          },
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
