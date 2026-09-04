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

  Future<int> startSession({required String userId, int? programId}) async {
    final row = await _supabase
        .from('workout_sessions')
        .insert({
          'user_id': userId,
          'program_id': programId,
          'started_at': DateTime.now().toIso8601String(),
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

  Future<void> finishSession({
    required int sessionId,
    required double totalVolumeKg,
    required int durationSeconds,
  }) async {
    await _supabase
        .from('workout_sessions')
        .update({
          'completed_at': DateTime.now().toIso8601String(),
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
}
