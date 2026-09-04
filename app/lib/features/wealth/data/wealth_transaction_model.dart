enum WealthTransactionType {
  expense,
  income;

  static WealthTransactionType fromCode(String code) =>
      code == 'income' ? income : expense;

  String get code => this == income ? 'income' : 'expense';
}

/// 1 dong so giao dich chi tieu/thu nhap - gop chung 1 bang
/// `wealth_transactions` thay vi 2-3 bang rieng (don gian hon, du cho
/// Phase 1). [incomeKind] chi co gia tri khi [type] la income: 'active'
/// (luong/freelance/kinh doanh) hoac 'passive' (cho thue nha/co tuc...).
class WealthTransaction {
  const WealthTransaction({
    required this.id,
    required this.type,
    required this.categoryCode,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    this.note,
    this.incomeKind,
    this.paymentAccountType,
    this.paymentBankCode,
    this.paymentBankName,
  });

  final String id;
  final WealthTransactionType type;
  final String categoryCode;
  final double amount;
  final String currency;
  final DateTime occurredAt;
  final String? note;
  final String? incomeKind;
  // Chi co gia tri khi type=expense - dung de tu dong sinh 1 dong
  // wealth_balance_entries tru vao dung Tien mat/Ngan hang da chon (Phase D).
  final String? paymentAccountType; // 'cash' | 'bank'
  final String? paymentBankCode;
  final String? paymentBankName;

  bool get isPassiveIncome => incomeKind == 'passive';

  factory WealthTransaction.fromRow(Map<String, dynamic> row) {
    return WealthTransaction(
      id: row['id'] as String,
      type: WealthTransactionType.fromCode(row['type'] as String),
      categoryCode: row['category_code'] as String,
      amount: (row['amount'] as num).toDouble(),
      currency: row['currency'] as String,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      note: row['note'] as String?,
      incomeKind: row['income_kind'] as String?,
      paymentAccountType: row['payment_account_type'] as String?,
      paymentBankCode: row['payment_bank_code'] as String?,
      paymentBankName: row['payment_bank_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertRow(String userId) => {
    'user_id': userId,
    'type': type.code,
    'category_code': categoryCode,
    'amount': amount,
    'currency': currency,
    'occurred_at': occurredAt.toIso8601String(),
    'note': note,
    'income_kind': incomeKind,
    'payment_account_type': paymentAccountType,
    'payment_bank_code': paymentBankCode,
    'payment_bank_name': paymentBankName,
  };
}
