import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/program_model.dart';
import 'program_detail_screen.dart';

/// Danh sach chuong trinh tap (giao an) - port tu man "1c" cua FitViet (Gate
/// 2/3), rut gon khong co o tim kiem/chip loc (chi 3 chuong trinh o Phase
/// 2, chua can loc).
class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programListProvider);
    final activeIdAsync = ref.watch(activeProgramIdProvider);
    final activeId = activeIdAsync.valueOrNull;

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
                    ref.tr('fitness_programs_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: programsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.fitnessAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('fitness_programs_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (programs) => ListView.separated(
                  itemCount: programs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final program = programs[i];
                    return _ProgramCard(
                      program: program,
                      isActive: program.id == activeId,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProgramDetailScreen(program: program),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.isActive,
    required this.onTap,
  });
  final Program program;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.titleVi,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                ),
                if (isActive)
                  Consumer(
                    builder: (context, ref, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fitnessAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        ref.tr('fitness_program_active_badge'),
                        style: AppTextStyles.body(
                          size: 11,
                          weight: FontWeight.w800,
                        ).copyWith(color: AppColors.fitnessAccent),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _DifficultyBadge(difficulty: program.difficulty),
                const SizedBox(width: 8),
                Text(
                  '${program.equipment} · ${program.sessionsPerWeek} buổi/tuần',
                  style: AppTextStyles.muted(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final ProgramDifficulty? difficulty;

  @override
  Widget build(BuildContext context) {
    final steps = difficulty?.steps ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < steps;
        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: 4,
          height: 6.0 + i * 4,
          decoration: BoxDecoration(
            color: filled ? AppColors.fitnessAccent : AppColors.glassBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
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
