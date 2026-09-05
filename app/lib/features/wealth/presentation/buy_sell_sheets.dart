import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/wealth_holding_model.dart';

/// Menu hanh dong khi bam vao 1 khoan nam giu co quantity/avgCost (Co phieu,
/// Kim loai) - Sua / Mua them / Ban, dung chung cho nhieu man hinh Portfolio
/// de tranh lap code giua cac loai tai san.
void showHoldingActionsSheet(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onEdit,
  // null = an dong "Mua them" - dung cho Nha dat (khong co khai niem mua
  // them cung 1 bat dong san).
  VoidCallback? onBuyMore,
  required VoidCallback onSell,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12172E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _ActionRow(
              icon: Icons.edit_rounded,
              label: ref.tr('wealth_edit_holding'),
              color: AppColors.wealthAccent,
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            if (onBuyMore != null)
              _ActionRow(
                icon: Icons.add_shopping_cart_rounded,
                label: ref.tr('wealth_buy_more'),
                color: AppColors.teal,
                onTap: () {
                  Navigator.of(context).pop();
                  onBuyMore();
                },
              ),
            _ActionRow(
              icon: Icons.sell_rounded,
              label: ref.tr('wealth_sell'),
              color: AppColors.pink,
              onTap: () {
                Navigator.of(context).pop();
                onSell();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyles.body(weight: FontWeight.w700, color: color),
      ),
      onTap: onTap,
    );
  }
}

void showBuyMoreSheet(
  BuildContext context, {
  required WealthHolding holding,
  required String unitLabel,
  double? livePrice,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BuyMoreSheet(
      holding: holding,
      unitLabel: unitLabel,
      livePrice: livePrice,
    ),
  );
}

void showSellSheet(
  BuildContext context, {
  required WealthHolding holding,
  required String unitLabel,
  double? livePrice,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SellSheet(
      holding: holding,
      unitLabel: unitLabel,
      livePrice: livePrice,
    ),
  );
}

class _BuyMoreSheet extends ConsumerStatefulWidget {
  const _BuyMoreSheet({
    required this.holding,
    required this.unitLabel,
    this.livePrice,
  });
  final WealthHolding holding;
  final String unitLabel;
  final double? livePrice;

  @override
  ConsumerState<_BuyMoreSheet> createState() => _BuyMoreSheetState();
}

class _BuyMoreSheetState extends ConsumerState<_BuyMoreSheet> {
  final _quantityController = TextEditingController();
  late final _priceController = TextEditingController(
    text: widget.livePrice == null ? '' : groupThousands(widget.livePrice!),
  );
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final addedQty = double.tryParse(_quantityController.text.trim());
    final price = parseThousandsFormatted(_priceController.text);
    if (addedQty == null || addedQty <= 0 || price == null || price < 0) {
      return;
    }
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final oldQty = widget.holding.quantity ?? 0;
      final oldCost = widget.holding.avgCost ?? 0;
      final newQty = oldQty + addedQty;
      // Gia von binh quan gia quyen (weighted average) - chuan ke toan khi
      // mua them cung 1 ma o gia khac lan mua truoc.
      final newAvgCost = newQty == 0
          ? oldCost
          : (oldQty * oldCost + addedQty * price) / newQty;
      await ref
          .read(wealthHoldingRepositoryProvider)
          .updateQuantityAndCost(
            userId,
            widget.holding.id,
            quantity: newQty,
            avgCost: newAvgCost,
          );
      await ref
          .read(wealthInvestmentTransactionRepositoryProvider)
          .record(
            userId: userId,
            assetType: widget.holding.assetType,
            action: 'buy',
            symbol: widget.holding.symbol,
            quantity: addedQty,
            price: price,
            currency: widget.holding.currency,
          );
      ref.invalidate(wealthHoldingsProvider(widget.holding.assetType));
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
                '${ref.tr('wealth_buy_more_title')} — ${widget.holding.symbol ?? widget.holding.name ?? ''}',
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              _AmountField(
                controller: _quantityController,
                hint: '${ref.tr('wealth_quantity_hint')} (${widget.unitLabel})',
                thousands: false,
              ),
              const SizedBox(height: 10),
              _AmountField(
                controller: _priceController,
                hint: ref.tr('wealth_buy_price_hint'),
                thousands: true,
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
      ),
    );
  }
}

class _SellSheet extends ConsumerStatefulWidget {
  const _SellSheet({
    required this.holding,
    required this.unitLabel,
    this.livePrice,
  });
  final WealthHolding holding;
  final String unitLabel;
  final double? livePrice;

  @override
  ConsumerState<_SellSheet> createState() => _SellSheetState();
}

class _SellSheetState extends ConsumerState<_SellSheet> {
  final _quantityController = TextEditingController();
  late final _priceController = TextEditingController(
    text: widget.livePrice == null ? '' : groupThousands(widget.livePrice!),
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final soldQty = double.tryParse(_quantityController.text.trim());
    final price = parseThousandsFormatted(_priceController.text);
    final currentQty = widget.holding.quantity ?? 0;
    if (soldQty == null || soldQty <= 0 || price == null || price < 0) return;
    if (soldQty > currentQty + 1e-9) {
      setState(() => _error = ref.tr('wealth_sell_exceeds_holding'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final repo = ref.read(wealthHoldingRepositoryProvider);
      final remainingQty = currentQty - soldQty;
      // Con lai gan bang 0 (sai so lam tron) -> xoa han khoan nam giu thay vi
      // giu lai 1 dong voi so luong xap xi 0 vo nghia.
      if (remainingQty <= 1e-9) {
        await repo.deleteHolding(userId, widget.holding.id);
      } else {
        await repo.updateQuantityAndCost(
          userId,
          widget.holding.id,
          quantity: remainingQty,
          avgCost: widget.holding.avgCost ?? 0,
        );
      }
      await ref
          .read(wealthInvestmentTransactionRepositoryProvider)
          .record(
            userId: userId,
            assetType: widget.holding.assetType,
            action: 'sell',
            symbol: widget.holding.symbol,
            quantity: soldQty,
            price: price,
            currency: widget.holding.currency,
          );
      ref.invalidate(wealthHoldingsProvider(widget.holding.assetType));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgCost = widget.holding.avgCost ?? 0;
    final soldQty = double.tryParse(_quantityController.text.trim());
    final price = parseThousandsFormatted(_priceController.text);
    final realizedPnl = (soldQty != null && price != null)
        ? (price - avgCost) * soldQty
        : null;
    final isProfit = (realizedPnl ?? 0) >= 0;
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
        child: StatefulBuilder(
          builder: (context, setSheetState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ref.tr('wealth_sell_title')} — ${widget.holding.symbol ?? widget.holding.name ?? ''}',
                  style: AppTextStyles.heading(size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ref.tr('wealth_sell_max_note')}: '
                  '${widget.holding.quantity ?? 0} ${widget.unitLabel}',
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 16),
                _AmountField(
                  controller: _quantityController,
                  hint:
                      '${ref.tr('wealth_sell_quantity_hint')} (${widget.unitLabel})',
                  thousands: false,
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 10),
                _AmountField(
                  controller: _priceController,
                  hint: ref.tr('wealth_sell_price_hint'),
                  thousands: true,
                  onChanged: (_) => setSheetState(() {}),
                ),
                if (realizedPnl != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${ref.tr('wealth_realized_pnl_label')}: '
                    '${isProfit ? '+' : ''}${groupThousandsDecimal(realizedPnl)} '
                    '${widget.holding.currency}',
                    style: AppTextStyles.body(size: 12, weight: FontWeight.w700)
                        .copyWith(
                          color: isProfit ? AppColors.teal : AppColors.pink,
                        ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: AppTextStyles.muted(size: 11)
                        .copyWith(color: AppColors.pink),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: ref.tr('wealth_sell'),
                    accentGradient: AppColors.wealthAccentGradient,
                    accentColor: AppColors.wealthAccent,
                    onTap: _saving ? null : _save,
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

/// Ban 1 bat dong san - khac Co phieu/Kim loai vi khong co quantity (moi
/// dong la 1 can nha doc lap): chi can gia ban cuoi cung, xoa han khoi danh
/// sach nam giu va ghi lai 1 dong 'sell' vao lich su dau tu.
void showRealEstateSellSheet(
  BuildContext context, {
  required WealthHolding holding,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RealEstateSellSheet(holding: holding),
  );
}

class _RealEstateSellSheet extends ConsumerStatefulWidget {
  const _RealEstateSellSheet({required this.holding});
  final WealthHolding holding;

  @override
  ConsumerState<_RealEstateSellSheet> createState() =>
      _RealEstateSellSheetState();
}

class _RealEstateSellSheetState extends ConsumerState<_RealEstateSellSheet> {
  late final _priceController = TextEditingController(
    text: widget.holding.manualValue == null
        ? ''
        : groupThousands(widget.holding.manualValue!),
  );
  bool _saving = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = parseThousandsFormatted(_priceController.text);
    if (price == null || price < 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      await ref
          .read(wealthHoldingRepositoryProvider)
          .deleteHolding(userId, widget.holding.id);
      await ref
          .read(wealthInvestmentTransactionRepositoryProvider)
          .record(
            userId: userId,
            assetType: widget.holding.assetType,
            action: 'sell',
            symbol: widget.holding.symbol,
            amount: price,
            currency: widget.holding.currency,
            note: widget.holding.name,
          );
      ref.invalidate(wealthHoldingsProvider(widget.holding.assetType));
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
                '${ref.tr('wealth_real_estate_sell')} — ${widget.holding.name ?? ''}',
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                ref.tr('wealth_real_estate_sell_confirm'),
                style: AppTextStyles.muted(size: 11.5),
              ),
              const SizedBox(height: 16),
              _AmountField(
                controller: _priceController,
                hint: ref.tr('wealth_real_estate_sell_price_hint'),
                thousands: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: ref.tr('wealth_sell'),
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

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.hint,
    required this.thousands,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final bool thousands;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: thousands ? [ThousandsInputFormatter()] : null,
      onChanged: onChanged,
      style: AppTextStyles.body(),
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
