import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/fitness_data.dart';
import 'body_diagram.dart';
import 'fitness_timer_screen.dart';

class FitnessExerciseListScreen extends ConsumerWidget {
  const FitnessExerciseListScreen({super.key, required this.group});
  final MuscleGroup group;

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
                  child: Text(
                    fitnessGroupLabel(ref, group),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
                BodyDiagram(
                  region: regionForMuscleGroup(group.nameEn),
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: group.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final ex = group.exercises[i];
                  final detail = ex.isTimeBased
                      ? '${ex.sets} × ${ex.workSeconds}s'
                      : '${ex.sets} × ${ex.reps} ${ref.tr('fitness_reps')}';
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FitnessTimerScreen(
                          exercise: ex,
                          color: group.color,
                          region: regionForMuscleGroup(group.nameEn),
                        ),
                      ),
                    ),
                    child: GlowBox(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(detail, style: AppTextStyles.muted()),
                              ],
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
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
