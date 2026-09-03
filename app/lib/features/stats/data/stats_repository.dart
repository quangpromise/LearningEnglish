import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 ngày trong biểu đồ "hoạt động tuần này" — [date] là ngày thật (server,
/// UTC), [seconds] là tổng số giây luyện tập ghi nhận được trong ngày đó.
class DailyActivity {
  const DailyActivity({required this.date, required this.seconds});
  final DateTime date;
  final int seconds;

  /// Nhãn hiển thị theo thứ trong tuần (T2..T7, CN) dựa trên [date] thật,
  /// không cố định cứng — đúng bất kể hôm nay là thứ mấy.
  String get weekdayLabel {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[date.weekday - 1];
  }
}

class UserStats {
  const UserStats({
    required this.wordsLearned,
    required this.songsCompleted,
    required this.avgPronunciationScore,
    required this.practiceSeconds,
    required this.streakDays,
    required this.weeklyActivity,
  });

  final int wordsLearned;
  final int songsCompleted;
  final int avgPronunciationScore;
  final int practiceSeconds;
  final int streakDays;
  final List<DailyActivity> weeklyActivity;

  static const empty = UserStats(
    wordsLearned: 0,
    songsCompleted: 0,
    avgPronunciationScore: 0,
    practiceSeconds: 0,
    streakDays: 0,
    weeklyActivity: [],
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
    List<dynamic> results;
    try {
      results = await Future.wait([
        _supabase.rpc('my_stats_summary'),
        _supabase.rpc('my_weekly_activity'),
      ]);
    } on PostgrestException catch (e) {
      // "JWT issued at future" (PGRST303) - da xac nhan CHI xay ra ngay sau
      // khi cap nhat APK trong app roi mo lai (khong xay ra o lan mo app
      // binh thuong), va tu het khi tat/mo lai app - dung la trieu chung
      // cua do lech dong ho THOANG QUA giua cac node server cua Supabase
      // (token vua duoc GoTrue mint xong, nhung node PostgREST xac thuc yeu
      // cau lai nhan thoi gian cham hon vai giay), KHONG phai loi dong ho
      // may nguoi dung. Doi 1 chut cho dong ho cac node dong bo lai roi thu
      // lai truoc - neu van loi (vd do that su la session cu/het han that)
      // moi ep lam moi session va thu lan cuoi.
      if (e.code != 'PGRST303') rethrow;
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        results = await Future.wait([
          _supabase.rpc('my_stats_summary'),
          _supabase.rpc('my_weekly_activity'),
        ]);
      } on PostgrestException catch (e2) {
        if (e2.code != 'PGRST303') rethrow;
        await _supabase.auth.refreshSession();
        results = await Future.wait([
          _supabase.rpc('my_stats_summary'),
          _supabase.rpc('my_weekly_activity'),
        ]);
      }
    }
    final row = (results[0] as List).first as Map<String, dynamic>;
    final weekRows = results[1] as List;
    return UserStats(
      wordsLearned: row['words_learned'] as int? ?? 0,
      songsCompleted: row['songs_completed'] as int? ?? 0,
      avgPronunciationScore: row['avg_pronunciation_score'] as int? ?? 0,
      practiceSeconds: row['practice_seconds'] as int? ?? 0,
      streakDays: row['streak_days'] as int? ?? 0,
      weeklyActivity: weekRows.map((r) {
        final m = r as Map<String, dynamic>;
        return DailyActivity(
          date: DateTime.parse(m['activity_date'] as String),
          seconds: m['seconds'] as int? ?? 0,
        );
      }).toList(),
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

  /// [source] phân biệt luyện từ tab "Luyện phát âm" (`pronunciation_tab`)
  /// với shadowing lồng trong 1 bài học (vd `story:<id>`, xem migration
  /// 0027_pronunciation_attempt_source.sql) - chỉ để phân tích sau này,
  /// không ảnh hưởng điểm hay thống kê hiển thị.
  Future<void> recordPronunciationScore(int score, {String? source}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_pronunciation_attempts').insert({
      'user_id': userId,
      'score': score,
      'source': source,
    });
  }

  /// [source] phan biet thoi gian luyen tap Hoc Tieng Anh ('english', mac
  /// dinh) voi thoi gian dung Fitness ('fitness') - dung rieng cho bieu do
  /// "Hoat dong tuan nay" o man Ho so khi mo tu tung khu vuc (xem migration
  /// 0031_activity_source.sql). Tong chung (user_practice_time, dung cho
  /// the "Thoi gian luyen tap") van cong don ca 2 nguon, khong doi.
  Future<void> addPracticeSeconds(
    int seconds, {
    String source = 'english',
  }) async {
    if (seconds <= 0) return;
    await _supabase.rpc(
      'add_practice_seconds',
      params: {'delta': seconds, 'p_source': source},
    );
  }

  /// Rieng bieu do 7 ngay gan nhat theo 1 nguon cu the - dung cho man Ho so
  /// khi xem tu Fitness (khong can ca UserStats day du nhu ben Hoc Tieng Anh).
  Future<List<DailyActivity>> fetchWeeklyActivity({
    String source = 'english',
  }) async {
    final rows = await _supabase.rpc(
      'my_weekly_activity',
      params: {'p_source': source},
    );
    return (rows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return DailyActivity(
        date: DateTime.parse(m['activity_date'] as String),
        seconds: m['seconds'] as int? ?? 0,
      );
    }).toList();
  }

  Future<void> resetStats() async {
    await _supabase.rpc('reset_my_stats');
  }
}
