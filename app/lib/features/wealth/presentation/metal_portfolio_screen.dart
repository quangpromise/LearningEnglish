import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/exchange_rate_repository.dart';
import '../data/wealth_holding_model.dart';

/// Portfolio Vang/Bac/Dong (Phase C) - moi lan them la 1 "lo" doc lap (giong
/// cach Vi ghi tung dong bien dong, KHONG gop thanh 1 so du duy nhat) vi
/// nguoi dung thuong mua vang nhieu dot gia khac nhau va muon nho lai tung
/// lan. Gia hien tai lay tu wealth-vn-assets (Vang SJC/PNJ trong nuoc, Bac/
/// Dong la GIA THE GIOI quy doi - ghi chu ro trong UI).
class MetalPortfolioScreen extends ConsumerStatefulWidget {
  const MetalPortfolioScreen({super.key});

  @override
  ConsumerState<MetalPortfolioScreen> createState() =>
      _MetalPortfolioScreenState();
}

class _MetalKind {
  const _MetalKind(this.assetType, this.labelKey, this.unitKey);
  final String assetType;
  final String labelKey;
  final String unitKey;
}

const _kinds = [
  _MetalKind('gold', 'wealth_metal_name_gold', 'wealth_metal_unit_luong'),
  _MetalKind('silver', 'wealth_metal_name_silver', 'wealth_metal_unit_luong'),
  _MetalKind('copper', 'wealth_metal_name_copper', 'wealth_metal_unit_kg'),
];

class _MetalPortfolioScreenState extends ConsumerState<MetalPortfolioScreen> {
  _MetalKind _selected = _kinds[0];

  double? _currentUnitPrice(WealthVnAssetSnapshot snap) {
    switch (_selected.assetType) {
      case 'gold':
        return snap.goldSjcSell ?? snap.goldPnjSell;
      case 'silver':
        return snap.xagVndPerLuong;
      case 'copper':
        return snap.xcuVndPerKg;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final holdingsAsync = ref.watch(
      wealthHoldingsProvider(_selected.assetType),
    );
    final snapAsync = ref.watch(wealthVnAssetsProvider);
    final unitPrice = snapAsync.valueOrNull == null
        ? null
        : _currentUnitPrice(snapAsync.valueOrNull!);

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
                    ref.tr('wealth_investments_metal_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final k in _kinds) ...[
                  _KindChip(
                    label: ref.tr(k.labelKey),
                    selected: k.assetType == _selected.assetType,
                    onTap: () => setState(() => _selected = k),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            if (_selected.assetType != 'gold')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  ref.tr('wealth_metal_world_price_note'),
                  style: AppTextStyles.muted(size: 10.5),
                ),
              ),
            const SizedBox(height: 12),
            if (unitPrice != null)
              Text(
                '${ref.tr('wealth_metal_current_price')}: '
                '${formatVnd(unitPrice)} / ${ref.tr(_selected.unitKey)}',
                style: AppTextStyles.body(size: 12, weight: FontWeight.w700),
              ),
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
                    itemBuilder: (context, i) => _LotTile(
                      holding: holdings[i],
                      unit: ref.tr(_selected.unitKey),
                      unitPrice: unitPrice,
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
                onTap: () => _showAddSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMetalLotSheet(kind: _selected),
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
  const _LotTile({
    required this.holding,
    required this.unit,
    required this.unitPrice,
  });
  final WealthHolding holding;
  final String unit;
  final double? unitPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = holding.quantity ?? 0;
    final avgCost = holding.avgCost ?? 0;
    final currentValue = unitPrice != null ? unitPrice! * quantity : null;
    return Dismissible(
      key: ValueKey(holding.id),
      direction: DismissDirection.endToStart,
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
        ref.invalidate(wealthHoldingsProvider(holding.assetType));
      },
      child: GlowBox(
        borderRadius: 16,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$quantity $unit',
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  Text(
                    '${ref.tr('wealth_metal_cost_price')}: ${formatVnd(avgCost)}',
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            if (currentValue != null)
              Text(
                formatVnd(currentValue),
                style: AppTextStyles.body(weight: FontWeight.w800),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddMetalLotSheet extends ConsumerStatefulWidget {
  const _AddMetalLotSheet({required this.kind});
  final _MetalKind kind;

  @override
  ConsumerState<_AddMetalLotSheet> createState() => _AddMetalLotSheetState();
}

class _AddMetalLotSheetState extends ConsumerState<_AddMetalLotSheet> {
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = double.tryParse(_quantityController.text.trim());
    final cost = double.tryParse(_costController.text.trim());
    if (quantity == null || quantity <= 0 || cost == null || cost < 0) return;
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
              assetType: widget.kind.assetType,
              quantity: quantity,
              avgCost: cost,
              currency: 'VND',
            ),
          );
      ref.invalidate(wealthHoldingsProvider(widget.kind.assetType));
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
              '${ref.tr('wealth_add_holding')} — ${ref.tr(widget.kind.labelKey)}',
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 16),
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
                    '${ref.tr('wealth_quantity_hint')} (${ref.tr(widget.kind.unitKey)})',
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
                onTap: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
