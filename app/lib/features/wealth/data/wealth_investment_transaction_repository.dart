import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_investment_transaction_model.dart';

class WealthInvestmentTransactionRepository {
  WealthInvestmentTransactionRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthInvestmentTransaction>> fetchAll(
    String userId,
    String assetType,
  ) async {
    final rows = await _supabase
        .from('wealth_investment_transactions')
        .select()
        .eq('user_id', userId)
        .eq('asset_type', assetType)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map(
          (r) => WealthInvestmentTransaction.fromRow(r as Map<String, dynamic>),
        )
        .toList();
  }

  /// Cac giao dich dau tu sinh ra tu 1 dong chi tieu "Dau tu" cu the - dung
  /// luc XOA khoan chi tieu do de biet phai tru lai bao nhieu o Portfolio
  /// (xem migration 0067 + deleteInvestmentExpense).
  Future<List<WealthInvestmentTransaction>> fetchBySourceTransaction(
    String userId,
    String transactionId,
  ) async {
    final rows = await _supabase
        .from('wealth_investment_transactions')
        .select()
        .eq('user_id', userId)
        .eq('source_transaction_id', transactionId);
    return (rows as List)
        .map(
          (r) => WealthInvestmentTransaction.fromRow(r as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> deleteById(String userId, String id) async {
    await _supabase
        .from('wealth_investment_transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> record({
    required String userId,
    required String assetType,
    required String action,
    String? symbol,
    double? quantity,
    double? price,
    double? amount,
    String currency = 'VND',
    String? note,
    DateTime? occurredAt,

    /// Dong chi tieu (wealth_transactions) da sinh ra giao dich nay - co no
    /// thi luc xoa khoan chi tieu do biet duong tru lai holding + xoa dung
    /// dong lich su nay (xem migration 0067).
    String? sourceTransactionId,
  }) async {
    await _supabase.from('wealth_investment_transactions').insert({
      'user_id': userId,
      'asset_type': assetType,
      'symbol': ?symbol,
      'action': action,
      'quantity': ?quantity,
      'price': ?price,
      'amount': ?amount,
      'currency': currency,
      'note': ?note,
      'occurred_at': (occurredAt ?? DateTime.now()).toIso8601String(),
      'source_transaction_id': ?sourceTransactionId,
    });
  }
}
