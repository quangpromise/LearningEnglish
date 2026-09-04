import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/recurring_service_model.dart';

/// Bottom sheet them/sua 1 dich vu dinh ky - chon ngay bat dau + chu ky
/// (tuan/thang/nam/so nam tuy chon) de TU TINH ngay het han, hoac chon
/// "Ngay cu the" de tu go thang ngay het han truc tiep (khong tu tinh lai
/// khi gia han lan sau, phai chon lai moi lan). Truyen [existing] de mo o
/// CHE DO SUA - chi cho sua ten/so tien mac dinh/note/so ngay nhac truoc,
/// KHONG cho doi chu ky/ngay het han (dung "Gia han" de doi ngay het han).
void showAddServiceSheet(BuildContext context, {RecurringService? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddServiceSheet(existing: existing),
  );
}

const _kCycleTypes = ['week', 'month', 'year', 'custom_years', 'manual'];
const _kLeadDaysOptions = [7, 15, 30];

class _AddServiceSheet extends ConsumerStatefulWidget {
  const _AddServiceSheet({this.existing});
  final RecurringService? existing;

  @override
  ConsumerState<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends ConsumerState<_AddServiceSheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _amountController = TextEditingController(
    text: widget.existing == null
        ? ''
        : groupThousands(widget.existing!.defaultAmount),
  );
  late final _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  final _cycleYearsController = TextEditingController(text: '1');
  late String _currency = widget.existing?.currency ?? 'VND';
  String _cycleType = 'month';
  late int _reminderLeadDays = widget.existing?.reminderLeadDays ?? 7;
  DateTime _startDate = DateTime.now();
  DateTime? _manualExpiryDate;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _cycleYearsController.dispose();
    super.dispose();
  }

  DateTime? get _computedExpiry {
    if (_cycleType == 'manual') return _manualExpiryDate;
    return RecurringService.computeNextExpiry(
      cycleType: _cycleType,
      from: _startDate,
      cycleYears: double.tryParse(_cycleYearsController.text.trim()),
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _pickManualExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _manualExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _manualExpiryDate = date);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = parseThousandsFormatted(_amountController.text);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    if (name.isEmpty || amount == null || amount < 0) return;
    if (!_isEditing && _computedExpiry == null) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final repo = ref.read(recurringServiceRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          userId: userId,
          id: widget.existing!.id,
          name: name,
          defaultAmount: amount,
          reminderLeadDays: _reminderLeadDays,
          note: note,
        );
      } else {
        await repo.create(
          userId: userId,
          name: name,
          defaultAmount: amount,
          currency: _currency,
          cycleType: _cycleType,
          cycleYears: _cycleType == 'custom_years'
              ? double.tryParse(_cycleYearsController.text.trim())
              : null,
          startDate: _startDate,
          expiryDate: _computedExpiry!,
          reminderLeadDays: _reminderLeadDays,
          note: note,
        );
      }
      ref.invalidate(recurringServicesProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _cycleLabel(String type) => switch (type) {
    'week' => ref.tr('wealth_service_cycle_week'),
    'month' => ref.tr('wealth_service_cycle_month'),
    'year' => ref.tr('wealth_service_cycle_year'),
    'custom_years' => ref.tr('wealth_service_cycle_custom_years'),
    _ => ref.tr('wealth_service_cycle_manual'),
  };

  String _leadLabel(int days) => switch (days) {
    30 => ref.tr('wealth_service_lead_1_month'),
    15 => ref.tr('wealth_service_lead_half_month'),
    _ => ref.tr('wealth_service_lead_1_week'),
  };

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final expiry = _computedExpiry;
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
                _isEditing
                    ? ref.tr('wealth_service_edit')
                    : ref.tr('wealth_service_add'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.glassFill,
                  hintText: ref.tr('wealth_service_name_hint'),
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                Text(
                  ref.tr('wealth_service_start_date'),
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickStartDate,
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
                    child: Text(
                      _fmtDate(_startDate),
                      style: AppTextStyles.body(size: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ref.tr('wealth_service_cycle'),
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _kCycleTypes)
                      _Chip(
                        label: _cycleLabel(t),
                        selected: _cycleType == t,
                        onTap: () => setState(() => _cycleType = t),
                      ),
                  ],
                ),
                if (_cycleType == 'custom_years') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cycleYearsController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.glassFill,
                      hintText: ref.tr('wealth_service_years_hint'),
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                if (_cycleType == 'manual') ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickManualExpiry,
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
                      child: Text(
                        _manualExpiryDate == null
                            ? ref.tr('wealth_service_pick_expiry')
                            : _fmtDate(_manualExpiryDate!),
                        style: AppTextStyles.body(size: 13),
                      ),
                    ),
                  ),
                ] else if (expiry != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${ref.tr('wealth_service_expiry_preview')}: ${_fmtDate(expiry)}',
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.wealthAccent,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              Text(
                ref.tr('wealth_service_reminder_lead'),
                style: AppTextStyles.muted(size: 11),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _kLeadDaysOptions)
                    _Chip(
                      label: _leadLabel(d),
                      selected: _reminderLeadDays == d,
                      onTap: () => setState(() => _reminderLeadDays = d),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: ref.tr('wallet_save'),
                  accentGradient: AppColors.wealthAccentGradient,
                  accentColor: AppColors.wealthAccent,
                  onTap: _saving || (!_isEditing && _computedExpiry == null)
                      ? null
                      : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
