import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_transaction_model.dart';

class WealthTransactionRepository {
  WealthTransactionRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthTransaction>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_transactions')
        .select()
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthTransaction.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTransaction(String userId, WealthTransaction tx) async {
    await _supabase.from('wealth_transactions').insert(tx.toInsertRow(userId));
  }

  Future<void> deleteTransaction(String userId, String id) async {
    await _supabase
        .from('wealth_transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
