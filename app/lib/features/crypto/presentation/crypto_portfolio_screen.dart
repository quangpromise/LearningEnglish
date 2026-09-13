import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'crypto_coin_detail_screen.dart';
import 'crypto_coin_picker_sheet.dart';
import 'crypto_portfolio_tab.dart';
import 'crypto_providers.dart';

/// Man Portfolio Crypto rieng - truoc day la 1 tab trong CryptoScreen, gio
/// chuyen sang Vi > Tai san dau tu > Crypto (Phase C) vi Crypto da dong bo
/// Supabase giong cac loai tai san dau tu khac thay vi tach rieng nhu truoc.
/// Tai dung nguyen [CryptoPortfolioTab] (danh sach nam giu + lich su mua/ban)
/// chi them header + nut "+" (truoc day nam o CryptoScreen).
///
/// State-machine 1 popup duy nhat: chi tiet coin va lich su giao dich hien
/// INLINE (khong con mo them showModalBottomSheet/openAppPopup rieng) de
/// swipe xuong/tap ngoai luon dong het ve Home dung 1 lan, khong con hien
/// tuong "pop-up long pop-up".
class CryptoPortfolioScreen extends ConsumerStatefulWidget {
  const CryptoPortfolioScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<CryptoPortfolioScreen> createState() =>
      _CryptoPortfolioScreenState();
}

class _CryptoPortfolioScreenState extends ConsumerState<CryptoPortfolioScreen> {
  bool _showHistory = false;
  String? _historyCoinId;

  @override
  Widget build(BuildContext context) {
    final coinDetail = ref.watch(marketCoinDetailProvider);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: coinDetail != null
            ? CryptoCoinDetailScreen(
                symbol: coinDetail.symbol,
                name: coinDetail.name,
                imageUrl: coinDetail.imageUrl,
                fallbackPrice: coinDetail.fallbackPrice,
                fallbackChangePercent: coinDetail.fallbackChangePercent,
                onBack: () =>
                    ref.read(marketCoinDetailProvider.notifier).state = null,
              )
            : _showHistory
            ? CryptoHistoryView(
                coinId: _historyCoinId,
                onBack: () => setState(() => _showHistory = false),
              )
            : _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final back = widget.onBack;
                if (back != null) {
                  back();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
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
                ref.tr('crypto_tab_portfolio'),
                style: AppTextStyles.heading(size: 20),
              ),
            ),
            GestureDetector(
              onTap: () => showCryptoCoinPicker(context, ref),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.wealthAccentGradient,
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
        Expanded(
          child: CryptoPortfolioTab(
            onOpenHistory: (coinId) => setState(() {
              _showHistory = true;
              _historyCoinId = coinId;
            }),
          ),
        ),
      ],
    );
  }
}
