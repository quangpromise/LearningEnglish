import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_split_bill_model.dart';

class WealthSplitBillRepository {
  WealthSplitBillRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthSplitBill>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_split_bills')
        .select()
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthSplitBill.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<WealthSplitBillShare>> fetchShares(
    String userId,
    String billId,
  ) async {
    final rows = await _supabase
        .from('wealth_split_bill_shares')
        .select()
        .eq('user_id', userId)
        .eq('bill_id', billId)
        .order('created_at');
    return (rows as List)
        .map((r) => WealthSplitBillShare.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Tao 1 lan chia bill + tung dong nguoi tuong ung (1 lan goi, khong lap
  /// insert rieng cho de dam bao khong bi thieu dong neu loi giua chung).
  /// Tra ve id cua bill vua tao + id CUA TUNG SHARE theo DUNG thu tu
  /// [shares] truyen vao (de UI gan lai shareId cho tung nguoi trong bo nho).
  Future<(String billId, List<String> shareIds)> createBill({
    required String userId,
    required double totalAmount,
    required String currency,
    required String paymentAccountType,
    String? paymentBankCode,
    String? paymentBankName,
    String? transactionId,
    required DateTime occurredAt,
    required List<({String personName, bool isMe, double amount})> shares,
  }) async {
    final billRow = await _supabase
        .from('wealth_split_bills')
        .insert({
          'user_id': userId,
          'total_amount': totalAmount,
          'currency': currency,
          'payment_account_type': paymentAccountType,
          'payment_bank_code': paymentBankCode,
          'payment_bank_name': paymentBankName,
          'transaction_id': transactionId,
          'occurred_at': occurredAt.toIso8601String(),
        })
        .select('id')
        .single();
    final billId = billRow['id'] as String;

    final shareRows = await _supabase
        .from('wealth_split_bill_shares')
        .insert([
          for (final s in shares)
            {
              'bill_id': billId,
              'user_id': userId,
              'person_name': s.personName,
              'is_me': s.isMe,
              'amount': s.amount,
              'status': s.isMe ? 'paid' : 'pending',
            },
        ])
        .select('id');
    final shareIds = (shareRows as List).map((r) => r['id'] as String).toList();
    return (billId, shareIds);
  }

  Future<void> updateShareStatus(
    String userId,
    String shareId, {
    required String status,
    String? debtId,
  }) async {
    await _supabase
        .from('wealth_split_bill_shares')
        .update({'status': status, 'debt_id': debtId})
        .eq('id', shareId)
        .eq('user_id', userId);
  }
}
