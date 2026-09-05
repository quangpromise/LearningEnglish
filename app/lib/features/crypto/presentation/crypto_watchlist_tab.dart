import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/okx_service.dart';
import 'crypto_coin_row.dart';
import 'crypto_providers.dart';
import 'okx_only_coin_row.dart';

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

    // Coin ngoai top 100 da theo doi tu ket qua tim kiem (key "okx:SYMBOL",
    // xem OkxOnlyCoinRow) - khong co trong `list` (chi top 100 von hoa) nen
    // phai lay rieng tu okxAllTickersProvider.
    final okxWatchedSymbols = watchlist
        .where((k) => k.startsWith('okx:'))
        .map((k) => k.substring('okx:'.length))
        .toSet();
    final okxWatchedRows = okxWatchedSymbols.isEmpty
        ? const <OkxTickerRow>[]
        : (ref.watch(okxAllTickersProvider).valueOrNull ?? [])
              .where((r) => okxWatchedSymbols.contains(r.symbol))
              .toList();

    if (watched.isEmpty && okxWatchedRows.isEmpty) {
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
      itemCount: watched.length + okxWatchedRows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i < watched.length) {
          return CryptoCoinRow(coin: watched[i], currency: currency);
        }
        return OkxOnlyCoinRow(row: okxWatchedRows[i - watched.length]);
      },
    );
  }
}
