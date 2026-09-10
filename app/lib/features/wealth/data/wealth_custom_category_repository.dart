import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_custom_category_model.dart';

class WealthCustomCategoryRepository {
  WealthCustomCategoryRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthCustomCategory>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_custom_categories')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (rows as List)
        .map((r) => WealthCustomCategory.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String userId,
    required String name,
    required String iconKey,
  }) async {
    await _supabase.from('wealth_custom_categories').insert({
      'user_id': userId,
      'name': name,
      'icon_key': iconKey,
    });
  }

  Future<void> update({
    required String userId,
    required String id,
    required String name,
    required String iconKey,
  }) async {
    await _supabase
        .from('wealth_custom_categories')
        .update({'name': name, 'icon_key': iconKey})
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> delete(String userId, String id) async {
    await _supabase
        .from('wealth_custom_categories')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
