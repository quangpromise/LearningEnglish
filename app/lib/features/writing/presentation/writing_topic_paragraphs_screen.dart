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
import '../data/writing_paragraph_data.dart';
import '../data/writing_progress.dart';
import 'writing_paragraph_screen.dart';

/// Danh sach bai Doan van cua 1 chu de. Da chon goi y -> chi 8 bai cua cap
/// do, ban tay LUON chi vao bai chua lam dau tien. Tu hoc -> du 24 bai, chia
/// 3 nhom Co ban/Trung cap/Nang cao, khong ban tay.
class WritingTopicParagraphsScreen extends ConsumerWidget {
  const WritingTopicParagraphsScreen({super.key, required this.topic});

  final WritingTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final level = ref.watch(learnerLevelProvider);
    final done = ref.watch(writingDoneParagraphsProvider).valueOrNull ?? {};
    final paragraphs = topic.paragraphsFor(level);

    Widget item(WritingParagraph p, int number) => _ParagraphTile(
      number: number,
      title: lang == AppLanguage.en ? p.titleEn : p.titleVi,
      subtitle: '${p.sentences.length} ${ref.tr('writing_sentence_count')}',
      color: topic.color,
      done: done.contains(p.id),
      onTap: () => openAppPopup(context, WritingParagraphScreen(paragraph: p)),
    );

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
                        lang == AppLanguage.en ? topic.titleEn : topic.titleVi,
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('writing_paragraph_pick_hint'),
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
                  if (level != null)
                    for (var i = 0; i < paragraphs.length; i++) ...[
                      item(paragraphs[i], i + 1),
                      const SizedBox(height: 10),
                    ]
                  else
                    for (final lv in LearnerLevel.values) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Text(
                          ref.tr(lv.labelKey).toUpperCase(),
                          style: AppTextStyles.muted(size: 11)
                              .copyWith(letterSpacing: 1),
                        ),
                      ),
                      for (final (i, p) in topic.paragraphsFor(lv).indexed) ...[
                        item(p, i + 1),
                        const SizedBox(height: 10),
                      ],
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParagraphTile extends StatelessWidget {
  const _ParagraphTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.done,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final Color color;
  final bool done;
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
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
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
            Icon(
              done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: done ? AppColors.teal : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
