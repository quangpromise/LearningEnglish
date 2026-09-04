import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_debt_model.dart';

class WealthDebtRepository {
  WealthDebtRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthDebt>> fetchAll(String userId, String direction) async {
    final rows = await _supabase
        .from('wealth_debts')
        .select('*, wealth_debt_persons(name)')
        .eq('user_id', userId)
        .eq('direction', direction)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthDebt.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<WealthDebt>> fetchByPerson(String userId, String personId) async {
    final rows = await _supabase
        .from('wealth_debts')
        .select('*, wealth_debt_persons(name)')
        .eq('user_id', userId)
        .eq('person_id', personId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthDebt.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String userId,
    required String personId,
    required String direction,
    required double amount,
    required String currency,
    String? note,
    required DateTime occurredAt,
  }) async {
    await _supabase.from('wealth_debts').insert({
      'user_id': userId,
      'person_id': personId,
      'direction': direction,
      'original_amount': amount,
      'remaining_amount': amount,
      'currency': currency,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
    });
  }

  /// Goi sau khi ghi 1 [WealthDebtPayment] - giam remaining_amount va tu
  /// danh dau settled_at neu ve 0.
  Future<void> applyPayment(
    String userId,
    String debtId,
    double paidAmount,
  ) async {
    final row = await _supabase
        .from('wealth_debts')
        .select('remaining_amount')
        .eq('id', debtId)
        .eq('user_id', userId)
        .single();
    final remaining = ((row['remaining_amount'] as num).toDouble() - paidAmount)
        .clamp(0, double.infinity);
    await _supabase
        .from('wealth_debts')
        .update({
          'remaining_amount': remaining,
          if (remaining <= 0) 'settled_at': DateTime.now().toIso8601String(),
        })
        .eq('id', debtId)
        .eq('user_id', userId);
  }

  Future<void> updateNote(String userId, String id, String? note) async {
    await _supabase
        .from('wealth_debts')
        .update({'note': note})
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Sua lai note va/hoac so tien goc - CHI goi khi remaining_amount con
  /// bang original_amount (chua co lan tra nao), do UI tu kiem tra truoc
  /// (xem debt_screen.dart) de tranh lam sai lech remaining_amount da tru
  /// dan qua cac lan tra.
  Future<void> updateNoteAndAmount(
    String userId,
    String id, {
    String? note,
    double? amount,
  }) async {
    await _supabase
        .from('wealth_debts')
        .update({
          'note': note,
          'original_amount': ?amount,
          'remaining_amount': ?amount,
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> delete(String userId, String id) async {
    await _supabase
        .from('wealth_debts')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
