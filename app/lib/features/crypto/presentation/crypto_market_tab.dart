import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
import '../data/okx_service.dart';
import 'crypto_coin_detail_screen.dart';
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
            return _OkxOnlyCoinRow(row: extraOkx[j - 1]);
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

/// 1 dong coin tim thay tren OKX nhung KHONG nam trong top 100 von hoa cua
/// CoinGecko - khong co rank/logo/von hoa/luong luu hanh (OKX khong tra ve
/// nhung thong tin nay), chi hien ma+gia+%24h, bam vao van mo duoc chart
/// chi tiet nhu coin thuong.
class _OkxOnlyCoinRow extends StatelessWidget {
  const _OkxOnlyCoinRow({required this.row});
  final OkxTickerRow row;

  @override
  Widget build(BuildContext context) {
    final isUp = row.changePercent24h >= 0;
    return GestureDetector(
      onTap: () => openAppPopup(
        context,
        CryptoCoinDetailScreen(
          symbol: row.symbol,
          name: row.symbol,
          fallbackPrice: row.price,
          fallbackChangePercent: row.changePercent24h,
        ),
      ),
      child: GlowBox(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.glassFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.currency_bitcoin_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                row.symbol,
                style: AppTextStyles.body(weight: FontWeight.w800, size: 12.5),
              ),
            ),
            Text(
              '\$${row.price.toStringAsFixed(row.price >= 1 ? 2 : 6)}',
              style: AppTextStyles.body(weight: FontWeight.w800, size: 11.5),
            ),
            const SizedBox(width: 8),
            Text(
              '${isUp ? '+' : ''}${row.changePercent24h.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isUp ? AppColors.teal : AppColors.pink,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
