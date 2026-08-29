import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_currency.dart';
import 'crypto_coin_picker_sheet.dart';
import 'crypto_market_tab.dart';
import 'crypto_portfolio_tab.dart';
import 'crypto_providers.dart';

class CryptoScreen extends ConsumerStatefulWidget {
  const CryptoScreen({super.key});

  @override
  ConsumerState<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends ConsumerState<CryptoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(cryptoCurrencyProvider);
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
                  child: Text(
                    ref.tr('crypto_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                _CurrencyToggle(currency: currency),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_tabController.index != 1) {
                      _tabController.animateTo(1);
                    }
                    showCryptoCoinPicker(context, ref);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassBorder),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                tabs: [
                  Tab(text: ref.tr('crypto_tab_market')),
                  Tab(text: ref.tr('crypto_tab_portfolio')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [CryptoMarketTab(), CryptoPortfolioTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyToggle extends ConsumerWidget {
  const _CurrencyToggle({required this.currency});
  final CryptoCurrency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CryptoCurrency.values.map((c) {
          final selected = c == currency;
          return GestureDetector(
            onTap: () => ref.read(cryptoCurrencyProvider.notifier).state = c,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.accentGradient : null,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                c.code.toUpperCase(),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
