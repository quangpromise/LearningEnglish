import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/grammar_data.dart';
import 'grammar_quiz_screen.dart';
import 'grammar_topic_detail_screen.dart';
import 'irregular_verbs_screen.dart';

enum _GrammarStep { topics, irregularVerbs, detail, quiz }

/// Danh sach 31 chu diem ngu phap co ban - vao tu 1 the rieng trong man
/// Vocabulary (khong phai tu tab rieng), moi chu diem co giai thich +
/// vi du + 5 cau trac nghiem luyen tap. Cung la "khung" duy nhat cho CA
/// luong (chon chu diem/bang dong tu bat quy tac -> chi tiet -> quiz),
/// KHONG mo them popup/route nao khac - xem giai thich chi tiet trong
/// VocabularyTopicsScreen (cung nguyen tac, dung lam mau).
class GrammarTopicsScreen extends ConsumerStatefulWidget {
  const GrammarTopicsScreen({super.key});

  @override
  ConsumerState<GrammarTopicsScreen> createState() =>
      _GrammarTopicsScreenState();
}

class _GrammarTopicsScreenState extends ConsumerState<GrammarTopicsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  _GrammarStep _step = _GrammarStep.topics;
  GrammarTopic? _activeTopic;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openIrregularVerbs() =>
      setState(() => _step = _GrammarStep.irregularVerbs);

  void _openTopic(GrammarTopic topic) {
    setState(() {
      _activeTopic = topic;
      _step = _GrammarStep.detail;
    });
  }

  void _backToTopics() => setState(() => _step = _GrammarStep.topics);

  void _startQuiz() => setState(() => _step = _GrammarStep.quiz);

  void _backToDetail() => setState(() => _step = _GrammarStep.detail);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _GrammarStep.irregularVerbs:
        return IrregularVerbsScreen(onBack: _backToTopics);
      case _GrammarStep.detail:
        final topic = _activeTopic ?? kGrammarTopics.first;
        return GrammarTopicDetailScreen(
          topic: topic,
          onBack: _backToTopics,
          onStartQuiz: _startQuiz,
        );
      case _GrammarStep.quiz:
        return GrammarQuizScreen(
          topic: _activeTopic ?? kGrammarTopics.first,
          onClose: _backToDetail,
          onFinishToTopics: _backToTopics,
        );
      case _GrammarStep.topics:
        return _buildTopicsList(context);
    }
  }

  Widget _buildTopicsList(BuildContext context) {
    final topics = kGrammarTopics.where((t) {
      if (_query.isEmpty) return true;
      return t.name.toLowerCase().contains(_query) ||
          t.nameEn.toLowerCase().contains(_query) ||
          t.formula.toLowerCase().contains(_query);
    }).toList();

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
                        ref.tr('grammar_topics_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('grammar_topics_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                        hintText: ref.tr('grammar_search_hint'),
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openIrregularVerbs,
              child: GlowBox(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.table_chart_rounded,
                        color: AppColors.purple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ref.tr('grammar_irregular_verbs_title'),
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
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
                  : ListView.separated(
                      itemCount: topics.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final topic = topics[i];
                        return GestureDetector(
                          onTap: () => _openTopic(topic),
                          child: GlowBox(
                            borderRadius: 18,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
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
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        grammarTopicLabel(ref, topic),
                                        style: AppTextStyles.body(
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        topic.formula,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.muted(size: 11.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: topic.color,
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
