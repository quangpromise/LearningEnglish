import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_debt_model.dart';
import '../data/wealth_transaction_model.dart';
import 'bank_picker_sheet.dart';

/// Tra/thu no CUNG LUC cho nhieu nguoi da chon o man No (Phase G+) - moi
/// nguoi mac dinh duoc tra/thu DU so con lai (gop theo currency, co the sua
/// lai tung dong), dung CHUNG 1 hinh thuc thanh toan cho ca lo giong het
/// pay_debt_sheet.dart nhung lap lai cho tung khoan. Neu 1 nguoi co NHIEU
/// khoan no rieng le (cung chieu, cung currency), so tien nhap duoc phan bo
/// lan luot vao khoan CU nhat truoc (FIFO) cho toi khi het.
Future<void> showBatchPayDebtSheet(
  BuildContext context,
  String direction,
  List<WealthDebt> debts,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BatchPayDebtSheet(direction: direction, debts: debts),
  );
}

/// 1 dong nhap tien cho 1 (nguoi, loai tien te) - co the dai dien nhieu
/// [WealthDebt] neu nguoi do co nhieu khoan no rieng le chua tra het.
class _PersonAmountGroup {
  _PersonAmountGroup({
    required this.personId,
    required this.personName,
    required this.currency,
    required this.debts,
  }) : controller = TextEditingController(
         text: groupThousands(
           debts.fold<double>(0, (s, d) => s + d.remainingAmount),
         ),
       );

  final String personId;
  final String personName;
  final String currency;
  final List<WealthDebt> debts;
  final TextEditingController controller;

  double get totalRemaining =>
      debts.fold<double>(0, (s, d) => s + d.remainingAmount);
}

class _BatchPayDebtSheet extends ConsumerStatefulWidget {
  const _BatchPayDebtSheet({required this.direction, required this.debts});
  final String direction;
  final List<WealthDebt> debts;

  @override
  ConsumerState<_BatchPayDebtSheet> createState() => _BatchPayDebtSheetState();
}

class _BatchPayDebtSheetState extends ConsumerState<_BatchPayDebtSheet> {
  late final List<_PersonAmountGroup> _groups = _buildGroups();
  bool _payByCash = true;
  VnBank? _payByBank;
  bool _saving = false;

  bool get _isIOwe => widget.direction == 'i_owe';

  List<_PersonAmountGroup> _buildGroups() {
    final map = <String, List<WealthDebt>>{};
    for (final d in widget.debts) {
      if (d.isSettled) continue;
      map.putIfAbsent('${d.personId}|${d.currency}', () => []).add(d);
    }
    return [
      for (final entry in map.entries)
        _PersonAmountGroup(
          personId: entry.value.first.personId,
          personName: entry.value.first.personName,
          currency: entry.value.first.currency,
          debts: entry.value
            ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt)),
        ),
    ];
  }

  @override
  void dispose() {
    for (final g in _groups) {
      g.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_payByCash && _payByBank == null) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final accountType = _payByCash ? 'cash' : 'bank';
    final bankCode = !_payByCash && !_payByBank!.isOther
        ? _payByBank!.code
        : null;
    final bankName = !_payByCash ? _payByBank!.shortName : null;
    final now = DateTime.now();
    final debtPaymentRepo = ref.read(wealthDebtPaymentRepositoryProvider);
    final debtRepo = ref.read(wealthDebtRepositoryProvider);
    final balanceRepo = ref.read(wealthBalanceEntryRepositoryProvider);
    final txRepo = ref.read(wealthTransactionRepositoryProvider);
    var anyExpenseCreated = false;
    final affectedPersonIds = <String>{};
    try {
      for (final group in _groups) {
        var amount = parseThousandsFormatted(group.controller.text) ?? 0;
        if (amount <= 0) continue;
        affectedPersonIds.add(group.personId);
        final note = '${group.personName} - ${_isIOwe ? 'trả nợ' : 'thu nợ'}';
        for (final debt in group.debts) {
          if (amount <= 0) break;
          final apply = amount >= debt.remainingAmount
              ? debt.remainingAmount
              : amount;
          if (apply <= 0) continue;
          amount -= apply;
          final paymentId = await debtPaymentRepo.record(
            userId: userId,
            debtId: debt.id,
            amount: apply,
            paymentAccountType: accountType,
            paymentBankCode: bankCode,
            paymentBankName: bankName,
            currency: debt.currency,
            note: null,
            occurredAt: now,
          );
          // Minh tra no (i_owe) la 1 khoan CHI - ghi them wealth_transactions
          // giong pay_debt_sheet.dart de tinh vao Chi tieu o man Bao cao.
          if (_isIOwe) {
            final tx = WealthTransaction(
              id: '',
              type: WealthTransactionType.expense,
              categoryCode: 'DEBT',
              amount: apply,
              currency: debt.currency,
              occurredAt: now,
              note: note,
              paymentAccountType: accountType,
              paymentBankCode: bankCode,
              paymentBankName: bankName,
            );
            final txId = await txRepo.addTransaction(userId, tx);
            await debtPaymentRepo.linkTransaction(userId, paymentId, txId);
            anyExpenseCreated = true;
          }
          await debtRepo.applyPayment(userId, debt.id, apply);
          final signedAmount = _isIOwe ? -apply : apply;
          await balanceRepo.addEntry(
            userId,
            WealthBalanceEntry(
              id: '',
              accountType: accountType,
              bankCode: bankCode,
              bankName: bankName,
              currency: debt.currency,
              amount: signedAmount,
              note: note,
              occurredAt: now,
              source: 'debt_payment',
              sourceDebtPaymentId: paymentId,
            ),
          );
        }
      }
      ref.invalidate(walletBalanceEntriesProvider);
      ref.invalidate(debtsProvider(widget.direction));
      for (final personId in affectedPersonIds) {
        ref.invalidate(debtsByPersonProvider(personId));
      }
      if (anyExpenseCreated) {
        ref.invalidate(wealthTransactionsProvider);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
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
                    ref.tr(
                      _isIOwe
                          ? 'wealth_debt_batch_pay_title'
                          : 'wealth_debt_batch_collect_title',
                    ),
                    style: AppTextStyles.heading(size: 16),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final group in _groups) ...[
                            Text(
                              group.personName,
                              style: AppTextStyles.body(
                                size: 13,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: group.controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [ThousandsInputFormatter()],
                              style: AppTextStyles.body(),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.glassFill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
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
