import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_balance_entry_model.dart';

class WealthBalanceEntryRepository {
  WealthBalanceEntryRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthBalanceEntry>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_balance_entries')
        .select()
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthBalanceEntry.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEntry(String userId, WealthBalanceEntry entry) async {
    await _supabase
        .from('wealth_balance_entries')
        .insert(entry.toInsertRow(userId));
  }

  /// Cap nhat lai 1 dong da co (sua so tien/note/ngay) - giu nguyen
  /// account_type/bank vi khong cho doi "Tien mat" thanh "Ngan hang" hay
  /// nguoc lai khi sua (xoa di them lai neu can doi loai tai khoan).
  Future<void> updateEntry(String userId, WealthBalanceEntry entry) async {
    await _supabase
        .from('wealth_balance_entries')
        .update({
          'amount': entry.amount,
          'currency': entry.currency,
          'note': entry.note,
          'occurred_at': entry.occurredAt.toIso8601String(),
        })
        .eq('id', entry.id)
        .eq('user_id', userId);
  }

  /// Sua lai dong da sinh ra tu 1 lan tra no (source_debt_payment_id) -
  /// dung khi nguoi dung sua so tien/note cua lan tra do trong lich su No,
  /// giu nguyen account_type/bank da chon luc tra (khong doi hinh thuc khi
  /// chi sua so tien/note).
  Future<void> updateBySourceDebtPayment(
    String userId,
    String debtPaymentId, {
    required double amount,
    String? note,
  }) async {
    await _supabase
        .from('wealth_balance_entries')
        .update({'amount': amount, 'note': note})
        .eq('user_id', userId)
        .eq('source_debt_payment_id', debtPaymentId);
  }

  Future<void> deleteEntry(String userId, String id) async {
    await _supabase
        .from('wealth_balance_entries')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Xoa tat ca dong da sinh ra tu 1 giao dich Chi tieu - dung khi SUA lai
  /// giao dich do (xoa het bo cu roi chen lai bo moi theo split vua sua),
  /// khac voi xoa han giao dich (luc do DB tu cascade qua FK
  /// source_transaction_id, khong can goi ham nay).
  Future<void> deleteBySourceTransaction(
    String userId,
    String transactionId,
  ) async {
    await _supabase
        .from('wealth_balance_entries')
        .delete()
        .eq('user_id', userId)
        .eq('source_transaction_id', transactionId);
  }

  /// Tong so du gop theo (accountType, bankCode/bankName, currency) - dung
  /// cho man Vi > Tai san hien co va tong o Home.
  List<WealthAccountTotal> computeTotals(List<WealthBalanceEntry> entries) {
    final totals = <String, WealthAccountTotal>{};
    for (final e in entries) {
      final key =
          '${e.accountType}|${e.bankCode ?? e.bankName ?? ''}|${e.currency}';
      final existing = totals[key];
      totals[key] = WealthAccountTotal(
        accountType: e.accountType,
        bankCode: e.bankCode,
        bankName: e.bankName,
        currency: e.currency,
        total: (existing?.total ?? 0) + e.amount,
      );
    }
    return totals.values.toList();
  }
}
