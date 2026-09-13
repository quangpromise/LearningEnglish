import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../vocabulary/data/vocab_level_filter.dart';
import '../../vocabulary/data/vocabulary_data.dart';
import '../data/writing_scoring.dart';

/// Vong go tu tieng Anh theo nghia tieng Viet - hien Y NGHIA (VocabWord.vi),
/// nguoi dung go dap an tieng Anh vao 1 TextField (khac
/// VocabularyQuizScreen: cai do la trac nghiem chon 1 trong 4). Cham diem
/// bang scoreVocabAnswer (chinh xac/gan dung do loi chinh ta nhe/sai han) -
/// tu dong chuyen cau sau 900ms roi hien ket qua cuoi vong (mirror timing +
/// bo cuc man ket qua cua VocabularyQuizScreen).
class WritingVocabQuizScreen extends ConsumerStatefulWidget {
  const WritingVocabQuizScreen({
    super.key,
    required this.topic,
    required this.onClose,
    required this.onFinishToTopics,
  });

  final VocabTopic topic;

  /// Nut dong (X) - quay ve luoi chu de.
  final VoidCallback onClose;

  /// Bam "Done" sau khi lam xong - thoat het luong Tu vung, ve man chon
  /// che do Luyen viet (giu dung hanh vi cu: pop 2 lan tu Quiz se vuot qua
  /// ca man chon chu de, khong dung lai o do).
  final VoidCallback onFinishToTopics;

  @override
  ConsumerState<WritingVocabQuizScreen> createState() =>
      _WritingVocabQuizScreenState();
}

class _WritingVocabQuizScreenState
    extends ConsumerState<WritingVocabQuizScreen> {
  late final List<VocabWord> _order;

  /// Cap hoc chot luc mo vong (doi cap giua chung khong anh huong vong dang
  /// lam) - null = Tu hoc, giu nguyen hanh vi cu (ca chu de, khong goi y).
  late final LearnerLevel? _level;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _index = 0;
  VocabAnswerResult? _result;
  final List<VocabAnswerResult> _results = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _level = ref.read(learnerLevelProvider);
    final words = List.of(wordsForLevel(widget.topic, _level))
      ..shuffle(Random());
    // So tu moi vong theo cap (xem docs/research-level-based-content.md muc
    // 4a) - truoc day bat go ca ~100 tu cua chu de trong 1 vong.
    final perRound = switch (_level) {
      null => words.length,
      LearnerLevel.basic => 10,
      LearnerLevel.intermediate => 15,
      LearnerLevel.advanced => 20,
    };
    _order = words.take(perRound).toList();
    // Chu de khong con tu nao o cap nay (ly thuyet khong xay ra vi luoi chu
    // de da an chu de qua it tu) - vao thang man ket qua thay vi loi index.
    _finished = _order.isEmpty;
  }

  /// Goi y theo cap: Co ban = chu cai dau + so ky tu, Trung cap = so ky tu,
  /// Nang cao/Tu hoc = khong goi y.
  String? _hintFor(VocabWord word) {
    final letters = word.en.replaceAll(RegExp(r'[^A-Za-z]'), '').length;
    return switch (_level) {
      LearnerLevel.basic =>
        ref
            .tr('writing_vocab_hint_letters')
            .replaceFirst('{hint}', '${word.en[0]}...')
            .replaceFirst('{count}', '$letters'),
      LearnerLevel.intermediate =>
        ref.tr('writing_vocab_hint_count').replaceFirst('{count}', '$letters'),
      _ => null,
    };
  }

  /// Cap Co ban: sai chinh ta nhe (closeTypo) van tinh la dung khi cham
  /// tong ket - nguoi moi hay go thieu/du 1 chu, khong nen bi tru diem.
  bool _countsAsCorrect(VocabAnswerResult r) =>
      r == VocabAnswerResult.correct ||
      (_level == LearnerLevel.basic && r == VocabAnswerResult.closeTypo);

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
    setState(() {
      _result = result;
      _results.add(result);
    });
  }

  /// Nguoi dung tu bam de chuyen cau (khong con tu dong chuyen sau khi
  /// cham) - theo yeu cau: xem xong ket qua/giai thich roi moi qua cau moi.
  void _next() {
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
                  onTap: widget.onClose,
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
                  if (_hintFor(_current) case final hint?) ...[
                    const SizedBox(height: 8),
                    Text(
                      hint,
                      style: AppTextStyles.muted(size: 12)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
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
                label: ref.tr(
                  _result == null
                      ? 'writing_check_button'
                      : (_index < _order.length - 1
                            ? 'writing_next_button'
                            : 'writing_see_result_button'),
                ),
                onTap: _result == null ? _submit : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final correct = _results.where(_countsAsCorrect).length;
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
                      i < _results.length && _countsAsCorrect(_results[i]);
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
                onTap: widget.onFinishToTopics,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
