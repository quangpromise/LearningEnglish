import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_format.dart';
import '../data/wealth_holding_model.dart';
import '../data/wealth_investment_transaction_model.dart';

/// Bottom sheet "chi tiet + lich su" DUNG CHUNG cho moi loai khoan dau tu
/// dung WealthHolding (Co phieu/Vang/Bat dong san/Ngoai te) - KHONG co bieu
/// do gia (khac Crypto co CryptoCoinDetailScreen rieng voi chart that qua
/// OKX candles) vi cac nguon gia con lai (Twelve Data/VCB) khong co san
/// chuoi gia LICH SU, chi co gia HIEN TAI - hien thi gia tri+PNL hien tai va
/// toan bo lich su mua/ban/danh gia lai (loc theo symbol trong asset_type).
void showWealthHoldingHistorySheet(
  BuildContext context, {
  required WealthHolding holding,
  double? livePrice,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _WealthHoldingHistorySheet(holding: holding, livePrice: livePrice),
  );
}

class _WealthHoldingHistorySheet extends ConsumerWidget {
  const _WealthHoldingHistorySheet({required this.holding, this.livePrice});
  final WealthHolding holding;
  final double? livePrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      wealthInvestmentTransactionsProvider(holding.assetType),
    );
    final history =
        (historyAsync.valueOrNull ?? [])
            .where((t) => holding.symbol == null || t.symbol == holding.symbol)
            .toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    final quantity = holding.quantity;
    final avgCost = holding.avgCost;
    final isManual = holding.manualValue != null;
    final currentValue = isManual
        ? holding.manualValue
        : (livePrice != null && quantity != null
              ? livePrice! * quantity
              : null);
    final totalCost = isManual
        ? null
        : (avgCost != null && quantity != null ? avgCost * quantity : null);
    final pnl = (currentValue != null && totalCost != null)
        ? currentValue - totalCost
        : null;

    return FractionallySizedBox(
      heightFactor: 0.78,
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
                        holding.name ?? holding.symbol ?? '',
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
                const SizedBox(height: 14),
                GlowBox(
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr('wealth_holding_current_value'),
                              style: AppTextStyles.muted(size: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentValue == null
                                  ? '—'
                                  : formatVnd(currentValue),
                              style: AppTextStyles.heading(size: 16),
                            ),
                            if (pnl != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${pnl >= 0 ? '+' : ''}${formatVnd(pnl)}',
                                style: AppTextStyles.body(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: pnl >= 0
                                      ? AppColors.teal
                                      : AppColors.pink,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isManual && quantity != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$quantity',
                              style: AppTextStyles.body(
                                weight: FontWeight.w800,
                              ),
                            ),
                            if (avgCost != null)
                              Text(
                                '${ref.tr('wealth_metal_cost_price')}: ${formatVnd(avgCost)}',
                                style: AppTextStyles.muted(size: 11),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ref.tr('wealth_holding_history_title'),
                  style: AppTextStyles.heading(size: 14),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: historyAsync.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.wealthAccent,
                          ),
                        )
                      : history.isEmpty
                      ? Center(
                          child: Text(
                            ref.tr('crypto_history_empty'),
                            style: AppTextStyles.muted(),
                          ),
                        )
                      : ListView.separated(
                          itemCount: history.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) =>
                              _HistoryRow(t: history[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nut icon nho (History/+) dat canh 1 dong holding trong cac man Portfolio
/// (Co phieu/Vang/Bat dong san/Ngoai te) - dung CHUNG 1 kieu dang cho tat ca.
class WealthHoldingRowIconButton extends StatelessWidget {
  const WealthHoldingRowIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.wealthAccent.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: AppColors.wealthAccent),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.t});
  final WealthInvestmentTransaction t;

  @override
  Widget build(BuildContext context) {
    final isBuy = t.action == 'buy';
    final isSell = t.action == 'sell';
    final color = isSell
        ? AppColors.pink
        : (isBuy ? AppColors.teal : AppColors.textMuted);
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.action.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatDateMdy(t.occurredAt),
                  style: AppTextStyles.muted(size: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (t.quantity != null)
                Text(
                  '${t.quantity}',
                  style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
                ),
              if (t.amount != null)
                Text(
                  formatVnd(t.amount!),
                  style: AppTextStyles.muted(size: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
