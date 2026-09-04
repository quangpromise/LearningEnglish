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

/// 1 dong "nguoi + so tien" trong che do chia no cho nhieu nguoi.
class _SplitPersonRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
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

  // Che do "Chia cho nhieu nguoi" - cung 1 tong so tien (_amountController)
  // duoc tach thanh nhieu khoan no rieng, moi khoan gan 1 nguoi khac nhau
  // (vd cho 3 nguoi ban muon deu nhau tien nha hang). Khi bat, _personController
  // khong con dung nua - moi dong trong [_splitPeople] co nguoi + so tien rieng.
  bool _splitMode = false;
  final List<_SplitPersonRow> _splitPeople = [];

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    for (final p in _splitPeople) {
      p.dispose();
    }
    super.dispose();
  }

  void _toggleSplitMode() {
    setState(() {
      _splitMode = !_splitMode;
      if (_splitMode && _splitPeople.length < 2) {
        while (_splitPeople.length < 2) {
          _splitPeople.add(_SplitPersonRow());
        }
      }
    });
  }

  void _addSplitPerson() {
    setState(() => _splitPeople.add(_SplitPersonRow()));
  }

  void _removeSplitPerson(int i) {
    setState(() => _splitPeople.removeAt(i).dispose());
  }

  double get _totalAmount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0;

  double get _splitAllocated => _splitPeople.fold<double>(
    0,
    (s, p) =>
        s +
        (double.tryParse(p.amountController.text.trim().replaceAll(',', '.')) ??
            0),
  );

  void _splitEqually() {
    if (_splitPeople.isEmpty) return;
    final each = _totalAmount / _splitPeople.length;
    setState(() {
      for (final p in _splitPeople) {
        p.amountController.text = each <= 0 ? '' : each.toStringAsFixed(0);
      }
    });
  }

  bool get _splitValid {
    if (_totalAmount <= 0) return false;
    if (_splitPeople.length < 2) return false;
    for (final p in _splitPeople) {
      if (p.nameController.text.trim().isEmpty) return false;
      final amount = double.tryParse(
        p.amountController.text.trim().replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) return false;
    }
    return (_splitAllocated - _totalAmount).abs() < 0.5;
  }

  Future<void> _save() async {
    if (_splitMode) {
      await _saveSplit();
    } else {
      await _saveSingle();
    }
  }

  Future<void> _saveSingle() async {
    final name = _personController.text.trim();
    final amount = _totalAmount;
    if (name.isEmpty || amount <= 0) return;
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

  /// Tao 1 [WealthDebt] rieng cho MOI nguoi trong [_splitPeople] - cung note/
  /// ngay/currency, chi khac nguoi + so tien phan chia cua ho.
  Future<void> _saveSplit() async {
    if (!_splitValid) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final occurredAt = DateTime.now();
    try {
      final personRepo = ref.read(wealthDebtPersonRepositoryProvider);
      final debtRepo = ref.read(wealthDebtRepositoryProvider);
      for (final p in _splitPeople) {
        final name = p.nameController.text.trim();
        final amount =
            double.tryParse(
              p.amountController.text.trim().replaceAll(',', '.'),
            ) ??
            0;
        if (name.isEmpty || amount <= 0) continue;
        final person = await personRepo.findOrCreate(userId, name);
        await debtRepo.create(
          userId: userId,
          personId: person.id,
          direction: widget.direction,
          amount: amount,
          currency: _currency,
          note: note,
          occurredAt: occurredAt,
        );
      }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.direction == 'i_owe'
                          ? ref.tr('wealth_debt_add_i_owe')
                          : ref.tr('wealth_debt_add_owed_to_me'),
                      style: AppTextStyles.heading(size: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleSplitMode,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _splitMode
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color: _splitMode
                              ? AppColors.wealthAccent
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ref.tr('wealth_debt_split_mode'),
                          style: AppTextStyles.muted(size: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_splitMode) ...[
                DebtPersonPickerField(controller: _personController),
                const SizedBox(height: 10),
              ] else if (_splitMode)
                Text(
                  ref.tr('wealth_debt_split_total_hint'),
                  style: AppTextStyles.muted(size: 11),
                ),
              if (_splitMode) const SizedBox(height: 6),
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
                      onChanged: (_) => setState(() {}),
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
              if (_splitMode) ...[
                const SizedBox(height: 12),
                for (var i = 0; i < _splitPeople.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DebtPersonPickerField(
                            controller: _splitPeople[i].nameController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: _splitPeople[i].amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AppTextStyles.body(size: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.glassFill,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_splitPeople.length > 2)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => _removeSplitPerson(i),
                          ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _addSplitPerson,
                      child: Text(
                        '+ ${ref.tr('wealth_debt_split_add_person')}',
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.wealthAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: _splitEqually,
                      child: Text(
                        ref.tr('wealth_debt_split_equal'),
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if ((_splitAllocated - _totalAmount).abs() > 0.5)
                      Text(
                        '${ref.tr('wealth_split_remaining')}: '
                        '${(_totalAmount - _splitAllocated).toStringAsFixed(0)}',
                        style: AppTextStyles.muted(size: 11)
                            .copyWith(color: AppColors.pink),
                      ),
                  ],
                ),
              ],
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
                  onTap: _saving || (_splitMode && !_splitValid) ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
