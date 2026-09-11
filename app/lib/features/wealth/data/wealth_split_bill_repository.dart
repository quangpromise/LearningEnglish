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
  /// [status] cua tung nguoi (tru "Toi") duoc CHON SAN luc chia (Ghi no/Da
  /// tra), khong con trang thai "cho xu ly" nua - xem wealth_split_bill_
  /// screen.dart (nguoi dung chon Ghi no/Da tra NGAY khi phan bo, truoc khi
  /// bam Pay, thay vi phai quay lai xu ly sau).
  Future<(String billId, List<String> shareIds)> createBill({
    required String userId,
    required double totalAmount,
    required String currency,
    required String paymentAccountType,
    String? paymentBankCode,
    String? paymentBankName,
    String? transactionId,
    String? note,
    required DateTime occurredAt,
    required List<
      ({String personName, bool isMe, double amount, String status})
    >
    shares,
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
          'note': note,
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
              'status': s.isMe ? 'paid' : s.status,
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

  /// Goi khi 1 khoan No (owed_to_me) gan voi 1 dong Chia bill (qua debt_id)
  /// DA THU XONG (remaining_amount ve 0, xem pay_debt_sheet.dart va
  /// batch_pay_debt_sheet.dart) - tu dong chuyen dong share tuong ung tu
  /// 'debt' ("Da ghi no") sang 'paid' ("Da nhan tien") de bien lai phan anh
  /// dung trang thai moi nhat ma khong can quay lai man Chia bill bam tay.
  Future<void> markSharesPaidByDebtId(String userId, String debtId) async {
    await _supabase
        .from('wealth_split_bill_shares')
        .update({'status': 'paid'})
        .eq('debt_id', debtId)
        .eq('user_id', userId);
  }

  Future<void> updateNote(String userId, String id, String? note) async {
    await _supabase
        .from('wealth_split_bills')
        .update({'note': note})
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Xoa 1 lan chia bill - CHI xoa dong wealth_split_bills (+ cascade xoa
  /// het cac dong wealth_split_bill_shares cua no, xem migration 0050/0052).
  /// KHONG tu dong xoa khoan Chi tieu/No lien quan - noi goi (xem
  /// wealth_split_bill_history_screen.dart _deleteBill) phai tu xoa cac dong
  /// do TRUOC qua repo tuong ung (WealthTransactionRepository, WealthDebt
  /// Repository) de tan dung dung cascade san co cua tung bang, tranh lap
  /// lai logic "don dep Vi" da co san o cac repo do.
  Future<void> delete(String userId, String id) async {
    await _supabase
        .from('wealth_split_bills')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
