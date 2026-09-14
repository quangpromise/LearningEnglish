import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../pronunciation/data/pronunciation_scoring.dart';
import '../../writing/data/writing_scoring.dart';
import '../../planner/presentation/planner_links.dart';
import '../data/daily_words_repository.dart';
import '../data/vocabulary_data.dart';
import 'daily_words_controller.dart';

/// Danh dau 1 tu da tra loi dung hom nay; neu da on HET tu cua hom nay thi tu
/// tick "Hoan thanh" viec "On tu vung hom nay" trong Lap ke hoach (neu nguoi
/// dung da them viec do vao ke hoach - xem planner_links.dart).
Future<void> _markDailyWordLearned(WidgetRef ref, String en) async {
  await ref.read(dailyWordsControllerProvider.notifier).markLearned(en);
  if (ref.read(dailyWordsControllerProvider).pending.isEmpty) {
    await completeVocabReviewToday(ref);
  }
}

/// Dang cua 1 cau hoi trong luot on - [DailyStudyMode.random] tron ca 3.
enum _QuestionType { quiz, writing, speaking }

/// Diem phat am toi thieu (0-100) de tinh la "noi dung" - voi tu don diem
/// chi la 0 hoac 100; cum nhieu tu (vd "give up") cho phep sai 1 tu khi cum
/// dai tu 4 tu tro len.
const _kSpeakingPassScore = 70;

/// Man on tap "hoc hom nay", mo khi bam vao thong bao nhac (hoac bam "Bat
/// dau hoc" o Ho so) - hoi LAN LUOT TAT CA cac tu DA CHON theo cach on nguoi
/// dung da chon ([DailyStudyMode]):
/// - Quiz = trac nghiem chon 1 trong 4.
/// - Writing = go tu tieng Anh theo nghia, cham bang scoreVocabAnswer giong
///   tinh nang Luyen viet.
/// - Speaking = hien nghia tieng Viet, nguoi dung noi to tu tieng Anh qua mic
///   (co nut nghe phat am mau), cham bang scorePronunciation.
/// - Random = moi cau ngau nhien 1 trong 3 dang tren, chia DEU de ca 3 dang
///   deu xuat hien (khi co tu 3 tu tro len).
/// Tra loi dung chi cap nhat tien do trong ngay.
class DailyQuizPopupScreen extends ConsumerStatefulWidget {
  const DailyQuizPopupScreen({super.key});

  @override
  ConsumerState<DailyQuizPopupScreen> createState() =>
      _DailyQuizPopupScreenState();
}

class _DailyQuizPopupScreenState extends ConsumerState<DailyQuizPopupScreen> {
  List<DailyWordEntry>? _order;
  List<_QuestionType>? _types;
  List<List<String>>? _options;
  int _index = 0;
  final List<bool> _results = [];
  bool _finished = false;
  bool _initialized = false;

  /// 1 phien nhan dien giong noi dung chung cho moi cau Speaking - chi khoi
  /// tao khi luot on thuc su co cau Speaking (tranh xin quyen mic vo ich).
  final stt.SpeechToText _speech = stt.SpeechToText();
  Future<bool>? _speechReady;

  Future<bool> _ensureSpeech() =>
      _speechReady ??= _speech.initialize().catchError((_) => false);

  @override
  void dispose() {
    if (_speechReady != null) _speech.stop();
    super.dispose();
  }

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
    final types = switch (state.mode) {
      DailyStudyMode.writing => List.filled(
        order.length,
        _QuestionType.writing,
      ),
      DailyStudyMode.speaking => List.filled(
        order.length,
        _QuestionType.speaking,
      ),
      // Chia xoay vong quiz/writing/speaking roi xao tron - vd 10 cau ra
      // 4/3/3, dam bao du ca 3 dang thay vi random thuan co the ra toan 1 dang.
      DailyStudyMode.random => [
        for (var i = 0; i < order.length; i++)
          _QuestionType.values[i % _QuestionType.values.length],
      ]..shuffle(rnd),
      DailyStudyMode.quiz ||
      null => List.filled(order.length, _QuestionType.quiz),
    };
    final pool = words.length >= 4
        ? words.map((w) => w.en).toList()
        : kVocabTopics.expand((t) => t.words.map((w) => w.en)).toList();
    _options = order.map((w) {
      final candidates = pool.where((en) => en != w.en).toList()..shuffle(rnd);
      return [w.en, ...candidates.take(3)]..shuffle(rnd);
    }).toList();
    _order = order;
    _types = types;
    if (types.contains(_QuestionType.speaking)) _ensureSpeech();
  }

  /// Tra loi dung ngay luc cham (khong doi bam "Cau tiep") - CHI cap nhat
  /// tien do trong ngay (chip xanh + "3/10" o Ho so), KHONG ghi vao thong ke
  /// "Tu da hoc" toan cuc: viec do de luc bam "Ket thuc hoc" o Ho so (xem
  /// _DailyWordsSection trong profile_screen.dart) de tra loi dung trong luc
  /// LUYEN TAP khong bi tinh la "da hoc that su" cho toi khi nguoi dung tu
  /// ket thuc phien.
  void _onCorrect() => _markDailyWordLearned(ref, _order![_index].en);

  /// Cau hien tai xong (ket qua cuoi cung cua cau) - chuyen sang cau tiep
  /// hoac man tong ket.
  void _onDone(bool correct) {
    if (!mounted || _finished) return;
    setState(() {
      _results.add(correct);
      if (_index < _order!.length - 1) {
        _index++;
      } else {
        _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyWordsControllerProvider);
    _initIfNeeded(state);
    if (!state.loaded) return const ScreenBackground(child: SizedBox.expand());

    final order = _order;
    if (order == null || order.isEmpty) return const _DailyEmptyView();
    if (_finished) return _DailyResultView(order: order, results: _results);

    final word = order[_index];
    final type = _types![_index];
    final isLast = _index == order.length - 1;
    final titleKey = switch (type) {
      _QuestionType.quiz => 'daily_quiz_title',
      _QuestionType.writing => 'daily_writing_title',
      _QuestionType.speaking => 'daily_speaking_title',
    };

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
                '${ref.tr(titleKey).toUpperCase()} · ${ref.tr('vocab_question_label')} ${_index + 1}/${order.length}',
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              // Key theo so cau: moi cau la 1 State moi (xoa lua chon/o nhap/
              // ket qua ghi am cua cau truoc), ke ca 2 cau lien tiep cung dang.
              child: KeyedSubtree(
                key: ValueKey(_index),
                child: switch (type) {
                  _QuestionType.quiz => _QuizQuestion(
                    word: word,
                    options: _options![_index],
                    onCorrect: _onCorrect,
                    onDone: _onDone,
                  ),
                  _QuestionType.writing => _WritingQuestion(
                    word: word,
                    isLast: isLast,
                    onCorrect: _onCorrect,
                    onDone: _onDone,
                  ),
                  _QuestionType.speaking => _SpeakingQuestion(
                    word: word,
                    isLast: isLast,
                    speech: _speech,
                    speechReady: _ensureSpeech(),
                    onCorrect: _onCorrect,
                    onDone: _onDone,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O hien nghia tieng Viet cua tu dang hoi - dung chung cho 3 dang cau.
class _MeaningBox extends StatelessWidget {
  const _MeaningBox({required this.label, required this.vi, this.footer});
  final String label;
  final String vi;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.muted(size: 10).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 6),
          Text(vi, style: AppTextStyles.heading(size: 20)),
          ?footer,
        ],
      ),
    );
  }
}

/// Dang Quiz: trac nghiem chon 1 trong 4, tu qua cau sau 0.7 giay.
class _QuizQuestion extends ConsumerStatefulWidget {
  const _QuizQuestion({
    required this.word,
    required this.options,
    required this.onCorrect,
    required this.onDone,
  });
  final DailyWordEntry word;
  final List<String> options;
  final VoidCallback onCorrect;
  final ValueChanged<bool> onDone;

  @override
  ConsumerState<_QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends ConsumerState<_QuizQuestion> {
  String? _picked;

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    final correct = option == widget.word.en;
    if (correct) widget.onCorrect();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) widget.onDone(correct);
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final picked = _picked;
    final correct = picked != null && picked == word.en;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MeaningBox(label: ref.tr('vocab_choose_word_for'), vi: word.vi),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: widget.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final opt = widget.options[i];
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
                          style: AppTextStyles.body(weight: FontWeight.w700),
                        ),
                      ),
                      // Loa nghe phat am tung dap an - GestureDetector rieng
                      // nen bam vao day CHI phat am, khong chon luon dap an
                      // (khong bi lo dap an dung vi dap an nao cung co loa).
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
          SizedBox(
            width: double.infinity,
            child: Text(
              correct
                  ? ref.tr('daily_quiz_correct')
                  : ref.tr('daily_quiz_wrong'),
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                weight: FontWeight.w800,
                color: correct ? AppColors.teal : AppColors.pink,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Dang Writing: hien nghia tieng Viet, nguoi dung go tu tieng Anh vao o
/// nhap, cham bang scoreVocabAnswer (dung/gan dung do sai chinh ta nhe/sai)
/// - cung cach cham voi WritingVocabQuizScreen cua tinh nang Luyen viet.
/// Nguoi dung tu bam de qua cau tiep sau khi xem ket qua.
class _WritingQuestion extends ConsumerStatefulWidget {
  const _WritingQuestion({
    required this.word,
    required this.isLast,
    required this.onCorrect,
    required this.onDone,
  });
  final DailyWordEntry word;
  final bool isLast;
  final VoidCallback onCorrect;
  final ValueChanged<bool> onDone;

  @override
  ConsumerState<_WritingQuestion> createState() => _WritingQuestionState();
}

class _WritingQuestionState extends ConsumerState<_WritingQuestion> {
  final _controller = TextEditingController();
  VocabAnswerResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_result != null) return;
    final result = scoreVocabAnswer(_controller.text, widget.word.en);
    // Gan dung (chi sai chinh ta nhe) van tinh la dung - giong cap Co ban
    // cua Luyen viet, day la on tap nhanh chu khong phai bai kiem tra.
    if (result != VocabAnswerResult.wrong) widget.onCorrect();
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MeaningBox(label: ref.tr('writing_vocab_type_for'), vi: word.vi),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
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
                  : (widget.isLast
                        ? 'writing_see_result_button'
                        : 'writing_next_button'),
            ),
            onTap: _result == null
                ? _submit
                : () => widget.onDone(_result != VocabAnswerResult.wrong),
          ),
        ),
      ],
    );
  }
}

/// Dang Speaking: hien nghia tieng Viet, nguoi dung noi to tu tieng Anh qua
/// mic, cham bang scorePronunciation (cung cach cham voi Luyen phat am).
/// Nut "Nghe phat am mau" doc tu bang TTS va hien luon tu + IPA de nguoi
/// dung doc theo; tu cung tu hien sau lan noi dau tien. Duoc thu lai nhieu
/// lan - cau tinh la dung neu CO IT NHAT 1 lan dat [_kSpeakingPassScore].
class _SpeakingQuestion extends ConsumerStatefulWidget {
  const _SpeakingQuestion({
    required this.word,
    required this.isLast,
    required this.speech,
    required this.speechReady,
    required this.onCorrect,
    required this.onDone,
  });
  final DailyWordEntry word;
  final bool isLast;
  final stt.SpeechToText speech;
  final Future<bool> speechReady;
  final VoidCallback onCorrect;
  final ValueChanged<bool> onDone;

  @override
  ConsumerState<_SpeakingQuestion> createState() => _SpeakingQuestionState();
}

class _SpeakingQuestionState extends ConsumerState<_SpeakingQuestion> {
  bool? _available;
  bool _listening = false;
  bool _scoring = false;
  bool _revealed = false;
  bool _passed = false;
  String _recognized = '';
  PronunciationScore? _result;
  Completer<void>? _finalResultCompleter;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.speech.errorListener = _handleSttError;
    widget.speech.statusListener = _handleSttStatus;
    widget.speechReady.then((ok) {
      if (mounted) setState(() => _available = ok);
    });
  }

  @override
  void dispose() {
    if (widget.speech.errorListener == _handleSttError) {
      widget.speech.errorListener = null;
    }
    if (widget.speech.statusListener == _handleSttStatus) {
      widget.speech.statusListener = null;
    }
    if (_listening) widget.speech.stop();
    super.dispose();
  }

  void _completeListening() {
    if (!(_finalResultCompleter?.isCompleted ?? true)) {
      _finalResultCompleter!.complete();
    }
  }

  void _handleSttError(SpeechRecognitionError error) => _completeListening();

  /// Mot so nen tang (vd web/Safari) khong tra ve finalResult khi het gio
  /// hoac khong nghe thay gi - dua vao trang thai "done" de khong treo mic.
  void _handleSttStatus(String status) {
    if (status == stt.SpeechToText.doneStatus) _completeListening();
  }

  void _listenSample() {
    AppTts.instance.speak(widget.word.en);
    setState(() => _revealed = true);
  }

  Future<void> _startListening() async {
    if (_available != true || _listening || _scoring) return;
    setState(() {
      _listening = true;
      _result = null;
      _recognized = '';
      _error = null;
    });
    final completer = Completer<void>();
    _finalResultCompleter = completer;
    try {
      await widget.speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() => _recognized = result.recognizedWords);
          if (result.finalResult && !completer.isCompleted) {
            completer.complete();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'en_US',
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _listening = false;
          _error = '${ref.tr('pron_record_failed')} $e';
        });
      }
      return;
    }
    // Tu ket thuc khi nguoi dung ngung noi (pauseFor) hoac het listenFor -
    // khong bat buoc phai bam dung, voi 1 tu don cach nay tu nhien hon.
    await completer.future;
    if (mounted && _listening) await _stopAndScore();
  }

  Future<void> _stopAndScore() async {
    if (!_listening) return;
    setState(() {
      _listening = false;
      _scoring = true;
    });
    final completer = _finalResultCompleter;
    await widget.speech.stop();
    if (completer != null && !completer.isCompleted) {
      await completer.future.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {},
      );
    }
    if (!mounted) return;
    final result = scorePronunciation(
      targetEn: widget.word.en,
      recognized: _recognized,
    );
    final pass = result.score >= _kSpeakingPassScore;
    if (pass && !_passed) widget.onCorrect();
    setState(() {
      _scoring = false;
      _result = result;
      _revealed = true;
      _passed = _passed || pass;
    });
    ref
        .read(statsRepositoryProvider)
        .recordPronunciationScore(result.score, source: 'daily_words')
        .then((_) => ref.invalidate(myStatsProvider))
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final result = _result;
    final pass = result != null && result.score >= _kSpeakingPassScore;
    final resultColor = pass ? AppColors.teal : AppColors.pink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MeaningBox(
          label: ref.tr('daily_speaking_say_for'),
          vi: word.vi,
          footer: _revealed
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: word.en,
                          style: AppTextStyles.body(
                            size: 16,
                            weight: FontWeight.w800,
                            color: AppColors.blue,
                          ),
                        ),
                        if (word.ipa.isNotEmpty)
                          TextSpan(
                            text: '  ${word.ipa}',
                            style: AppTextStyles.muted(size: 13),
                          ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: _listenSample,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.volume_up_rounded,
                    size: 18,
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ref.tr('daily_speaking_listen'),
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_available == false)
                  Text(
                    ref.tr('pron_no_mic'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.muted(),
                  )
                else ...[
                  GestureDetector(
                    onTap: _available != true || _scoring
                        ? null
                        : (_listening ? _stopAndScore : _startListening),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_listening ? AppColors.pink : AppColors.blue)
                                    .withValues(alpha: _scoring ? 0.2 : 0.5),
                            blurRadius: 44,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: _scoring || _available == null
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              _listening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _scoring
                        ? ref.tr('pron_scoring')
                        : _listening
                        ? ref.tr('pron_listening_stop')
                        : ref.tr('pron_tap_to_record'),
                    style: AppTextStyles.muted(),
                  ),
                  if (_listening && _recognized.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _recognized,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(size: 11, color: AppColors.pink),
                  ),
                ],
                if (result != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: resultColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: resultColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${result.score}%',
                          style: AppTextStyles.heading(size: 22)
                              .copyWith(color: resultColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.tr(
                                  pass
                                      ? 'daily_speaking_pass'
                                      : 'daily_speaking_fail',
                                ),
                                style: AppTextStyles.body(
                                  size: 13,
                                  weight: FontWeight.w800,
                                  color: resultColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ref.tr('daily_speaking_you_said')} ${_recognized.trim().isEmpty ? ref.tr('daily_speaking_nothing_heard') : _recognized}',
                                style: AppTextStyles.muted(size: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            // Chua noi lan nao (hoac khong co mic) van cho qua cau - tinh la
            // chua dung, tranh ket cung trong luot on tron (Random).
            label: ref.tr(
              result == null && !_passed
                  ? 'daily_skip_button'
                  : (widget.isLast
                        ? 'writing_see_result_button'
                        : 'writing_next_button'),
            ),
            filled: result != null || _passed,
            onTap: _listening || _scoring ? null : () => widget.onDone(_passed),
          ),
        ),
      ],
    );
  }
}

/// Nut dong + thanh tien do chia o theo so cau.
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

/// Man tong ket cuoi luot on - dung chung cho moi cach on.
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
