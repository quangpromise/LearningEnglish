/// 1 lan tra/nhan tra 1 phan khoan no - luon di kem 1 hinh thuc (Tien mat
/// hoac 1 ngan hang cu the) de tu dong sinh dong wealth_balance_entries
/// tuong ung (tru hoac cong vao Vi).
class WealthDebtPayment {
  const WealthDebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentAccountType,
    required this.currency,
    required this.occurredAt,
    this.paymentBankCode,
    this.paymentBankName,
    this.note,
  });

  final String id;
  final String debtId;
  final double amount;
  final String paymentAccountType; // 'cash' | 'bank'
  final String? paymentBankCode;
  final String? paymentBankName;
  final String currency;
  final String? note;
  final DateTime occurredAt;

  factory WealthDebtPayment.fromRow(Map<String, dynamic> row) {
    return WealthDebtPayment(
      id: row['id'] as String,
      debtId: row['debt_id'] as String,
      amount: (row['amount'] as num).toDouble(),
      paymentAccountType: row['payment_account_type'] as String,
      paymentBankCode: row['payment_bank_code'] as String?,
      paymentBankName: row['payment_bank_name'] as String?,
      currency: row['currency'] as String,
      note: row['note'] as String?,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
    );
  }
}
