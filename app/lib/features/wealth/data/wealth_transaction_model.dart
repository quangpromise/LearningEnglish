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
  });

  final String id;
  final WealthTransactionType type;
  final String categoryCode;
  final double amount;
  final String currency;
  final DateTime occurredAt;
  final String? note;
  final String? incomeKind;

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
  };
}
