import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/daily_words_repository.dart';
import '../data/vocabulary_data.dart';
import 'daily_words_controller.dart';

/// Man hinh quiz, mo khi bam vao thong bao nhac "hoc hom nay" (hoac bam
/// "Bat dau hoc" o Ho so) - hoi LAN LUOT TAT CA cac tu DA CHON (khong loc
/// bot tu da tung tra loi dung truoc do - moi lan mo deu hoi du danh sach),
/// giong nhu VocabularyQuizScreen. Tra loi DUNG se ghi vao thong ke "Tu da
/// hoc" o Ho so (khong anh huong lan hoi ke tiep - tu do van tiep tuc duoc
/// hoi lai o cac lan nhac sau, giup on lap lai xuyen suot ngay).
class DailyQuizPopupScreen extends ConsumerStatefulWidget {
  const DailyQuizPopupScreen({super.key});

  @override
  ConsumerState<DailyQuizPopupScreen> createState() =>
      _DailyQuizPopupScreenState();
}

class _DailyQuizPopupScreenState extends ConsumerState<DailyQuizPopupScreen> {
  List<DailyWordEntry>? _order;
  List<List<String>>? _options;
  int _index = 0;
  String? _picked;
  final List<bool> _results = [];
  bool _finished = false;
  bool _initialized = false;

  void _initIfNeeded(DailyWordsState state) {
    if (_initialized) return;
    _initialized = true;
    final words = state.words;
    if (words.isEmpty) return;
    final rnd = Random();
    final order = List.of(words)..shuffle(rnd);
    final pool = state.words.length >= 4
        ? state.words.map((w) => w.en).toList()
        : kVocabTopics.expand((t) => t.words.map((w) => w.en)).toList();
    final options = order.map((w) {
      final candidates = pool.where((en) => en != w.en).toList()..shuffle(rnd);
      final opts = [w.en, ...candidates.take(3)]..shuffle(rnd);
      return opts;
    }).toList();
    _order = order;
    _options = options;
  }

  DailyWordEntry get _current => _order![_index];

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    final correct = option == _current.en;
    if (correct) {
      ref.read(dailyWordsControllerProvider.notifier).markLearned(_current.en);
      ref
          .read(statsRepositoryProvider)
          .recordWordLearned(_current.en)
          .then((_) => ref.invalidate(myStatsProvider))
          .catchError((_) {});
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _results.add(correct);
      if (_index < _order!.length - 1) {
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
    final state = ref.watch(dailyWordsControllerProvider);
    _initIfNeeded(state);

    final order = _order;
    if (order == null || order.isEmpty) {
      return ScreenBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.teal,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  ref.tr('daily_quiz_empty'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(weight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                PillButton(
                  label: ref.tr('daily_quiz_close'),
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_finished) return _buildResult(context, order);

    final options = _options![_index];
    final word = _current;
    final picked = _picked;
    final correct = picked != null && picked == word.en;

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
                    children: List.generate(order.length, (i) {
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
                color: AppColors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${ref.tr('daily_quiz_title').toUpperCase()} · ${ref.tr('vocab_question_label')} ${_index + 1}/${order.length}',
                style: const TextStyle(
                  color: AppColors.purple,
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
                  Text(word.vi, style: AppTextStyles.heading(size: 20)),
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
                  final isPicked = picked == opt;
                  final isCorrect = opt == word.en;
                  Color bg = AppColors.glassFill;
                  Color border = AppColors.glassBorder;
                  if (picked != null && isCorrect) {
                    bg = AppColors.teal.withValues(alpha: 0.16);
                    border = AppColors.teal.withValues(alpha: 0.5);
                  } else if (picked != null && isPicked && !isCorrect) {
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
            if (picked != null) ...[
              const SizedBox(height: 12),
              Text(
                correct
                    ? ref.tr('daily_quiz_correct')
                    : ref.tr('daily_quiz_wrong'),
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  weight: FontWeight.w800,
                  color: correct ? AppColors.teal : AppColors.pink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, List<DailyWordEntry> order) {
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
                      color: AppColors.purple,
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
                itemCount: order.length,
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
                            '${order[i].en} — ${order[i].vi}',
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
                label: ref.tr('daily_quiz_close'),
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
