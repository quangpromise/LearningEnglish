import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_debt_payment_model.dart';

class WealthDebtPaymentRepository {
  WealthDebtPaymentRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthDebtPayment>> fetchAll(String userId, String debtId) async {
    final rows = await _supabase
        .from('wealth_debt_payments')
        .select(
          'id, debt_id, amount, payment_account_type, payment_bank_code, payment_bank_name, currency, note, occurred_at, transaction_id',
        )
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

  /// Lay `debt_id` + `amount` + `transaction_id` cua 1 lan tra - dung khi
  /// XOA truc tiep 1 dong wealth_balance_entries co source='debt_payment' tu
  /// man Vi (thay vi xoa tu man No): can biet tra lai bao nhieu vao
  /// remaining_amount cua dung khoan no nao, va xoa dong wealth_transactions
  /// lien ket (neu co) de dong bo voi man Bao cao (xem
  /// wallet_existing_assets_tab.dart).
  Future<({String debtId, double amount, String? transactionId})?> fetchOne(
    String userId,
    String id,
  ) async {
    final row = await _supabase
        .from('wealth_debt_payments')
        .select('debt_id, amount, transaction_id')
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return (
      debtId: row['debt_id'] as String,
      amount: (row['amount'] as num).toDouble(),
      transactionId: row['transaction_id'] as String?,
    );
  }

  /// Gan `transaction_id` sau khi da tao dong wealth_transactions tuong ung
  /// (xem pay_debt_sheet.dart) - tach rieng vi phai co `id` cua lan tra
  /// (tra ve tu [record]) truoc khi tao duoc dong giao dich lien ket.
  Future<void> linkTransaction(
    String userId,
    String id,
    String transactionId,
  ) async {
    await _supabase
        .from('wealth_debt_payments')
        .update({'transaction_id': transactionId})
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Sua lai note/so tien 1 lan tra da ghi - noi goi (debt_person_history_screen.dart)
  /// chiu trach nhiem dieu chinh lai remaining_amount cua khoan no
  /// ([WealthDebtRepository.restoreAmount] + `applyPayment`) va dong
  /// wealth_balance_entries lien quan ([WealthBalanceEntryRepository.
  /// updateBySourceDebtPayment]) truoc/sau khi goi ham nay, giong cach
  /// add_transaction_sheet.dart dieu phoi nhieu bang cho 1 lan sua.
  Future<void> update(
    String userId,
    String id, {
    String? note,
    required double amount,
  }) async {
    await _supabase
        .from('wealth_debt_payments')
        .update({'note': note, 'amount': amount})
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> delete(String userId, String id) async {
    await _supabase
        .from('wealth_debt_payments')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
