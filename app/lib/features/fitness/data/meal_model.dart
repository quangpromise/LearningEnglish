/// Cac muc tieu dinh duong co dinh - port dung gia tri cua FitViet
/// (NutritionCalculator, Gate 6). CHUA cho tuy chinh theo tung user o phase
/// nay (dung y het gioi han da biet cua ban goc).
const kNutritionGoalKcal = 2200;
const kNutritionGoalProteinG = 140;
const kNutritionGoalCarbG = 250;
const kNutritionGoalFatG = 70;

enum MealSlot {
  breakfast,
  lunch,
  dinner,
  snack;

  String get labelKey => switch (this) {
    MealSlot.breakfast => 'fitness_nutrition_slot_breakfast',
    MealSlot.lunch => 'fitness_nutrition_slot_lunch',
    MealSlot.dinner => 'fitness_nutrition_slot_dinner',
    MealSlot.snack => 'fitness_nutrition_slot_snack',
  };

  static MealSlot fromCode(String code) => switch (code) {
    'breakfast' => breakfast,
    'lunch' => lunch,
    'dinner' => dinner,
    _ => snack,
  };
}

/// 1 mon an co san de chon nhanh khi log bua an - noi dung TINH (khong luu
/// Supabase), port tu SeedData.mealPresets cua FitViet (Gate 6 + Gate 9: 5
/// mon dau + 15 mon Viet Nam them vao). Macro uoc luong theo cong thuc
/// kcal ≈ 4×protein + 4×carb + 9×fat (~10% do chinh xac), KHONG phai tra
/// cuu tu 1 CSDL dinh duong that - dung y het gioi han cua ban goc (app
/// hoan toan offline, khong goi API dinh duong nao).
class FoodPreset {
  const FoodPreset({
    required this.name,
    required this.kcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  final String name;
  final int kcal;
  final double proteinG;
  final double carbG;
  final double fatG;
}

const kFoodPresets = [
  FoodPreset(name: 'Ức gà áp chảo', kcal: 220, proteinG: 33, carbG: 0, fatG: 9),
  FoodPreset(
    name: 'Cơm trắng (1 chén)',
    kcal: 205,
    proteinG: 4.3,
    carbG: 45,
    fatG: 0.4,
  ),
  FoodPreset(
    name: 'Trứng luộc',
    kcal: 78,
    proteinG: 6.3,
    carbG: 0.6,
    fatG: 5.3,
  ),
  FoodPreset(
    name: 'Sữa chua không đường',
    kcal: 100,
    proteinG: 6,
    carbG: 8,
    fatG: 5,
  ),
  FoodPreset(name: 'Chuối', kcal: 105, proteinG: 1.3, carbG: 27, fatG: 0.4),
  FoodPreset(
    name: 'Bún chả Hà Nội',
    kcal: 480,
    proteinG: 28,
    carbG: 55,
    fatG: 16,
  ),
  FoodPreset(
    name: 'Gỏi cuốn tôm thịt',
    kcal: 150,
    proteinG: 10,
    carbG: 20,
    fatG: 3,
  ),
  FoodPreset(
    name: 'Canh chua cá lóc',
    kcal: 180,
    proteinG: 20,
    carbG: 12,
    fatG: 5,
  ),
  FoodPreset(
    name: 'Bánh cuốn chả lụa',
    kcal: 350,
    proteinG: 15,
    carbG: 50,
    fatG: 9,
  ),
  FoodPreset(name: 'Xôi xéo', kcal: 400, proteinG: 8, carbG: 70, fatG: 10),
  FoodPreset(name: 'Cá kho tộ', kcal: 250, proteinG: 25, carbG: 8, fatG: 13),
  FoodPreset(
    name: 'Rau muống xào tỏi',
    kcal: 90,
    proteinG: 3,
    carbG: 8,
    fatG: 5,
  ),
  FoodPreset(name: 'Sữa đậu nành', kcal: 130, proteinG: 8, carbG: 12, fatG: 5),
  FoodPreset(name: 'Bánh flan', kcal: 220, proteinG: 5, carbG: 30, fatG: 9),
  FoodPreset(
    name: 'Hủ tiếu Nam Vang',
    kcal: 420,
    proteinG: 22,
    carbG: 55,
    fatG: 12,
  ),
  FoodPreset(name: 'Bò lúc lắc', kcal: 320, proteinG: 30, carbG: 10, fatG: 18),
  FoodPreset(
    name: 'Trái cây thập cẩm',
    kcal: 120,
    proteinG: 1.5,
    carbG: 30,
    fatG: 0.5,
  ),
  FoodPreset(
    name: 'Đậu hũ sốt cà chua',
    kcal: 180,
    proteinG: 12,
    carbG: 10,
    fatG: 10,
  ),
  FoodPreset(
    name: 'Yến mạch trộn sữa chua & hạt',
    kcal: 300,
    proteinG: 14,
    carbG: 40,
    fatG: 10,
  ),
  FoodPreset(name: 'Chè đậu xanh', kcal: 250, proteinG: 6, carbG: 48, fatG: 4),
];

/// 1 bua an da log cua nguoi dung - CUA TUNG USER nen luu Supabase (khac
/// [FoodPreset] noi dung tinh), xem migration
/// supabase/migrations/0030_fitness_nutrition.sql.
class Meal {
  const Meal({
    required this.id,
    required this.slot,
    required this.name,
    required this.kcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  final int id;
  final MealSlot slot;
  final String name;
  final int kcal;
  final double proteinG;
  final double carbG;
  final double fatG;
}
