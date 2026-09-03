import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exercise_model.dart';

/// Chi tiet 1 bai tap - huong dan tung buoc + thanh % tham gia cua tung
/// nhom co (an neu involvementPercents rong - day la tin hieu CHU DONG
/// "an the nay" tu du lieu goc FitViet, khong phai thieu du lieu, xem
/// exercise_model.dart).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteExerciseIdsProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(exercise.id) ?? false;
    final muscles = exercise.displayedMuscles;
    final percents = exercise.involvementPercents;
    final showInvolvement =
        percents.isNotEmpty && percents.length == muscles.length;

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                _CircleBtn(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFavorite ? AppColors.pink : null,
                  onTap: () => ref
                      .read(favoriteExerciseIdsProvider.notifier)
                      .toggle(exercise.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(exercise.nameVi, style: AppTextStyles.heading(size: 20)),
            Text(exercise.nameEn, style: AppTextStyles.muted()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  label: exercise.difficulty.labelVi(),
                  color: AppColors.amber,
                ),
                _Tag(
                  label: exercise.muscleGroup.labelVi(),
                  color: AppColors.teal,
                ),
                _Tag(label: exercise.equipment, color: AppColors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  if (showInvolvement) ...[
                    Text(
                      'Mức độ tham gia nhóm cơ',
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < muscles.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InvolvementBar(
                          label: muscles[i],
                          percent: percents[i],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Hướng dẫn thực hiện',
                    style: AppTextStyles.heading(size: 14),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < exercise.instructions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.glassFill,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: AppTextStyles.body(
                                size: 11,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.instructions[i],
                              style: AppTextStyles.body(size: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvolvementBar extends StatelessWidget {
  const _InvolvementBar({required this.label, required this.percent});
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body(size: 12.5)),
            Text(
              '$percent%',
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppColors.blue),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.glassBorder),
          ),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}
