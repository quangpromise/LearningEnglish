import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/utils/keep_screen_on.dart';
import '../data/gym_vocabulary.dart';
import '../data/workout_model.dart';
import '../data/workout_prefs.dart';
import 'exercise_photo_animator.dart';
import 'rest_vocab_card.dart';
import 'workout_finished_screen.dart';

/// Man log truc tiep 1 buoi tap - port tu WorkoutViewModel/may trang thai
/// cua FitViet (Gate 4): log 1 set -> nghi (dem nguoc) -> set tiep theo ->
/// het bai tap cuoi -> hoan thanh. Toan bo state chi song trong man hinh nay
/// qua [WorkoutController] (khong phai Riverpod provider toan cuc), dung y
/// cach AiVoiceChatScreen tu quan state phuc tap cua no.
///
/// Thiet ke cho luc DANG TAP (tay ra mo hoi, nhin luot, dien thoai de tren
/// gia ta): so to, nut bam >= 56dp, nut chinh co dinh o day man hinh, giu
/// man hinh sang, rung bao 3-2-1 va khi het gio nghi. Luc nghi hien the
/// "Hoc khi nghi" (tu vung gym tieng Anh) - loi san pham GymTalk.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.blocks, this.programId});
  final List<WorkoutExerciseBlock> blocks;
  final int? programId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

enum _ExitChoice { save, discard }

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  /// Null khi chua dang nhap - man hinh hien trang thai yeu cau dang nhap
  /// thay vi crash (truoc day `currentUser!`).
  WorkoutController? _controller;

  /// Controller da duoc giao cho man tong ket (man do tu dispose).
  bool _handedOff = false;

  bool _learnWhileResting = true;
  GymVocabProgress? _vocab;
  List<GymWord> _words = const [];
  int _wordIndex = 0;
  int _wordsReviewed = 0;

  WorkoutPhase? _lastPhase;
  int? _lastRestSecond;

  /// Nguoi dung da tu chon thoi gian nghi -> khong de tuy chon luu tren may
  /// (doc bat dong bo, co the ve muon) ghi de len.
  bool _restPickedByUser = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null || widget.blocks.isEmpty) return;
    final controller = WorkoutController(
      blocks: widget.blocks,
      outbox: ref.read(workoutOutboxProvider),
      userId: userId,
      programId: widget.programId,
    );
    controller
      ..onRestElapsed = _onRestElapsed
      ..addListener(_onControllerChanged)
      ..start();
    _controller = controller;
    _lastPhase = controller.phase;
    KeepScreenOn.enable();
    _loadPrefsAndWords(controller);
  }

  Future<void> _loadPrefsAndWords(WorkoutController controller) async {
    final prefs = await WorkoutPrefs.load();
    final vocab = await GymVocabProgress.load();
    if (!mounted) return;
    if (!_restPickedByUser) controller.setRestDuration(prefs.restSeconds);
    setState(() {
      _learnWhileResting = prefs.learnWhileResting;
      _vocab = vocab;
      _words = pickGymWords(
        exercises: controller.exercises,
        boxes: vocab.boxes,
        count: 15,
        random: Random(),
      );
    });
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = _controller!;
    final phase = controller.phase;
    if (_lastPhase == WorkoutPhase.resting && phase != WorkoutPhase.resting) {
      // Het nghi (tu nhien/bo qua/hoan tac) -> dung doc tu dang phat do.
      AppTts.instance.stopSpeaking();
      _lastRestSecond = null;
    }
    if (phase == WorkoutPhase.resting) {
      // Rung nhe o 3-2-1 - CHI khi giam dung 1 giay, tranh rung don dap khi
      // app quay lai tu nen (dem nguoc nhay tu 40 xuong 2).
      final second = controller.restSecondsRemaining;
      final previous = _lastRestSecond;
      if (previous != null &&
          second == previous - 1 &&
          second >= 1 &&
          second <= 3) {
        HapticFeedback.selectionClick();
      }
      _lastRestSecond = second;
    }
    _lastPhase = phase;
    if (phase == WorkoutPhase.finished) {
      _goToFinished(controller);
      return;
    }
    setState(() {});
  }

  void _onRestElapsed() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  void _goToFinished(WorkoutController controller) {
    if (_handedOff) return;
    _handedOff = true;
    controller
      ..removeListener(_onControllerChanged)
      ..onRestElapsed = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutFinishedScreen(
          controller: controller,
          wordsReviewed: _wordsReviewed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null && !_handedOff) {
      controller
        ..removeListener(_onControllerChanged)
        ..onRestElapsed = null
        ..dispose();
    }
    KeepScreenOn.disable();
    AppTts.instance.stopSpeaking();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Thao tac
  // ---------------------------------------------------------------------

  String _t(String key) => AppStrings.t(key, ref.read(appLanguageProvider));

  /// Nut X / nut back he thong: hoi truoc khi thoat (truoc day thoat thang,
  /// de lai buoi tap dang do tren server).
  Future<void> _confirmExit() async {
    final controller = _controller;
    if (controller == null) {
      Navigator.of(context).pop();
      return;
    }
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    final sets = controller.totalSetsLogged;
    final choice = await showDialog<_ExitChoice>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          _t('fitness_workout_exit_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          sets == 0
              ? _t('fitness_workout_exit_message_empty')
              : _t('fitness_workout_exit_message')
                    .replaceFirst('{sets}', '$sets'),
          style: AppTextStyles.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_ExitChoice.discard),
            child: Text(
              _t('fitness_workout_exit_discard'),
              style: const TextStyle(
                color: AppColors.pink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (sets > 0)
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitChoice.save),
              child: Text(
                _t('fitness_workout_exit_save'),
                style: const TextStyle(
                  color: AppColors.wealthUp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(_t('fitness_workout_exit_continue')),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted || choice == null) return;
    switch (choice) {
      case _ExitChoice.save:
        // Chuyen phase -> finished, listener tu mo man tong ket.
        controller.finishEarly();
      case _ExitChoice.discard:
        controller.discard();
        Navigator.of(context).pop();
    }
  }

  Future<void> _pickRestDuration() async {
    final controller = _controller;
    if (controller == null) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.bgMid,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('fitness_workout_rest_duration'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final seconds in kRestDurationOptions)
                    ChoiceChip(
                      label: Text('${seconds}s'),
                      selected: seconds == controller.restDurationSeconds,
                      selectedColor: AppColors.fitnessAccent,
                      labelStyle: AppTextStyles.body(
                        size: 16,
                        weight: FontWeight.w800,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      onSelected: (_) =>
                          Navigator.of(sheetContext).pop(seconds),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    _restPickedByUser = true;
    controller.setRestDuration(picked);
    WorkoutPrefs.saveRestSeconds(picked);
  }

  GymWord? get _currentWord =>
      _words.isEmpty ? null : _words[_wordIndex % _words.length];

  void _answerWord({required bool known}) {
    final word = _currentWord;
    if (word == null) return;
    final vocab = _vocab;
    if (vocab != null && known) {
      vocab.markKnown(word);
    } else if (vocab != null) {
      vocab.markLearning(word);
    }
    AppTts.instance.stopSpeaking();
    setState(() {
      _wordsReviewed++;
      if (!known) {
        // Chua nho -> gap lai sau vai the trong CHINH buoi nay.
        final at = min(_wordIndex + 4, _words.length);
        _words = [..._words]..insert(at, word);
      }
      _wordIndex++;
    });
  }

  void _setLearnWhileResting(bool enabled) {
    if (!enabled) AppTts.instance.stopSpeaking();
    setState(() => _learnWhileResting = enabled);
    WorkoutPrefs.saveLearnWhileResting(enabled);
  }

  // ---------------------------------------------------------------------
  // Giao dien
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _SignedOutView(onBack: () => Navigator.of(context).pop());
    }
    final resting = controller.phase == WorkoutPhase.resting;
    final word = _currentWord;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  controller: controller,
                  onClose: _confirmExit,
                  onPickRest: _pickRestDuration,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: resting
                        ? _RestingView(
                            controller: controller,
                            vocabCard: !_learnWhileResting
                                ? _EnableLearnButton(
                                    onTap: () => _setLearnWhileResting(true),
                                  )
                                : word == null
                                ? null
                                : RestVocabCard(
                                    // Moi the 1 key rieng: tu "Chua nho"
                                    // gap lai ngay the sau van bat dau o
                                    // trang thai an nghia.
                                    key: ValueKey(_wordIndex),
                                    word: word,
                                    onKnown: () => _answerWord(known: true),
                                    onStillLearning: () =>
                                        _answerWord(known: false),
                                    onTurnOff: () =>
                                        _setLearnWhileResting(false),
                                  ),
                          )
                        : _LoggingView(controller: controller),
                  ),
                ),
                const SizedBox(height: 12),
                if (resting)
                  Row(
                    children: [
                      Expanded(
                        child: _BigButton(
                          label: ref.tr('fitness_workout_add_rest'),
                          filled: false,
                          onTap: () => controller.addRestSeconds(15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _BigButton(
                          label: ref.tr('fitness_workout_skip_rest'),
                          onTap: controller.skipRest,
                        ),
                      ),
                    ],
                  )
                else
                  _BigButton(
                    label: ref.tr('fitness_workout_complete_set'),
                    icon: Icons.check_rounded,
                    onTap: controller.completeSet,
                  ),
                if (controller.canUndo)
                  TextButton.icon(
                    onPressed: controller.undoLastSet,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      foregroundColor: AppColors.fitnessTextSecondary,
                    ),
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: Text(ref.tr('fitness_workout_undo_set')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.controller,
    required this.onClose,
    required this.onPickRest,
  });
  final WorkoutController controller;
  final VoidCallback onClose;
  final VoidCallback onPickRest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.close_rounded, onTap: onClose),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref
                          .tr('fitness_workout_exercise_progress')
                          .replaceFirst(
                            '{current}',
                            '${controller.groupIndex + 1}',
                          )
                          .replaceFirst(
                            '{total}',
                            '${controller.groups.length}',
                          ),
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                  ),
                  _ElapsedText(controller: controller),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.fitnessDivider,
                  color: AppColors.fitnessAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.timer_outlined, onTap: onPickRest),
      ],
    );
  }
}

/// Dong ho tong thoi gian buoi tap - tu rebuild moi giay, tach rieng de
/// khong phai rebuild ca man hinh.
class _ElapsedText extends StatefulWidget {
  const _ElapsedText({required this.controller});
  final WorkoutController controller;

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.controller.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: AppTextStyles.body(
        weight: FontWeight.w700,
        color: AppColors.fitnessTextSecondary,
      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

class _LoggingView extends ConsumerWidget {
  const _LoggingView({required this.controller});
  final WorkoutController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final block = controller.currentBlock;
    final exercise = block.exercise;
    final lang = ref.watch(appLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExercisePhotoAnimator(
          key: ValueKey(exercise.id),
          assets: exercise.photoAssets,
          height: 170,
        ),
        const SizedBox(height: 14),
        Text(
          exercise.nameFor(lang),
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 24),
        ),
        Text(
          exercise.altNameFor(lang),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(size: 14),
        ),
        const SizedBox(height: 10),
        Center(child: _SetBadge(controller: controller)),
        const SizedBox(height: 6),
        Text(
          ref
              .tr('fitness_workout_target_reps')
              .replaceFirst('{min}', '${block.targetRepsMin}')
              .replaceFirst('{max}', '${block.targetRepsMax}'),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(size: 13),
        ),
        const SizedBox(height: 18),
        _StepperRow(
          label: ref.tr('fitness_workout_weight_kg'),
          value: _formatKg(controller.currentWeightKg),
          onMinus: () => controller.adjustWeight(-2.5),
          onPlus: () => controller.adjustWeight(2.5),
        ),
        const SizedBox(height: 12),
        _StepperRow(
          label: ref.tr('fitness_workout_reps'),
          value: '${controller.currentReps}',
          onMinus: () => controller.adjustReps(-1),
          onPlus: () => controller.adjustReps(1),
        ),
      ],
    );
  }

  /// 20.0 -> "20", 22.5 -> "22.5".
  static String _formatKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
}

class _SetBadge extends ConsumerWidget {
  const _SetBadge({required this.controller});
  final WorkoutController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = controller.isPairedGroup
        ? 'A${controller.pairSubIndex + 1} · '
              '${controller.currentSetNumber}/${controller.currentTotalSets}'
        : ref
              .tr('fitness_workout_set_label')
              .replaceFirst('{current}', '${controller.currentSetNumber}')
              .replaceFirst('{total}', '${controller.currentTotalSets}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fitnessAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 15,
          weight: FontWeight.w800,
          color: AppColors.fitnessAccentBright,
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(weight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 88,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 30),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

/// Nut +/- 56dp (truoc day 36dp - kho bam trung khi tay dang cam ta/ra mo
/// hoi).
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fitnessAccent.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, size: 26, color: AppColors.fitnessAccentBright),
        ),
      ),
    );
  }
}

class _RestingView extends ConsumerWidget {
  const _RestingView({required this.controller, required this.vocabCard});
  final WorkoutController controller;
  final Widget? vocabCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = controller.currentBlock.exercise;
    final vocabCard = this.vocabCard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Center(
          child: _RestRing(
            remaining: controller.restSecondsRemaining,
            total: controller.restTotalSeconds,
            label: ref.tr('fitness_workout_resting'),
          ),
        ),
        const SizedBox(height: 14),
        GlowBox(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: 16,
          child: Row(
            children: [
              Text(
                ref.tr('fitness_workout_next_up'),
                style: AppTextStyles.muted(size: 13),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  next.nameFor(ref.watch(appLanguageProvider)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              _SetBadge(controller: controller),
            ],
          ),
        ),
        if (vocabCard != null) ...[const SizedBox(height: 14), vocabCard],
      ],
    );
  }
}

class _RestRing extends StatelessWidget {
  const _RestRing({
    required this.remaining,
    required this.total,
    required this.label,
  });
  final int remaining;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (remaining / total).clamp(0.0, 1.0);
    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: fraction),
            duration: const Duration(milliseconds: 250),
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.fitnessDivider,
              color: remaining <= 3
                  ? AppColors.fitnessAccentBright
                  : AppColors.fitnessAccent,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$remaining',
                  style: AppTextStyles.heading(size: 56).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(label, style: AppTextStyles.muted(size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnableLearnButton extends ConsumerWidget {
  const _EnableLearnButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.blue,
      ),
      icon: const Icon(Icons.school_rounded, size: 18),
      label: Text(ref.tr('fitness_rest_learn_enable')),
    );
  }
}

/// Nut hanh dong chinh co dinh o day man hinh - cao 60dp, chu to.
class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.onTap,
    this.filled = true,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : AppColors.fitnessAccentBright;
    return Material(
      color: filled
          ? AppColors.fitnessAccent
          : AppColors.fitnessAccent.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 24),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(size: 18)
                      .copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFill,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SignedOutView extends ConsumerWidget {
  const _SignedOutView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: AppColors.fitnessAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  ref.tr('fitness_workout_signed_out'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(size: 15),
                ),
                const SizedBox(height: 20),
                PillButton(
                  label: ref.tr('fitness_workout_go_back'),
                  accentColor: AppColors.fitnessAccent,
                  onTap: onBack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
