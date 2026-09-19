import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../crypto/presentation/crypto_portfolio_screen.dart';
import 'foreign_currency_portfolio_screen.dart';
import 'investment_value_chart.dart';
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
            const PopupBackButton(),
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
        // Bieu do gia tri danh muc theo thoi gian - dat TREN danh sach tai
        // san: mo man nay ra la thay ngay danh muc dang len hay xuong, roi
        // moi den chi tiet tung nhom.
        GlowBox(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          borderRadius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nut VND/USD + con mat nam ngay canh tieu de bieu do. Truoc
              // day chung o the "Tong tai san dau tu" ben duoi bieu do - ma
              // the do lai hien LAI dung con so bieu do da hien, nen da bo
              // han the, chuyen 2 nut nay len day.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr('investment_chart_title'),
                      style: AppTextStyles.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CurrencyToggleChip(
                    currency: ref.watch(investmentDisplayCurrencyProvider),
                    onChanged: (c) => ref
                        .read(investmentDisplayCurrencyProvider.notifier)
                        .set(c),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => ref
                        .read(investmentPrivacyModeProvider.notifier)
                        .toggle(),
                    child: Icon(
                      ref.watch(investmentPrivacyModeProvider)
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const InvestmentValueChart(),
            ],
          ),
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
