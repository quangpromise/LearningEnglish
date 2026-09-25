import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 dong bang "Thu thach tuan Body + Brain" voi ban be.
class FriendChallengeEntry {
  const FriendChallengeEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.daysDone,
    required this.isMe,
  });

  factory FriendChallengeEntry.fromJson(Map<String, dynamic> json) =>
      FriendChallengeEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        userId: json['user_id'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        daysDone: (json['days_done'] as num?)?.toInt() ?? 0,
        isMe: json['is_me'] as bool? ?? false,
      );

  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;

  /// So ngay dat Body + Brain trong 7 ngay gan nhat (0-7).
  final int daysDone;
  final bool isMe;
}

/// Doc bang xep hang tuan qua RPC friends_body_brain_week (migration 0074).
/// So lieu cua moi nguoi lay tu user_gymtalk_state - duoc day len boi
/// GymTalkSyncService.
class FriendsChallengeRepository {
  FriendsChallengeRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<FriendChallengeEntry>> fetchWeek() async {
    if (_supabase.auth.currentUser == null) return const [];
    final rows = await _supabase.rpc('friends_body_brain_week');
    return [
      for (final row in rows as List)
        FriendChallengeEntry.fromJson(Map<String, dynamic>.from(row as Map)),
    ];
  }
}
