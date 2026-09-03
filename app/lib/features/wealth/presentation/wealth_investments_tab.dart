import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../crypto/presentation/crypto_screen.dart';
import '../data/stocks_intl_repository.dart';
import '../data/wealth_holding_model.dart';

class WealthInvestmentsTab extends ConsumerWidget {
  const WealthInvestmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(wealthHoldingsProvider);
    return ListView(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CryptoScreen())),
          child: GlowBox(
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.currency_bitcoin_rounded,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('wealth_investments_crypto_title'),
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      Text(
                        ref.tr('wealth_investments_crypto_subtitle'),
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          ref.tr('wealth_investments_stocks_title'),
          style: AppTextStyles.heading(size: 14),
        ),
        const SizedBox(height: 10),
        holdingsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            ),
          ),
          error: (_, _) => Text(
            ref.tr('wealth_empty_holdings'),
            style: AppTextStyles.muted(),
          ),
          data: (holdings) {
            if (holdings.isEmpty) {
              return Text(
                ref.tr('wealth_empty_holdings'),
                style: AppTextStyles.muted(),
              );
            }
            final symbols = holdings.map((h) => h.symbol).toList();
            final quotesAsync = ref.watch(stocksIntlQuotesProvider(symbols));
            return Column(
              children: [
                for (final h in holdings) ...[
                  _HoldingTile(
                    holding: h,
                    quote: quotesAsync.valueOrNull?.firstWhereOrNull(
                      (q) => q.symbol == h.symbol,
                    ),
                    quoteFailed: quotesAsync.hasError,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: ref.tr('wealth_add_holding'),
            filled: false,
            icon: const Icon(
              Icons.add_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
            onTap: () => _showAddHoldingSheet(context, ref),
          ),
        ),
      ],
    );
  }
}

void _showAddHoldingSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddHoldingSheet(),
  );
}

class _AddHoldingSheet extends ConsumerStatefulWidget {
  const _AddHoldingSheet();

  @override
  ConsumerState<_AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<_AddHoldingSheet> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _avgCostController = TextEditingController();
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
          .addHolding(
            userId,
            WealthHolding(
              id: '',
              symbol: symbol,
              quantity: quantity,
              avgCost: avgCost,
              currency: 'USD',
            ),
          );
      ref.invalidate(wealthHoldingsProvider);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('wealth_add_holding'),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 16),
            _HoldingField(
              controller: _symbolController,
              hint: ref.tr('wealth_symbol_hint'),
              keyboardType: TextInputType.text,
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
                onTap: _saving ? null : _save,
              ),
            ),
          ],
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
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.body(),
      cursorColor: AppColors.blue,
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

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({
    required this.holding,
    required this.quote,
    required this.quoteFailed,
  });
  final WealthHolding holding;
  final StockQuote? quote;
  final bool quoteFailed;

  @override
  Widget build(BuildContext context) {
    final currentPrice = quote?.price;
    final gain = currentPrice != null
        ? (currentPrice - holding.avgCost) * holding.quantity
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
                  holding.symbol,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                Text(
                  '${holding.quantity} cp · giá vốn \$${holding.avgCost.toStringAsFixed(2)}',
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
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                Text(
                  '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(2)}',
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
                color: AppColors.blue,
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
