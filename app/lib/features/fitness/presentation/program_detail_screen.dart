import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exercise_model.dart';
import '../data/program_model.dart';
import 'workout_preview_screen.dart';

/// Lich tuan cua 1 chuong trinh - port tu man "2b" cua FitViet (Gate 15 -
/// lich tuan THAT theo tung ngay, khac ban demo tinh cua Gate 3). Neu day la
/// giao an dang theo VA hom nay la ngay tap, hien nut "Bat dau tap hom nay".
class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.program});
  final Program program;

  Future<void> _setActive(WidgetRef ref) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(workoutRepositoryProvider)
        .setActiveProgramId(userId, program.id);
    ref.invalidate(activeProgramIdProvider);
  }

  static const _weekdayKeys = [
    'fitness_program_weekday_1',
    'fitness_program_weekday_2',
    'fitness_program_weekday_3',
    'fitness_program_weekday_4',
    'fitness_program_weekday_5',
    'fitness_program_weekday_6',
    'fitness_program_weekday_7',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activeProgramIdProvider).valueOrNull;
    final isActive = activeId == program.id;
    final exercisesAsync = ref.watch(exerciseListProvider);
    final today = DateTime.now();
    final sortedDays = [...program.days]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

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
                    program.titleVi,
                    style: AppTextStyles.heading(size: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PillButton(
              label: isActive
                  ? ref.tr('fitness_program_active_badge')
                  : ref.tr('fitness_program_set_active'),
              accentColor: AppColors.fitnessAccent,
              filled: !isActive,
              onTap: isActive ? null : () => _setActive(ref),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: exercisesAsync.when(
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
                data: (allExercises) {
                  final byId = {for (final e in allExercises) e.id: e};
                  return ListView.separated(
                    itemCount: sortedDays.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final day = sortedDays[i];
                      final isToday = day.dayOfWeek == today.weekday;
                      return _DayCard(
                        title: ref.tr(_weekdayKeys[day.dayOfWeek - 1]),
                        isToday: isToday,
                        day: day,
                        exercisesById: byId,
                        showStartButton: isActive && isToday && !day.isRestDay,
                        onStart: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WorkoutPreviewScreen(
                              program: program,
                              day: day,
                            ),
                          ),
                        ),
                      );
                    },
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

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.title,
    required this.isToday,
    required this.day,
    required this.exercisesById,
    required this.showStartButton,
    required this.onStart,
  });

  final String title;
  final bool isToday;
  final ProgramDay day;
  final Map<int, Exercise> exercisesById;
  final bool showStartButton;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.body(weight: FontWeight.w800)),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.fitnessAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Consumer(
            builder: (context, ref, _) => day.isRestDay
                ? Text(
                    ref.tr('fitness_program_rest_day'),
                    style: AppTextStyles.muted(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final ex in day.exercises)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            exercisesById[ex.exerciseId]?.nameVi ??
                                '#${ex.exerciseId}',
                            style: AppTextStyles.muted(),
                          ),
                        ),
                    ],
                  ),
          ),
          if (showStartButton) ...[
            const SizedBox(height: 10),
            Consumer(
              builder: (context, ref, _) => PillButton(
                label: ref.tr('fitness_program_start_today'),
                accentColor: AppColors.fitnessAccent,
                onTap: onStart,
              ),
            ),
          ],
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
