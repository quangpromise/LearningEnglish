import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/daily_words_repository.dart';
import '../data/vocabulary_data.dart';
import 'daily_words_controller.dart';

/// Man hinh quiz 1 cau, mo khi bam vao thong bao nhac "hoc hom nay" - hoi 1
/// tu NGAU NHIEN trong danh sach tu con dang cho hoc (chua tra loi dung lan
/// nao trong ngay). Tra loi DUNG moi tinh la "da hoc" (ghi vao thong ke Ho
/// so) - tra sai thi tu do van o lai danh sach, se duoc hoi lai o lan nhac
/// sau.
class DailyQuizPopupScreen extends ConsumerStatefulWidget {
  const DailyQuizPopupScreen({super.key});

  @override
  ConsumerState<DailyQuizPopupScreen> createState() =>
      _DailyQuizPopupScreenState();
}

class _DailyQuizPopupScreenState extends ConsumerState<DailyQuizPopupScreen> {
  DailyWordEntry? _word;
  List<String>? _options;
  String? _picked;
  bool _initialized = false;

  void _initIfNeeded(DailyWordsState state) {
    if (_initialized) return;
    _initialized = true;
    final pending = state.pending;
    if (pending.isEmpty) return;
    final rnd = Random();
    final word = pending[rnd.nextInt(pending.length)];
    final pool = pending.length >= 4
        ? pending.map((w) => w.en).toList()
        : kVocabTopics.expand((t) => t.words.map((w) => w.en)).toList();
    final candidates = pool.where((en) => en != word.en).toList()..shuffle(rnd);
    final options = [word.en, ...candidates.take(3)]..shuffle(rnd);
    _word = word;
    _options = options;
  }

  void _pick(String option) {
    if (_picked != null || _word == null) return;
    setState(() => _picked = option);
    final correct = option == _word!.en;
    if (correct) {
      ref.read(dailyWordsControllerProvider.notifier).markLearned(_word!.en);
      ref
          .read(statsRepositoryProvider)
          .recordWordLearned(_word!.en)
          .then((_) => ref.invalidate(myStatsProvider))
          .catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyWordsControllerProvider);
    _initIfNeeded(state);

    if (_word == null) {
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

    final word = _word!;
    final options = _options!;
    final picked = _picked;
    final correct = picked != null && picked == word.en;

    return PopScope(
      canPop: true,
      child: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.tr('daily_quiz_title'),
                    style: AppTextStyles.heading(size: 17),
                  ),
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
                ],
              ),
              const SizedBox(height: 20),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: ref.tr('daily_quiz_close'),
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
