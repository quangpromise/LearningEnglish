import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../crypto/data/crypto_currency.dart';
import '../../crypto/presentation/crypto_portfolio_screen.dart';
import '../../crypto/presentation/crypto_providers.dart';
import 'metal_portfolio_screen.dart';
import 'real_estate_portfolio_screen.dart';
import 'stock_portfolio_screen.dart';

/// Tab "Tai san dau tu" trong man Vi (Phase C) - 4 the: Crypto/Co phieu/
/// Kim loai quy/Nha dat, moi the mo 1 man Portfolio rieng. Thay the
/// WealthInvestmentsTab cu (chi co Crypto+Co phieu, Crypto la link ngoai
/// sang CryptoScreen thay vi Portfolio thuc).
class WalletInvestmentAssetsTab extends ConsumerWidget {
  const WalletInvestmentAssetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(investmentPrivacyModeProvider);

    // Crypto: gia tri = gia OKX/CoinGecko (USD) x so luong, quy doi VND.
    final cryptoHoldings = ref.watch(cryptoPortfolioProvider);
    final liveCoins = ref.watch(liveCoinsProvider(CryptoCurrency.usd));
    final coinPriceById = {for (final c in liveCoins) c.id: c.price};
    final usdVnd = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
    double cryptoValueVnd = 0;
    if (usdVnd != null) {
      for (final h in cryptoHoldings) {
        final price = coinPriceById[h.coinId];
        if (price != null) cryptoValueVnd += price * h.quantity * usdVnd;
      }
    }

    // Co phieu: can gia hien tai qua stocksIntlQuotesProvider - tinh don
    // gian bang gia von (avgCost) x so luong quy doi VND lam uoc luong khi
    // chua co gia moi nhat trong bo nho cache cua provider gia.
    final stockHoldings =
        ref.watch(wealthHoldingsProvider('stock_intl')).valueOrNull ?? [];
    double stockValueVnd = 0;
    if (usdVnd != null) {
      for (final h in stockHoldings) {
        stockValueVnd += (h.avgCost ?? 0) * (h.quantity ?? 0) * usdVnd;
      }
    }

    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
    final goldHoldings =
        ref.watch(wealthHoldingsProvider('gold')).valueOrNull ?? [];
    final silverHoldings =
        ref.watch(wealthHoldingsProvider('silver')).valueOrNull ?? [];
    final copperHoldings =
        ref.watch(wealthHoldingsProvider('copper')).valueOrNull ?? [];
    double metalValueVnd = 0;
    if (snap != null) {
      final goldPrice = snap.goldSjcSell ?? snap.goldPnjSell;
      if (goldPrice != null) {
        for (final h in goldHoldings) {
          metalValueVnd += goldPrice * (h.quantity ?? 0);
        }
      }
      if (snap.xagVndPerLuong != null) {
        for (final h in silverHoldings) {
          metalValueVnd += snap.xagVndPerLuong! * (h.quantity ?? 0);
        }
      }
      if (snap.xcuVndPerKg != null) {
        for (final h in copperHoldings) {
          metalValueVnd += snap.xcuVndPerKg! * (h.quantity ?? 0);
        }
      }
    }

    final realEstateHoldings =
        ref.watch(wealthHoldingsProvider('real_estate')).valueOrNull ?? [];
    final realEstateValueVnd = realEstateHoldings.fold<double>(
      0,
      (s, h) => s + (h.manualValue ?? 0),
    );

    final total =
        cryptoValueVnd + stockValueVnd + metalValueVnd + realEstateValueVnd;

    return ListView(
      children: [
        GlowBox(
          padding: const EdgeInsets.all(16),
          borderRadius: 18,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_investments_total'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hidden ? '•••••••' : formatVnd(total),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(investmentPrivacyModeProvider.notifier).toggle(),
                child: Icon(
                  hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InvestmentTile(
          icon: Icons.currency_bitcoin_rounded,
          color: AppColors.amber,
          title: ref.tr('wealth_investments_crypto_title'),
          value: hidden ? null : formatVnd(cryptoValueVnd),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CryptoPortfolioScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.show_chart_rounded,
          color: AppColors.blue,
          title: ref.tr('wealth_investments_stocks_title'),
          value: hidden ? null : formatVnd(stockValueVnd),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StockPortfolioScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.diamond_rounded,
          color: AppColors.wealthAccent,
          title: ref.tr('wealth_investments_metal_title'),
          value: hidden ? null : formatVnd(metalValueVnd),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MetalPortfolioScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.home_work_rounded,
          color: AppColors.teal,
          title: ref.tr('wealth_investments_real_estate_title'),
          value: hidden ? null : formatVnd(realEstateValueVnd),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RealEstatePortfolioScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body(weight: FontWeight.w800),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
