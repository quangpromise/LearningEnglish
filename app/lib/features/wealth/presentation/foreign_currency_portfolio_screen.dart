import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/exchange_rate_repository.dart';
import '../data/wealth_holding_model.dart';
import 'buy_sell_sheets.dart';
import 'confirm_delete.dart';
import 'wealth_holding_history_sheet.dart';

const _kAssetType = 'foreign_currency';

/// Portfolio Ngoai te (USD/EUR/JPY...) - dinh gia REALTIME theo ty gia
/// Vietcombank (Mua tien mat/Mua chuyen khoan/Ban ra), lay tu
/// wealth-vn-assets (xem exchange_rate_repository.dart). Moi lan them la 1
/// "lo" doc lap (giong Vang) vi ty gia luc mua co the khac nhau giua cac
/// lan. Dinh gia hien tai dung gia "Mua chuyen khoan" (ngan hang mua lai
/// ngoai te cua ban -> so tien VND ban thuc nhan duoc), khong dung "Ban ra"
/// (gia ban NGOAI TE cho ban, khong lien quan khi dang GIU ngoai te).
class ForeignCurrencyPortfolioScreen extends ConsumerStatefulWidget {
  const ForeignCurrencyPortfolioScreen({super.key});

  @override
  ConsumerState<ForeignCurrencyPortfolioScreen> createState() =>
      _ForeignCurrencyPortfolioScreenState();
}

class _ForeignCurrencyPortfolioScreenState
    extends ConsumerState<ForeignCurrencyPortfolioScreen> {
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final holdingsAsync = ref.watch(wealthHoldingsProvider(_kAssetType));
    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
    final holdings = holdingsAsync.valueOrNull ?? [];
    final codes = <String>[];
    for (final h in holdings) {
      final code = h.symbol;
      if (code != null && !codes.contains(code)) codes.add(code);
    }
    final selected = codes.contains(_selectedCode)
        ? _selectedCode
        : (codes.isEmpty ? null : codes.first);
    final selectedRate = selected == null ? null : snap?.rateFor(selected);
    final unitPrice =
        selectedRate?.buyTransfer ??
        selectedRate?.buyCash ??
        selectedRate?.sell;

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
                    ref.tr('wealth_investments_currency_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr('wealth_currency_bank_note'),
              style: AppTextStyles.muted(size: 10.5),
            ),
            const SizedBox(height: 12),
            if (codes.isNotEmpty)
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final code in codes) ...[
                      _KindChip(
                        label: code,
                        selected: code == selected,
                        onTap: () => setState(() => _selectedCode = code),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (unitPrice != null && selectedRate != null)
              _RateSummary(rate: selectedRate),
            const SizedBox(height: 10),
            Expanded(
              child: holdingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('wealth_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (holdings) {
                  final filtered = selected == null
                      ? holdings
                      : holdings.where((h) => h.symbol == selected).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('wealth_empty_holdings'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _LotTile(
                      holding: filtered[i],
                      unitPrice: snap
                          ?.rateFor(filtered[i].symbol ?? '')
                          ?.buyTransfer,
                    ),
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
                onTap: () => _showAddSheet(context, initialCode: selected),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {String? initialCode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCurrencyLotSheet(initialCode: initialCode),
    ).then((addedCode) {
      if (addedCode is String && mounted) {
        setState(() => _selectedCode = addedCode);
      }
    });
  }
}

class _RateSummary extends ConsumerWidget {
  const _RateSummary({required this.rate});
  final ForeignCurrencyRate rate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _RateColumn(
              label: ref.tr('wealth_currency_rate_buy_cash'),
              value: rate.buyCash,
            ),
          ),
          Expanded(
            child: _RateColumn(
              label: ref.tr('wealth_currency_rate_buy_transfer'),
              value: rate.buyTransfer,
              highlight: true,
            ),
          ),
          Expanded(
            child: _RateColumn(
              label: ref.tr('wealth_currency_rate_sell'),
              value: rate.sell,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateColumn extends StatelessWidget {
  const _RateColumn({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final double? value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted(size: 9.5)),
        const SizedBox(height: 2),
        Text(
          value == null ? '—' : formatVnd(value!),
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w800,
          ).copyWith(color: highlight ? AppColors.wealthAccent : null),
        ),
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? AppColors.wealthAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _LotTile extends ConsumerWidget {
  const _LotTile({required this.holding, required this.unitPrice});
  final WealthHolding holding;
  final double? unitPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(investmentPrivacyModeProvider);
    final quantity = holding.quantity ?? 0;
    final avgCost = holding.avgCost ?? 0;
    final currentValue = unitPrice != null ? unitPrice! * quantity : null;
    final totalCost = avgCost * quantity;
    final pnl = currentValue == null ? null : currentValue - totalCost;
    final pnlPercent = (pnl == null || totalCost == 0)
        ? null
        : pnl / totalCost * 100;
    return Dismissible(
      key: ValueKey(holding.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      onDismissed: (_) async {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return;
        await ref
            .read(wealthHoldingRepositoryProvider)
            .deleteHolding(userId, holding.id);
        ref.invalidate(wealthHoldingsProvider(_kAssetType));
      },
      child: GlowBox(
        borderRadius: 16,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showWealthHoldingHistorySheet(
                  context,
                  holding: holding,
                  livePrice: unitPrice,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hidden ? '•••••••' : '$quantity ${holding.symbol}',
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            hidden
                                ? '•••••••'
                                : '${ref.tr('wealth_metal_cost_price')}: ${formatVnd(avgCost)}',
                            style: AppTextStyles.muted(size: 11),
                          ),
                        ],
                      ),
                    ),
                    if (currentValue != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hidden ? '•••••••' : formatVnd(currentValue),
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          if (pnl != null && !hidden)
                            Text(
                              '${pnl >= 0 ? '+' : ''}${formatVnd(pnl)}'
                              '${pnlPercent == null ? '' : ' (${pnl >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%)'}',
                              style: AppTextStyles.muted(size: 11).copyWith(
                                color: pnl >= 0
                                    ? AppColors.teal
                                    : AppColors.pink,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            WealthHoldingRowIconButton(
              icon: Icons.history_rounded,
              onTap: () => showWealthHoldingHistorySheet(
                context,
                holding: holding,
                livePrice: unitPrice,
              ),
            ),
            const SizedBox(width: 6),
            WealthHoldingRowIconButton(
              icon: Icons.add_rounded,
              onTap: () => showHoldingActionsSheet(
                context,
                ref,
                onEdit: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _AddCurrencyLotSheet(
                    initialCode: holding.symbol,
                    existing: holding,
                  ),
                ),
                onBuyMore: () => showBuyMoreSheet(
                  context,
                  holding: holding,
                  unitLabel: holding.symbol ?? '',
                  livePrice: unitPrice,
                ),
                onSell: () => showSellSheet(
                  context,
                  holding: holding,
                  unitLabel: holding.symbol ?? '',
                  livePrice: unitPrice,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCurrencyLotSheet extends ConsumerStatefulWidget {
  const _AddCurrencyLotSheet({this.initialCode, this.existing});
  final String? initialCode;
  final WealthHolding? existing;

  @override
  ConsumerState<_AddCurrencyLotSheet> createState() =>
      _AddCurrencyLotSheetState();
}

class _AddCurrencyLotSheetState extends ConsumerState<_AddCurrencyLotSheet> {
  late final _quantityController = TextEditingController(
    text: widget.existing?.quantity?.toString() ?? '',
  );
  late final _costController = TextEditingController(
    text: widget.existing?.avgCost == null
        ? ''
        : groupThousands(widget.existing!.avgCost!),
  );
  String? _expandedCode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _expandedCode = widget.existing?.symbol ?? widget.initialCode;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  /// Sua 1 lo da co - giu nguyen 2 o quantity/cost tach rieng (nguoi dung co
  /// the muon sua lai gia von lich su, khac voi luc THEM MOI luon dung dung
  /// gia thi truong hien tai).
  Future<void> _saveEdit() async {
    final code = widget.existing!.symbol;
    final quantity = double.tryParse(_quantityController.text.trim());
    final cost = parseThousandsFormatted(_costController.text);
    if (code == null ||
        quantity == null ||
        quantity <= 0 ||
        cost == null ||
        cost < 0) {
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
          .updateQuantityAndCost(
            userId,
            widget.existing!.id,
            quantity: quantity,
            avgCost: cost,
          );
      ref.invalidate(wealthHoldingsProvider(_kAssetType));
      if (mounted) Navigator.of(context).pop(code);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Them 1 lo MOI - gia von = dung gia mua chuyen khoan REALTIME dang hien
  /// o hang da mo rong (khong con o nhap tay rieng) - theo yeu cau nguoi
  /// dung gon lai luong them: bam 1 dong tien te -> hien o nhap so luong +
  /// nut xac nhan ngay duoi dong do.
  Future<void> _confirmAdd(String code, double? price) async {
    if (price == null || price <= 0) return;
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      await ref
          .read(wealthHoldingRepositoryProvider)
          .insertNew(
            userId,
            WealthHolding(
              id: '',
              assetType: _kAssetType,
              symbol: code,
              quantity: quantity,
              avgCost: price,
              currency: 'VND',
            ),
          );
      ref.invalidate(wealthHoldingsProvider(_kAssetType));
      if (mounted) Navigator.of(context).pop(code);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
    final rates = snap?.rates ?? const [];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                ref.tr(
                  widget.existing == null
                      ? 'wealth_add_currency_holding'
                      : 'wealth_edit_holding',
                ),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              if (widget.existing == null) ...[
                Text(
                  ref.tr('wealth_currency_pick_title'),
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 10),
                if (rates.isEmpty)
                  Text(
                    ref.tr('wealth_currency_rates_loading'),
                    style: AppTextStyles.muted(size: 11)
                        .copyWith(color: AppColors.pink),
                  )
                else
                  for (final r in rates)
                    _CurrencyRow(
                      rate: r,
                      expanded: _expandedCode == r.code,
                      saving: _saving,
                      quantityController: _quantityController,
                      onTap: () => setState(() {
                        if (_expandedCode == r.code) {
                          _expandedCode = null;
                        } else {
                          _expandedCode = r.code;
                          _quantityController.clear();
                        }
                      }),
                      onConfirm: () => _confirmAdd(
                        r.code,
                        r.buyTransfer ?? r.buyCash ?? r.sell,
                      ),
                    ),
              ] else ...[
                Text(
                  widget.existing!.symbol ?? '',
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.glassFill,
                    hintText:
                        '${ref.tr('wealth_quantity_hint')} (${widget.existing!.symbol ?? ''})',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [ThousandsInputFormatter()],
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.glassFill,
                    hintText: ref.tr('wealth_metal_cost_price'),
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: ref.tr('wallet_save'),
                    accentGradient: AppColors.wealthAccentGradient,
                    accentColor: AppColors.wealthAccent,
                    onTap: _saving ? null : _saveEdit,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 dong "accordion" cho 1 loai ngoai te trong danh sach THEM MOI - luon
/// hien ma tien te + gia mua chuyen khoan realtime; bam vao de mo/thu gon o
/// nhap so luong + nut xac nhan ngay ben duoi CUNG dong do (thay vi phai
/// chon roi cuon xuong o nhap rieng o cuoi nhu truoc).
class _CurrencyRow extends ConsumerWidget {
  const _CurrencyRow({
    required this.rate,
    required this.expanded,
    required this.saving,
    required this.quantityController,
    required this.onTap,
    required this.onConfirm,
  });
  final ForeignCurrencyRate rate;
  final bool expanded;
  final bool saving;
  final TextEditingController quantityController;
  final VoidCallback onTap;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = rate.buyTransfer ?? rate.buyCash ?? rate.sell;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expanded
            ? AppColors.wealthAccent.withValues(alpha: 0.12)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded ? AppColors.wealthAccent : AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    rate.code,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                ),
                Text(
                  price == null ? '—' : formatVnd(price),
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: AppColors.wealthAccent,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.glassFill,
                      hintText:
                          '${ref.tr('wealth_quantity_hint')} (${rate.code})',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: saving ? null : onConfirm,
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      gradient: AppColors.wealthAccentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
