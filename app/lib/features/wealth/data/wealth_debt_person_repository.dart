import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_debt_person_model.dart';

class WealthDebtPersonRepository {
  WealthDebtPersonRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthDebtPerson>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_debt_persons')
        .select()
        .eq('user_id', userId)
        .order('name');
    return (rows as List)
        .map((r) => WealthDebtPerson.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Tim theo ten khong phan biet hoa/thuong (unique index tren
  /// (user_id, lower(name))) - neu da co thi tra ve id cu, chua co thi tao
  /// moi. Dung khi nguoi dung go 1 ten hoan toan moi trong
  /// [DebtPersonPickerField] thay vi chon tu goi y co san.
  Future<WealthDebtPerson> findOrCreate(String userId, String name) async {
    final existing = await _supabase
        .from('wealth_debt_persons')
        .select()
        .eq('user_id', userId)
        .ilike('name', name)
        .maybeSingle();
    if (existing != null) return WealthDebtPerson.fromRow(existing);
    final row = await _supabase
        .from('wealth_debt_persons')
        .insert({'user_id': userId, 'name': name})
        .select()
        .single();
    return WealthDebtPerson.fromRow(row);
  }
}
