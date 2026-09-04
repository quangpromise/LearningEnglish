/// 1 khoan no cu the cua 1 nguoi. `direction='i_owe'` = minh no nguoi nay
/// (khoan phai tra); `'owed_to_me'` = nguoi nay no minh (khoan phai thu).
/// `remainingAmount` giam dan qua tung [WealthDebtPayment], ve 0 la da tra
/// xong (`settledAt` khac null).
class WealthDebt {
  const WealthDebt({
    required this.id,
    required this.personId,
    required this.personName,
    required this.direction,
    required this.originalAmount,
    required this.remainingAmount,
    required this.currency,
    required this.occurredAt,
    this.note,
    this.settledAt,
  });

  final String id;
  final String personId;
  final String personName;
  final String direction; // 'i_owe' | 'owed_to_me'
  final double originalAmount;
  final double remainingAmount;
  final String currency;
  final String? note;
  final DateTime occurredAt;
  final DateTime? settledAt;

  bool get isSettled => settledAt != null;
  bool get isIOwe => direction == 'i_owe';

  factory WealthDebt.fromRow(Map<String, dynamic> row) {
    final person = row['wealth_debt_persons'] as Map<String, dynamic>?;
    return WealthDebt(
      id: row['id'] as String,
      personId: row['person_id'] as String,
      personName: person?['name'] as String? ?? '',
      direction: row['direction'] as String,
      originalAmount: (row['original_amount'] as num).toDouble(),
      remainingAmount: (row['remaining_amount'] as num).toDouble(),
      currency: row['currency'] as String,
      note: row['note'] as String?,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      settledAt: row['settled_at'] == null
          ? null
          : DateTime.parse(row['settled_at'] as String),
    );
  }
}
