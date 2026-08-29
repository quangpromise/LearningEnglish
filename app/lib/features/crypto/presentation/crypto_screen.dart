import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_repository.dart';

final cryptoTop100Provider = FutureProvider.autoDispose<List<CryptoCoin>>(
  (ref) => CryptoRepository.fetchTop100(),
);

class CryptoScreen extends ConsumerWidget {
  const CryptoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(cryptoTop100Provider);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('crypto_title'),
                        style: AppTextStyles.heading(size: 20),
                      ),
                      Text(
                        ref.tr('crypto_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.invalidate(cryptoTop100Provider),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: coins.when(
                data: (list) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(cryptoTop100Provider),
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _CoinTile(coin: list[i]),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.textMuted,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ref.tr('crypto_error'),
                        style: AppTextStyles.muted(),
                      ),
                      const SizedBox(height: 14),
                      PillButton(
                        label: ref.tr('crypto_retry'),
                        onTap: () => ref.invalidate(cryptoTop100Provider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price >= 1) return '\$${price.toStringAsFixed(2)}';
  if (price >= 0.01) return '\$${price.toStringAsFixed(4)}';
  return '\$${price.toStringAsFixed(8)}';
}

String _formatMarketCap(double cap) {
  if (cap >= 1e12) return '\$${(cap / 1e12).toStringAsFixed(2)}T';
  if (cap >= 1e9) return '\$${(cap / 1e9).toStringAsFixed(2)}B';
  if (cap >= 1e6) return '\$${(cap / 1e6).toStringAsFixed(2)}M';
  return '\$${cap.toStringAsFixed(0)}';
}

class _CoinTile extends StatelessWidget {
  const _CoinTile({required this.coin});
  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) {
    final isUp = coin.change24hPercent >= 0;
    final changeColor = isUp ? AppColors.teal : AppColors.pink;
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('${coin.rank}', style: AppTextStyles.muted(size: 12)),
          ),
          const SizedBox(width: 8),
          ClipOval(
            child: Image.network(
              coin.imageUrl,
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) =>
                  Container(width: 28, height: 28, color: AppColors.glassFill),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin.name,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${coin.symbol} · ${_formatMarketCap(coin.marketCapUsd)}',
                  style: AppTextStyles.muted(size: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(coin.priceUsd),
                style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
              ),
              Text(
                '${isUp ? '+' : ''}${coin.change24hPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
