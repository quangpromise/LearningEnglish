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
        .eq('hidden_from_suggestions', false)
        .order('name');
    return (rows as List)
        .map((r) => WealthDebtPerson.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Tim theo ten khong phan biet hoa/thuong (unique index tren
  /// (user_id, lower(name))) - neu da co thi tra ve id cu (tu dong BO AN neu
  /// truoc do da bi an qua [hideFromSuggestions] - go lai dung ten tuc la
  /// "them lai" theo dung y nguoi dung), chua co thi tao moi. Dung khi nguoi
  /// dung go 1 ten hoan toan moi trong [DebtPersonPickerField] thay vi chon
  /// tu goi y co san.
  Future<WealthDebtPerson> findOrCreate(String userId, String name) async {
    final existing = await _supabase
        .from('wealth_debt_persons')
        .select()
        .eq('user_id', userId)
        .ilike('name', name)
        .maybeSingle();
    if (existing != null) {
      final row = await _supabase
          .from('wealth_debt_persons')
          .update({'hidden_from_suggestions': false})
          .eq('id', existing['id'] as String)
          .select()
          .single();
      return WealthDebtPerson.fromRow(row);
    }
    final row = await _supabase
        .from('wealth_debt_persons')
        .insert({'user_id': userId, 'name': name})
        .select()
        .single();
    return WealthDebtPerson.fromRow(row);
  }

  /// "Xoa" 1 nguoi khoi danh sach goi y - CHI an di (khong xoa dong that su),
  /// vi wealth_debts.person_id tham chieu toi day voi on delete cascade, xoa
  /// cung se mat lich su no that. Goi lai [findOrCreate] dung ten se tu bo an.
  Future<void> hideFromSuggestions(String userId, String personId) async {
    await _supabase
        .from('wealth_debt_persons')
        .update({'hidden_from_suggestions': true})
        .eq('user_id', userId)
        .eq('id', personId);
  }
}
