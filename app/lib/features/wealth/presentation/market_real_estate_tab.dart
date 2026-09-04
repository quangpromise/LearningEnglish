import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';

/// Khong co nguon gia thi truong Nha dat theo tung khu vuc mien phi/dang tin
/// cay nao - hien thang danh sach bat dong san nguoi dung tu nhap (cung du
/// lieu voi Vi > Tai san dau tu > Nha dat) thay vi 1 "thi truong" gia lap.
class MarketRealEstateTab extends ConsumerWidget {
  const MarketRealEstateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(wealthHoldingsProvider('real_estate'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.tr('wealth_market_real_estate_note'),
          style: AppTextStyles.muted(size: 10.5),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: holdingsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_load_error'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (holdings) {
              if (holdings.isEmpty) {
                return Center(
                  child: Text(
                    ref.tr('wealth_empty_holdings'),
                    style: AppTextStyles.muted(),
                  ),
                );
              }
              return ListView.separated(
                itemCount: holdings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final h = holdings[i];
                  return GlowBox(
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            h.name ?? '',
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          formatByCurrency(h.manualValue ?? 0, h.currency),
                          style: AppTextStyles.body(weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
