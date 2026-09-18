/// 1 dau viec trong "To do list" - tinh nang RIENG, khong dung chung du lieu
/// voi "Lap ke hoach" (features/planner): Planner la timeline theo gio co
/// lap lai/nhac nho/dong bo Supabase, con day co chu dich la danh sach viec
/// gon nhe cua RIENG trong ngay.
class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  final String id;
  final String title;

  /// Ngay + gio den han. NGAY cua truong nay la ngay GOC nguoi dung dat -
  /// KHONG bao gio bi ghi de khi viec bi don sang hom sau (xem
  /// [TodoTaskX.isCarriedOver]).
  final DateTime dueAt;
  final DateTime createdAt;

  /// null = chua hoan thanh.
  final DateTime? completedAt;

  /// Lan sua cuoi - dung de GOP du lieu khi dong bo nhieu may (ban sua sau
  /// cung thang). null = du lieu cu tu truoc khi co dong bo.
  final DateTime? updatedAt;

  bool get isCompleted => completedAt != null;

  /// Moi lan sua deu dong dau [updatedAt] moi - KHONG de lot truong nay, neu
  /// khong ban tren server se luon "moi hon" va ghi de mat sua doi cuc bo.
  TodoTask copyWith({
    String? title,
    DateTime? dueAt,
    Object? completedAt = _sentinel,
    DateTime? updatedAt,
  }) => TodoTask(
    id: id,
    title: title ?? this.title,
    dueAt: dueAt ?? this.dueAt,
    createdAt: createdAt,
    completedAt: identical(completedAt, _sentinel)
        ? this.completedAt
        : completedAt as DateTime?,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  static const _sentinel = Object();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueAt': dueAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    dueAt: DateTime.parse(json['dueAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );
}

/// Trang thai HIEN THI - suy ra tu du lieu chu KHONG luu trong [TodoTask],
/// nen khong bao gio co chuyen "trang thai luu trong DB lech voi thuc te"
/// (vd viec da qua gio nhung con ghi la upcoming vi chua ai chay job cap
/// nhat).
enum TodoStatus { upcoming, incomplete, completed, overdue, carriedOver }

DateTime todoDayKey(DateTime d) => DateTime(d.year, d.month, d.day);

extension TodoTaskX on TodoTask {
  /// Viec CHUA xong va da qua ngay -> tu dong "chuyen sang hom nay".
  ///
  /// CACH LAM: KHONG ghi de [dueAt] moi ngay (cach do phai co 1 job chay luc
  /// nua dem, de sinh viec trung, va lam mat ngay hen goc). Thay vao do suy
  /// ra luc hien thi - cung 1 [TodoTask], cung id, cung createdAt, khong he
  /// co ban sao nao duoc tao ra.
  bool isCarriedOver(DateTime now) =>
      !isCompleted && todoDayKey(dueAt).isBefore(todoDayKey(now));

  /// Ngay viec nay THUC SU xuat hien tren danh sach.
  DateTime effectiveDay(DateTime now) =>
      isCarriedOver(now) ? todoDayKey(now) : todoDayKey(dueAt);

  TodoStatus statusAt(DateTime now) {
    if (isCompleted) return TodoStatus.completed;
    if (isCarriedOver(now)) return TodoStatus.carriedOver;
    if (dueAt.isBefore(now)) return TodoStatus.overdue;
    return todoDayKey(dueAt) == todoDayKey(now)
        ? TodoStatus.upcoming
        : TodoStatus.incomplete;
  }
}
