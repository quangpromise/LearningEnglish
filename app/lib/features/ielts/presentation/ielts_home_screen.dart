import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/ielts_models.dart';
import '../data/ielts_test_data.dart';
import 'ielts_exam_screen.dart';
import 'ielts_history_screen.dart';

/// Man vao cua tinh nang IELTS - mirror toeic_home_screen.dart. Phase 1 chi
/// co Reading + Listening (Writing/Speaking se dung Gemini AI cham diem, lam
/// o phase sau).
class IeltsHomeScreen extends ConsumerWidget {
  const IeltsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupHeader(title: ref.tr('ielts_title')),
            const SizedBox(height: 4),
            Text(ref.tr('ielts_home_subtitle'), style: AppTextStyles.muted()),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children: [
                  for (final test in kIeltsTests) ...[
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IeltsHistoryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends ConsumerWidget {
  const _TestCard({required this.test});
  final IeltsTest test;

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
            ref.tr('ielts_question_count'),
            style: AppTextStyles.muted(size: 11.5),
          ),
          const SizedBox(height: 16),
          _ModeRow(
            icon: Icons.school_rounded,
            title: ref.tr('toeic_mode_practice'),
            description: ref.tr('toeic_mode_practice_desc'),
            color: AppColors.teal,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => IeltsExamScreen(test: test, mode: 'practice'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ModeRow(
            icon: Icons.timer_rounded,
            title: ref.tr('toeic_mode_exam'),
            description: ref.tr('ielts_mode_exam_desc'),
            color: AppColors.pink,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => IeltsExamScreen(test: test, mode: 'exam'),
              ),
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
