import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vocabulary_data.dart';
import 'vocabulary_topic_detail_screen.dart';

class VocabularyTopicsScreen extends ConsumerWidget {
  const VocabularyTopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        ref.tr('vocab_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('vocab_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                itemCount: kVocabTopics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final topic = kVocabTopics[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VocabularyTopicDetailScreen(topic: topic),
                      ),
                    ),
                    child: GlowBox(
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  topic.color,
                                  topic.color.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              topic.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            topicLabel(ref, topic),
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            '${topic.words.length} ${ref.tr('vocab_word_count')}',
                            style: AppTextStyles.muted(size: 11),
                          ),
                        ],
                      ),
                    ),
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
