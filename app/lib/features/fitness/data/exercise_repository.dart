import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exercise_model.dart';

/// Thu vien 155 bai tap + danh sach yeu thich. Giong het cach am nhac dang
/// lam (xem favorites_repository.dart/songs_data.dart): danh sach bai tap la
/// noi dung TINH, dong goi san trong app (assets/fitness/exercises_seed.json,
/// trich xuat 1 lan tu FitViet), KHONG luu trong Supabase - chi rieng "yeu
/// thich" moi can luu theo tung user (migration
/// supabase/migrations/0028_favorite_exercises.sql).
class ExerciseRepository {
  ExerciseRepository(this._supabase);
  final SupabaseClient _supabase;

  List<Exercise>? _cachedExercises;

  Future<List<Exercise>> getAllExercises() async {
    final cached = _cachedExercises;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(
      'assets/fitness/exercises_seed.json',
    );
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final exercises = list.map((map) {
      return Exercise(
        id: map['id'] as int,
        nameVi: map['nameVi'] as String,
        nameEn: map['nameEn'] as String,
        primaryMuscle: map['primaryMuscle'] as String,
        secondaryMuscles: (map['secondaryMuscles'] as List).cast<String>(),
        involvementPercents: (map['involvementPercents'] as List).cast<int>(),
        equipment: map['equipment'] as String,
        instructions: (map['instructions'] as List).cast<String>(),
        suggestedSetsMin: map['suggestedSetsMin'] as int,
        suggestedSetsMax: map['suggestedSetsMax'] as int,
        suggestedRepsMin: map['suggestedRepsMin'] as int,
        suggestedRepsMax: map['suggestedRepsMax'] as int,
        suggestedRestSeconds: map['suggestedRestSeconds'] as int,
        muscleGroupCode: map['muscleGroupCode'] as String,
        movementType: map['movementType'] as String,
        difficultyCode: map['difficultyCode'] as String,
        photoSlug: map['photoSlug'] as String,
      );
    }).toList();
    _cachedExercises = exercises;
    return exercises;
  }

  Future<Set<int>> getFavoriteIds(String userId) async {
    final rows = await _supabase
        .from('user_favorite_exercises')
        .select('exercise_id')
        .eq('user_id', userId);
    return (rows as List)
        .map((r) => (r as Map<String, dynamic>)['exercise_id'] as int)
        .toSet();
  }

  Future<void> addFavorite(String userId, int exerciseId) async {
    await _supabase.from('user_favorite_exercises').upsert({
      'user_id': userId,
      'exercise_id': exerciseId,
    }, onConflict: 'user_id,exercise_id');
  }

  Future<void> removeFavorite(String userId, int exerciseId) async {
    await _supabase
        .from('user_favorite_exercises')
        .delete()
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId);
  }
}
