import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../data/vocab_level_filter.dart';
import '../data/vocabulary_data.dart';
import 'vocabulary_topic_detail_screen.dart';

class VocabularyTopicsScreen extends ConsumerStatefulWidget {
  const VocabularyTopicsScreen({super.key});

  @override
  ConsumerState<VocabularyTopicsScreen> createState() =>
      _VocabularyTopicsScreenState();
}

class _VocabularyTopicsScreenState
    extends ConsumerState<VocabularyTopicsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cap hoc tu "Goi y lo trinh" (null = Tu hoc -> hien du 59 chu de, dem
    // du tu nhu cu) - xem vocab_level_filter.dart.
    final level = ref.watch(learnerLevelProvider);
    final topics = topicsForLevel(kVocabTopics, level).where((t) {
      if (_query.isEmpty) return true;
      return t.name.toLowerCase().contains(_query) ||
          t.nameEn.toLowerCase().contains(_query);
    }).toList();
    // So tu CON LAI (chua danh dau "Da hoc") cua tung chu de - tu da hoc bi
    // an khoi man chi tiet chu de (xem VocabularyTopicDetailScreen.build)
    // nen o day cung phai tru bot de khop voi so luong nguoi dung se thay
    // khi bam vao.
    final learned = ref.watch(learnedWordsProvider).valueOrNull ?? const {};
    int remainingCount(VocabTopic t) {
      final words = wordsForLevel(t, level);
      return learned.isEmpty
          ? words.length
          : words.where((w) => !learned.contains(w.en.toLowerCase())).length;
    }

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
            if (level != null) ...[
              const SizedBox(height: 10),
              const LearnerLevelBanner(),
            ],
            const SizedBox(height: 14),
            GlowBox(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                      style: AppTextStyles.body(size: 13),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: ref.tr('vocab_search_hint'),
                        hintStyle: AppTextStyles.muted(size: 13),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: topics.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('search_no_results'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : GridView.builder(
                      itemCount: topics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                            VocabularyTopicDetailScreen(topic: topic),
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
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${remainingCount(topic)} ${ref.tr('vocab_word_count')}',
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
