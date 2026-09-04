import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/recurring_service_model.dart';
import '../data/recurring_service_repository.dart';
import 'payment_split_editor.dart';

/// Bottom sheet gia han 1 dich vu - so tien mac dinh lay tu lan truoc
/// (`service.defaultAmount`), co the tuy chinh lai; thanh toan co the tach
/// nhieu hinh thuc (Tien mat + Ngan hang) cho cung 1 lan gia han. Neu chu ky
/// la 'manual', bat buoc tu chon ngay het han moi (khong tu tinh duoc).
void showRenewServiceSheet(BuildContext context, RecurringService service) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RenewServiceSheet(service: service),
  );
}

class _RenewServiceSheet extends ConsumerStatefulWidget {
  const _RenewServiceSheet({required this.service});
  final RecurringService service;

  @override
  ConsumerState<_RenewServiceSheet> createState() => _RenewServiceSheetState();
}

class _RenewServiceSheetState extends ConsumerState<_RenewServiceSheet> {
  late final _amountController = TextEditingController(
    text: groupThousands(widget.service.defaultAmount),
  );
  double _amount = 0;
  List<PaymentSplit> _splits = const [];
  DateTime? _manualNewExpiry;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = widget.service.defaultAmount;
    _amountController.addListener(() {
      setState(
        () => _amount = parseThousandsFormatted(_amountController.text) ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  DateTime? get _newExpiry {
    if (widget.service.cycleType == 'manual') return _manualNewExpiry;
    return RecurringService.computeNextExpiry(
      cycleType: widget.service.cycleType,
      from: widget.service.expiryDate,
      cycleYears: widget.service.cycleYears,
    );
  }

  bool get _splitsValid {
    final sum = _splits.fold<double>(0, (s, p) => s + p.amount);
    return _amount > 0 && (sum - _amount).abs() < 0.5;
  }

  Future<void> _pickManualExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.service.expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _manualNewExpiry = date);
  }

  Future<void> _save() async {
    final expiry = _newExpiry;
    if (expiry == null || !_splitsValid) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      await ref
          .read(recurringServiceRepositoryProvider)
          .renew(
            userId: userId,
            service: widget.service,
            totalAmount: _amount,
            newExpiryDate: expiry,
            payments: _splits
                .where((s) => s.amount > 0)
                .map(
                  (s) => RenewalPaymentInput(
                    accountType: s.accountType,
                    bankCode: s.bankCode,
                    bankName: s.bankName,
                    amount: s.amount,
                  ),
                )
                .toList(),
          );
      ref.invalidate(recurringServicesProvider);
      ref.invalidate(walletBalanceEntriesProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isManual = widget.service.cycleType == 'manual';
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
                '${ref.tr('wealth_service_renew')} — ${widget.service.name}',
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 16),
              TextField(
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
              if (isManual) ...[
                const SizedBox(height: 10),
                Text(
                  ref.tr('wealth_service_pick_expiry'),
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 6),
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
                      _manualNewExpiry == null
                          ? ref.tr('wealth_service_pick_expiry')
                          : _fmtDate(_manualNewExpiry!),
                      style: AppTextStyles.body(size: 13),
                    ),
                  ),
                ),
              ] else if (_newExpiry != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${ref.tr('wealth_service_expiry_preview')}: ${_fmtDate(_newExpiry!)}',
                  style: AppTextStyles.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.wealthAccent,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                ref.tr('wealth_pay_by'),
                style: AppTextStyles.muted(size: 11),
              ),
              const SizedBox(height: 6),
              PaymentSplitEditor(
                totalAmount: _amount,
                onChanged: (splits) => _splits = splits,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: ref.tr('wealth_service_renew'),
                  accentGradient: AppColors.wealthAccentGradient,
                  accentColor: AppColors.wealthAccent,
                  onTap: _saving || !_splitsValid || _newExpiry == null
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
