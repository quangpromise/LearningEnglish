import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pointing_hand_badge.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../../learning_path/presentation/learning_path_accent.dart';
import '../../vocabulary/data/vocab_level_filter.dart';
import '../../vocabulary/data/vocabulary_data.dart';
import 'writing_vocab_quiz_screen.dart';

/// Luoi chon chu de tu vung cho che do "Go tu tieng Anh" - mirror
/// vocabulary_topics_screen.dart (khong co o tim kiem rieng vi so chu de it
/// hon can dung tro lai qua lai giua 2 man), nhung bam vao 1 chu de se mo
/// WritingVocabQuizScreen (go tu) thay vi VocabularyTopicDetailScreen (xem
/// tu dien).
class WritingVocabTopicScreen extends ConsumerWidget {
  const WritingVocabTopicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cung bo loc cap hoc voi man Tu vung theo chu de (vocab_level_filter.dart)
    // - null = Tu hoc, hien du moi chu de/moi tu nhu cu.
    final level = ref.watch(learnerLevelProvider);
    final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
    final topics = topicsForLevel(kVocabTopics, level);
    final handTopic = level != null && persona != null && topics.isNotEmpty
        ? topics.first
        : null;
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
                        ref.tr('writing_mode_vocab_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('writing_vocab_pick_topic'),
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
              child: GridView.builder(
                itemCount: topics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final topic = topics[i];
                  return GestureDetector(
                    onTap: () => openAppPopup(
                      context,
                      WritingVocabQuizScreen(topic: topic),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
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
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${wordsForLevel(topic, level).length} ${ref.tr('vocab_word_count')}',
                                  style: AppTextStyles.muted(size: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (topic == handTopic)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: PointingHandBadge(
                              color: personaColor(persona!),
                            ),
                          ),
                      ],
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
