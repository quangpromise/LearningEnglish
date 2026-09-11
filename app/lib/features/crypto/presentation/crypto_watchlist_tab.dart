import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_repository.dart';
import '../data/crypto_watchlist_repository.dart';
import '../data/okx_service.dart';
import 'crypto_coin_row.dart';
import 'crypto_providers.dart';
import 'okx_only_coin_row.dart';

/// Danh sach coin nguoi dung "theo doi" (bam sao o tab Market) - chi de xem
/// gia, khong lien quan Portfolio (khong so luong nam giu, khong lai/lo).
class CryptoWatchlistTab extends ConsumerStatefulWidget {
  const CryptoWatchlistTab({super.key});

  @override
  ConsumerState<CryptoWatchlistTab> createState() => _CryptoWatchlistTabState();
}

class _CryptoWatchlistTabState extends ConsumerState<CryptoWatchlistTab> {
  // Cac symbol da goi syncAdd trong phien nay - tranh goi lap lai moi lan
  // widget rebuild (vd moi 30s do auto-refresh gia). Dung de "vun lai" nhung
  // coin da theo doi TU TRUOC KHI co tinh nang Thong bao gia (nen chua bao
  // gio duoc dong bo len price_alert_watchlist, vi luc do sync chi chay o
  // thoi diem BAM SAO - xem CryptoWatchlistRepository.syncAdd) - moi lan mo
  // tab Watchlist se tu dong bo bu nhung coin dang hien thi o day.
  final _syncedSymbols = <String>{};

  void _backfillServerSync(
    List<CryptoCoin> watched,
    List<OkxTickerRow> okxRows,
  ) {
    for (final c in watched) {
      if (_syncedSymbols.add(c.symbol)) {
        CryptoWatchlistRepository.syncAdd(symbol: c.symbol);
      }
    }
    for (final r in okxRows) {
      if (_syncedSymbols.add(r.symbol)) {
        CryptoWatchlistRepository.syncAdd(symbol: r.symbol);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _backfillServerSync(watched, okxWatchedRows),
    );

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
