import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/toeic_models.dart';
import '../data/toeic_scoring.dart';
import 'toeic_listening_player.dart';
import 'toeic_part_scene_illustration.dart';
import 'toeic_passage_view.dart';
import 'toeic_question_view.dart';
import 'toeic_result_screen.dart';

/// Man lam bai chinh - dung CHUNG 1 instance duy nhat cho ca 200 cau (khong
/// push 1 route rieng cho moi cau), lap qua `test.questions` (flat list)
/// bang 1 chi so `_index`. Ho tro 2 che do:
/// - 'practice' (Luyen tap): chon xong hien dap an+giai thich ngay, khong
///   gioi han gio, tu do di chuyen qua lai.
/// - 'exam' (Thi thu): khong lo dung/sai cho toi khi nop bai; Reading dem
///   nguoc 75 phut (tu dong nop khi het gio); Listening dem XUOI (khong
///   phai dem nguoc chinh xac tung khoang lang cua ETS that - xem comment
///   o _handleSectionTimers) va audio tu phat 1 lan duy nhat, khong the
///   nghe lai.
class ToeicExamScreen extends ConsumerStatefulWidget {
  const ToeicExamScreen({super.key, required this.test, required this.mode});

  final ToeicTest test;

  /// 'practice' hoac 'exam'.
  final String mode;

  @override
  ConsumerState<ToeicExamScreen> createState() => _ToeicExamScreenState();
}

class _ToeicExamScreenState extends ConsumerState<ToeicExamScreen> {
  static const _readingDurationSeconds = 75 * 60;

  int _index = 0;
  final Map<String, int> _picked = {};
  late final DateTime _startedAt;
  bool _submitting = false;

  Timer? _readingTimer;
  int _readingSecondsRemaining = _readingDurationSeconds;
  Timer? _listeningTimer;
  int _listeningElapsedSeconds = 0;

  ToeicQuestion get _current => widget.test.questions[_index];
  bool get _isExam => widget.mode == 'exam';
  bool get _isLastQuestion => _index == widget.test.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _handleSectionTimers();
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _listeningTimer?.cancel();
    AppTts.instance.stopSpeaking();
    super.dispose();
  }

  /// Bat/tat timer dung theo ky nang cua cau HIEN TAI - CHI ap dung Thi thu.
  /// Luu y: Listening dung dong ho dem XUOI (khong phai dem nguoc dung tung
  /// giay im lang thuc te cua ETS - dieu do phu thuoc file am thanh that ma
  /// app nay khong co, chi mo phong bang TTS) de nguoi dung van co cam giac
  /// "khong the tua nhanh", trong khi Reading dem nguoc dung 75 phut giong
  /// de thi that va tu dong nop bai khi het gio.
  void _handleSectionTimers() {
    if (!_isExam) return;
    if (_current.part.skill == ToeicSkill.listening) {
      _readingTimer?.cancel();
      _readingTimer = null;
      _listeningTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _listeningElapsedSeconds++);
      });
    } else {
      _listeningTimer?.cancel();
      _listeningTimer = null;
      _readingTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_readingSecondsRemaining <= 0) {
          _submit(autoSubmitted: true);
        } else {
          setState(() => _readingSecondsRemaining--);
        }
      });
    }
  }

  void _goTo(int newIndex) {
    setState(() => _index = newIndex);
    _handleSectionTimers();
  }

  void _onPick(int optionIndex) {
    setState(() => _picked[_current.id] = optionIndex);
  }

  String _audioGroupKey(ToeicQuestion q) => q.audioScriptId ?? q.id;

  double? _pitchForSpeaker(int speakerIndex) => switch (speakerIndex) {
    0 => AppTts.pitchNarrator,
    1 => AppTts.pitchSpeakerA,
    2 => AppTts.pitchSpeakerB,
    _ => AppTts.pitchNarrator,
  };

  List<ToeicAudioSegment> _segmentsFor(ToeicQuestion q) {
    if (q.audioScriptId != null) {
      final script = widget.test.audioScripts[q.audioScriptId]!;
      return [
        for (final line in script.lines)
          (text: line.textEn, pitch: _pitchForSpeaker(line.speakerIndex)),
      ];
    }
    return [
      if (q.promptEn != null) (text: q.promptEn!, pitch: AppTts.pitchNarrator),
      for (final opt in q.options) (text: opt, pitch: AppTts.pitchNarrator),
    ];
  }

  int _blankNumberFor(ToeicQuestion q) {
    final siblings = widget.test.questions
        .where((x) => x.passageId == q.passageId)
        .toList();
    return siblings.indexOf(q) + 1;
  }

  bool get _canGoNext {
    if (!_isExam) return true;
    if (_current.part.skill == ToeicSkill.listening) {
      return _picked.containsKey(_current.id);
    }
    return true;
  }

  Future<void> _confirmExit() async {
    if (!_isExam) {
      Navigator.of(context).maybePop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgTop,
        title: Text(
          ref.tr('toeic_exit_confirm_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          ref.tr('toeic_exit_confirm_body'),
          style: AppTextStyles.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(ref.tr('toeic_exit_confirm_stay')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              ref.tr('toeic_exit_confirm_leave'),
              style: const TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).maybePop();
  }

  Future<void> _confirmSubmit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgTop,
        title: Text(
          ref.tr('toeic_submit_confirm_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          ref.tr('toeic_submit_confirm_body'),
          style: AppTextStyles.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(ref.tr('toeic_exit_confirm_stay')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(ref.tr('toeic_submit_test')),
          ),
        ],
      ),
    );
    if (ok == true) _submit();
  }

  Future<void> _submit({bool autoSubmitted = false}) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    _readingTimer?.cancel();
    _listeningTimer?.cancel();
    AppTts.instance.stopSpeaking();

    final listeningQs = widget.test.listeningQuestions;
    final readingQs = widget.test.readingQuestions;
    int countCorrect(List<ToeicQuestion> qs) =>
        qs.where((q) => _picked[q.id] == q.correctIndex).length;
    final listeningCorrect = countCorrect(listeningQs);
    final readingCorrect = countCorrect(readingQs);
    final scaledListening = rawToScaledScore(
      listeningCorrect,
      listeningQs.length,
    );
    final scaledReading = rawToScaledScore(readingCorrect, readingQs.length);
    final scaledTotal = scaledListening + scaledReading;
    final durationSeconds = DateTime.now().difference(_startedAt).inSeconds;

    ref
        .read(toeicAttemptRepositoryProvider)
        .saveAttempt(
          testId: widget.test.id,
          mode: widget.mode,
          listeningCorrect: listeningCorrect,
          listeningTotal: listeningQs.length,
          readingCorrect: readingCorrect,
          readingTotal: readingQs.length,
          scaledListening: scaledListening,
          scaledReading: scaledReading,
          scaledTotal: scaledTotal,
          durationSeconds: durationSeconds,
        )
        .catchError((_) {});

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ToeicResultScreen(
          test: widget.test,
          picked: Map.of(_picked),
          listeningCorrect: listeningCorrect,
          listeningTotal: listeningQs.length,
          readingCorrect: readingCorrect,
          readingTotal: readingQs.length,
          scaledListening: scaledListening,
          scaledReading: scaledReading,
          scaledTotal: scaledTotal,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    final picked = _picked[q.id];
    final answeredInPractice = !_isExam && picked != null;

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _confirmExit,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ref.tr('toeic_part_label')} ${q.part.displayNumber}',
                        style: AppTextStyles.heading(size: 15),
                      ),
                      Text(
                        '${ref.tr('toeic_question_label')} ${_index + 1}/${widget.test.questions.length}',
                        style: AppTextStyles.muted(size: 10.5),
                      ),
                    ],
                  ),
                ),
                if (_isExam)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_rounded,
                          size: 14,
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          q.part.skill == ToeicSkill.reading
                              ? _formatDuration(_readingSecondsRemaining)
                              : _formatDuration(_listeningElapsedSeconds),
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q.part == ToeicPartNumber.p1) ...[
                      ToeicPartSceneIllustration(spec: q.illustration!),
                      const SizedBox(height: 14),
                    ],
                    if (q.part.skill == ToeicSkill.listening) ...[
                      ToeicListeningPlayer(
                        key: ValueKey(_audioGroupKey(q)),
                        segments: _segmentsFor(q),
                        autoPlay: _isExam,
                        allowReplay: !_isExam,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (q.passageId != null) ...[
                      ToeicPassageView(
                        passage: widget.test.passages[q.passageId]!,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (q.promptEn != null) ...[
                      GlowBox(
                        borderRadius: 18,
                        child: Text(
                          '"${q.promptEn}"',
                          style: AppTextStyles.heading(size: 15),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (q.part == ToeicPartNumber.p6) ...[
                      Text(
                        'Chỗ trống (${_blankNumberFor(q)})',
                        style: AppTextStyles.muted(
                          size: 10.5,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ToeicOptionsList(
                      options: q.options,
                      correctIndex: q.correctIndex,
                      pickedIndex: picked,
                      showFeedback: !_isExam,
                      onPick: _onPick,
                    ),
                    if (answeredInPractice) ...[
                      const SizedBox(height: 14),
                      ToeicExplanationCard(
                        explanationVi: q.explanationVi,
                        isCorrect: picked == q.correctIndex,
                      ),
                      const SizedBox(height: 16),
                      PillButton(
                        label: _isLastQuestion
                            ? ref.tr('toeic_result_title')
                            : ref.tr('toeic_continue_button'),
                        onTap: () {
                          if (_isLastQuestion) {
                            _submit();
                          } else {
                            _goTo(_index + 1);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_isExam) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: ref.tr('toeic_prev_question'),
                      filled: false,
                      onTap: _index == 0 ? null : () => _goTo(_index - 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PillButton(
                      label: _isLastQuestion
                          ? ref.tr('toeic_submit_test')
                          : ref.tr('toeic_next_question'),
                      onTap: _isLastQuestion
                          ? _confirmSubmit
                          : (_canGoNext ? () => _goTo(_index + 1) : null),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
