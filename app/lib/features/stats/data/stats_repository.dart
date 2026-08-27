import 'package:supabase_flutter/supabase_flutter.dart';

class UserStats {
  const UserStats({
    required this.wordsLearned,
    required this.songsCompleted,
    required this.avgPronunciationScore,
    required this.practiceSeconds,
  });

  final int wordsLearned;
  final int songsCompleted;
  final int avgPronunciationScore;
  final int practiceSeconds;

  static const empty = UserStats(
    wordsLearned: 0,
    songsCompleted: 0,
    avgPronunciationScore: 0,
    practiceSeconds: 0,
  );

  String get practiceTimeLabel {
    final h = practiceSeconds ~/ 3600;
    final m = (practiceSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}p';
    return '${m}p';
  }
}

/// Thống kê THẬT của người dùng (không phải số demo cứng) — ghi nhận khi
/// người dùng thực sự tra từ / nghe hết bài / chấm điểm phát âm, xem
/// migration 0004_real_stats.sql.
class StatsRepository {
  StatsRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<UserStats> fetchMyStats() async {
    final res = await _supabase.rpc('my_stats_summary');
    final row = (res as List).first as Map<String, dynamic>;
    return UserStats(
      wordsLearned: row['words_learned'] as int? ?? 0,
      songsCompleted: row['songs_completed'] as int? ?? 0,
      avgPronunciationScore: row['avg_pronunciation_score'] as int? ?? 0,
      practiceSeconds: row['practice_seconds'] as int? ?? 0,
    );
  }

  Future<void> recordWordLearned(String word) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || word.trim().isEmpty) return;
    await _supabase.from('user_learned_words').upsert({
      'user_id': userId,
      'word': word.trim().toLowerCase(),
    }, onConflict: 'user_id,word');
  }

  Future<void> recordSongCompleted(String songTitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_completed_songs').upsert({
      'user_id': userId,
      'song_title': songTitle,
    }, onConflict: 'user_id,song_title');
  }

  Future<void> recordPronunciationScore(int score) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_pronunciation_attempts').insert({
      'user_id': userId,
      'score': score,
    });
  }

  Future<void> addPracticeSeconds(int seconds) async {
    if (seconds <= 0) return;
    await _supabase.rpc('add_practice_seconds', params: {'delta': seconds});
  }

  Future<void> resetStats() async {
    await _supabase.rpc('reset_my_stats');
  }
}
