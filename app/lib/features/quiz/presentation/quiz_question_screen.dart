import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/quiz_data.dart';

class QuizQuestionScreen extends ConsumerStatefulWidget {
  const QuizQuestionScreen({
    super.key,
    required this.category,
    required this.riddles,
    required this.onBack,
    required this.onFinished,
  });
  final String category;
  final List<Riddle> riddles;

  /// Nut back o header - quay ve luoi chu de.
  final VoidCallback onBack;

  /// Da tra loi het cau cuoi - chuyen sang man ket qua voi danh sach dung/
  /// sai tuong ung tung cau.
  final void Function(List<bool> results) onFinished;

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen> {
  int _index = 0;
  String? _picked;
  final List<bool> _results = [];
  late final List<List<String>> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _shuffledOptions = widget.riddles.map((r) {
      final opts = [r.answer, ...r.distractors];
      opts.shuffle(rnd);
      return opts;
    }).toList();
  }

  Riddle get _current => widget.riddles[_index];

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _results.add(option == _current.answer);
      if (_index < widget.riddles.length - 1) {
        setState(() {
          _index++;
          _picked = null;
        });
      } else {
        widget.onFinished(_results);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _shuffledOptions[_index];
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
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
                  child: Row(
                    children: List.generate(widget.riddles.length, (i) {
                      final done = i <= _index;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: done ? AppColors.accentGradient : null,
                            color: done ? null : AppColors.glassFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${categoryLabel(ref, widget.category).toUpperCase()} · ${ref.tr('quiz_question_label')} ${_index + 1}/${widget.riddles.length}',
                style: const TextStyle(
                  color: Color(0xFF9DB4FF),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GlowBox(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${_current.en}"',
                    style: AppTextStyles.heading(size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(_current.vi, style: AppTextStyles.muted()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final opt = options[i];
                  final isPicked = _picked == opt;
                  final isCorrect = opt == _current.answer;
                  Color? bg = AppColors.glassFill;
                  Color border = AppColors.glassBorder;
                  if (_picked != null && isCorrect) {
                    bg = AppColors.teal.withValues(alpha: 0.16);
                    border = AppColors.teal.withValues(alpha: 0.5);
                  } else if (_picked != null && isPicked && !isCorrect) {
                    bg = AppColors.pink.withValues(alpha: 0.16);
                    border = AppColors.pink.withValues(alpha: 0.5);
                  }
                  return GestureDetector(
                    onTap: () => _pick(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: AppTextStyles.body(
                                  size: 12,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt,
                              style: AppTextStyles.body(
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Text(
                'Trả lời đúng để nhận +10 XP',
                style: AppTextStyles.muted(size: 12)
                    .copyWith(color: AppColors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
