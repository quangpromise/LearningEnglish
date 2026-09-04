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
    });
  }
}
