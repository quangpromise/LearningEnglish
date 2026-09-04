import 'package:supabase_flutter/supabase_flutter.dart';

import 'meal_model.dart';

/// Bua an da log CUA TUNG USER theo tung ngay - luu Supabase de dong bo da
/// thiet bi, khac [kFoodPresets] (noi dung tinh dong goi san). "Ngay" dung
/// dinh dang YYYY-MM-DD (cot kieu `date` trong Postgres) de moi lan mo lai
/// app deu tu dong tinh dung "hom nay" theo gio may, khong can 1 co che
/// dayTicker() rieng nhu FitViet (Riverpod tu invalidate khi can qua
/// [todayMealsProvider]).
class NutritionRepository {
  NutritionRepository(this._supabase);
  final SupabaseClient _supabase;

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<List<Meal>> getMealsForDate(String userId, DateTime date) async {
    final rows = await _supabase
        .from('fitness_meals')
        .select()
        .eq('user_id', userId)
        .eq('logged_date', _dateKey(date))
        .order('created_at');
    return (rows as List)
        .map((r) => _fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMeal({
    required String userId,
    required MealSlot slot,
    required FoodPreset preset,
    required DateTime date,
  }) async {
    await _supabase.from('fitness_meals').insert({
      'user_id': userId,
      'slot': slot.name,
      'name': preset.name,
      'kcal': preset.kcal,
      'protein_g': preset.proteinG,
      'carb_g': preset.carbG,
      'fat_g': preset.fatG,
      'logged_date': _dateKey(date),
    });
  }

  Future<void> removeMeal(int mealId) async {
    await _supabase.from('fitness_meals').delete().eq('id', mealId);
  }

  Meal _fromRow(Map<String, dynamic> row) => Meal(
    id: row['id'] as int,
    slot: MealSlot.fromCode(row['slot'] as String),
    name: row['name'] as String,
    kcal: row['kcal'] as int,
    proteinG: (row['protein_g'] as num).toDouble(),
    carbG: (row['carb_g'] as num).toDouble(),
    fatG: (row['fat_g'] as num).toDouble(),
  );
}
