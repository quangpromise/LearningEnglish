import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_holding_model.dart';
import 'confirm_delete.dart';

const _kAssetType = 'real_estate';

/// Portfolio Nha dat (Phase C) - khong co API gia thi truong theo tung can
/// cu the nen nguoi dung TU NHAP gia tri uoc tinh (`manualValue`), co the
/// sua lai bat ky luc nao. Moi bat dong san la 1 dong doc lap (khong co
/// symbol/quantity nhu cac loai tai san khac).
class RealEstatePortfolioScreen extends ConsumerWidget {
  const RealEstatePortfolioScreen({super.key});

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
                    ref.tr('wealth_investments_real_estate_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr('wealth_real_estate_manual_note'),
              style: AppTextStyles.muted(size: 10.5),
            ),
            const SizedBox(height: 14),
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
                    itemBuilder: (context, i) =>
                        _PropertyTile(holding: holdings[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('wealth_real_estate_add'),
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
      builder: (_) => const _PropertySheet(),
    );
  }
}

class _PropertyTile extends ConsumerWidget {
  const _PropertyTile({required this.holding});
  final WealthHolding holding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: GestureDetector(
        onTap: () => _showAddSheet(context, holding: holding),
        child: GlowBox(
          borderRadius: 16,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.name ?? '',
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                    if (holding.symbol?.isNotEmpty == true)
                      Text(
                        holding.symbol!,
                        style: AppTextStyles.muted(size: 11),
                      ),
                  ],
                ),
              ),
              Text(
                formatByCurrency(holding.manualValue ?? 0, holding.currency),
                style: AppTextStyles.body(weight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {WealthHolding? holding}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PropertySheet(existing: holding),
    );
  }
}

class _PropertySheet extends ConsumerStatefulWidget {
  const _PropertySheet({this.existing});
  final WealthHolding? existing;

  @override
  ConsumerState<_PropertySheet> createState() => _PropertySheetState();
}

class _PropertySheetState extends ConsumerState<_PropertySheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.existing?.symbol ?? '',
  );
  late final _valueController = TextEditingController(
    text: widget.existing?.manualValue?.toStringAsFixed(0) ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text.trim());
    if (name.isEmpty || value == null || value < 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final repo = ref.read(wealthHoldingRepositoryProvider);
      if (widget.existing == null) {
        await repo.insertNew(
          userId,
          WealthHolding(
            id: '',
            assetType: _kAssetType,
            name: name,
            symbol: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            manualValue: value,
            currency: 'VND',
          ),
        );
      } else {
        await repo.updateManualValue(userId, widget.existing!.id, value);
        await ref
            .read(wealthInvestmentTransactionRepositoryProvider)
            .record(
              userId: userId,
              assetType: _kAssetType,
              action: 'revalue',
              amount: value,
              currency: 'VND',
            );
      }
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
                ref.tr('wealth_real_estate_add'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                enabled: widget.existing == null,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.glassFill,
                  hintText: ref.tr('wealth_real_estate_name_hint'),
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                enabled: widget.existing == null,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.glassFill,
                  hintText: ref.tr('wallet_note_hint'),
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.glassFill,
                  hintText: ref.tr('wealth_real_estate_value_hint'),
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
      ),
    );
  }
}
