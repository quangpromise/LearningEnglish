import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'community_screen.dart';
import 'fitness_dashboard_section.dart';
import 'muscle_group_categories_screen.dart';
import 'nutrition_screen.dart';
import 'programs_list_screen.dart';

/// Man Home cua khu vuc Fitness - theo dung mau Home cua Hoc Tieng Anh (xem
/// music_player/presentation/home_screen.dart): 1 khung nhom danh muc voi
/// cac the icon+ten, thay vi de tinh nang chiem han 1 tab rieng o thanh Menu
/// (da giai phong Menu de danh cho thanh nhac dai + tab Tin nhan).
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              accentColor: AppColors.fitnessAccent,
              unreadCount: unread,
              onMessagesTap: () =>
                  openAppPopup(context, const ConversationsScreen()),
            ),
            const SizedBox(height: 22),
            // Toan bo phan con lai co the dai hon 1 man hinh (them
            // FitnessDashboardSection o Phase 4) nen can cuon duoc, khac
            // truoc day (Column tinh khong cuon) khi noi dung con it.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FitnessDashboardSection(),
                    const SizedBox(height: 16),
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
                            // LayoutBuilder tinh be rong 1 the theo cong thuc
                            // "vua du 4 the/hang" - dung CHUNG 1 quy tac voi
                            // Home Hoc Tieng Anh va Wealth de dong bo tren ca
                            // 3 app (kem ca khi hien chi co 1 the, san sang
                            // khi them tinh nang moi).
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 12.0;
                                const columns = 4;
                                final itemWidth =
                                    (constraints.maxWidth -
                                        spacing * (columns - 1)) /
                                    columns;
                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: 14,
                                  children: [
                                    _FitnessTile(
                                      width: itemWidth,
                                      icon: Icons.calendar_month_rounded,
                                      label: ref.tr('fitness_programs_title'),
                                      onTap: () => openAppPopup(
                                        context,
                                        const ProgramsListScreen(),
                                      ),
                                    ),
                                    _FitnessTile(
                                      width: itemWidth,
                                      icon: Icons.fitness_center_rounded,
                                      label: ref.tr('fitness_library_title'),
                                      onTap: () => openAppPopup(
                                        context,
                                        const MuscleGroupCategoriesScreen(),
                                      ),
                                    ),
                                    _FitnessTile(
                                      width: itemWidth,
                                      icon: Icons.restaurant_rounded,
                                      label: ref.tr('fitness_nutrition_title'),
                                      onTap: () => openAppPopup(
                                        context,
                                        const NutritionScreen(),
                                      ),
                                    ),
                                    _FitnessTile(
                                      width: itemWidth,
                                      icon: Icons.groups_rounded,
                                      label: ref.tr('fitness_community_title'),
                                      onTap: () => openAppPopup(
                                        context,
                                        const CommunityScreen(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
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
    required this.width,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
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
            SizedBox(
              height: 28,
              child: TileLabelText(label: label, maxWidth: width),
            ),
          ],
        ),
      ),
    );
  }
}
