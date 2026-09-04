/// 1 "chu no/nguoi no" - dung de gop nhieu khoan no rieng biet cua cung 1
/// nguoi thanh 1 "lich su no" (xem [DebtPersonPickerField]).
class WealthDebtPerson {
  const WealthDebtPerson({required this.id, required this.name});

  final String id;
  final String name;

  factory WealthDebtPerson.fromRow(Map<String, dynamic> row) =>
      WealthDebtPerson(id: row['id'] as String, name: row['name'] as String);
}
