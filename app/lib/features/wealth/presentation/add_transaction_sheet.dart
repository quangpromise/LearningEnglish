import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/wealth_category.dart';
import '../data/wealth_transaction_model.dart';

/// Bottom sheet them 1 giao dich chi tieu/thu nhap - [type] co dinh theo tab
/// dang mo (Chi tieu hoac Thu nhap), khong cho doi loai trong sheet de UI
/// don gian (giong cach Fitness khong cho doi nhom co khi da vao 1 nhom).
void showAddWealthTransactionSheet(
  BuildContext context,
  WidgetRef ref,
  WealthTransactionType type,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTransactionSheet(type: type),
  );
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet({required this.type});
  final WealthTransactionType type;

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _categoryCode = WealthExpenseCategory.other.code;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _categoryCode = widget.type == WealthTransactionType.expense
        ? WealthExpenseCategory.other.code
        : WealthIncomeCategory.salary.code;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final incomeKind = widget.type == WealthTransactionType.income
        ? (WealthIncomeCategory.fromCode(_categoryCode).isPassive
              ? 'passive'
              : 'active')
        : null;
    final tx = WealthTransaction(
      id: '',
      type: widget.type,
      categoryCode: _categoryCode,
      amount: amount,
      currency: 'VND',
      occurredAt: DateTime.now(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      incomeKind: incomeKind,
    );
    try {
      await ref
          .read(wealthTransactionRepositoryProvider)
          .addTransaction(userId, tx);
      ref.invalidate(wealthTransactionsProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == WealthTransactionType.expense;
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
              ref.tr('wealth_add_transaction'),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: isExpense
                  ? [
                      for (final c in WealthExpenseCategory.values)
                        _CategoryChip(
                          icon: c.icon,
                          label: c.labelVi(),
                          selected: _categoryCode == c.code,
                          onTap: () => setState(() => _categoryCode = c.code),
                        ),
                    ]
                  : [
                      for (final c in WealthIncomeCategory.values)
                        _CategoryChip(
                          icon: c.icon,
                          label: c.labelVi(),
                          selected: _categoryCode == c.code,
                          onTap: () => setState(() => _categoryCode = c.code),
                        ),
                    ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.body(),
              cursorColor: AppColors.blue,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.glassFill,
                hintText: ref.tr('wealth_amount_hint'),
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
              style: AppTextStyles.body(),
              cursorColor: AppColors.blue,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.glassFill,
                hintText: ref.tr('wealth_note_hint'),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? AppColors.blue : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: selected ? AppColors.blue : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
