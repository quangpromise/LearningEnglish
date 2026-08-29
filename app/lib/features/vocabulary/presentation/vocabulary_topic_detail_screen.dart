import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vocabulary_data.dart';
import 'vocabulary_quiz_screen.dart';

const _maxWordsPerSession = 10;

class VocabularyTopicDetailScreen extends ConsumerStatefulWidget {
  const VocabularyTopicDetailScreen({super.key, required this.topic});

  final VocabTopic topic;

  @override
  ConsumerState<VocabularyTopicDetailScreen> createState() =>
      _VocabularyTopicDetailScreenState();
}

class _VocabularyTopicDetailScreenState
    extends ConsumerState<VocabularyTopicDetailScreen> {
  final Set<VocabWord> _selected = {};

  void _toggle(VocabWord word) {
    setState(() {
      if (_selected.contains(word)) {
        _selected.remove(word);
      } else if (_selected.length < _maxWordsPerSession) {
        _selected.add(word);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.topic.words;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topicLabel(ref, widget.topic),
                        style: AppTextStyles.heading(size: 17),
                      ),
                      Text(
                        ref
                            .tr('vocab_select_hint')
                            .replaceFirst('{max}', '$_maxWordsPerSession'),
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.topic.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_selected.length}/$_maxWordsPerSession',
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: widget.topic.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: words.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final word = words[i];
                  final isSelected = _selected.contains(word);
                  return GestureDetector(
                    onTap: () => _toggle(word),
                    child: GlowBox(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.topic.color
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? widget.topic.color
                                    : AppColors.glassBorder,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      word.en,
                                      style: AppTextStyles.body(
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      word.ipa,
                                      style: AppTextStyles.muted(size: 11),
                                    ),
                                  ],
                                ),
                                Text(
                                  word.vi,
                                  style: AppTextStyles.muted(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('vocab_start_learning'),
                onTap: _selected.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VocabularyQuizScreen(
                            topic: widget.topic,
                            words: _selected.toList(),
                          ),
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
