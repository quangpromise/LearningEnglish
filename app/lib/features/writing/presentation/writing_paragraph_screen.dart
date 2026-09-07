import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/writing_paragraph_data.dart';
import '../data/writing_scoring.dart';

/// Man dich tung cau cua 1 doan van - moi cau tieng Viet co 1 TextField
/// rieng, 1 nut "Cham diem" o cuoi trang cham TAT CA cau cung luc bang
/// scoreSentence(). Sau khi cham: hien % + to mau tung tu (xanh = khop,
/// do = thieu/sai) + cau dung day du + nhan thi ngu phap (day la phan
/// "giai thich diem sai" theo yeu cau).
class WritingParagraphScreen extends ConsumerStatefulWidget {
  const WritingParagraphScreen({super.key, required this.paragraph});

  final WritingParagraph paragraph;

  @override
  ConsumerState<WritingParagraphScreen> createState() =>
      _WritingParagraphScreenState();
}

class _WritingParagraphScreenState
    extends ConsumerState<WritingParagraphScreen> {
  late final List<TextEditingController> _controllers;
  List<SentenceScore?> _scores = [];
  bool _graded = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.paragraph.sentences.length,
      (_) => TextEditingController(),
    );
    _scores = List.filled(widget.paragraph.sentences.length, null);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _grade() {
    final sentences = widget.paragraph.sentences;
    setState(() {
      _scores = [
        for (var i = 0; i < sentences.length; i++)
          scoreSentence(
            targetEn: sentences[i].en,
            userInput: _controllers[i].text,
          ),
      ];
      _graded = true;
    });
  }

  int get _overallScore {
    if (_scores.isEmpty || _scores.any((s) => s == null)) return 0;
    final total = _scores.fold<int>(0, (sum, s) => sum + s!.score);
    return (total / _scores.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final title = lang == AppLanguage.en
        ? widget.paragraph.titleEn
        : widget.paragraph.titleVi;
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
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.heading(size: 17)),
                      if (_graded)
                        Text(
                          '${ref.tr('writing_overall_score')}: $_overallScore%',
                          style: AppTextStyles.muted(size: 11.5).copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      else
                        Text(
                          ref.tr('writing_paragraph_hint'),
                          style: AppTextStyles.muted(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: widget.paragraph.sentences.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = widget.paragraph.sentences[i];
                  final score = _scores[i];
                  return _SentenceCard(
                    index: i,
                    sentence: s,
                    controller: _controllers[i],
                    score: score,
                    enabled: !_graded,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr(
                  _graded ? 'writing_regrade_button' : 'writing_grade_button',
                ),
                accentGradient: LinearGradient(
                  colors: [
                    AppColors.teal,
                    AppColors.teal.withValues(alpha: 0.65),
                  ],
                ),
                accentColor: AppColors.teal,
                onTap: _grade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentenceCard extends ConsumerWidget {
  const _SentenceCard({
    required this.index,
    required this.sentence,
    required this.controller,
    required this.score,
    required this.enabled,
  });

  final int index;
  final WritingSentence sentence;
  final TextEditingController controller;
  final SentenceScore? score;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = score == null
        ? AppColors.glassBorder
        : (score!.score >= 80
              ? AppColors.teal
              : (score!.score >= 40 ? AppColors.amber : AppColors.pink));
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.muted(
                      size: 11,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sentence.vi,
                  style: AppTextStyles.body(weight: FontWeight.w700),
                ),
              ),
              if (score != null)
                Text(
                  '${score!.score}%',
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: null,
            style: AppTextStyles.body(size: 13.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: ref.tr('writing_paragraph_type_hint'),
              hintStyle: AppTextStyles.muted(size: 13),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: AppColors.glassFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < score!.targetWords.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (score!.wordResults[i]
                                  ? AppColors.teal
                                  : AppColors.pink)
                              .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      score!.targetWords[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: score!.wordResults[i]
                            ? AppColors.teal
                            : AppColors.pink,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ref.tr('writing_correct_answer_label')}: ${sentence.en}',
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ref.tr('writing_tense_label')}: ${sentence.tenseLabel}',
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
