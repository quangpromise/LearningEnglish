import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_portfolio_repository.dart';
import '../data/crypto_repository.dart';
import '../data/crypto_transaction_repository.dart';
import '../../wealth/presentation/confirm_delete.dart';
import 'crypto_providers.dart';

class CryptoPortfolioTab extends ConsumerWidget {
  const CryptoPortfolioTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final holdings = ref.watch(cryptoPortfolioProvider);
    final coinsAsync = ref.watch(cryptoTop100Provider(currency));
    final hidden = ref.watch(cryptoPrivacyModeProvider);

    // Uu tien du lieu CU con hieu luc (xem ly do trong crypto_market_tab.dart)
    // thay vi doi thanh man hinh loi moi khi 1 lan tu dong lam moi bi that bai.
    if (coinsAsync.hasValue) {
      final coins = ref.watch(liveCoinsProvider(currency));
      final byId = {for (final c in coins) c.id: c};
      double valueNow = 0;
      double value24hAgo = 0;
      for (final h in holdings) {
        final c = byId[h.coinId];
        if (c == null) continue;
        final v = c.price * h.quantity;
        valueNow += v;
        value24hAgo += v / (1 + c.change24hPercent / 100);
      }
      final pct = value24hAgo == 0
          ? 0.0
          : (valueNow - value24hAgo) / value24hAgo * 100;
      final isUp = pct >= 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlowBox(
            borderRadius: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('crypto_total_value'),
                        style: AppTextStyles.muted(size: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hidden
                            ? '********'
                            : formatCryptoPrice(valueNow, currency),
                        style: AppTextStyles.heading(size: 26),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isUp ? '+' : ''}${pct.toStringAsFixed(2)}% (24h)',
                        style: TextStyle(
                          color: isUp ? AppColors.teal : AppColors.pink,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ref.read(cryptoPrivacyModeProvider.notifier).toggle(),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openHistory(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: holdings.isEmpty
                ? Center(
                    child: Text(
                      ref.tr('crypto_portfolio_empty'),
                      style: AppTextStyles.muted(),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: holdings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _HoldingTile(
                      holding: holdings[i],
                      coin: byId[holdings[i].coinId],
                      currency: currency,
                    ),
                  ),
          ),
        ],
      );
    }
    if (coinsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Text(ref.tr('crypto_error'), style: AppTextStyles.muted()),
    );
  }

  void _openHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HistorySheet(),
    );
  }
}

class _HoldingTile extends ConsumerWidget {
  const _HoldingTile({
    required this.holding,
    required this.coin,
    required this.currency,
  });

  final CryptoHolding holding;
  final CryptoCoin? coin;
  final CryptoCurrency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = coin?.price ?? 0;
    final change = coin?.change24hPercent ?? 0;
    final isUp = change >= 0;
    final value = price * holding.quantity;
    final hidden = ref.watch(cryptoPrivacyModeProvider);

    return Dismissible(
      key: ValueKey(holding.coinId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      onDismissed: (_) =>
          ref.read(cryptoPortfolioProvider.notifier).remove(holding.coinId),
      child: GestureDetector(
        onTap: () => _openBuySell(context, ref),
        child: GlowBox(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  holding.imageUrl,
                  width: 30,
                  height: 30,
                  errorBuilder: (_, _, _) => Container(
                    width: 30,
                    height: 30,
                    color: AppColors.glassFill,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.name,
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                    Text(
                      hidden
                          ? '**** ${holding.symbol}'
                          : '${holding.quantity} ${holding.symbol}',
                      style: AppTextStyles.muted(size: 12),
                    ),
                    Text(
                      '@ ${formatCryptoPrice(price, currency)}',
                      style: AppTextStyles.muted(size: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hidden ? '******' : formatCryptoPrice(value, currency),
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                  Text(
                    '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isUp ? AppColors.teal : AppColors.pink,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBuySell(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<_BuySellResult>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          '${holding.name} (${holding.symbol})',
          style: AppTextStyles.heading(size: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ref.tr('crypto_currently_holding')}: ${holding.quantity} ${holding.symbol}',
              style: AppTextStyles.muted(size: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTextStyles.muted(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(ref.tr('crypto_cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.pink.withValues(alpha: 0.16),
            ),
            onPressed: () {
              final q = double.tryParse(controller.text.replaceAll(',', '.'));
              if (q == null || q <= 0) return;
              Navigator.of(dialogContext)
                  .pop(_BuySellResult(isBuy: false, quantity: q));
            },
            child: Text(
              ref.tr('crypto_sell'),
              style: const TextStyle(
                color: AppColors.pink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.teal.withValues(alpha: 0.16),
            ),
            onPressed: () {
              final q = double.tryParse(controller.text.replaceAll(',', '.'));
              if (q == null || q <= 0) return;
              Navigator.of(dialogContext)
                  .pop(_BuySellResult(isBuy: true, quantity: q));
            },
            child: Text(
              ref.tr('crypto_buy'),
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (result == null) return;

    final notifier = ref.read(cryptoPortfolioProvider.notifier);
    if (result.isBuy) {
      await notifier.buy(
        coinId: holding.coinId,
        symbol: holding.symbol,
        name: holding.name,
        imageUrl: holding.imageUrl,
        quantity: result.quantity,
        priceAtTime: coin?.price ?? 0,
      );
    } else {
      await notifier.sell(
        coinId: holding.coinId,
        quantity: result.quantity,
        priceAtTime: coin?.price ?? 0,
      );
    }
  }
}

class _BuySellResult {
  const _BuySellResult({required this.isBuy, required this.quantity});
  final bool isBuy;
  final double quantity;
}

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cryptoTransactionHistoryProvider);
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ScreenBackground(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ref.tr('crypto_history_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                    ),
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
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: switch (historyAsync) {
                    AsyncData(:final value) when value.isEmpty => Center(
                      child: Text(
                        ref.tr('crypto_history_empty'),
                        style: AppTextStyles.muted(),
                      ),
                    ),
                    AsyncData(:final value) => ListView.separated(
                      itemCount: value.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _HistoryRow(transaction: value[i]),
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.transaction});
  final CryptoTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.type == CryptoTransactionType.buy;
    final color = isBuy ? AppColors.teal : AppColors.pink;
    final t = transaction.timestamp;
    final dateLabel =
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              transaction.imageUrl,
              width: 26,
              height: 26,
              errorBuilder: (_, _, _) =>
                  Container(width: 26, height: 26, color: AppColors.glassFill),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
                ),
                Text(dateLabel, style: AppTextStyles.muted(size: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isBuy ? '+' : '-'}${transaction.quantity} ${transaction.symbol}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                '@ \$${transaction.priceAtTime.toStringAsFixed(2)}',
                style: AppTextStyles.muted(size: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
