import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exercise_model.dart';
import 'exercise_library_screen.dart';

/// Man hinh danh muc nhom co (diem vao cua Thu vien bai tap) - thiet ke theo
/// mau tham khao dang "the ngang, ten ben trai, anh giai phau co bleed sang
/// phai" (nguoi dung cung cap anh, da xac nhan co ban quyen su dung, xem
/// [MuscleGroup.imageAsset]). Bam vao 1 the se mo [ExerciseLibraryScreen] da
/// loc san theo nhom co do.
class MuscleGroupCategoriesScreen extends ConsumerStatefulWidget {
  const MuscleGroupCategoriesScreen({super.key});

  @override
  ConsumerState<MuscleGroupCategoriesScreen> createState() =>
      _MuscleGroupCategoriesScreenState();
}

class _MuscleGroupCategoriesScreenState
    extends ConsumerState<MuscleGroupCategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openLibrary({MuscleGroup? group, String query = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ExerciseLibraryScreen(initialGroup: group, initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              showBackButton: true,
              accentColor: AppColors.fitnessAccent,
              trailing: GestureDetector(
                onTap: () => _openLibrary(),
                child: const _IconCircle(icon: Icons.list_alt_rounded),
              ),
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
                      style: AppTextStyles.body(),
                      cursorColor: AppColors.fitnessAccent,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => _openLibrary(query: v),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: ref.tr('fitness_search_hint'),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: MuscleGroup.values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final group = MuscleGroup.values[i];
                  return _MuscleGroupCard(
                    group: group,
                    onTap: () => _openLibrary(group: group),
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

class _MuscleGroupCard extends ConsumerWidget {
  const _MuscleGroupCard({required this.group, required this.onTap});
  final MuscleGroup group;
  final VoidCallback onTap;

  // Nen tham thay vi mau nen chinh (den/cam) cua app - de anh giai phau (nen
  // xanh navy tu app tham khao) hoa hop tu nhien thay vi bi lech tong.
  static const _cardBg = Color(0xFF0E1420);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -8,
                top: 0,
                bottom: 0,
                width: 190,
                child: Image.asset(
                  group.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              // Scrim ben trai de chu luon doc duoc du anh sang/toi khac nhau.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      _cardBg,
                      _cardBg.withValues(alpha: 0.75),
                      _cardBg.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 0.92],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ref.tr(group.labelKey),
                    style: AppTextStyles.heading(size: 17),
                  ),
                ),
              ),
            ],
          ),
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
