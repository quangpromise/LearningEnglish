import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'debt_person_picker_field.dart';

/// Bottom sheet them 1 khoan no moi - [direction] co dinh theo tab dang mo
/// ('i_owe' hoac 'owed_to_me').
void showAddDebtSheet(BuildContext context, String direction) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddDebtSheet(direction: direction),
  );
}

class _AddDebtSheet extends ConsumerStatefulWidget {
  const _AddDebtSheet({required this.direction});
  final String direction;

  @override
  ConsumerState<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<_AddDebtSheet> {
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _currency = 'VND';
  bool _saving = false;

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _personController.text.trim();
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (name.isEmpty || amount == null || amount <= 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final person = await ref
          .read(wealthDebtPersonRepositoryProvider)
          .findOrCreate(userId, name);
      await ref
          .read(wealthDebtRepositoryProvider)
          .create(
            userId: userId,
            personId: person.id,
            direction: widget.direction,
            amount: amount,
            currency: _currency,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            occurredAt: DateTime.now(),
          );
      ref.invalidate(debtPersonsProvider);
      ref.invalidate(debtsProvider(widget.direction));
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
              widget.direction == 'i_owe'
                  ? ref.tr('wealth_debt_add_i_owe')
                  : ref.tr('wealth_debt_add_owed_to_me'),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 16),
            DebtPersonPickerField(controller: _personController),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.glassFill,
                      hintText: ref.tr('wallet_amount_hint'),
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(
                    () => _currency = _currency == 'VND' ? 'USD' : 'VND',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      _currency,
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
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
