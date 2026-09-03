import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_holding_model.dart';

class WealthHoldingRepository {
  WealthHoldingRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthHolding>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_holdings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => WealthHolding.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addHolding(String userId, WealthHolding holding) async {
    // upsert theo (user_id, symbol) - them lan 2 cung ma se cong don thay vi
    // tao dong trung, dung gia tri moi nguoi dung nhap (khong tu tinh binh
    // quan gia von o Phase 1, giu don gian).
    await _supabase
        .from('wealth_holdings')
        .upsert(holding.toInsertRow(userId), onConflict: 'user_id,symbol');
  }

  Future<void> deleteHolding(String userId, String id) async {
    await _supabase
        .from('wealth_holdings')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
