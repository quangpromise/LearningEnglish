import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_debt_payment_model.dart';

class WealthDebtPaymentRepository {
  WealthDebtPaymentRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthDebtPayment>> fetchAll(String userId, String debtId) async {
    final rows = await _supabase
        .from('wealth_debt_payments')
        .select()
        .eq('user_id', userId)
        .eq('debt_id', debtId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthDebtPayment.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Chi ghi dong payment - viec giam remaining_amount cua khoan no ([
  /// WealthDebtRepository.applyPayment]) va sinh dong wealth_balance_entries
  /// tuong ung do noi goi (pay_debt_sheet.dart) dieu phoi, giong cach
  /// add_transaction_sheet.dart dieu phoi wealth_transactions +
  /// wealth_balance_entries cho Chi tieu.
  Future<String> record({
    required String userId,
    required String debtId,
    required double amount,
    required String paymentAccountType,
    String? paymentBankCode,
    String? paymentBankName,
    required String currency,
    String? note,
    required DateTime occurredAt,
  }) async {
    final row = await _supabase
        .from('wealth_debt_payments')
        .insert({
          'user_id': userId,
          'debt_id': debtId,
          'amount': amount,
          'payment_account_type': paymentAccountType,
          'payment_bank_code': paymentBankCode,
          'payment_bank_name': paymentBankName,
          'currency': currency,
          'note': note,
          'occurred_at': occurredAt.toIso8601String(),
        })
        .select('id')
        .single();
    return row['id'] as String;
  }
}
