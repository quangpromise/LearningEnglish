/// 1 dich vu tra phi dinh ky (Netflix, hosting, domain...) - tu tinh ngay
/// het han theo chu ky ('week'/'month'/'year'/'custom_years') hoac nguoi
/// dung tu chon thang ngay het han ('manual', khong tu tinh).
class RecurringService {
  const RecurringService({
    required this.id,
    required this.name,
    required this.defaultAmount,
    required this.currency,
    required this.cycleType,
    required this.startDate,
    required this.expiryDate,
    required this.reminderLeadDays,
    this.cycleYears,
    this.note,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double defaultAmount;
  final String currency; // 'VND' | 'USD'
  final String
  cycleType; // 'week' | 'month' | 'year' | 'custom_years' | 'manual'
  final double? cycleYears;
  final DateTime startDate;
  final DateTime expiryDate;
  final int reminderLeadDays; // 7 | 15 | 30
  final String? note;
  final bool isActive;

  // So sanh theo NGAY LICH (bo gio/phut) - truoc day dung thang
  // expiryDate.difference(DateTime.now()) nen vd het han 06/09 nhung dang
  // la 11:44 ngay 05/09 chi lech ~12 tieng se bi lam tron xuong "0 ngay"
  // (inDays cat cut phan le), du thuc te van con nguyen 1 ngay.
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    return expiryDay.difference(today).inDays;
  }

  bool get isExpiringSoon => daysLeft <= reminderLeadDays;

  factory RecurringService.fromRow(Map<String, dynamic> row) {
    return RecurringService(
      id: row['id'] as String,
      name: row['name'] as String,
      defaultAmount: (row['default_amount'] as num).toDouble(),
      currency: row['currency'] as String,
      cycleType: row['cycle_type'] as String,
      cycleYears: (row['cycle_years'] as num?)?.toDouble(),
      startDate: DateTime.parse(row['start_date'] as String),
      expiryDate: DateTime.parse(row['expiry_date'] as String),
      reminderLeadDays: row['reminder_lead_days'] as int? ?? 7,
      note: row['note'] as String?,
      isActive: row['is_active'] as bool? ?? true,
    );
  }

  /// Tinh ngay het han tiep theo tu 1 moc thoi gian (`from`) theo dung chu
  /// ky cua dich vu - dung ca luc tao moi (from=startDate) lan luc gia han
  /// (from=expiryDate CU, khong phai hom nay, giong cach cac dich vu thue
  /// bao that gia han "noi tiep" ky truoc thay vi tinh lai tu luc bam gia
  /// han). Tra ve null neu cycleType='manual' (nguoi dung phai tu chon).
  static DateTime? computeNextExpiry({
    required String cycleType,
    required DateTime from,
    double? cycleYears,
  }) {
    switch (cycleType) {
      case 'week':
        return from.add(const Duration(days: 7));
      case 'month':
        final m = from.month + 1;
        return DateTime(
          from.year + (m > 12 ? 1 : 0),
          m > 12 ? m - 12 : m,
          from.day,
        );
      case 'year':
        return DateTime(from.year + 1, from.month, from.day);
      case 'custom_years':
        final years = (cycleYears ?? 1).round();
        return DateTime(from.year + years, from.month, from.day);
      default:
        return null;
    }
  }
}
