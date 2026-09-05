import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/okx_service.dart';
import 'crypto_coin_detail_screen.dart';
import 'crypto_providers.dart';

/// 1 dong coin tim thay tren OKX nhung KHONG nam trong top 100 von hoa cua
/// CoinGecko - khong co rank/logo/von hoa/luong luu hanh (OKX khong tra ve
/// nhung thong tin nay), chi hien ma+gia+%24h, bam vao van mo duoc chart
/// chi tiet nhu coin thuong. Dung chung cho tab Market (ket qua tim kiem
/// ngoai top 100) va tab Watchlist (coin ngoai top 100 da theo doi) - key
/// watchlist rieng "okx:SYMBOL" (khac id CoinGecko cua cryptoWatchlistProvider)
/// vi coin nay khong co id CoinGecko.
class OkxOnlyCoinRow extends ConsumerWidget {
  const OkxOnlyCoinRow({super.key, required this.row});
  final OkxTickerRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = row.changePercent24h >= 0;
    final watchlist = ref.watch(cryptoWatchlistProvider);
    final watchKey = 'okx:${row.symbol}';
    final watched = watchlist.contains(watchKey);
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(cryptoWatchlistProvider.notifier).toggle(watchKey),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  watched ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: watched ? AppColors.amber : AppColors.textMuted,
                ),
              ),
            ),
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
