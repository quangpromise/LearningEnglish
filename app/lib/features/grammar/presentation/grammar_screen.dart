import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../music_player/data/songs_data.dart';
import '../data/grammar_content.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key, required this.sentence});
  final LyricLine sentence;

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  late final DetectedGrammar _detected;

  @override
  void initState() {
    super.initState();
    _detected = detectGrammar(widget.sentence.en);
  }

  @override
  Widget build(BuildContext context) {
    final point = _detected.point;
    final wordBlocks = _detected.wordBlocks;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text('Ngữ pháp', style: AppTextStyles.heading(size: 15)),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue.withValues(alpha: 0.18),
                    AppColors.purple.withValues(alpha: 0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      point.tag,
                      style: const TextStyle(
                        color: Color(0xFF5B3CFF),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.sentence.en,
                    style: AppTextStyles.heading(size: 19),
                  ),
                  Text(widget.sentence.vi, style: AppTextStyles.muted()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  GlowBox(
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CẤU TRÚC',
                          style: AppTextStyles.muted(size: 11)
                              .copyWith(letterSpacing: 0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          point.formula,
                          style: AppTextStyles.body(
                            weight: FontWeight.w800,
                            color: AppColors.blue,
                          ),
                        ),
                        if (wordBlocks.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final b in wordBlocks)
                                _WordBlock(label: b.label, word: b.word),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          point.explanation,
                          style: AppTextStyles.body(
                            size: 13,
                            weight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlowBox(
                    borderRadius: 22,
                    child: _QuizSection(quizzes: point.quizzes),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PillButton(
              label: 'Tiếp tục',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordBlock extends StatelessWidget {
  const _WordBlock({required this.label, required this.word});
  final String label;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            word,
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Danh sách nhiều câu hỏi trắc nghiệm, cho phép chấm chọn và chuyển câu -
/// thay cho phiên bản cũ chỉ có 1 câu hỏi và không bấm chọn được.
class _QuizSection extends StatefulWidget {
  const _QuizSection({required this.quizzes});
  final List<GrammarQuizQuestion> quizzes;

  @override
  State<_QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<_QuizSection> {
  int _index = 0;
  int? _selected;
  int _correctCount = 0;

  void _select(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      if (i == widget.quizzes[_index].correctIndex) _correctCount++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.quizzes.length;
    if (_index >= total) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BÀI TẬP NHANH',
            style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'Bạn đúng $_correctCount/$total câu.',
            style: AppTextStyles.heading(size: 16),
          ),
        ],
      );
    }
    final q = widget.quizzes[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BÀI TẬP NHANH',
              style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.6),
            ),
            Text('${_index + 1}/$total', style: AppTextStyles.muted(size: 11)),
          ],
        ),
        const SizedBox(height: 10),
        Text(q.prompt, style: AppTextStyles.body(size: 13)),
        const SizedBox(height: 10),
        for (var i = 0; i < q.options.length; i++)
          _QuizOption(
            text: q.options[i],
            state: _selected == null
                ? _QuizOptionState.neutral
                : i == q.correctIndex
                ? _QuizOptionState.correct
                : i == _selected
                ? _QuizOptionState.wrong
                : _QuizOptionState.neutral,
            onTap: () => _select(i),
          ),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: _index + 1 < total ? 'Câu tiếp theo' : 'Xem kết quả',
              onTap: _next,
            ),
          ),
        ],
      ],
    );
  }
}

enum _QuizOptionState { neutral, correct, wrong }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.text,
    required this.state,
    required this.onTap,
  });
  final String text;
  final _QuizOptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _QuizOptionState.correct => AppColors.teal,
      _QuizOptionState.wrong => AppColors.pink,
      _QuizOptionState.neutral => null,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: color != null
              ? color.withValues(alpha: 0.16)
              : AppColors.glassFill,
          border: Border.all(
            color: color != null
                ? color.withValues(alpha: 0.5)
                : AppColors.glassBorder,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? Colors.transparent,
                border: Border.all(
                  color: color ?? AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: state == _QuizOptionState.correct
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : state == _QuizOptionState.wrong
                  ? const Icon(Icons.close, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
