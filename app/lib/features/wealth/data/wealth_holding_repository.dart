import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_holding_model.dart';

class WealthHoldingRepository {
  WealthHoldingRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthHolding>> fetchAll(String userId, String assetType) async {
    final rows = await _supabase
        .from('wealth_holdings')
        .select()
        .eq('user_id', userId)
        .eq('asset_type', assetType)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => WealthHolding.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Upsert theo (user_id, asset_type, symbol) - chi dung duoc khi holding co
  /// symbol (stock_intl/gold/silver/copper). Nha dat (khong co symbol) luon
  /// insert dong moi qua [insertNew] va sua/xoa theo `id`.
  Future<void> upsertBySymbol(String userId, WealthHolding holding) async {
    await _supabase
        .from('wealth_holdings')
        .upsert(
          holding.toInsertRow(userId),
          onConflict: 'user_id,asset_type,symbol',
        );
  }

  Future<String> insertNew(String userId, WealthHolding holding) async {
    final row = await _supabase
        .from('wealth_holdings')
        .insert(holding.toInsertRow(userId))
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// Sua lai so luong/gia von cua 1 khoan nam giu theo `id` - dung cho Kim
  /// loai (moi lo la 1 dong doc lap, khong co symbol de upsert lai) va cho
  /// bat ky loai nao khac can sua ma khong doi symbol.
  Future<void> updateQuantityAndCost(
    String userId,
    String id, {
    required double quantity,
    required double avgCost,
  }) async {
    await _supabase
        .from('wealth_holdings')
        .update({'quantity': quantity, 'avg_cost': avgCost})
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> updateManualValue(
    String userId,
    String id,
    double manualValue,
  ) async {
    await _supabase
        .from('wealth_holdings')
        .update({'manual_value': manualValue})
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteHolding(String userId, String id) async {
    await _supabase
        .from('wealth_holdings')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
