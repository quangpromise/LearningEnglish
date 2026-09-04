import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/wealth_debt_model.dart';

/// Sua note luon duoc, sua SO TIEN GOC chi khi chua co lan tra nao
/// (remaining_amount == original_amount) - tranh lam sai lech so du da tru
/// dan qua cac lan tra truoc do. Dung chung cho ca man debt_screen.dart
/// (khong con dung nua sau khi gop theo nguoi) va debt_person_history_screen.dart.
Future<void> showEditDebtDialog(
  BuildContext context,
  WidgetRef ref,
  WealthDebt debt,
) async {
  final noteController = TextEditingController(text: debt.note ?? '');
  final canEditAmount = debt.remainingAmount == debt.originalAmount;
  final amountController = TextEditingController(
    text: groupThousands(debt.originalAmount),
  );
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bgMid,
      title: Text(debt.personName, style: AppTextStyles.heading(size: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEditAmount)
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [ThousandsInputFormatter()],
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: ref.tr('wallet_amount_hint'),
              ),
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
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return;
  final newAmount = canEditAmount
      ? parseThousandsFormatted(amountController.text)
      : null;
  await ref
      .read(wealthDebtRepositoryProvider)
      .updateNoteAndAmount(
        userId,
        debt.id,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        amount: newAmount != null && newAmount > 0 ? newAmount : null,
      );
  ref.invalidate(debtsProvider(debt.direction));
  ref.invalidate(debtsByPersonProvider(debt.personId));
}
