import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/grammar_data.dart';
import 'grammar_quiz_screen.dart';

/// Giai thich 1 chu diem ngu phap: cong thuc + giai thich ngan + vi du
/// song ngu, cuoi trang co nut vao lam 5 cau trac nghiem luyen tap.
class GrammarTopicDetailScreen extends ConsumerWidget {
  const GrammarTopicDetailScreen({super.key, required this.topic});
  final GrammarTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
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
                  child: Text(
                    grammarTopicLabel(ref, topic),
                    style: AppTextStyles.heading(size: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: topic.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      topic.formula,
                      style: TextStyle(
                        color: topic.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    topic.explanationVi,
                    style: AppTextStyles.body(size: 13.5),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    ref.tr('grammar_topics_examples_title'),
                    style: AppTextStyles.muted(size: 11)
                        .copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  ...topic.examples.map(
                    (ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlowBox(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.en,
                              style: AppTextStyles.body(
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(ex.vi, style: AppTextStyles.muted(size: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('grammar_topics_start_practice'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GrammarQuizScreen(topic: topic),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
