import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.xp,
    required this.isMe,
  });
  final int rank;
  final String displayName;
  final int xp;
  final bool isMe;
}

class MyQuizRank {
  const MyQuizRank({required this.rank, required this.xp});
  final int rank;
  final int xp;
}

/// Bảng xếp hạng đố vui THẬT (không phải danh sách cứng trong code) — xem
/// migration 0008_quiz_leaderboard.sql.
class LeaderboardRepository {
  LeaderboardRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<LeaderboardEntry>> fetchTop({int topN = 20}) async {
    final res = await _supabase.rpc(
      'quiz_leaderboard',
      params: {'top_n': topN},
    );
    return (res as List).map((r) {
      final m = r as Map<String, dynamic>;
      return LeaderboardEntry(
        rank: m['rank'] as int,
        displayName: m['display_name'] as String? ?? 'Người dùng',
        xp: m['xp'] as int? ?? 0,
        isMe: m['is_me'] as bool? ?? false,
      );
    }).toList();
  }

  Future<MyQuizRank> fetchMyRank() async {
    final res = await _supabase.rpc('my_quiz_rank');
    final row = (res as List).first as Map<String, dynamic>;
    return MyQuizRank(
      rank: row['rank'] as int? ?? 1,
      xp: row['xp'] as int? ?? 0,
    );
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    await _supabase.rpc('add_quiz_xp', params: {'amount': amount});
  }
}
