import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../data/writing_bank.dart';
import '../data/writing_progress.dart';
import 'writing_mixed_list_screen.dart';
import 'writing_topic_paragraphs_screen.dart';

/// Man chon chu de Doan van - ngan hang bai theo cap (kWritingTopics, moi chu
/// de 8 bai/cap). Da chon goi y lo trinh -> moi the chi dem bai cua cap do,
/// ban tay LUON chi vao chu de con bai chua lam dau tien. Tu hoc -> hien du
/// 24 bai/chu de, khong ban tay. Muc "On tong hop 12 thi" (bo 24 doan cu)
/// chi hien cho Tu hoc/Nang cao - xem docs/research-level-based-content.md.
class WritingParagraphListScreen extends ConsumerWidget {
  const WritingParagraphListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final level = ref.watch(learnerLevelProvider);
    final done = ref.watch(writingDoneParagraphsProvider).valueOrNull ?? {};
    final showMixed = level == null || level == LearnerLevel.advanced;

    int doneCount(WritingTopic t) =>
        t.paragraphsFor(level).where((p) => done.contains(p.id)).length;

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
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('writing_mode_paragraph_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('writing_topic_pick_hint'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (level != null) ...[
              const SizedBox(height: 10),
              const LearnerLevelBanner(),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  for (final t in kWritingTopics) ...[
                    _TopicCard(
                      title: lang == AppLanguage.en ? t.titleEn : t.titleVi,
                      subtitle:
                          '${t.paragraphsFor(level).length} '
                          '${ref.tr('writing_lesson_count')}'
                          '${level != null ? ' · ${ref.tr(level.labelKey)}' : ''}'
                          ' · ${ref.tr('writing_done_count').replaceFirst('{done}', '${doneCount(t)}').replaceFirst('{total}', '${t.paragraphsFor(level).length}')}',
                      icon: t.icon,
                      color: t.color,
                      onTap: () => openAppPopup(
                        context,
                        WritingTopicParagraphsScreen(topic: t),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (showMixed)
                    _TopicCard(
                      title: ref.tr('writing_mixed_title'),
                      subtitle: ref.tr('writing_mixed_desc'),
                      icon: Icons.layers_rounded,
                      color: AppColors.teal,
                      onTap: () => openAppPopup(
                        context,
                        const WritingMixedParagraphListScreen(),
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

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
                  Text(subtitle, style: AppTextStyles.muted(size: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
