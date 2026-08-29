import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/grammar_data.dart';

/// 5 cau trac nghiem dien vao cho trong CO SAN cho 1 chu diem ngu phap
/// (khac quiz tu vung: cau hoi/dap an la co dinh, khong random tao
/// distractor). Het cau cuoi hien bang ket qua ngay tren man nay va dung
/// lai, giong quy uoc cua VocabularyQuizScreen.
class GrammarQuizScreen extends ConsumerStatefulWidget {
  const GrammarQuizScreen({super.key, required this.topic});
  final GrammarTopic topic;

  @override
  ConsumerState<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends ConsumerState<GrammarQuizScreen> {
  int _index = 0;
  int? _picked;
  final List<bool> _results = [];
  bool _finished = false;

  GrammarQuestion get _current => widget.topic.questions[_index];

  void _pick(int optionIndex) {
    if (_picked != null) return;
    setState(() => _picked = optionIndex);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _results.add(optionIndex == _current.correctIndex);
      if (_index < widget.topic.questions.length - 1) {
        setState(() {
          _index++;
          _picked = null;
        });
      } else {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult(context);

    final topic = widget.topic;
    final total = topic.questions.length;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                  child: Row(
                    children: List.generate(total, (i) {
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
                color: topic.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${grammarTopicLabel(ref, topic).toUpperCase()} · ${ref.tr('vocab_question_label')} ${_index + 1}/$total',
                style: TextStyle(
                  color: topic.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GlowBox(
              borderRadius: 24,
              child: Text(
                _current.promptEn,
                style: AppTextStyles.heading(size: 18),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _current.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final opt = _current.options[i];
                  final isPicked = _picked == i;
                  final isCorrect = i == _current.correctIndex;
                  Color bg = AppColors.glassFill;
                  Color border = AppColors.glassBorder;
                  if (_picked != null && isCorrect) {
                    bg = AppColors.teal.withValues(alpha: 0.16);
                    border = AppColors.teal.withValues(alpha: 0.5);
                  } else if (_picked != null && isPicked && !isCorrect) {
                    bg = AppColors.pink.withValues(alpha: 0.16);
                    border = AppColors.pink.withValues(alpha: 0.5);
                  }
                  return GestureDetector(
                    onTap: () => _pick(i),
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
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final correct = _results.where((r) => r).length;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            Text(
              ref.tr('vocab_completed'),
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: const Color(0xFFC9A8FF), letterSpacing: 1),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _results.isEmpty ? 0 : correct / _results.length,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: widget.topic.color,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$correct/${_results.length}',
                        style: AppTextStyles.heading(size: 26),
                      ),
                      Text(
                        ref.tr('vocab_correct_count'),
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: widget.topic.questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ok = i < _results.length && _results[i];
                  final q = widget.topic.questions[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: (ok ? AppColors.teal : AppColors.pink)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            ok ? Icons.check_rounded : Icons.close_rounded,
                            size: 13,
                            color: ok ? AppColors.teal : AppColors.pink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${q.promptEn} — ${q.options[q.correctIndex]}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('vocab_done'),
                onTap: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  nav.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
