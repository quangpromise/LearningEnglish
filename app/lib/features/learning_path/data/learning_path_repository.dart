import 'package:supabase_flutter/supabase_flutter.dart';

import 'learning_path_models.dart';

/// Luu/doc persona nguoi dung da chon o khao sat "Goi y lo trinh hoc" -
/// bang `user_learning_path_choice` (migration 0042), 1 dong/user, mirror
/// dung pattern cua LessonProgressRepository
/// (story/data/lesson_progress_repository.dart).
class LearningPathRepository {
  LearningPathRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<LearningPersona?> fetchChoice() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _supabase
        .from('user_learning_path_choice')
        .select('persona')
        .eq('user_id', userId)
        .maybeSingle();
    final persona = row?['persona'] as String?;
    if (persona == null) return null;
    try {
      return LearningPersona.values.byName(persona);
    } on ArgumentError {
      return null;
    }
  }

  Future<void> choosePersona(LearningPersona persona) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_learning_path_choice').upsert({
      'user_id': userId,
      'persona': persona.name,
    }, onConflict: 'user_id');
  }
}
