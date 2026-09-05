import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/stocks_intl_repository.dart';
import '../data/wealth_holding_model.dart';
import 'confirm_delete.dart';

const _kAssetType = 'stock_intl';

/// Portfolio Co phieu quoc te (thu cong - nguoi dung tu nhap so luong/gia
/// von, gia hien tai qua Twelve Data). Tach tu WealthInvestmentsTab cu
/// (Phase C) - gio la 1 man rieng mo tu Vi > Tai san dau tu > Co phieu.
class StockPortfolioScreen extends ConsumerWidget {
  const StockPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(wealthHoldingsProvider(_kAssetType));
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
                    ref.tr('wealth_investments_stocks_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: holdingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('wealth_empty_holdings'),
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
                  final symbols = holdings
                      .map((h) => h.symbol ?? '')
                      .where((s) => s.isNotEmpty)
                      .join(',');
                  final quotesAsync = ref.watch(
                    stocksIntlQuotesProvider(symbols),
                  );
                  return ListView(
                    children: [
                      for (final h in holdings) ...[
                        Dismissible(
                          key: ValueKey(h.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => confirmDelete(context, ref),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.pink.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.pink,
                            ),
                          ),
                          onDismissed: (_) async {
                            final userId = ref
                                .read(supabaseClientProvider)
                                .auth
                                .currentUser
                                ?.id;
                            if (userId == null) return;
                            await ref
                                .read(wealthHoldingRepositoryProvider)
                                .deleteHolding(userId, h.id);
                            ref.invalidate(wealthHoldingsProvider(_kAssetType));
                          },
                          child: GestureDetector(
                            onTap: () =>
                                _showAddHoldingSheet(context, ref, existing: h),
                            child: _HoldingTile(
                              holding: h,
                              quote: quotesAsync.valueOrNull?.firstWhereOrNull(
                                (q) => q.symbol == h.symbol,
                              ),
                              quoteFailed: quotesAsync.hasError,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('wealth_add_holding'),
                accentGradient: AppColors.wealthAccentGradient,
                accentColor: AppColors.wealthAccent,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                onTap: () => _showAddHoldingSheet(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddHoldingSheet(
  BuildContext context,
  WidgetRef ref, {
  WealthHolding? existing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddHoldingSheet(existing: existing),
  );
}

class _AddHoldingSheet extends ConsumerStatefulWidget {
  const _AddHoldingSheet({this.existing});
  final WealthHolding? existing;

  @override
  ConsumerState<_AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<_AddHoldingSheet> {
  late final _symbolController = TextEditingController(
    text: widget.existing?.symbol ?? '',
  );
  late final _quantityController = TextEditingController(
    text: widget.existing?.quantity?.toString() ?? '',
  );
  late final _avgCostController = TextEditingController(
    text: widget.existing?.avgCost?.toString() ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _avgCostController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = double.tryParse(_quantityController.text.trim());
    final avgCost = double.tryParse(_avgCostController.text.trim());
    if (symbol.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        avgCost == null) {
      return;
    }
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      await ref
          .read(wealthHoldingRepositoryProvider)
          .upsertBySymbol(
            userId,
            WealthHolding(
              id: '',
              assetType: _kAssetType,
              symbol: symbol,
              quantity: quantity,
              avgCost: avgCost,
              currency: 'USD',
            ),
          );
      ref.invalidate(wealthHoldingsProvider(_kAssetType));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF12172E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null
                    ? ref.tr('wealth_add_holding')
                    : ref.tr('wealth_edit_holding'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              _HoldingField(
                controller: _symbolController,
                hint: ref.tr('wealth_symbol_hint'),
                keyboardType: TextInputType.text,
                enabled: widget.existing == null,
              ),
              const SizedBox(height: 10),
              _HoldingField(
                controller: _quantityController,
                hint: ref.tr('wealth_quantity_hint'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              _HoldingField(
                controller: _avgCostController,
                hint: ref.tr('wealth_avg_cost_hint'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: ref.tr('wealth_save'),
                  accentGradient: AppColors.wealthAccentGradient,
                  accentColor: AppColors.wealthAccent,
                  onTap: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldingField extends StatelessWidget {
  const _HoldingField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppTextStyles.body(),
      cursorColor: AppColors.wealthAccent,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.glassFill,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HoldingTile extends ConsumerWidget {
  const _HoldingTile({
    required this.holding,
    required this.quote,
    required this.quoteFailed,
  });
  final WealthHolding holding;
  final StockQuote? quote;
  final bool quoteFailed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(investmentPrivacyModeProvider);
    final currentPrice = quote?.price;
    final quantity = holding.quantity ?? 0;
    final avgCost = holding.avgCost ?? 0;
    final gain = currentPrice != null
        ? (currentPrice - avgCost) * quantity
        : null;
    final gainPercent = (currentPrice != null && avgCost != 0)
        ? (currentPrice - avgCost) / avgCost * 100
        : null;
    return GlowBox(
      borderRadius: 18,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol ?? '',
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                Text(
                  hidden
                      ? '•••••••'
                      : '$quantity ${ref.tr('wealth_stock_unit_share')} · '
                            '${ref.tr('wealth_stock_avg_cost_label')} '
                            '\$${avgCost.toStringAsFixed(2)}',
                  style: AppTextStyles.muted(size: 11),
                ),
              ],
            ),
          ),
          if (currentPrice != null && gain != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hidden ? '•••••••' : '\$${currentPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                if (!hidden)
                  Text(
                    '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(2)}'
                    '${gainPercent == null ? '' : ' (${gainPercent >= 0 ? '+' : ''}${gainPercent.toStringAsFixed(1)}%)'}',
                    style: AppTextStyles.muted(size: 11).copyWith(
                      color: gain >= 0 ? AppColors.teal : AppColors.pink,
                    ),
                  ),
              ],
            )
          else if (quoteFailed)
            Consumer(
              builder: (context, ref, _) => Text(
                ref.tr('wealth_quote_error'),
                style: AppTextStyles.muted(size: 10.5),
              ),
            )
          else
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.wealthAccent,
              ),
            ),
        ],
      ),
    );
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
