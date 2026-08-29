import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';

/// Man Menu - gom cac tinh nang khong can chiem rieng 1 tab o thanh dieu
/// huong duoi (Doc sach, Do vui) vao 1 danh sach, vao tu nut Menu cuoi
/// thanh dieu huong.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ref.tr('menu_title'), style: AppTextStyles.heading(size: 20)),
            Text(ref.tr('menu_subtitle'), style: AppTextStyles.muted()),
            const SizedBox(height: 18),
            _MenuItem(
              icon: Icons.auto_stories_rounded,
              color: AppColors.purple,
              title: ref.tr('reading_title'),
              subtitle: ref.tr('reading_quick_subtitle'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReadingLibraryScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuItem(
              icon: Icons.extension_rounded,
              color: AppColors.blue,
              title: ref.tr('quiz_title'),
              subtitle: ref.tr('quiz_subtitle'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuizCategoryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  Text(subtitle, style: AppTextStyles.muted(size: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
