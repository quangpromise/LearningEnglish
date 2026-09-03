import 'package:supabase_flutter/supabase_flutter.dart';

/// Tiến độ hoàn thành cho nội dung KHÔNG phải bài hát (vd micro-story) - bảng
/// MỚI `user_lesson_progress` (migration 0026), tách khỏi
/// `user_completed_songs` vì bảng đó khoá theo `song_title` (not null, nửa
/// khoá chính) nên không tái dùng được cho nội dung khác tên, xem
/// docs/architecture-multimedia-platform.md §A.3 (Lỗi tiềm ẩn #2).
class LessonProgressRepository {
  LessonProgressRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<bool> isCompleted(String lessonId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final rows = await _supabase
        .from('user_lesson_progress')
        .select('lesson_id')
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .limit(1);
    return (rows as List).isNotEmpty;
  }

  Future<void> markCompleted(String lessonId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
    }, onConflict: 'user_id,lesson_id');
  }
}
