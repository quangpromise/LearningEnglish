import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_repository.dart';
import 'crypto_providers.dart';

/// 1 dong coin gon trong 2 dong chu - CA 4 chi so (Gia, 24h%, Von hoa,
/// Luong luu hanh) deu nam trong be rong man hinh, khong can cuon ngang -
/// dung chung cho tab Market va tab Watchlist. Co 1 nut sao de
/// them/bo khoi watchlist ngay tren dong, khong can mo man rieng.
class CryptoCoinRow extends ConsumerWidget {
  const CryptoCoinRow({super.key, required this.coin, required this.currency});

  final CryptoCoin coin;
  final CryptoCurrency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = coin.change24hPercent >= 0;
    final changeColor = isUp ? AppColors.teal : AppColors.pink;
    final watchlist = ref.watch(cryptoWatchlistProvider);
    final watched = watchlist.contains(coin.id);
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                ref.read(cryptoWatchlistProvider.notifier).toggle(coin.id),
            child: Padding(
              padding: const EdgeInsets.only(right: 4, top: 1),
              child: Icon(
                watched ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: watched ? AppColors.amber : AppColors.textMuted,
              ),
            ),
          ),
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
