import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/program_model.dart';
import '../data/workout_model.dart';
import 'workout_session_screen.dart';

/// Xem truoc bai tap hom nay TRUOC KHI vao log that - port tu
/// WorkoutPreviewScreen cua FitViet (Gate 24): anh minh hoa, target set×rep,
/// "goi y muc ta" (muc ta nang nhat tung log cho bai do, mac dinh 20kg neu
/// chua tung tap) - chi khi bam "Bat dau" moi thuc su tao 1 workout_sessions
/// moi trong Supabase.
class WorkoutPreviewScreen extends ConsumerStatefulWidget {
  const WorkoutPreviewScreen({
    super.key,
    required this.program,
    required this.day,
  });
  final Program program;
  final ProgramDay day;

  @override
  ConsumerState<WorkoutPreviewScreen> createState() =>
      _WorkoutPreviewScreenState();
}

class _WorkoutPreviewScreenState extends ConsumerState<WorkoutPreviewScreen> {
  late final Future<List<WorkoutExerciseBlock>> _blocksFuture =
      _resolveBlocks();

  Future<List<WorkoutExerciseBlock>> _resolveBlocks() async {
    final allExercises = await ref.read(exerciseListProvider.future);
    final byId = {for (final e in allExercises) e.id: e};
    final repo = ref.read(workoutRepositoryProvider);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    final sorted = [...widget.day.exercises]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final blocks = <WorkoutExerciseBlock>[];
    for (final exRef in sorted) {
      final exercise = byId[exRef.exerciseId];
      if (exercise == null) continue;
      double recommended = kDefaultRecommendedWeightKg;
      if (userId != null) {
        recommended =
            await repo.getRecommendedWeight(userId, exRef.exerciseId) ??
            kDefaultRecommendedWeightKg;
      }
      blocks.add(
        WorkoutExerciseBlock(
          exercise: exercise,
          targetSets: exRef.targetSets,
          targetRepsMin: exRef.targetRepsMin,
          targetRepsMax: exRef.targetRepsMax,
          recommendedWeightKg: recommended,
        ),
      );
    }
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
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
                    ref.tr('fitness_workout_preview_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<WorkoutExerciseBlock>>(
                future: _blocksFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.fitnessAccent,
                      ),
                    );
                  }
                  final blocks = snapshot.data!;
                  return ListView.separated(
                    itemCount: blocks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _PreviewTile(block: blocks[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<WorkoutExerciseBlock>>(
              future: _blocksFuture,
              builder: (context, snapshot) {
                final blocks = snapshot.data;
                return PillButton(
                  label: ref.tr('fitness_workout_begin'),
                  accentColor: AppColors.fitnessAccent,
                  onTap: blocks == null
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => WorkoutSessionScreen(
                              blocks: blocks,
                              programId: widget.program.id,
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.block});
  final WorkoutExerciseBlock block;

  @override
  Widget build(BuildContext context) {
    final exercise = block.exercise;
    return GlowBox(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              exercise.photoAssets.first,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 52,
                height: 52,
                color: AppColors.fitnessAccent.withValues(alpha: 0.6),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.nameVi,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
                Consumer(
                  builder: (context, ref, _) => Text(
                    ref
                        .tr('fitness_workout_sets_reps')
                        .replaceFirst('{sets}', '${block.targetSets}')
                        .replaceFirst('{min}', '${block.targetRepsMin}')
                        .replaceFirst('{max}', '${block.targetRepsMax}'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) => Text(
                    ref
                        .tr('fitness_workout_recommended_weight')
                        .replaceFirst(
                          '{kg}',
                          block.recommendedWeightKg.toStringAsFixed(0),
                        ),
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                    ).copyWith(color: AppColors.fitnessAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
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
