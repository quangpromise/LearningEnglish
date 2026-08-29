import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vocabulary_data.dart';

/// Quiz "học từ hôm nay": hiện nghĩa tiếng Việt, chọn từ tiếng Anh đúng
/// trong 4 lựa chọn. Cac tu duoc hoi theo THU TU NGAU NHIEN (khong theo
/// thu tu da chon o man truoc). Sau cau cuoi cung, hien bang ket qua ngay
/// tren cung man hinh nay va DUNG LAI - khong tu dong lam lai/chuyen bai.
class VocabularyQuizScreen extends ConsumerStatefulWidget {
  const VocabularyQuizScreen({
    super.key,
    required this.topic,
    required this.words,
  });

  final VocabTopic topic;
  final List<VocabWord> words;

  @override
  ConsumerState<VocabularyQuizScreen> createState() =>
      _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends ConsumerState<VocabularyQuizScreen> {
  late final List<VocabWord> _order;
  late final List<List<String>> _options;
  int _index = 0;
  String? _picked;
  final List<bool> _results = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _order = List.of(widget.words)..shuffle(rnd);
    // Lay tu gay nhieu (distractor) tu CA chu de hien tai - neu chu de qua
    // it tu (vd chon het < 4 tu), lay bo sung tu toan bo danh sach tu vung.
    final pool = widget.topic.words.length >= 4
        ? widget.topic.words
        : kVocabTopics.expand((t) => t.words).toList();
    _options = _order.map((w) {
      final candidates = pool.where((p) => p.en != w.en).toList()..shuffle(rnd);
      final opts = [w.en, ...candidates.take(3).map((p) => p.en)];
      opts.shuffle(rnd);
      return opts;
    }).toList();
  }

  VocabWord get _current => _order[_index];

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _results.add(option == _current.en);
      if (_index < _order.length - 1) {
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

    final options = _options[_index];
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
                    ref.tr('vocab_choose_word_for'),
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(_current.vi, style: AppTextStyles.heading(size: 20)),
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
                  final isCorrect = opt == _current.en;
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
                itemCount: _order.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ok = i < _results.length && _results[i];
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
                // Dung lai o day theo dung yeu cau - khong tu dong lam lai
                // hay chuyen sang bo tu tiep theo. Quay thang ve man danh
                // sach chu de (bo qua man chi tiet/chon tu vua dung).
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
