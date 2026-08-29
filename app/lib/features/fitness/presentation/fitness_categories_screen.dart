import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/fitness_data.dart';
import 'body_diagram.dart';
import 'fitness_exercise_list_screen.dart';

/// Danh sach nhom co - vao tu man Menu, moi nhom co bieu do co don gian
/// (tu ve) to do vung tuong ung.
class FitnessCategoriesScreen extends ConsumerWidget {
  const FitnessCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('fitness_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('fitness_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                itemCount: kMuscleGroups.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, i) {
                  final group = kMuscleGroups[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FitnessExerciseListScreen(group: group),
                      ),
                    ),
                    child: GlowBox(
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: BodyDiagram(
                              region: regionForMuscleGroup(group.nameEn),
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fitnessGroupLabel(ref, group),
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            '${group.exercises.length} ${ref.tr('fitness_exercise_count')}',
                            style: AppTextStyles.muted(size: 11),
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
      ),
    );
  }
}
