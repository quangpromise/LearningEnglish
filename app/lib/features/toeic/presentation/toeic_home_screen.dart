import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/toeic_models.dart';
import '../data/toeic_test_data.dart';
import 'toeic_exam_screen.dart';
import 'toeic_history_screen.dart';

/// Man vao cua tinh nang TOEIC - chon 1 de trong [kToeicTests] (hien chi co
/// 1 de, nhung list nay da chuan bi san cho nhieu de sau nay khong can doi
/// code) roi chon che do Luyen tap/Thi thu.
class ToeicHomeScreen extends ConsumerWidget {
  const ToeicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupHeader(title: ref.tr('toeic_title')),
            const SizedBox(height: 4),
            Text(ref.tr('toeic_home_subtitle'), style: AppTextStyles.muted()),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children: [
                  for (final test in kToeicTests) ...[
                    _TestCard(test: test),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            PillButton(
              label: ref.tr('toeic_view_history'),
              filled: false,
              icon: const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.wealthAccent,
              ),
              onTap: () => openAppPopup(context, const ToeicHistoryScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends ConsumerWidget {
  const _TestCard({required this.test});
  final ToeicTest test;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(test.titleVi, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 4),
          Text(
            ref.tr('toeic_question_count'),
            style: AppTextStyles.muted(size: 11.5),
          ),
          const SizedBox(height: 16),
          _ModeRow(
            icon: Icons.school_rounded,
            title: ref.tr('toeic_mode_practice'),
            description: ref.tr('toeic_mode_practice_desc'),
            color: AppColors.teal,
            onTap: () => openAppPopup(
              context,
              ToeicExamScreen(test: test, mode: 'practice'),
            ),
          ),
          const SizedBox(height: 10),
          _ModeRow(
            icon: Icons.timer_rounded,
            title: ref.tr('toeic_mode_exam'),
            description: ref.tr('toeic_mode_exam_desc'),
            color: AppColors.pink,
            // dismissible: false - man thi co tinh gio, tranh vuot xuong lam
            // mat bai dang lam do (xem doc comment cua openAppPopup).
            onTap: () => openAppPopup(
              context,
              ToeicExamScreen(test: test, mode: 'exam'),
              dismissible: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(description, style: AppTextStyles.muted(size: 11)),
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
