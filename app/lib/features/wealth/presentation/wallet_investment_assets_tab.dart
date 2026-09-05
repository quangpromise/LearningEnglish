import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
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
    // 'VND' | 'USD' - chi anh huong cach HIEN THI (khong doi cach luu tru),
    // vi tat ca gia tri deu da duoc quy doi VND lam mau so chung ben trong.
    // Luu qua SharedPreferences (investmentDisplayCurrencyProvider) de giu
    // nguyen lua chon o lan mo lai sau, khong tu reset ve VND.
    final displayCurrency = ref.watch(investmentDisplayCurrencyProvider);

    // Crypto: gia tri = gia OKX/CoinGecko (USD) x so luong, quy doi VND.
    // KHONG co gia von (avgCost) duoc luu cho tung lan mua nen dung % thay
    // doi 24h (cung nguon voi man Crypto Portfolio) thay vi PNL so voi von.
    final cryptoHoldings = ref.watch(cryptoPortfolioProvider);
    final liveCoins = ref.watch(liveCoinsProvider(CryptoCurrency.usd));
    final coinById = {for (final c in liveCoins) c.id: c};
    final usdVnd = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
    double cryptoValueVnd = 0;
    double cryptoValue24hAgoVnd = 0;
    if (usdVnd != null) {
      for (final h in cryptoHoldings) {
        final c = coinById[h.coinId];
        if (c == null) continue;
        final v = c.price * h.quantity * usdVnd;
        cryptoValueVnd += v;
        cryptoValue24hAgoVnd += v / (1 + c.change24hPercent / 100);
      }
    }
    final cryptoPercent = cryptoValue24hAgoVnd == 0
        ? null
        : (cryptoValueVnd - cryptoValue24hAgoVnd) / cryptoValue24hAgoVnd * 100;

    // Co phieu: gia hien tai qua stocksIntlQuotesProvider (gia thuc, khong
    // con dung tam avgCost lam gia hien tai) de tinh dung PNL so voi von.
    final stockHoldings =
        ref.watch(wealthHoldingsProvider('stock_intl')).valueOrNull ?? [];
    final stockSymbols = stockHoldings
        .map((h) => h.symbol ?? '')
        .where((s) => s.isNotEmpty)
        .join(',');
    final stockQuotes =
        ref.watch(stocksIntlQuotesProvider(stockSymbols)).valueOrNull ?? [];
    final stockPriceBySymbol = {for (final q in stockQuotes) q.symbol: q.price};
    double stockValueVnd = 0;
    double stockCostVnd = 0;
    if (usdVnd != null) {
      for (final h in stockHoldings) {
        final qty = h.quantity ?? 0;
        final avgCost = h.avgCost ?? 0;
        final price = stockPriceBySymbol[h.symbol] ?? avgCost;
        stockValueVnd += price * qty * usdVnd;
        stockCostVnd += avgCost * qty * usdVnd;
      }
    }
    final stockPnlVnd = stockValueVnd - stockCostVnd;
    final stockPnlPercent = stockCostVnd == 0
        ? null
        : stockPnlVnd / stockCostVnd * 100;

    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
    final goldHoldings =
        ref.watch(wealthHoldingsProvider('gold')).valueOrNull ?? [];
    final silverHoldings =
        ref.watch(wealthHoldingsProvider('silver')).valueOrNull ?? [];
    final copperHoldings =
        ref.watch(wealthHoldingsProvider('copper')).valueOrNull ?? [];
    double metalValueVnd = 0;
    double metalCostVnd = 0;
    for (final h in [...goldHoldings, ...silverHoldings, ...copperHoldings]) {
      metalCostVnd += (h.avgCost ?? 0) * (h.quantity ?? 0);
    }
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
    final metalPnlVnd = metalValueVnd - metalCostVnd;
    final metalPnlPercent = metalCostVnd == 0
        ? null
        : metalPnlVnd / metalCostVnd * 100;

    final realEstateHoldings =
        ref.watch(wealthHoldingsProvider('real_estate')).valueOrNull ?? [];
    final realEstateValueVnd = realEstateHoldings.fold<double>(
      0,
      (s, h) => s + (h.manualValue ?? 0),
    );

    final total =
        cryptoValueVnd + stockValueVnd + metalValueVnd + realEstateValueVnd;

    // Moi gia tri duoc luu ben trong bang VND - khi nguoi dung chon xem
    // theo USD thi chia lai cho ty gia (usdVnd), bo qua neu ty gia chua
    // tai duoc (hien thi tam VND).
    String display(double vnd) {
      if (displayCurrency == 'USD' && usdVnd != null && usdVnd > 0) {
        return formatUsd(vnd / usdVnd);
      }
      return formatVnd(vnd);
    }

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
                      hidden ? '•••••••' : display(total),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ],
                ),
              ),
              _CurrencyToggleChip(
                currency: displayCurrency,
                onChanged: (c) =>
                    ref.read(investmentDisplayCurrencyProvider.notifier).set(c),
              ),
              const SizedBox(width: 10),
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
          value: hidden ? null : display(cryptoValueVnd),
          changeText: hidden || cryptoPercent == null
              ? null
              : '${cryptoPercent >= 0 ? '+' : ''}${cryptoPercent.toStringAsFixed(1)}% (24h)',
          changeColor: cryptoPercent == null
              ? null
              : (cryptoPercent >= 0 ? AppColors.teal : AppColors.pink),
          onTap: () => openAppPopup(context, const CryptoPortfolioScreen()),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.show_chart_rounded,
          color: AppColors.blue,
          title: ref.tr('wealth_investments_stocks_title'),
          value: hidden ? null : display(stockValueVnd),
          changeText: hidden || stockCostVnd == 0
              ? null
              : '${stockPnlVnd >= 0 ? '+' : ''}${display(stockPnlVnd)}'
                    '${stockPnlPercent == null ? '' : ' (${stockPnlPercent >= 0 ? '+' : ''}${stockPnlPercent.toStringAsFixed(1)}%)'}',
          changeColor: stockCostVnd == 0
              ? null
              : (stockPnlVnd >= 0 ? AppColors.teal : AppColors.pink),
          onTap: () => openAppPopup(context, const StockPortfolioScreen()),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.diamond_rounded,
          color: AppColors.wealthAccent,
          title: ref.tr('wealth_investments_metal_title'),
          value: hidden ? null : display(metalValueVnd),
          changeText: hidden || metalCostVnd == 0
              ? null
              : '${metalPnlVnd >= 0 ? '+' : ''}${display(metalPnlVnd)}'
                    '${metalPnlPercent == null ? '' : ' (${metalPnlPercent >= 0 ? '+' : ''}${metalPnlPercent.toStringAsFixed(1)}%)'}',
          changeColor: metalCostVnd == 0
              ? null
              : (metalPnlVnd >= 0 ? AppColors.teal : AppColors.pink),
          onTap: () => openAppPopup(context, const MetalPortfolioScreen()),
        ),
        const SizedBox(height: 10),
        _InvestmentTile(
          icon: Icons.home_work_rounded,
          color: AppColors.teal,
          title: ref.tr('wealth_investments_real_estate_title'),
          value: hidden ? null : display(realEstateValueVnd),
          onTap: () => openAppPopup(context, const RealEstatePortfolioScreen()),
        ),
      ],
    );
  }
}

/// Chuyen doi hien thi tong gia tri dau tu giua VND/USD - chi doi CACH HIEN
/// THI (gia tri goc luu VND khong doi), dung khi nguoi dung muon xem theo
/// gia USD (vi du de so sanh voi gia coin/co phieu the gioi).
class _CurrencyToggleChip extends StatelessWidget {
  const _CurrencyToggleChip({required this.currency, required this.onChanged});
  final String currency;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(currency == 'VND' ? 'USD' : 'VND'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          currency,
          style: AppTextStyles.body(weight: FontWeight.w800, size: 12),
        ),
      ),
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
    this.changeText,
    this.changeColor,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String? value;
  final String? changeText;
  final Color? changeColor;
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value!,
                    style: AppTextStyles.body(
                      weight: FontWeight.w700,
                      size: 12,
                    ),
                  ),
                  if (changeText != null)
                    Text(
                      changeText!,
                      style: AppTextStyles.muted(size: 10.5)
                          .copyWith(color: changeColor),
                    ),
                ],
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
