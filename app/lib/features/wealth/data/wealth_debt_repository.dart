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

  /// Cong lai [amount] vao remaining_amount - dung khi xoa truc tiep 1 dong
  /// wealth_balance_entries co source='debt_payment' tu man Vi (thay vi xoa
  /// tu man No): payment da bi xoa nen phai hoan lai remaining_amount va
  /// mo lai settled_at neu khoan no truoc do da settled.
  Future<void> restoreAmount(
    String userId,
    String debtId,
    double amount,
  ) async {
    final row = await _supabase
        .from('wealth_debts')
        .select('remaining_amount, original_amount')
        .eq('id', debtId)
        .eq('user_id', userId)
        .single();
    final original = (row['original_amount'] as num).toDouble();
    final restored = ((row['remaining_amount'] as num).toDouble() + amount)
        .clamp(0, original);
    await _supabase
        .from('wealth_debts')
        .update({'remaining_amount': restored, 'settled_at': null})
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
