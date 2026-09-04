import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/meal_model.dart';

/// Man Dinh duong (Fitness Phase 3) - port tu man "1g" cua FitViet (Gate 6):
/// vong tron kcal, 3 thanh macro, danh sach bua an hom nay, "+ Them mon"
/// chon tu danh sach mon co san (Gate 9). Muc tieu kcal/macro CO DINH (chua
/// cho tuy chinh theo user), dung y het gioi han da biet cua ban goc.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  Future<void> _addMeal(
    BuildContext context,
    WidgetRef ref,
    MealSlot slot,
    FoodPreset preset,
  ) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(nutritionRepositoryProvider)
        .addMeal(
          userId: userId,
          slot: slot,
          preset: preset,
          date: DateTime.now(),
        );
    ref.invalidate(todayMealsProvider);
  }

  void _openAddMealSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddMealSheet(
        onPick: (slot, preset) => _addMeal(context, ref, slot, preset),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(todayMealsProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const _IconCircle(icon: Icons.chevron_left_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('fitness_nutrition_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: mealsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.fitnessAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('fitness_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (meals) {
                  final totalKcal = meals.fold<int>(0, (s, m) => s + m.kcal);
                  final totalProtein = meals.fold<double>(
                    0,
                    (s, m) => s + m.proteinG,
                  );
                  final totalCarb = meals.fold<double>(
                    0,
                    (s, m) => s + m.carbG,
                  );
                  final totalFat = meals.fold<double>(0, (s, m) => s + m.fatG);

                  return ListView(
                    children: [
                      GlowBox(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 22,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: CircularProgressIndicator(
                                      value: (totalKcal / kNutritionGoalKcal)
                                          .clamp(0, 1),
                                      strokeWidth: 12,
                                      backgroundColor: AppColors.glassBorder,
                                      color: AppColors.fitnessAccent,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$totalKcal',
                                        style: AppTextStyles.heading(size: 26),
                                      ),
                                      Text(
                                        ref
                                            .tr(
                                              'fitness_nutrition_kcal_of_goal',
                                            )
                                            .replaceFirst(
                                              '{goal}',
                                              '$kNutritionGoalKcal',
                                            ),
                                        style: AppTextStyles.muted(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _MacroBar(
                              label: ref.tr('fitness_nutrition_protein'),
                              value: totalProtein,
                              goal: kNutritionGoalProteinG.toDouble(),
                            ),
                            const SizedBox(height: 10),
                            _MacroBar(
                              label: ref.tr('fitness_nutrition_carb'),
                              value: totalCarb,
                              goal: kNutritionGoalCarbG.toDouble(),
                            ),
                            const SizedBox(height: 10),
                            _MacroBar(
                              label: ref.tr('fitness_nutrition_fat'),
                              value: totalFat,
                              goal: kNutritionGoalFatG.toDouble(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ref.tr('fitness_nutrition_today_meals'),
                              style: AppTextStyles.body(
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openAddMealSheet(context, ref),
                            child: Text(
                              ref.tr('fitness_nutrition_add_meal'),
                              style: AppTextStyles.body(
                                size: 13,
                                weight: FontWeight.w800,
                              ).copyWith(color: AppColors.fitnessAccent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (meals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            ref.tr('fitness_nutrition_no_meals'),
                            style: AppTextStyles.muted(),
                          ),
                        )
                      else
                        for (final meal in meals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MealTile(
                              meal: meal,
                              onRemove: () async {
                                await ref
                                    .read(nutritionRepositoryProvider)
                                    .removeMeal(meal.id);
                                ref.invalidate(todayMealsProvider);
                              },
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.goal,
  });
  final String label;
  final double value;
  final double goal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.muted()),
            Text(
              '${value.toStringAsFixed(0)}g / ${goal.toStringAsFixed(0)}g',
              style: AppTextStyles.muted(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (value / goal).clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.glassBorder,
            color: AppColors.fitnessAccent,
          ),
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal, required this.onRemove});
  final Meal meal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 16,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.body(weight: FontWeight.w700),
                ),
                Consumer(
                  builder: (context, ref, _) => Text(
                    '${ref.tr(meal.slot.labelKey)} · ${meal.kcal} kcal',
                    style: AppTextStyles.muted(),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({required this.onPick});
  final void Function(MealSlot slot, FoodPreset preset) onPick;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  MealSlot _slot = MealSlot.breakfast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) => Text(
              ref.tr('fitness_nutrition_pick_food_title'),
              style: AppTextStyles.heading(size: 16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final slot in MealSlot.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Consumer(
                      builder: (context, ref, _) => _SlotChip(
                        label: ref.tr(slot.labelKey),
                        selected: _slot == slot,
                        onTap: () => setState(() => _slot = slot),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 360,
            child: ListView.separated(
              itemCount: kFoodPresets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final preset = kFoodPresets[i];
                return GestureDetector(
                  onTap: () {
                    widget.onPick(_slot, preset);
                    Navigator.of(context).pop();
                  },
                  child: GlowBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style: AppTextStyles.body(weight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${preset.kcal} kcal',
                          style: AppTextStyles.muted(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.fitnessAccent.withValues(alpha: 0.25)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.fitnessAccent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12.5,
            weight: selected ? FontWeight.w800 : FontWeight.w600,
          ).copyWith(color: selected ? Colors.white : AppColors.textMuted),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: AppColors.glassBorder)),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}
