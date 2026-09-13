import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../crypto/presentation/crypto_portfolio_screen.dart';
import 'foreign_currency_portfolio_screen.dart';
import 'metal_portfolio_screen.dart';
import 'real_estate_portfolio_screen.dart';
import 'stock_portfolio_screen.dart';
import 'wallet_investment_assets_tab.dart';

enum _InvestmentStep { list, crypto, stock, metal, realEstate, currency }

/// Man Dau tu rieng biet - truoc day noi dung nay la 1 tab ben trong man Vi
/// ("Tai san dau tu"), gio tach thanh man rieng mo tu the "Tong Dau tu" o
/// carousel dau man Home Quan ly tai san (xem wealth_home_screen.dart) -
/// theo yeu cau nguoi dung tach biet Dau tu khoi Vi.
///
/// State-machine 1 popup duy nhat: 5 loai Portfolio (Crypto/Co phieu/Kim
/// loai/Nha dat/Ngoai te) hien INLINE thay vi moi loai mo 1 openAppPopup
/// rieng chong len, de swipe xuong/tap ngoai luon dong het ve Home dung 1
/// lan, khong con "pop-up long pop-up".
class WealthInvestmentScreen extends ConsumerStatefulWidget {
  const WealthInvestmentScreen({super.key});

  @override
  ConsumerState<WealthInvestmentScreen> createState() =>
      _WealthInvestmentScreenState();
}

class _WealthInvestmentScreenState
    extends ConsumerState<WealthInvestmentScreen> {
  _InvestmentStep _step = _InvestmentStep.list;

  void _backToList() => setState(() => _step = _InvestmentStep.list);

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: switch (_step) {
          _InvestmentStep.crypto => CryptoPortfolioScreen(onBack: _backToList),
          _InvestmentStep.stock => StockPortfolioScreen(onBack: _backToList),
          _InvestmentStep.metal => MetalPortfolioScreen(onBack: _backToList),
          _InvestmentStep.realEstate => RealEstatePortfolioScreen(
            onBack: _backToList,
          ),
          _InvestmentStep.currency => ForeignCurrencyPortfolioScreen(
            onBack: _backToList,
          ),
          _InvestmentStep.list => _buildList(context),
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
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
                ref.tr('wealth_investments_total'),
                style: AppTextStyles.heading(size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: WalletInvestmentAssetsTab(
            onOpenCrypto: () => setState(() => _step = _InvestmentStep.crypto),
            onOpenStock: () => setState(() => _step = _InvestmentStep.stock),
            onOpenMetal: () => setState(() => _step = _InvestmentStep.metal),
            onOpenRealEstate: () =>
                setState(() => _step = _InvestmentStep.realEstate),
            onOpenCurrency: () =>
                setState(() => _step = _InvestmentStep.currency),
          ),
        ),
      ],
    );
  }
}
