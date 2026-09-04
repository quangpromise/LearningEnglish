/// 1 dong bien dong so du Tien mat/Ngan hang trong Vi. So du hien tai cua 1
/// nhom (accountType, bankCode/bankName, currency) = tong `amount` cac dong
/// khop dieu kien (duong = nap/thu, am = rut/chi tieu/tra no).
class WealthBalanceEntry {
  const WealthBalanceEntry({
    required this.id,
    required this.accountType,
    required this.currency,
    required this.amount,
    required this.occurredAt,
    this.bankCode,
    this.bankName,
    this.note,
    this.source = 'manual',
    this.sourceTransactionId,
    this.sourceDebtPaymentId,
    this.sourceServiceRenewalPaymentId,
  });

  final String id;
  final String accountType; // 'cash' | 'bank'
  final String? bankCode;
  final String? bankName;
  final String currency; // 'VND' | 'USD'
  final double amount;
  final String? note;
  final DateTime occurredAt;
  final String source; // 'manual' | 'expense' | 'debt_payment'
  final String? sourceTransactionId;
  final String? sourceDebtPaymentId;
  final String? sourceServiceRenewalPaymentId;

  bool get isBank => accountType == 'bank';

  factory WealthBalanceEntry.fromRow(Map<String, dynamic> row) {
    return WealthBalanceEntry(
      id: row['id'] as String,
      accountType: row['account_type'] as String,
      bankCode: row['bank_code'] as String?,
      bankName: row['bank_name'] as String?,
      currency: row['currency'] as String,
      amount: (row['amount'] as num).toDouble(),
      note: row['note'] as String?,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      source: row['source'] as String? ?? 'manual',
      sourceTransactionId: row['source_transaction_id'] as String?,
      sourceDebtPaymentId: row['source_debt_payment_id'] as String?,
      sourceServiceRenewalPaymentId:
          row['source_service_renewal_payment_id'] as String?,
    );
  }

  Map<String, dynamic> toInsertRow(String userId) => {
    'user_id': userId,
    'account_type': accountType,
    if (bankCode != null) 'bank_code': bankCode,
    if (bankName != null) 'bank_name': bankName,
    'currency': currency,
    'amount': amount,
    if (note != null && note!.isNotEmpty) 'note': note,
    'occurred_at': occurredAt.toIso8601String(),
    'source': source,
    if (sourceTransactionId != null)
      'source_transaction_id': sourceTransactionId,
    if (sourceDebtPaymentId != null)
      'source_debt_payment_id': sourceDebtPaymentId,
    if (sourceServiceRenewalPaymentId != null)
      'source_service_renewal_payment_id': sourceServiceRenewalPaymentId,
  };
}

/// Tong so du cua 1 nhom tai khoan (vi du "Vietcombank - VND" hoac
/// "Tien mat - USD") - tinh tu danh sach [WealthBalanceEntry].
class WealthAccountTotal {
  const WealthAccountTotal({
    required this.accountType,
    required this.currency,
    required this.total,
    this.bankCode,
    this.bankName,
  });

  final String accountType;
  final String? bankCode;
  final String? bankName;
  final String currency;
  final double total;
}
