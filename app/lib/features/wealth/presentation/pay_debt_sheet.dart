import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_debt_model.dart';
import 'bank_picker_sheet.dart';

/// Bottom sheet tra 1 phan/toan bo khoan no ([debt.isIOwe]: minh tra - tru
/// vao Vi) hoac nhan nguoi khac tra no ([!debt.isIOwe]: cong vao Vi) - luon
/// bat buoc chon hinh thuc (Tien mat/1 ngan hang cu the) giong Chi tieu, de
/// tu dong dong bo dung so du Vi.
void showPayDebtSheet(BuildContext context, WealthDebt debt) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PayDebtSheet(debt: debt),
  );
}

class _PayDebtSheet extends ConsumerStatefulWidget {
  const _PayDebtSheet({required this.debt});
  final WealthDebt debt;

  @override
  ConsumerState<_PayDebtSheet> createState() => _PayDebtSheetState();
}

class _PayDebtSheetState extends ConsumerState<_PayDebtSheet> {
  late final _amountController = TextEditingController(
    text: groupThousands(widget.debt.remainingAmount),
  );
  final _noteController = TextEditingController();
  bool _payByCash = true;
  VnBank? _payByBank;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseThousandsFormatted(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (!_payByCash && _payByBank == null) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final debt = widget.debt;
    final accountType = _payByCash ? 'cash' : 'bank';
    final bankCode = !_payByCash && !_payByBank!.isOther
        ? _payByBank!.code
        : null;
    final bankName = !_payByCash ? _payByBank!.shortName : null;
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final now = DateTime.now();
    try {
      final paymentId = await ref
          .read(wealthDebtPaymentRepositoryProvider)
          .record(
            userId: userId,
            debtId: debt.id,
            amount: amount,
            paymentAccountType: accountType,
            paymentBankCode: bankCode,
            paymentBankName: bankName,
            currency: debt.currency,
            note: note,
            occurredAt: now,
          );
      await ref
          .read(wealthDebtRepositoryProvider)
          .applyPayment(userId, debt.id, amount);
      // Minh tra (i_owe) -> tru Vi; nguoi ta tra minh (owed_to_me) -> cong Vi.
      final signedAmount = debt.isIOwe ? -amount : amount;
      await ref
          .read(wealthBalanceEntryRepositoryProvider)
          .addEntry(
            userId,
            WealthBalanceEntry(
              id: '',
              accountType: accountType,
              bankCode: bankCode,
              bankName: bankName,
              currency: debt.currency,
              amount: signedAmount,
              note:
                  note ??
                  '${debt.personName} - ${debt.isIOwe ? 'trả nợ' : 'thu nợ'}',
              occurredAt: now,
              source: 'debt_payment',
              sourceDebtPaymentId: paymentId,
            ),
          );
      ref.invalidate(walletBalanceEntriesProvider);
      ref.invalidate(debtsProvider(debt.direction));
      ref.invalidate(debtsByPersonProvider(debt.personId));
      ref.invalidate(debtPaymentsProvider(debt.id));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final debt = widget.debt;
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
                      debt.isIOwe
                          ? ref.tr('wealth_debt_pay')
                          : ref.tr('wealth_debt_collect'),
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
                    const SizedBox(height: 10),
                    Text(
                      ref.tr('wealth_pay_by'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _Chip(
                            label: ref.tr('wallet_section_cash'),
                            selected: _payByCash,
                            onTap: () => setState(() {
                              _payByCash = true;
                              _payByBank = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Chip(
                            label:
                                _payByBank?.shortName ??
                                ref.tr('wealth_pay_by_bank'),
                            selected: !_payByCash,
                            onTap: () async {
                              final bank = await showBankPickerSheet(context);
                              if (bank != null) {
                                setState(() {
                                  _payByCash = false;
                                  _payByBank = bank;
                                });
                              }
                            },
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
            ),
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
          overflow: TextOverflow.ellipsis,
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
