import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/wealth_debt_model.dart';
import '../data/wealth_debt_payment_model.dart';

/// Sua note/so tien cua 1 LAN TRA NO cu the (khac voi showEditDebtDialog -
/// sua khoan no goc). Sua so tien phai dieu chinh lai ca remaining_amount
/// cua khoan no (hoan tra so cu, ap dung lai so moi) LAN dong
/// wealth_balance_entries lien quan de so du Vi luon dung, khong chi doi
/// rieng dong wealth_debt_payments.
Future<void> showEditDebtPaymentDialog(
  BuildContext context,
  WidgetRef ref,
  WealthDebt debt,
  WealthDebtPayment payment,
) async {
  final noteController = TextEditingController(text: payment.note ?? '');
  final amountController = TextEditingController(
    text: groupThousands(payment.amount),
  );
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bgMid,
      title: Text(
        ref.tr('wealth_debt_edit_payment'),
        style: AppTextStyles.heading(size: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ThousandsInputFormatter()],
            style: AppTextStyles.body(),
            decoration: InputDecoration(hintText: ref.tr('wallet_amount_hint')),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            style: AppTextStyles.body(),
            decoration: InputDecoration(hintText: ref.tr('wallet_note_hint')),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(ref.tr('common_cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(ref.tr('common_confirm')),
        ),
      ],
    ),
  );
  if (result != true) return;
  final newAmount = parseThousandsFormatted(amountController.text);
  if (newAmount == null || newAmount <= 0) return;
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return;
  final newNote = noteController.text.trim().isEmpty
      ? null
      : noteController.text.trim();

  final debtRepo = ref.read(wealthDebtRepositoryProvider);
  if (newAmount != payment.amount) {
    // Hoan lai so cu roi ap dung lai so moi - don gian va chinh xac hon
    // cong/tru chenh lech thu cong, tai su dung dung 2 ham da co san.
    await debtRepo.restoreAmount(userId, debt.id, payment.amount);
    await debtRepo.applyPayment(userId, debt.id, newAmount);
  }
  await ref
      .read(wealthDebtPaymentRepositoryProvider)
      .update(userId, payment.id, note: newNote, amount: newAmount);
  final signedAmount = debt.isIOwe ? -newAmount : newAmount;
  await ref
      .read(wealthBalanceEntryRepositoryProvider)
      .updateBySourceDebtPayment(
        userId,
        payment.id,
        amount: signedAmount,
        note:
            newNote ??
            '${debt.personName} - ${debt.isIOwe ? 'trả nợ' : 'thu nợ'}',
      );
  ref.invalidate(walletBalanceEntriesProvider);
  ref.invalidate(debtsProvider(debt.direction));
  ref.invalidate(debtsByPersonProvider(debt.personId));
  ref.invalidate(debtPaymentsProvider(debt.id));
}
