import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../vocabulary/data/vocabulary_data.dart';
import '../data/writing_scoring.dart';

/// Vong go tu tieng Anh theo nghia tieng Viet - hien Y NGHIA (VocabWord.vi),
/// nguoi dung go dap an tieng Anh vao 1 TextField (khac
/// VocabularyQuizScreen: cai do la trac nghiem chon 1 trong 4). Cham diem
/// bang scoreVocabAnswer (chinh xac/gan dung do loi chinh ta nhe/sai han) -
/// tu dong chuyen cau sau 900ms roi hien ket qua cuoi vong (mirror timing +
/// bo cuc man ket qua cua VocabularyQuizScreen).
class WritingVocabQuizScreen extends ConsumerStatefulWidget {
  const WritingVocabQuizScreen({super.key, required this.topic});

  final VocabTopic topic;

  @override
  ConsumerState<WritingVocabQuizScreen> createState() =>
      _WritingVocabQuizScreenState();
}

class _WritingVocabQuizScreenState
    extends ConsumerState<WritingVocabQuizScreen> {
  late final List<VocabWord> _order;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _index = 0;
  VocabAnswerResult? _result;
  final List<VocabAnswerResult> _results = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _order = List.of(widget.topic.words)..shuffle(Random());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  VocabWord get _current => _order[_index];

  void _submit() {
    if (_result != null) return;
    final result = scoreVocabAnswer(_controller.text, _current.en);
    setState(() => _result = result);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _results.add(result);
      if (_index < _order.length - 1) {
        setState(() {
          _index++;
          _result = null;
          _controller.clear();
        });
        _focusNode.requestFocus();
      } else {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult(context);

    Color borderColor = AppColors.glassBorder;
    Color? fillColor;
    if (_result == VocabAnswerResult.correct) {
      borderColor = AppColors.teal;
      fillColor = AppColors.teal.withValues(alpha: 0.12);
    } else if (_result == VocabAnswerResult.closeTypo) {
      borderColor = AppColors.amber;
      fillColor = AppColors.amber.withValues(alpha: 0.12);
    } else if (_result == VocabAnswerResult.wrong) {
      borderColor = AppColors.pink;
      fillColor = AppColors.pink.withValues(alpha: 0.12);
    }

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
                    children: List.generate(_order.length, (i) {
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
                color: widget.topic.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${topicLabel(ref, widget.topic).toUpperCase()} · ${ref.tr('vocab_question_label')} ${_index + 1}/${_order.length}',
                style: TextStyle(
                  color: widget.topic.color,
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
                    ref.tr('writing_vocab_type_for'),
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(_current.vi, style: AppTextStyles.heading(size: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              enabled: _result == null,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body(size: 16, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: ref.tr('writing_vocab_hint'),
                hintStyle: AppTextStyles.muted(),
                filled: true,
                fillColor: fillColor ?? AppColors.glassFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 10),
              Text(
                switch (_result!) {
                  VocabAnswerResult.correct => ref.tr('writing_result_correct'),
                  VocabAnswerResult.closeTypo =>
                    '${ref.tr('writing_result_close')} — ${_current.en}',
                  VocabAnswerResult.wrong =>
                    '${ref.tr('writing_result_wrong')} — ${_current.en}',
                },
                style: AppTextStyles.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: borderColor,
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('writing_check_button'),
                onTap: _result == null ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final correct = _results
        .where((r) => r == VocabAnswerResult.correct)
        .length;
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
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _results.isEmpty ? 0 : correct / _results.length,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: widget.topic.color,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$correct/${_results.length}',
                        style: AppTextStyles.heading(size: 24)
                            .copyWith(height: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.tr('vocab_correct_count'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(size: 11)
                            .copyWith(height: 1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: _order.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ok =
                      i < _results.length &&
                      _results[i] == VocabAnswerResult.correct;
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
                            '${_order[i].en} — ${_order[i].vi}',
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
