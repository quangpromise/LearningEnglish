import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../writing/data/writing_scoring.dart';
import '../data/daily_words_repository.dart';
import '../data/vocabulary_data.dart';
import 'daily_words_controller.dart';

/// Man on tap "hoc hom nay", mo khi bam vao thong bao nhac (hoac bam "Bat
/// dau hoc" o Ho so) - hoi LAN LUOT TAT CA cac tu DA CHON theo cach on nguoi
/// dung da chon ([DailyStudyMode]): Quiz = trac nghiem chon 1 trong 4,
/// Writing = go tu tieng Anh theo nghia, cham bang scoreVocabAnswer giong
/// tinh nang Luyen viet. Tra loi dung chi cap nhat tien do trong ngay.
class DailyQuizPopupScreen extends ConsumerWidget {
  const DailyQuizPopupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(dailyWordsControllerProvider.select((s) => s.mode));
    return mode == DailyStudyMode.writing
        ? const _DailyWritingView()
        : const _DailyQuizView();
  }
}

class _DailyQuizView extends ConsumerStatefulWidget {
  const _DailyQuizView();

  @override
  ConsumerState<_DailyQuizView> createState() => _DailyQuizViewState();
}

class _DailyQuizViewState extends ConsumerState<_DailyQuizView> {
  List<DailyWordEntry>? _order;
  List<List<String>>? _options;
  int _index = 0;
  String? _picked;
  final List<bool> _results = [];
  bool _finished = false;
  bool _initialized = false;

  void _initIfNeeded(DailyWordsState state) {
    if (_initialized) return;
    // Doi provider tai XONG (state.loaded) roi moi "chot" danh sach cau hoi -
    // truoc day chot ngay tu lan build DAU TIEN bat ke da tai xong hay chua,
    // nen truong hop mo Quiz NGAY LUC app vua khoi dong lai tu thong bao
    // (dailyWordsControllerProvider con dang doc SharedPreferences, state.words
    // van dang rong) se bi "dong bang" vinh vien voi danh sach rong - man
    // hinh bao "khong co tu de hoc" du du lieu that load xong ngay sau do.
    if (!state.loaded) return;
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
      // CHI cap nhat tien do trong ngay (danh sach "da tra loi dung hom
      // nay" dung de hien chip xanh + "3/10" o Ho so) - KHONG con ghi ngay
      // vao thong ke "Tu da hoc" TOAN CUC (Words Learned popup) tai day nua.
      // Viec do da chuyen sang luc bam "Ket thuc hoc" o Ho so (xem
      // _DailyWordsSection trong profile_screen.dart) de tra loi dung trong
      // luc dang LUYEN TAP (co the qua nhieu lan nhac trong ngay) khong bi
      // tinh la "da hoc that su" cho toi khi nguoi dung tu ket thuc phien.
      ref.read(dailyWordsControllerProvider.notifier).markLearned(_current.en);
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
    if (order == null || order.isEmpty) return const _DailyEmptyView();

    if (_finished) return _DailyResultView(order: order, results: _results);

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
            _DailyProgressHeader(total: order.length, index: _index),
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
                          // Loa nghe phat am tung dap an - GestureDetector
                          // rieng nen bam vao day CHI phat am, khong chon
                          // luon dap an (khong bi lo dap an dung vi tat ca
                          // dap an deu co loa nhu nhau).
                          SpeakerButton(
                            onTap: () => AppTts.instance.speak(opt),
                            color: AppColors.textMuted,
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
}

/// Che do Writing: hien nghia tieng Viet, nguoi dung go tu tieng Anh vao o
/// nhap, cham bang scoreVocabAnswer (dung/gan dung do sai chinh ta nhe/sai)
/// - cung cach cham voi WritingVocabQuizScreen cua tinh nang Luyen viet.
/// Nguoi dung tu bam de qua cau tiep sau khi xem ket qua.
class _DailyWritingView extends ConsumerStatefulWidget {
  const _DailyWritingView();

  @override
  ConsumerState<_DailyWritingView> createState() => _DailyWritingViewState();
}

class _DailyWritingViewState extends ConsumerState<_DailyWritingView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<DailyWordEntry>? _order;
  int _index = 0;
  VocabAnswerResult? _result;
  final List<bool> _results = [];
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DailyWordEntry get _current => _order![_index];

  void _submit() {
    if (_result != null) return;
    final result = scoreVocabAnswer(_controller.text, _current.en);
    // Gan dung (chi sai chinh ta nhe) van tinh la dung - giong cap Co ban
    // cua Luyen viet, day la on tap nhanh chu khong phai bai kiem tra.
    final ok = result != VocabAnswerResult.wrong;
    if (ok) {
      ref.read(dailyWordsControllerProvider.notifier).markLearned(_current.en);
    }
    setState(() {
      _result = result;
      _results.add(ok);
    });
  }

  void _next() {
    if (_index < _order!.length - 1) {
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
    final state = ref.watch(dailyWordsControllerProvider);
    if (!state.loaded) return const ScreenBackground(child: SizedBox.expand());
    final order = _order ??= List.of(state.words)..shuffle(Random());
    if (order.isEmpty) return const _DailyEmptyView();
    if (_finished) return _DailyResultView(order: order, results: _results);

    final word = _current;
    final (borderColor, fillColor) = switch (_result) {
      VocabAnswerResult.correct => (
        AppColors.teal,
        AppColors.teal.withValues(alpha: 0.12),
      ),
      VocabAnswerResult.closeTypo => (
        AppColors.amber,
        AppColors.amber.withValues(alpha: 0.12),
      ),
      VocabAnswerResult.wrong => (
        AppColors.pink,
        AppColors.pink.withValues(alpha: 0.12),
      ),
      null => (AppColors.glassBorder, AppColors.glassFill),
    };
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor),
    );

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DailyProgressHeader(total: order.length, index: _index),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${ref.tr('daily_writing_title').toUpperCase()} · ${ref.tr('vocab_question_label')} ${_index + 1}/${order.length}',
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
                    ref.tr('writing_vocab_type_for'),
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(word.vi, style: AppTextStyles.heading(size: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              enabled: _result == null,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body(size: 16, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: ref.tr('writing_vocab_hint'),
                hintStyle: AppTextStyles.muted(),
                filled: true,
                fillColor: fillColor,
                border: inputBorder,
                enabledBorder: inputBorder,
                disabledBorder: inputBorder,
              ),
            ),
            if (_result case final result?) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      switch (result) {
                        VocabAnswerResult.correct => ref.tr(
                          'writing_result_correct',
                        ),
                        VocabAnswerResult.closeTypo =>
                          '${ref.tr('writing_result_close')} — ${word.en}',
                        VocabAnswerResult.wrong =>
                          '${ref.tr('writing_result_wrong')} — ${word.en}',
                      },
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                  ),
                  SpeakerButton(
                    onTap: () => AppTts.instance.speak(word.en),
                    color: borderColor,
                  ),
                ],
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr(
                  _result == null
                      ? 'writing_check_button'
                      : (_index < order.length - 1
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
}

/// Nut dong + thanh tien do chia o theo so cau - dung chung cho Quiz/Writing.
class _DailyProgressHeader extends StatelessWidget {
  const _DailyProgressHeader({required this.total, required this.index});
  final int total;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              final done = i <= index;
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
    );
  }
}

class _DailyEmptyView extends ConsumerWidget {
  const _DailyEmptyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

/// Man tong ket cuoi luot on - dung chung cho Quiz/Writing.
class _DailyResultView extends ConsumerWidget {
  const _DailyResultView({required this.order, required this.results});
  final List<DailyWordEntry> order;
  final List<bool> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correct = results.where((r) => r).length;
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
                      value: results.isEmpty ? 0 : correct / results.length,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: AppColors.purple,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$correct/${results.length}',
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
                  final ok = i < results.length && results[i];
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
