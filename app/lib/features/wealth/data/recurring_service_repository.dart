import 'package:supabase_flutter/supabase_flutter.dart';

import 'recurring_service_model.dart';
import 'wealth_balance_entry_model.dart';
import 'wealth_balance_entry_repository.dart';

/// 1 hinh thuc thanh toan khi gia han (Tien mat hoac 1 ngan hang cu the) -
/// cho phep tach nhieu hinh thuc trong cung 1 lan gia han.
class RenewalPaymentInput {
  const RenewalPaymentInput({
    required this.accountType,
    required this.amount,
    this.bankCode,
    this.bankName,
  });
  final String accountType; // 'cash' | 'bank'
  final String? bankCode;
  final String? bankName;
  final double amount;
}

class RecurringServiceRepository {
  RecurringServiceRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<RecurringService>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_recurring_services')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('expiry_date');
    return (rows as List)
        .map((r) => RecurringService.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String userId,
    required String name,
    required double defaultAmount,
    required String currency,
    required String cycleType,
    double? cycleYears,
    required DateTime startDate,
    required DateTime expiryDate,
    required int reminderLeadDays,
    String? note,
  }) async {
    await _supabase.from('wealth_recurring_services').insert({
      'user_id': userId,
      'name': name,
      'default_amount': defaultAmount,
      'currency': currency,
      'cycle_type': cycleType,
      'cycle_years': cycleYears,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'expiry_date': expiryDate.toIso8601String().substring(0, 10),
      'reminder_lead_days': reminderLeadDays,
      'note': note,
    });
  }

  /// Sua lai thong tin co ban (ten/so tien mac dinh/note/so ngay nhac
  /// truoc), co the tuy chon sua lai LUON ngay het han truc tiep
  /// ([expiryDate], vd nhap sai luc tao hoac muon doi lai thu cong) - khac
  /// voi "Gia han" (tu dong day ngay het han theo chu ky + ghi lich su
  /// thanh toan), day chi doi thang ngay, khong tao dong thanh toan nao.
  Future<void> update({
    required String userId,
    required String id,
    required String name,
    required double defaultAmount,
    required int reminderLeadDays,
    String? note,
    DateTime? expiryDate,
  }) async {
    await _supabase
        .from('wealth_recurring_services')
        .update({
          'name': name,
          'default_amount': defaultAmount,
          'reminder_lead_days': reminderLeadDays,
          'note': note,
          if (expiryDate != null)
            'expiry_date': expiryDate.toIso8601String().substring(0, 10),
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Lay `renewal_id` + `service_id` + `previous_expiry_date` cua 1 lan gia
  /// han - dung khi xoa truc tiep 1 dong wealth_balance_entries co
  /// source='service_renewal' tu man Vi (xem wallet_existing_assets_tab.dart).
  Future<({String renewalId, String serviceId, DateTime previousExpiryDate})?>
  fetchRenewalPaymentInfo(String userId, String renewalPaymentId) async {
    final payment = await _supabase
        .from('wealth_service_renewal_payments')
        .select('renewal_id')
        .eq('id', renewalPaymentId)
        .eq('user_id', userId)
        .maybeSingle();
    if (payment == null) return null;
    final renewalId = payment['renewal_id'] as String;
    final renewal = await _supabase
        .from('wealth_service_renewals')
        .select('service_id, previous_expiry_date')
        .eq('id', renewalId)
        .eq('user_id', userId)
        .single();
    return (
      renewalId: renewalId,
      serviceId: renewal['service_id'] as String,
      previousExpiryDate: DateTime.parse(
        renewal['previous_expiry_date'] as String,
      ),
    );
  }

  Future<void> deleteRenewalPayment(String userId, String id) async {
    await _supabase
        .from('wealth_service_renewal_payments')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<int> countRenewalPayments(String userId, String renewalId) async {
    final rows = await _supabase
        .from('wealth_service_renewal_payments')
        .select('id')
        .eq('renewal_id', renewalId)
        .eq('user_id', userId);
    return (rows as List).length;
  }

  /// Xoa het 1 lan gia han va khoi phuc lai expiry_date cu cua dich vu - chi
  /// goi khi da xoa het cac dong thanh toan cua lan gia han do (xem
  /// wallet_existing_assets_tab.dart).
  Future<void> deleteRenewalAndRestoreExpiry({
    required String userId,
    required String renewalId,
    required String serviceId,
    required DateTime previousExpiryDate,
  }) async {
    await _supabase
        .from('wealth_service_renewals')
        .delete()
        .eq('id', renewalId)
        .eq('user_id', userId);
    await _supabase
        .from('wealth_recurring_services')
        .update({
          'expiry_date': previousExpiryDate.toIso8601String().substring(0, 10),
        })
        .eq('id', serviceId)
        .eq('user_id', userId);
  }

  Future<void> deactivate(String userId, String id) async {
    await _supabase
        .from('wealth_recurring_services')
        .update({'is_active': false})
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Gia han 1 dich vu: ghi lich su gia han + tung dong thanh toan (co the
  /// tach nhieu hinh thuc) + tu dong tao dong wealth_balance_entries tuong
  /// ung tru vao Vi, roi cap nhat expiry_date/default_amount moi cua dich
  /// vu va reset last_notified_on de bat dau lai chu ky nhac han.
  Future<void> renew({
    required String userId,
    required RecurringService service,
    required double totalAmount,
    required DateTime newExpiryDate,
    required List<RenewalPaymentInput> payments,
  }) async {
    final occurredAt = DateTime.now();
    final renewalRow = await _supabase
        .from('wealth_service_renewals')
        .insert({
          'service_id': service.id,
          'user_id': userId,
          'amount': totalAmount,
          'currency': service.currency,
          'previous_expiry_date': service.expiryDate
              .toIso8601String()
              .substring(0, 10),
          'new_expiry_date': newExpiryDate.toIso8601String().substring(0, 10),
          'occurred_at': occurredAt.toIso8601String(),
        })
        .select('id')
        .single();
    final renewalId = renewalRow['id'] as String;

    final balanceRepo = WealthBalanceEntryRepository(_supabase);
    for (final payment in payments) {
      if (payment.amount <= 0) continue;
      final inserted = await _supabase
          .from('wealth_service_renewal_payments')
          .insert({
            'renewal_id': renewalId,
            'user_id': userId,
            'amount': payment.amount,
            'payment_account_type': payment.accountType,
            'payment_bank_code': payment.bankCode,
            'payment_bank_name': payment.bankName,
            'currency': service.currency,
          })
          .select('id')
          .single();
      final paymentId = inserted['id'] as String;
      await balanceRepo.addEntry(
        userId,
        WealthBalanceEntry(
          id: '',
          accountType: payment.accountType,
          bankCode: payment.bankCode,
          bankName: payment.bankName,
          currency: service.currency,
          amount: -payment.amount,
          note: '${service.name} - gia hạn',
          occurredAt: occurredAt,
          source: 'service_renewal',
          sourceServiceRenewalPaymentId: paymentId,
        ),
      );
    }

    await _supabase
        .from('wealth_recurring_services')
        .update({
          'expiry_date': newExpiryDate.toIso8601String().substring(0, 10),
          'default_amount': totalAmount,
          'last_notified_on': null,
        })
        .eq('id', service.id)
        .eq('user_id', userId);
  }
}
