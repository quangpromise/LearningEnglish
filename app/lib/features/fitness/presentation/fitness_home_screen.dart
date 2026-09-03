import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/theme/app_theme.dart';
import 'muscle_group_categories_screen.dart';

/// Man Home cua khu vuc Fitness - theo dung mau Home cua Hoc Tieng Anh (xem
/// music_player/presentation/home_screen.dart): 1 khung nhom danh muc voi
/// cac the icon+ten, thay vi de tinh nang chiem han 1 tab rieng o thanh Menu
/// (da giai phong Menu de danh cho thanh nhac dai + tab Tin nhan).
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(accentColor: AppColors.fitnessAccent),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: GlowBox(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('fitness_home_category_workout'),
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 14),
                    _FitnessTile(
                      icon: Icons.fitness_center_rounded,
                      label: ref.tr('fitness_library_title'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MuscleGroupCategoriesScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FitnessTile extends StatelessWidget {
  const _FitnessTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(icon, color: AppColors.fitnessAccent, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 10.5, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
