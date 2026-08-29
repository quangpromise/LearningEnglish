import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'crypto_coin_row.dart';
import 'crypto_providers.dart';

/// Danh sach coin nguoi dung "theo doi" (bam sao o tab Market) - chi de xem
/// gia, khong lien quan Portfolio (khong so luong nam giu, khong lai/lo).
class CryptoWatchlistTab extends ConsumerWidget {
  const CryptoWatchlistTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final watchlist = ref.watch(cryptoWatchlistProvider);
    final coinsAsync = ref.watch(cryptoTop100Provider(currency));

    if (!coinsAsync.hasValue) {
      if (coinsAsync.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(ref.tr('crypto_error'), style: AppTextStyles.muted()),
      );
    }

    final list = ref.watch(liveCoinsProvider(currency));
    final watched = list.where((c) => watchlist.contains(c.id)).toList();

    if (watched.isEmpty) {
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

    return ListView.separated(
      itemCount: watched.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          CryptoCoinRow(coin: watched[i], currency: currency),
    );
  }
}
