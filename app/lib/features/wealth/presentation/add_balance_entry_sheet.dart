import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import 'bank_picker_sheet.dart';

/// Bottom sheet them/sua 1 dong bien dong so du (Nap/Rut) cho Tien mat hoac
/// Tien ngan hang - neu [initialBank] khac null nghia la dang them cho 1
/// ngan hang cu the (da chon truoc do qua [showBankPickerSheet]); null
/// nghia la Tien mat. Truyen [existing] de mo o CHE DO SUA.
Future<void> showAddBalanceEntrySheet(
  BuildContext context,
  WidgetRef ref, {
  VnBank? initialBank,
  WealthBalanceEntry? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _AddBalanceEntrySheet(bank: initialBank, existing: existing),
  );
}

class _AddBalanceEntrySheet extends ConsumerStatefulWidget {
  const _AddBalanceEntrySheet({this.bank, this.existing});
  final VnBank? bank;
  final WealthBalanceEntry? existing;

  @override
  ConsumerState<_AddBalanceEntrySheet> createState() =>
      _AddBalanceEntrySheetState();
}

class _AddBalanceEntrySheetState extends ConsumerState<_AddBalanceEntrySheet> {
  late final _amountController = TextEditingController(
    text: widget.existing == null
        ? ''
        : groupThousands(widget.existing!.amount.abs()),
  );
  late final _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late bool _isAdd = (widget.existing?.amount ?? 0) >= 0;
  late String _currency = widget.existing?.currency ?? 'VND';
  late DateTime _occurredAt = widget.existing?.occurredAt ?? DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final rawAmount = parseThousandsFormatted(_amountController.text);
    if (rawAmount == null || rawAmount <= 0) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final bank = widget.bank;
    final entry = WealthBalanceEntry(
      id: widget.existing?.id ?? '',
      accountType:
          widget.existing?.accountType ?? (bank == null ? 'cash' : 'bank'),
      bankCode:
          widget.existing?.bankCode ??
          (bank == null || bank.isOther ? null : bank.code),
      bankName: widget.existing?.bankName ?? bank?.shortName,
      currency: _currency,
      amount: _isAdd ? rawAmount : -rawAmount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      occurredAt: _occurredAt,
    );
    try {
      final repo = ref.read(wealthBalanceEntryRepositoryProvider);
      if (_isEditing) {
        await repo.updateEntry(userId, entry);
      } else {
        await repo.addEntry(userId, entry);
      }
      ref.invalidate(walletBalanceEntriesProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bank = widget.bank;
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
                bank == null ? ref.tr('wallet_section_cash') : bank.shortName,
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DirectionChip(
                      label: ref.tr('wallet_amount_direction_add'),
                      selected: _isAdd,
                      onTap: () => setState(() => _isAdd = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DirectionChip(
                      label: ref.tr('wallet_amount_direction_subtract'),
                      selected: !_isAdd,
                      onTap: () => setState(() => _isAdd = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [ThousandsInputFormatter()],
                      style: AppTextStyles.body(),
                      cursorColor: AppColors.wealthAccent,
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
                  _CurrencyToggle(
                    currency: _currency,
                    onChanged: (c) => setState(() => _currency = c),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                style: AppTextStyles.body(),
                cursorColor: AppColors.wealthAccent,
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
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_occurredAt.day.toString().padLeft(2, '0')}/'
                        '${_occurredAt.month.toString().padLeft(2, '0')}/'
                        '${_occurredAt.year} '
                        '${_occurredAt.hour.toString().padLeft(2, '0')}:'
                        '${_occurredAt.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.body(size: 13),
                      ),
                    ],
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

class _DirectionChip extends StatelessWidget {
  const _DirectionChip({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
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

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.currency, required this.onChanged});
  final String currency;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(currency == 'VND' ? 'USD' : 'VND'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          currency,
          style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
        ),
      ),
    );
  }
}
