import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exercise_model.dart';
import 'exercise_detail_screen.dart';

/// Thu vien bai tap (Fitness Phase 1) - xem/tim theo nhom co, bam vao xem
/// chi tiet + danh dau yeu thich. Port tu man "1c" cua FitViet, rut gon cho
/// lat cat dau tien (khong co anh GIF minh hoa - FitViet ban goc cung moi la
/// placeholder filename, chua co anh that).
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({
    super.key,
    this.initialGroup,
    this.initialQuery = '',
  });

  /// Nhom co duoc chon san khi mo tu 1 the trong
  /// [MuscleGroupCategoriesScreen] - null nghia la "Tất cả".
  final MuscleGroup? initialGroup;

  /// Tu khoa go san khi mo tu o tim kiem cua man danh muc.
  final String initialQuery;

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  late final _searchController = TextEditingController(
    text: widget.initialQuery,
  );
  late String _query = widget.initialQuery;
  late MuscleGroup? _selectedGroup = widget.initialGroup;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);
    final favoritesAsync = ref.watch(favoriteExerciseIdsProvider);
    final favoriteIds = favoritesAsync.valueOrNull ?? <int>{};
    final query = _query.trim().toLowerCase();

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
                    ref.tr('fitness_library_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlowBox(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.body(),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: ref.tr('fitness_search_placeholder'),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _GroupChip(
                    label: ref.tr('fitness_filter_all'),
                    selected: _selectedGroup == null,
                    onTap: () => setState(() => _selectedGroup = null),
                  ),
                  for (final group in MuscleGroup.values)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _GroupChip(
                        label: ref.tr(group.labelKey),
                        selected: _selectedGroup == group,
                        onTap: () => setState(() => _selectedGroup = group),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                data: (exercises) {
                  final filtered = exercises.where((e) {
                    final matchesGroup =
                        _selectedGroup == null ||
                        e.muscleGroup == _selectedGroup;
                    final matchesQuery =
                        query.isEmpty ||
                        e.nameVi.toLowerCase().contains(query) ||
                        e.nameEn.toLowerCase().contains(query);
                    return matchesGroup && matchesQuery;
                  }).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('fitness_no_results'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final exercise = filtered[i];
                      return _ExerciseTile(
                        exercise: exercise,
                        isFavorite: favoriteIds.contains(exercise.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseDetailScreen(exercise: exercise),
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

class _GroupChip extends StatelessWidget {
  const _GroupChip({
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
              ? AppColors.purple.withValues(alpha: 0.25)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.glassBorder,
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

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.isFavorite,
    required this.onTap,
  });
  final Exercise exercise;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        padding: const EdgeInsets.all(12),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
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
                  Text(
                    '${exercise.primaryMuscle} · ${ref.tr(exercise.difficulty.labelKey)}',
                    style: AppTextStyles.muted(),
                  ),
                ],
              ),
            ),
            Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: isFavorite ? AppColors.pink : AppColors.textMuted,
            ),
          ],
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
