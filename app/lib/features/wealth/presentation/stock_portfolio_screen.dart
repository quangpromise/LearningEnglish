import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/stocks_intl_repository.dart';
import '../data/wealth_holding_model.dart';
import 'confirm_delete.dart';
import 'stock_picker_sheet.dart';

/// Portfolio Co phieu (Viet Nam + Quoc te chung 1 danh sach) - them moi qua
/// [showStockPickerSheet] (tim theo ten/ma tu HOSE cho VN, danh sach ma
/// tieu bieu cho Quoc te, hoac tu nhap thu cong + gia neu khong tim thay).
/// Gia hien tai: VN qua stocks-vn (HOSE), Quoc te qua stocks-intl (Twelve
/// Data, gia THAT - khac Market > Quoc te dung gia token OKX chi de tham
/// khao) - ma nao khong co nguon gia song (tu nhap thu cong) dung lai
/// manualValue da luu luc them.
class StockPortfolioScreen extends ConsumerWidget {
  const StockPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intlHoldingsAsync = ref.watch(wealthHoldingsProvider('stock_intl'));
    final vnHoldingsAsync = ref.watch(wealthHoldingsProvider('stock_vn'));
    final isLoading = intlHoldingsAsync.isLoading || vnHoldingsAsync.isLoading;
    final holdings = <WealthHolding>[
      ...intlHoldingsAsync.valueOrNull ?? const [],
      ...vnHoldingsAsync.valueOrNull ?? const [],
    ];

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
              child: isLoading && holdings.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.wealthAccent,
                      ),
                    )
                  : holdings.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('wealth_empty_holdings'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : _HoldingsList(holdings: holdings),
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
                onTap: () => _pickAndAdd(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAdd(BuildContext context, WidgetRef ref) async {
    final picked = await showStockPickerSheet(context);
    if (picked == null || !context.mounted) return;
    _showAddHoldingSheet(context, picked: picked);
  }
}

class _HoldingsList extends ConsumerWidget {
  const _HoldingsList({required this.holdings});
  final List<WealthHolding> holdings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intlSymbols = holdings
        .where((h) => h.assetType == 'stock_intl')
        .map((h) => h.symbol ?? '')
        .where((s) => s.isNotEmpty)
        .join(',');
    final vnSymbols = holdings
        .where((h) => h.assetType == 'stock_vn')
        .map((h) => h.symbol ?? '')
        .where((s) => s.isNotEmpty)
        .join(',');
    final intlQuotesAsync = ref.watch(stocksIntlQuotesProvider(intlSymbols));
    final vnQuotesAsync = ref.watch(stocksVnQuotesProvider(vnSymbols));
    final intlBySymbol = {
      for (final q in intlQuotesAsync.valueOrNull ?? []) q.symbol: q,
    };
    final vnBySymbol = {
      for (final q in vnQuotesAsync.valueOrNull ?? []) q.symbol: q,
    };

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
              ref.invalidate(wealthHoldingsProvider(h.assetType));
            },
            child: GestureDetector(
              onTap: () => _showAddHoldingSheet(context, existing: h),
              child: _HoldingTile(
                holding: h,
                quote: h.assetType == 'stock_vn'
                    ? vnBySymbol[h.symbol]
                    : intlBySymbol[h.symbol],
                quoteFailed: h.assetType == 'stock_vn'
                    ? vnQuotesAsync.hasError
                    : intlQuotesAsync.hasError,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

void _showAddHoldingSheet(
  BuildContext context, {
  WealthHolding? existing,
  StockPickResult? picked,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddHoldingSheet(existing: existing, picked: picked),
  );
}

class _AddHoldingSheet extends ConsumerStatefulWidget {
  const _AddHoldingSheet({this.existing, this.picked});
  final WealthHolding? existing;
  final StockPickResult? picked;

  @override
  ConsumerState<_AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<_AddHoldingSheet> {
  late final _quantityController = TextEditingController(
    text: widget.existing?.quantity?.toString() ?? '',
  );
  late final _avgCostController = TextEditingController(
    text: widget.existing?.avgCost?.toString() ?? '',
  );
  bool _saving = false;

  String get _assetType =>
      widget.existing?.assetType ?? widget.picked?.assetType ?? 'stock_intl';
  String get _symbol => widget.existing?.symbol ?? widget.picked?.symbol ?? '';
  String? get _name => widget.existing?.name ?? widget.picked?.name;
  // Sua holding cu (khong co widget.picked) - giu nguyen manualValue da luu
  // truoc do (neu co) thay vi xoa mat khi luu lai.
  double? get _manualPrice =>
      widget.picked?.manualPrice ?? widget.existing?.manualValue;

  @override
  void dispose() {
    _quantityController.dispose();
    _avgCostController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final symbol = _symbol.trim().toUpperCase();
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
              assetType: _assetType,
              symbol: symbol,
              name: _name,
              quantity: quantity,
              avgCost: avgCost,
              manualValue: _manualPrice,
              currency: _assetType == 'stock_vn' ? 'VND' : 'USD',
            ),
          );
      ref.invalidate(wealthHoldingsProvider(_assetType));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVn = _assetType == 'stock_vn';
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _symbol,
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        size: 15,
                      ),
                    ),
                    if (_name != null)
                      Text(_name!, style: AppTextStyles.muted(size: 11.5)),
                  ],
                ),
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
                hint: isVn
                    ? ref.tr('wealth_stock_pick_price_hint_vn')
                    : ref.tr('wealth_avg_cost_hint'),
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
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [ThousandsInputFormatter()],
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
    final isVn = holding.assetType == 'stock_vn';
    // Uu tien gia song (quote); khong co (vd ma tu nhap thu cong, khong ton
    // tai tren HOSE/Twelve Data) thi fallback ve manualValue da luu luc them.
    final currentPrice = quote?.price ?? holding.manualValue;
    final quantity = holding.quantity ?? 0;
    final avgCost = holding.avgCost ?? 0;
    final gain = currentPrice != null
        ? (currentPrice - avgCost) * quantity
        : null;
    final gainPercent = (currentPrice != null && avgCost != 0)
        ? (currentPrice - avgCost) / avgCost * 100
        : null;
    final currencySymbol = isVn ? 'đ' : '\$';
    String fmt(double v) => isVn
        ? '${v.toStringAsFixed(0)}$currencySymbol'
        : '$currencySymbol${v.toStringAsFixed(2)}';
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
                            '${fmt(avgCost)}',
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
                  hidden ? '•••••••' : fmt(currentPrice),
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                if (!hidden)
                  Text(
                    '${gain >= 0 ? '+' : ''}${fmt(gain)}'
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
