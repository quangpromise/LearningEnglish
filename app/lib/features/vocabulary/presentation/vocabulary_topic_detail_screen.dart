import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/daily_words_repository.dart';
import '../data/vocabulary_data.dart';
import 'daily_words_controller.dart';
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

  // null = khong loc (hien tat ca, ke ca tu chua duoc gan nhan frequency/
  // partOfSpeech - xem doc comment cua 2 field do trong vocabulary_data.dart).
  VocabFrequency? _frequencyFilter;
  VocabPartOfSpeech? _posFilter;

  void _toggle(VocabWord word) {
    setState(() {
      if (_selected.contains(word)) {
        _selected.remove(word);
      } else if (_selected.length < _maxWordsPerSession) {
        _selected.add(word);
      }
    });
  }

  /// Danh dau 1 tu "Da hoc" - HOI XAC NHAN TRUOC (tu se bien mat khoi danh
  /// sach ngay sau khi dong y, xem ghi chu o duoi) roi moi ghi vao
  /// user_learned_words (nguon DUY NHAT cho ca thong ke "Words Learned" o
  /// man Ho so LAN popup xem lai, xem learnedWordsProvider) va lam moi lai
  /// danh sach de tu nay bien mat khoi man Tu vung theo chu de (loc theo
  /// learnedWordsProvider trong build() ben duoi) va cap nhat luon so tu
  /// con lai o man luoi chu de.
  Future<void> _markLearned(BuildContext context, VocabWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          ref.tr('vocab_mark_learned_confirm_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          ref
              .tr('vocab_mark_learned_confirm_body')
              .replaceFirst('{word}', word.en),
          style: AppTextStyles.muted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              ref.tr('vocab_mark_learned'),
              style: const TextStyle(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(statsRepositoryProvider).recordWordLearned(word.en);
    _selected.remove(word);
    ref.invalidate(learnedWordsProvider);
    ref.invalidate(myStatsProvider);
  }

  Future<void> _saveToDailyList(BuildContext context) async {
    final entries = _selected
        .map((w) => DailyWordEntry(en: w.en, vi: w.vi, ipa: w.ipa))
        .toList();
    await ref.read(dailyWordsControllerProvider.notifier).setWords(entries);
    if (!context.mounted) return;
    // Ro rang hon SnackBar mac dinh (chi chu trang tren nen xam, de bi luot
    // qua khong de y) - kem icon check + so tu vua duoc them.
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xEB0F1326),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.teal,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ref
                    .tr('vocab_added_to_daily')
                    .replaceFirst('{n}', '${entries.length}'),
                style: AppTextStyles.body(weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learned = ref.watch(learnedWordsProvider).valueOrNull ?? const {};
    final words = widget.topic.words.where((w) {
      final matchesFreq =
          _frequencyFilter == null || w.frequency == _frequencyFilter;
      final matchesPos = _posFilter == null || w.partOfSpeech == _posFilter;
      // Tu da danh dau "Da hoc" khong con hien o day nua - chuyen sang xem
      // trong popup "Words Learned" o the Hoat dong man Ho so.
      final notLearned = !learned.contains(w.en.toLowerCase());
      return matchesFreq && matchesPos && notLearned;
    }).toList();
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
            // Tab theo muc do thong dung (thay cho hang chip cu) - moi tab
            // ung voi 1 "phan khuc" nguoi hoc (moi bat dau/da co nen/nang
            // cao), kem 1 dong mo ta ben duoi giai thich phan khuc do danh
            // cho ai de nguoi dung tu chon dung tab phu hop trinh do minh.
            _FrequencyTabBar(
              value: _frequencyFilter,
              color: widget.topic.color,
              onChanged: (f) => setState(() => _frequencyFilter = f),
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr(switch (_frequencyFilter) {
                null => 'vocab_frequency_all_desc',
                VocabFrequency.common => 'vocab_frequency_common_desc',
                VocabFrequency.medium => 'vocab_frequency_medium_desc',
                VocabFrequency.rare => 'vocab_frequency_rare_desc',
              }),
              style: AppTextStyles.muted(size: 11.5),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: ref.tr('vocab_filter_all'),
                    selected: _posFilter == null,
                    color: widget.topic.color,
                    onTap: () => setState(() => _posFilter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final p in VocabPartOfSpeech.values) ...[
                    _FilterChip(
                      label: ref.tr(p.labelKey),
                      selected: _posFilter == p,
                      color: widget.topic.color,
                      onTap: () => setState(() => _posFilter = p),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: words.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('search_no_results'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.separated(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            style: AppTextStyles.muted(
                                              size: 11,
                                            ),
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
                                SpeakerButton(
                                  onTap: () => AppTts.instance.speak(word.en),
                                  color: widget.topic.color,
                                ),
                                Tooltip(
                                  message: ref.tr('vocab_mark_learned'),
                                  child: SpeakerButton(
                                    icon: Icons.check_circle_outline_rounded,
                                    tapSize: 36,
                                    iconSize: 20,
                                    onTap: () => _markLearned(context, word),
                                    color: AppColors.teal,
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
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: ref.tr('vocab_start_learning'),
                    onTap: _selected.isEmpty
                        ? null
                        : () => openAppPopup(
                            context,
                            VocabularyQuizScreen(
                              topic: widget.topic,
                              words: _selected.toList(),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: ref.tr('vocab_add_to_daily'),
                    filled: false,
                    onTap: _selected.isEmpty
                        ? null
                        : () => _saveToDailyList(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab chia theo muc do thong dung (Tat ca/Thong dung/Thuong gap/It gap) -
/// segmented control chia deu 4 o thay vi hang chip cuon ngang, de nguoi
/// dung thay het 4 lua chon cung luc (khong phai cuon moi thay "It gap").
class _FrequencyTabBar extends ConsumerWidget {
  const _FrequencyTabBar({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final VocabFrequency? value;
  final Color color;
  final ValueChanged<VocabFrequency?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          _segment(
            label: ref.tr('vocab_filter_all'),
            selected: value == null,
            onTap: () => onChanged(null),
          ),
          for (final f in VocabFrequency.values)
            _segment(
              label: ref.tr(f.labelKeyVi),
              selected: value == f,
              onTap: () => onChanged(f),
            ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.body(
                size: 11.5,
                weight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip loc theo partOfSpeech - cung kieu voi _FilterChip trong
/// wealth_income_tab.dart, chi khac o cho mau accent lay theo [color] truyen
/// vao (mau rieng cua tung chu de) thay vi mau co dinh.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? color : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
