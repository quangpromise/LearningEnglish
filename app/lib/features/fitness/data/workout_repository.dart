import 'package:supabase_flutter/supabase_flutter.dart';

/// Du lieu buoi tap CUA TUNG USER (chuong trinh dang theo, lich su buoi tap,
/// tung set da log) - khac voi ExerciseRepository/ProgramRepository (noi
/// dung tinh dong goi san), phan nay BAT BUOC luu Supabase de dong bo da
/// thiet bi, dung nhat quan voi cach toan bo du lieu theo user khac cua app
/// (stats, yeu thich...) dang lam - xem
/// supabase/migrations/0029_fitness_workout.sql.
class WorkoutRepository {
  WorkoutRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<int?> getActiveProgramId(String userId) async {
    final row = await _supabase
        .from('user_fitness_settings')
        .select('active_program_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row == null ? null : row['active_program_id'] as int?;
  }

  Future<void> setActiveProgramId(String userId, int programId) async {
    await _supabase.from('user_fitness_settings').upsert({
      'user_id': userId,
      'active_program_id': programId,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// [startedAt] do may khach truyen vao (thoi diem bam "Bat dau" that) -
  /// lenh insert co the chay tre hon nhieu neu dang mat mang va duoc thu lai.
  Future<int> startSession({
    required String userId,
    int? programId,
    DateTime? startedAt,
  }) async {
    final row = await _supabase
        .from('workout_sessions')
        .insert({
          'user_id': userId,
          'program_id': programId,
          'started_at': (startedAt ?? DateTime.now()).toIso8601String(),
        })
        .select('id')
        .single();
    return row['id'] as int;
  }

  Future<void> logSet({
    required int sessionId,
    required String userId,
    required int exerciseId,
    required int setIndex,
    required double weightKg,
    required int reps,
  }) async {
    await _supabase.from('workout_set_logs').insert({
      'session_id': sessionId,
      'user_id': userId,
      'exercise_id': exerciseId,
      'set_index': setIndex,
      'weight_kg': weightKg,
      'reps': reps,
    });
  }

  /// Go 1 set da log (nut "Hoan tac") - can policy delete o migration 0072.
  /// Xoa theo (buoi, bai, thu tu set) vi may khach khong giu id dong.
  Future<void> deleteSet({
    required int sessionId,
    required int exerciseId,
    required int setIndex,
  }) async {
    await _supabase
        .from('workout_set_logs')
        .delete()
        .eq('session_id', sessionId)
        .eq('exercise_id', exerciseId)
        .eq('set_index', setIndex);
  }

  Future<void> finishSession({
    required int sessionId,
    required double totalVolumeKg,
    required int durationSeconds,
    DateTime? completedAt,
  }) async {
    await _supabase
        .from('workout_sessions')
        .update({
          'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
          'total_volume_kg': totalVolumeKg,
          'duration_seconds': durationSeconds,
        })
        .eq('id', sessionId);
  }

  /// Muc ta nang nhat TUNG duoc log cho 1 bai tap (chi tinh set thuoc buoi
  /// da hoan thanh) - null neu chua tung tap bai nay lan nao, man hinh tu
  /// fallback ve [kDefaultRecommendedWeightKg].
  Future<double?> getRecommendedWeight(String userId, int exerciseId) async {
    final rows = await _supabase
        .from('workout_set_logs')
        .select('weight_kg, workout_sessions!inner(completed_at)')
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId)
        .not('workout_sessions.completed_at', 'is', null)
        .order('weight_kg', ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    final weight = (list.first as Map<String, dynamic>)['weight_kg'] as num?;
    return weight?.toDouble();
  }

  /// So buoi tap DA HOAN THANH tu [sinceDate] - dung cho "X/Y buoi tuan nay",
  /// dung y het gioi han da biet cua FitViet: tong so buoi trong tuan so voi
  /// muc tieu, KHONG doi chieu tung ngay lich cu the.
  Future<int> getCompletedSessionsCount(
    String userId,
    DateTime sinceDate,
  ) async {
    final rows = await _supabase
        .from('workout_sessions')
        .select('id')
        .eq('user_id', userId)
        .not('completed_at', 'is', null)
        .gte('started_at', sinceDate.toIso8601String());
    return (rows as List).length;
  }

  /// Lich su tap theo NGAY trong [days] ngay gan nhat - nguon du lieu duy
  /// nhat cua man Thong ke (bieu do khoi luong/so buoi/thoi luong, cac moc
  /// loc 7 ngay - 30 ngay - 3 thang - 1 nam). Tinh o may khach tu cac buoi
  /// DA HOAN THANH, khong them bang tong hop rieng nao trong Supabase.
  Future<FitnessHistorySeries> getHistorySeries(String userId, int days) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final since = today.subtract(Duration(days: days - 1));
    final rows = await _supabase
        .from('workout_sessions')
        .select('completed_at, total_volume_kg, duration_seconds')
        .eq('user_id', userId)
        .not('completed_at', 'is', null)
        .gte('completed_at', since.toIso8601String())
        .order('completed_at');

    final volume = List<double>.filled(days, 0);
    final sessions = List<int>.filled(days, 0);
    final minutes = List<int>.filled(days, 0);
    for (final row in rows as List) {
      final map = row as Map<String, dynamic>;
      final completedAt = DateTime.parse(map['completed_at'] as String)
          .toLocal();
      final date = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      final index = days - 1 - today.difference(date).inDays;
      if (index < 0 || index >= days) continue;
      volume[index] += (map['total_volume_kg'] as num?)?.toDouble() ?? 0;
      sessions[index] += 1;
      minutes[index] += ((map['duration_seconds'] as num?)?.toInt() ?? 0) ~/ 60;
    }
    return FitnessHistorySeries(
      days: days,
      dailyVolumeKg: volume,
      dailySessions: sessions,
      dailyDurationMinutes: minutes,
    );
  }

  /// So lieu cho Trang chu Fitness (Phase 4) - port tinh than tu
  /// DashboardStatsCalculator cua FitViet (Gate 3): chuoi ngay lien tiep co
  /// tap (streak), so buoi + tong kg TUAN NAY (tinh tu Thu Hai, khop dung
  /// quy uoc dayOfWeek=1 dang dung cho lich chuong trinh), va khoi luong 7
  /// ngay gan nhat cho bieu do cot. Chi quet 60 ngay gan nhat (du de tinh
  /// streak thuc te, tranh quet toan bo lich su vo thoi han).
  Future<FitnessDashboardStats> getDashboardStats(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final since = today.subtract(const Duration(days: 60));
    final rows = await _supabase
        .from('workout_sessions')
        .select('completed_at, total_volume_kg')
        .eq('user_id', userId)
        .not('completed_at', 'is', null)
        .gte('completed_at', since.toIso8601String())
        .order('completed_at');

    final sessions = (rows as List).map((r) {
      final map = r as Map<String, dynamic>;
      final completedAt = DateTime.parse(map['completed_at'] as String)
          .toLocal();
      final volume = (map['total_volume_kg'] as num).toDouble();
      return (
        date: DateTime(completedAt.year, completedAt.month, completedAt.day),
        volume: volume,
      );
    }).toList();

    final sessionDates = sessions.map((s) => s.date).toSet();

    var streak = 0;
    var cursor = sessionDates.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    while (sessionDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Tuan bat dau Thu Hai (dayOfWeek=1) - dung y het quy uoc ProgramDay.
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));
    var sessionsThisWeek = 0;
    var totalVolumeThisWeek = 0.0;
    var totalVolumePreviousWeek = 0.0;
    final dailyVolumeLast7 = List<double>.filled(7, 0);
    for (final s in sessions) {
      if (!s.date.isBefore(weekStart)) {
        sessionsThisWeek++;
        totalVolumeThisWeek += s.volume;
      } else if (!s.date.isBefore(previousWeekStart)) {
        totalVolumePreviousWeek += s.volume;
      }
      final daysAgo = today.difference(s.date).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        dailyVolumeLast7[6 - daysAgo] += s.volume;
      }
    }

    return FitnessDashboardStats(
      streakDays: streak,
      sessionsThisWeek: sessionsThisWeek,
      totalVolumeThisWeekKg: totalVolumeThisWeek,
      previousWeekVolumeKg: totalVolumePreviousWeek,
      dailyVolumeLast7: dailyVolumeLast7,
    );
  }
}

/// Xem [WorkoutRepository.getDashboardStats].
class FitnessDashboardStats {
  const FitnessDashboardStats({
    required this.streakDays,
    required this.sessionsThisWeek,
    required this.totalVolumeThisWeekKg,
    required this.dailyVolumeLast7,
    this.previousWeekVolumeKg = 0,
  });

  final int streakDays;
  final int sessionsThisWeek;
  final double totalVolumeThisWeekKg;

  /// Tong kg cua TUAN TRUOC - chi dung de ve mui ten tang/giam canh so
  /// "Tong khoi luong" o Trang chu, khong hien thanh so rieng.
  final double previousWeekVolumeKg;

  /// 7 gia tri, index 0 la 6 ngay truoc, index 6 la HOM NAY.
  final List<double> dailyVolumeLast7;
}

/// Chuoi so lieu theo NGAY cho man Thong ke - xem
/// [WorkoutRepository.getHistorySeries].
class FitnessHistorySeries {
  const FitnessHistorySeries({
    required this.days,
    required this.dailyVolumeKg,
    required this.dailySessions,
    required this.dailyDurationMinutes,
  });

  /// So ngay cua chuoi (7 / 30 / 90 / 365).
  final int days;

  /// Do dai dung bang [days]; phan tu CUOI CUNG la hom nay.
  final List<double> dailyVolumeKg;
  final List<int> dailySessions;
  final List<int> dailyDurationMinutes;

  double get totalVolumeKg =>
      dailyVolumeKg.fold<double>(0, (sum, v) => sum + v);
  int get totalSessions => dailySessions.fold<int>(0, (sum, v) => sum + v);
  int get totalMinutes =>
      dailyDurationMinutes.fold<int>(0, (sum, v) => sum + v);

  bool get isEmpty => totalSessions == 0;
}
