import 'package:supabase_flutter/supabase_flutter.dart';

/// Cấp độ + XP của người học, tính từ hoạt động THẬT đã ghi nhận (số từ đã
/// học, bài hát nghe hết, thời gian luyện, lần chấm phát âm đạt ≥ 60 điểm) —
/// xem `supabase/migrations/0064_learning_xp.sql` để biết công thức quy đổi.
class LearningXp {
  const LearningXp({
    required this.xp,
    required this.level,
    required this.xpInLevel,
    required this.xpToNext,
    required this.levelKey,
  });

  /// Tổng XP.
  final int xp;

  /// Cấp hiện tại, bắt đầu từ 1.
  final int level;

  /// Đã đi được bao nhiêu XP trong cấp này (0..[xpPerLevel]).
  final int xpInLevel;

  /// Còn bao nhiêu XP nữa thì lên cấp.
  final int xpToNext;

  /// Khoá tên cấp: beginner / elementary / intermediate / upper / advanced.
  /// Server trả về KHOÁ chứ không phải chữ hiển thị, phía app tự dịch qua
  /// `app_strings.dart` (khoá `level_<key>`) để thêm ngôn ngữ mới không phải
  /// sửa database.
  final String levelKey;

  /// Mỗi cấp cần bấy nhiêu XP — phải khớp với hằng số trong migration.
  static const xpPerLevel = 500;

  /// Phần đã hoàn thành của cấp hiện tại, dùng vẽ vòng tròn tiến độ (0..1).
  double get levelProgress =>
      (xpInLevel / xpPerLevel).clamp(0.0, 1.0).toDouble();

  /// Trạng thái khi chưa đăng nhập hoặc chưa chạy migration — UI vẫn vẽ được,
  /// chỉ là vòng tròn rỗng ở cấp 1.
  static const empty = LearningXp(
    xp: 0,
    level: 1,
    xpInLevel: 0,
    xpToNext: xpPerLevel,
    levelKey: 'beginner',
  );

  factory LearningXp.fromRow(Map<String, dynamic> row) => LearningXp(
    xp: (row['xp'] as num?)?.toInt() ?? 0,
    level: (row['level'] as num?)?.toInt() ?? 1,
    xpInLevel: (row['xp_in_level'] as num?)?.toInt() ?? 0,
    xpToNext: (row['xp_to_next'] as num?)?.toInt() ?? xpPerLevel,
    levelKey: row['level_key'] as String? ?? 'beginner',
  );
}

class LearningXpRepository {
  LearningXpRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Đọc cấp độ + XP của user hiện tại.
  ///
  /// Trả về [LearningXp.empty] thay vì ném lỗi trong 2 trường hợp lành tính:
  /// chưa đăng nhập, và chưa chạy migration 0064 trên Supabase (hàm RPC chưa
  /// tồn tại) — màn Home vẫn hiển thị bình thường thay vì hỏng cả trang chỉ
  /// vì một thẻ.
  Future<LearningXp> fetchMyXp() async {
    if (_supabase.auth.currentUser == null) return LearningXp.empty;
    try {
      final rows = await _supabase.rpc('my_learning_xp');
      if (rows is List && rows.isNotEmpty) {
        return LearningXp.fromRow(Map<String, dynamic>.from(rows.first as Map));
      }
      return LearningXp.empty;
    } on PostgrestException catch (e) {
      // 42883 = undefined_function (chua chay migration), PGRST202 = PostgREST
      // khong tim thay ham trong schema cache.
      if (e.code == '42883' || e.code == 'PGRST202') return LearningXp.empty;
      rethrow;
    }
  }

  /// Cộng XP thưởng thêm (sự kiện, mốc thành tích). XP từ hoạt động thường
  /// ngày KHÔNG đi qua đây — nó được tính thẳng từ dữ liệu hoạt động ở server.
  Future<int> addBonusXp(int amount) async {
    final total = await _supabase.rpc(
      'add_learning_xp',
      params: {'p_amount': amount},
    );
    return (total as num).toInt();
  }
}
