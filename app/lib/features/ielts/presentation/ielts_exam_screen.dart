import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/ielts_models.dart';
import '../data/ielts_scoring.dart';
import 'ielts_group_instruction_banner.dart';
import 'ielts_listening_player.dart';
import 'ielts_passage_view.dart';
import 'ielts_question_view.dart';
import 'ielts_result_screen.dart';

/// Man lam bai chinh - mirror toeic_exam_screen.dart: 1 instance duy nhat
/// lap qua flat list bang `_index`. Khac TOEIC o 2 diem: (1) `_picked` la
/// `Map<String, dynamic>` vi gia tri co the la int (multipleChoice) hoac
/// String (shortAnswer), phan biet qua `q.answerType`; (2) Reading dem
/// nguoc 60 phut (dung that cua IELTS, khac 75 phut cua TOEIC).
class IeltsExamScreen extends ConsumerStatefulWidget {
  const IeltsExamScreen({super.key, required this.test, required this.mode});

  final IeltsTest test;

  /// 'practice' hoac 'exam'.
  final String mode;

  @override
  ConsumerState<IeltsExamScreen> createState() => _IeltsExamScreenState();
}

class _IeltsExamScreenState extends ConsumerState<IeltsExamScreen> {
  static const _readingDurationSeconds = 60 * 60;

  int _index = 0;
  final Map<String, dynamic> _picked = {};

  /// Cau shortAnswer da duoc nguoi dung bam "Kiem tra" (chi Luyen tap) -
  /// TACH RIENG khoi `_picked.containsKey` vi `_picked` cho shortAnswer
  /// duoc cap nhat theo TUNG KY TU go (onChanged), khong the dung truc tiep
  /// de quyet dinh "da tra loi xong chua" nhu multipleChoice (chon 1 lan la
  /// xong ngay).
  final Set<String> _checkedShortAnswer = {};

  late final DateTime _startedAt;
  bool _submitting = false;

  Timer? _readingTimer;
  int _readingSecondsRemaining = _readingDurationSeconds;
  Timer? _listeningTimer;
  int _listeningElapsedSeconds = 0;

  IeltsQuestion get _current => widget.test.questions[_index];
  IeltsQuestion? get _previous =>
      _index > 0 ? widget.test.questions[_index - 1] : null;
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

  /// Chi ap dung Thi thu - Listening dem XUOI (mo phong gan dung, khong
  /// phai dem nguoc dung tung giay im lang thuc te cua bang ghi am that ma
  /// app nay khong co), Reading dem nguoc 60 phut va tu dong nop bai khi
  /// het gio, giong cach TOEIC da lam voi 75 phut.
  void _handleSectionTimers() {
    if (!_isExam) return;
    if (_current.section.skill == IeltsSkill.listening) {
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
          _submit();
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

  void _onPickOption(int optionIndex) {
    setState(() => _picked[_current.id] = optionIndex);
  }

  void _onChangeShortAnswer(String value) {
    setState(() => _picked[_current.id] = value);
  }

  void _checkShortAnswer() {
    setState(() => _checkedShortAnswer.add(_current.id));
  }

  String _audioGroupKey(IeltsQuestion q) => q.audioScriptId ?? q.id;

  double? _pitchForSpeaker(int speakerIndex) => switch (speakerIndex) {
    0 => AppTts.pitchNarrator,
    1 => AppTts.pitchSpeakerA,
    2 => AppTts.pitchSpeakerB,
    _ => AppTts.pitchNarrator,
  };

  List<IeltsAudioSegment> _segmentsFor(IeltsQuestion q) {
    final script = widget.test.audioScripts[q.audioScriptId];
    if (script == null) return const [];
    return [
      for (final line in script.lines)
        (text: line.textEn, pitch: _pitchForSpeaker(line.speakerIndex)),
    ];
  }

  bool get _canGoNext {
    if (!_isExam) return true;
    if (_current.section.skill == IeltsSkill.listening) {
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

  bool _isQuestionCorrect(IeltsQuestion q) {
    final value = _picked[q.id];
    if (value == null) return false;
    if (q.answerType == IeltsAnswerType.multipleChoice) {
      return value == q.correctIndex;
    }
    return isShortAnswerCorrect(value as String, q.acceptedAnswers);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    _readingTimer?.cancel();
    _listeningTimer?.cancel();
    AppTts.instance.stopSpeaking();

    final listeningQs = widget.test.listeningQuestions;
    final readingQs = widget.test.readingQuestions;
    final listeningCorrect = listeningQs.where(_isQuestionCorrect).length;
    final readingCorrect = readingQs.where(_isQuestionCorrect).length;
    final bandListening = rawToBandScore(listeningCorrect, listeningQs.length);
    final bandReading = rawToBandScore(readingCorrect, readingQs.length);
    final bandOverall = ((bandListening + bandReading) / 2 * 2).round() / 2;
    final durationSeconds = DateTime.now().difference(_startedAt).inSeconds;

    ref
        .read(ieltsAttemptRepositoryProvider)
        .saveAttempt(
          testId: widget.test.id,
          mode: widget.mode,
          listeningCorrect: listeningCorrect,
          listeningTotal: listeningQs.length,
          readingCorrect: readingCorrect,
          readingTotal: readingQs.length,
          bandListening: bandListening,
          bandReading: bandReading,
          bandOverall: bandOverall,
          durationSeconds: durationSeconds,
        )
        .catchError((_) {});

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => IeltsResultScreen(
          test: widget.test,
          picked: Map.of(_picked),
          listeningCorrect: listeningCorrect,
          listeningTotal: listeningQs.length,
          readingCorrect: readingCorrect,
          readingTotal: readingQs.length,
          bandListening: bandListening,
          bandReading: bandReading,
          bandOverall: bandOverall,
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
    final pickedString = picked is String ? picked : null;
    final isShortAnswerQuestion = q.answerType == IeltsAnswerType.shortAnswer;
    final shortAnswerChecked = _checkedShortAnswer.contains(q.id);
    final answeredInPractice =
        !_isExam &&
        (isShortAnswerQuestion ? shortAnswerChecked : picked != null);
    final isCorrect = answeredInPractice ? _isQuestionCorrect(q) : false;
    final showInstructionBanner =
        q.groupInstructionEn != null &&
        q.groupInstructionEn != _previous?.groupInstructionEn;

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
                        q.section.skill == IeltsSkill.reading
                            ? 'Reading Passage ${q.section.displayNumber}'
                            : 'Listening Section ${q.section.displayNumber}',
                        style: AppTextStyles.heading(size: 15),
                      ),
                      Text(
                        ref.tr(q.section.descriptionKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(size: 10.5),
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
                          q.section.skill == IeltsSkill.reading
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
                    if (q.section.skill == IeltsSkill.listening) ...[
                      IeltsListeningPlayer(
                        key: ValueKey(_audioGroupKey(q)),
                        segments: _segmentsFor(q),
                        autoPlay: _isExam,
                        allowReplay: !_isExam,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (q.passageId != null) ...[
                      IeltsPassageView(
                        passage: widget.test.passages[q.passageId]!,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (showInstructionBanner) ...[
                      IeltsGroupInstructionBanner(
                        instructionEn: q.groupInstructionEn!,
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
                    if (q.answerType == IeltsAnswerType.multipleChoice)
                      IeltsOptionsList(
                        options: q.options,
                        correctIndex: q.correctIndex!,
                        pickedIndex: picked as int?,
                        showFeedback: !_isExam,
                        onPick: _onPickOption,
                      )
                    else
                      IeltsShortAnswerField(
                        key: ValueKey(q.id),
                        initialValue: pickedString,
                        isCorrect: (!_isExam && shortAnswerChecked)
                            ? isShortAnswerCorrect(
                                pickedString ?? '',
                                q.acceptedAnswers,
                              )
                            : null,
                        showFeedback: !_isExam,
                        locked: !_isExam && shortAnswerChecked,
                        onChanged: _onChangeShortAnswer,
                      ),
                    if (answeredInPractice) ...[
                      const SizedBox(height: 14),
                      IeltsExplanationCard(
                        explanationVi: q.explanationVi,
                        isCorrect: isCorrect,
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
                    ] else if (!_isExam && isShortAnswerQuestion) ...[
                      const SizedBox(height: 14),
                      PillButton(
                        label: ref.tr('ielts_check_answer'),
                        onTap: (pickedString?.trim().isNotEmpty ?? false)
                            ? _checkShortAnswer
                            : null,
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
