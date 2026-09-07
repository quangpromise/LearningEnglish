import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/recurring_service_model.dart';
import '../data/recurring_service_repository.dart';
import 'debt_person_picker_field.dart';
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
  // Gia han bang cach GHI NO nguoi khac (vd muon tien ban be tra truoc) thay
  // vi tru thang vao Vi - xem RecurringServiceRepository.renew(viaDebt:).
  bool _viaDebt = false;
  final _debtPersonController = TextEditingController();

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
    _debtPersonController.dispose();
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
    if (_amount <= 0) return false;
    if (_viaDebt) return _debtPersonController.text.trim().isNotEmpty;
    final sum = _splits.fold<double>(0, (s, p) => s + p.amount);
    return (sum - _amount).abs() < 0.5;
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
            viaDebt: _viaDebt,
            payments: _viaDebt
                ? const []
                : _splits
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
      ref.invalidate(serviceRenewalsProvider);
      if (_viaDebt) {
        // Chua tru Vi/ghi chi tieu gi luc nay (xem RecurringServiceRepository
        // .renew(viaDebt:)) - chi tao 1 khoan "Dang no", chi tieu thuc su chi
        // duoc tinh khi nguoi dung tra khoan no nay sau nay.
        final person = await ref
            .read(wealthDebtPersonRepositoryProvider)
            .findOrCreate(userId, _debtPersonController.text.trim());
        await ref
            .read(wealthDebtRepositoryProvider)
            .create(
              userId: userId,
              personId: person.id,
              direction: 'i_owe',
              amount: _amount,
              currency: widget.service.currency,
              note: '${widget.service.name} - gia hạn',
              occurredAt: DateTime.now(),
            );
        ref.invalidate(debtPersonsProvider);
        ref.invalidate(debtsProvider('i_owe'));
      } else {
        ref.invalidate(walletBalanceEntriesProvider);
        ref.invalidate(wealthTransactionsProvider);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmtDate(DateTime d) => formatDateMdy(d);

  @override
  Widget build(BuildContext context) {
    final isManual = widget.service.cycleType == 'manual';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
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
                    GestureDetector(
                      onTap: () => setState(() => _viaDebt = !_viaDebt),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _viaDebt
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 18,
                            color: _viaDebt
                                ? AppColors.wealthAccent
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ref.tr('wealth_service_renew_via_debt'),
                            style: AppTextStyles.muted(size: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_viaDebt) ...[
                      Text(
                        ref.tr('wealth_debt_person_hint'),
                        style: AppTextStyles.muted(size: 11),
                      ),
                      const SizedBox(height: 6),
                      DebtPersonPickerField(controller: _debtPersonController),
                    ] else ...[
                      Text(
                        ref.tr('wealth_pay_by'),
                        style: AppTextStyles.muted(size: 11),
                      ),
                      const SizedBox(height: 6),
                      PaymentSplitEditor(
                        totalAmount: _amount,
                        onChanged: (splits) => setState(() => _splits = splits),
                      ),
                    ],
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
          ),
        ),
      ),
    );
  }
}
