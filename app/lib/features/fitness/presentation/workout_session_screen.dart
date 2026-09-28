import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/gymtalk_flags.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/utils/keep_screen_on.dart';
import '../../english_path/data/content_pack.dart';
import '../../english_path/data/english_path_providers.dart';
import '../../english_path/data/english_path_store.dart';
import '../../english_path/data/rest_game.dart';
import '../../english_path/presentation/rest_game_card.dart';
import '../../srs/data/srs_store.dart';
import '../../stats/data/learning_xp_repository.dart';
import '../../today/data/daily_progress_store.dart';
import '../data/coach_script.dart';
import '../data/gym_vocabulary.dart';
import '../data/rep_counter.dart';
import '../data/workout_model.dart';
import '../data/workout_prefs.dart';
import '../data/workout_presentation.dart';
import 'exercise_photo_animator.dart';
import 'rep_camera_screen.dart';
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
  List<GymWord> _words = const [];
  int _wordIndex = 0;
  int _wordsReviewed = 0;

  WorkoutPhase? _lastPhase;
  int? _lastRestSecond;

  /// Rest Game (mac dinh) hay the tu kieu cu - xem WorkoutPrefs.
  RestLearnMode _restMode = RestLearnMode.miniGame;

  /// Cho phep dang Listening trong Rest Game (xem WorkoutPrefs).
  bool _restListening = true;

  /// Phien Rest Game cua lan nghi hien tai (null khi dung the tu / khong co
  /// noi dung lo trinh).
  RestGameSession? _restGame;
  int _restGameCorrect = 0;

  /// Tong XP Rest Game da cong trong buoi (hien o Celebration cuoi buoi).
  int _restGameXpTotal = 0;

  /// Lay san luc initState - [_endRestGame] con chay trong dispose, luc do
  /// khong nen doc provider nua.
  late final LearningXpRepository _xpRepo;

  /// Nguoi dung da tu chon thoi gian nghi -> khong de tuy chon luu tren may
  /// (doc bat dong bo, co the ve muon) ghi de len.
  bool _restPickedByUser = false;

  /// Giong HLV tieng Anh (xem [_coach]).
  bool _coachVoice = true;

  /// Kich ban HLV dan buoi tap theo trinh do nguoi hoc (xem coach_script).
  late final CoachScript _script = CoachScript(
    level: ref.read(learnerLevelProvider),
  );

  /// Set/bai vua duoc HLV gioi thieu - tranh doc lai cung 1 set.
  String? _announcedSetKey;
  bool _prefsLoaded = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _xpRepo = ref.read(learningXpRepositoryProvider);
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
    await SrsStore.instance.ensureLoaded();
    if (!mounted) return;
    if (!_restPickedByUser) controller.setRestDuration(prefs.restSeconds);
    setState(() {
      _prefsLoaded = true;
      _learnWhileResting = prefs.learnWhileResting;
      _coachVoice = prefs.coachVoice;
      _restMode = prefs.restLearnMode;
      _restListening = prefs.restListening;
      _words = pickGymWords(
        exercises: controller.exercises,
        boxes: SrsStore.instance.boxes,
        count: 15,
        random: Random(),
      );
    });
    // Gioi thieu bai + set dau tien khi da biet nguoi dung co bat giong HLV.
    if (controller.phase == WorkoutPhase.logging) _announceSet(controller);
  }

  String _setKey(WorkoutController c) =>
      '${c.groupIndex}-${c.setOrRoundIndex}-${c.subIndex}';

  /// HLV doc: (bai moi) gioi thieu bai -> "Set x of y, aim for n reps" ->
  /// 1 nhac ky thuat tu huong dan tieng Anh cua bai.
  void _announceSet(WorkoutController controller) {
    // Chua doc xong cai dat (co the nguoi dung da tat giong HLV) -> chua noi.
    if (!_prefsLoaded) return;
    final key = _setKey(controller);
    if (key == _announcedSetKey) return;
    _announcedSetKey = key;
    if (!_coachVoice) return;
    final block = controller.currentBlock;
    final exercise = block.exercise;
    final lines = <String>[
      if (controller.currentSetNumber == 1 && controller.subIndex == 0)
        _script.exerciseIntro(exercise, sets: controller.currentTotalSets),
      _script.setStart(
        setNumber: controller.currentSetNumber,
        totalSets: controller.currentTotalSets,
        repsMin: block.targetRepsMin,
        repsMax: block.targetRepsMax,
      ),
    ];
    final cue = _script.formCue(
      exercise,
      setNumber: controller.currentSetNumber,
    );
    if (cue != null) lines.add(cue);
    AppTts.instance.speak(lines.join(' '));
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = _controller!;
    final phase = controller.phase;
    if (_lastPhase == WorkoutPhase.resting && phase != WorkoutPhase.resting) {
      // Het nghi (tu nhien/bo qua/hoan tac) -> dung doc tu dang phat do.
      TutorialVoice.shared.stop();
      _lastRestSecond = null;
      _endRestGame();
    }
    if (_lastPhase != WorkoutPhase.resting && phase == WorkoutPhase.resting) {
      _startRestGame(controller);
    }
    // Vao set moi (het nghi, bo qua nghi, sang bai B cua sieu set) -> HLV
    // gioi thieu set do.
    if (phase == WorkoutPhase.logging) _announceSet(controller);
    if (_lastPhase != WorkoutPhase.resting && phase == WorkoutPhase.resting) {
      _coach('Nice set! Rest for ${controller.restDurationSeconds} seconds.');
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
      // Giua gio nghi: 1 cau HLV (chi khi TAT the tu - tranh noi chen
      // luc nguoi dung dang nghe tu).
      if (!_learnWhileResting &&
          previous != null &&
          controller.restTotalSeconds >= 40 &&
          previous > controller.restTotalSeconds ~/ 2 &&
          second <= controller.restTotalSeconds ~/ 2) {
        _coach(_script.restMiddle());
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
    // Loi HLV cho set tiep theo do _announceSet doc (listener).
  }

  /// Dem rep bang camera cho set hien tai; so rep dem duoc dien thang vao
  /// o "Reps" (nguoi dung van chinh lai duoc truoc khi bam Hoan thanh set).
  Future<void> _openRepCamera() async {
    final controller = _controller;
    if (controller == null) return;
    final block = controller.currentBlock;
    final pattern = RepPattern.forExercise(block.exercise);
    if (pattern == null) return;
    TutorialVoice.shared.stop();
    final reps = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => RepCameraScreen(
          exercise: block.exercise,
          pattern: pattern,
          targetReps: block.targetRepsMax,
        ),
      ),
    );
    if (!mounted || reps == null || reps <= 0) return;
    controller.adjustReps(reps - controller.currentReps);
  }

  /// "Giong HLV": doc cau nhac TIENG ANH ngan (luyen nghe trong luc tap).
  /// Chi doc khi nguoi dung bat (mac dinh bat, tat trong bang cai dat nghi).
  void _coach(String text) {
    if (_coachVoice) AppTts.instance.speak(text);
  }

  void _goToFinished(WorkoutController controller) {
    if (_handedOff) return;
    _handedOff = true;
    // Vong "Tap" o man Hom nay.
    DailyProgressStore.instance.addWorkout();
    controller
      ..removeListener(_onControllerChanged)
      ..onRestElapsed = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutFinishedScreen(
          controller: controller,
          wordsReviewed: _wordsReviewed,
          restGameXp: _restGameXpTotal,
          // Doc o man tong ket (man nay tat TTS khi dong).
          coachLine: _coachVoice
              ? _script.workoutDone(
                  sets: controller.totalSetsLogged,
                  words: _wordsReviewed,
                )
              : null,
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
    TutorialVoice.shared.stop();
    _endRestGame();
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
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setSheetState) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _coachVoice,
                  activeThumbColor: AppColors.fitnessAccent,
                  title: Text(
                    _t('fitness_coach_voice'),
                    style: AppTextStyles.body(weight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    _t('fitness_coach_voice_sub'),
                    style: AppTextStyles.muted(),
                  ),
                  onChanged: (enabled) {
                    setSheetState(() {});
                    setState(() => _coachVoice = enabled);
                    if (!enabled) TutorialVoice.shared.stop();
                    WorkoutPrefs.saveCoachVoice(enabled);
                  },
                ),
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
    final now = DateTime.now();
    SrsStore.instance.review(
      word.key,
      known: known,
      now: now,
      content: word.toSrsCard(now),
    );
    DailyProgressStore.instance.addWordsReviewed();
    TutorialVoice.shared.stop();
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

  // ---------------------------------------------------------------------
  // Rest Game (spec #45)
  // ---------------------------------------------------------------------

  /// Item da choi trong LAN NGHI nay (len lai ke hoach giua chung khong
  /// lap lai cau vua lam).
  final Set<String> _playedThisRest = {};

  /// Dau moi lan nghi: len ke hoach cau hoi vua thoi gian nghi tu Unit dang
  /// hoc + cau on. Chua co noi dung lo trinh -> quay ve the tu.
  void _startRestGame(WorkoutController controller, {bool fresh = true}) {
    if (fresh) _playedThisRest.clear();
    _restGame = null;
    _restGameCorrect = 0;
    if (!_learnWhileResting || _restMode != RestLearnMode.miniGame) return;
    final pack = ref.read(contentPackProvider).valueOrNull;
    if (pack == null) return;
    final now = DateTime.now();
    final src = restGameSources(
      pack,
      ref.read(englishLevelProvider),
      ref.read(englishPathStateProvider),
      dueWords: {
        for (final c in SrsStore.instance.dueCards(now)) c.en.toLowerCase(),
      },
    );
    final plan = planRestGame(
      // Thoi gian CON LAI (bat Rest Game giua chung gio nghi thi it cau hon).
      restSeconds: controller.restSecondsRemaining,
      unitItems: src.unit,
      reviewItems: src.review,
      listeningEnabled: _restListening,
      random: Random(),
      exclude: _playedThisRest,
    );
    if (plan.isNotEmpty) _restGame = RestGameSession(plan);
  }

  /// Het gio nghi: dong phien, cong XP cho cac cau dung (+2 moi cau).
  void _endRestGame() {
    final session = _restGame;
    if (session == null) return;
    session.close();
    _restGame = null;
    final xp = _restGameCorrect * kRestGameXpPerCorrect;
    _restGameCorrect = 0;
    if (xp <= 0) return;
    _restGameXpTotal += xp;
    unawaited(
      _xpRepo
          .addBonusXp(xp)
          .then<void>((_) {})
          .catchError((Object e) => debugPrint('Rest Game XP failed: $e')),
    );
  }

  void _onRestGameAnswer(PracticeItem item, bool correct) {
    _playedThisRest.add(item.id);
    final store = EnglishPathStore.instance;
    if (correct) {
      _restGameCorrect++;
      store.recordCorrect(item.unitId, item.id);
    } else {
      store.recordWrong(item.id);
    }
    final word = _pathWords[item.wordEn];
    if (word != null) {
      final now = DateTime.now();
      SrsStore.instance.review(
        word.en,
        known: correct,
        now: now,
        content: SrsCard(
          key: word.en,
          en: word.en,
          vi: word.vi,
          ipa: word.ipa,
          exampleEn: word.exampleEn,
          exampleVi: word.exampleVi,
          due: now,
        ),
      );
    }
    DailyProgressStore.instance.addWordsReviewed();
  }

  /// Tu vung lo trinh theo `wordEn` (IPA/cau vi du cho the Rest Game) -
  /// dung 1 lan cho moi pack.
  Map<String, PathWord> get _pathWords {
    final pack = ref.read(contentPackProvider).valueOrNull;
    if (pack == null) return const {};
    if (!identical(pack, _pathWordsPack)) {
      _pathWordsPack = pack;
      _pathWordsCache = {
        for (final s in pack.stages)
          for (final u in s.units)
            for (final w in u.words) w.en: w,
      };
    }
    return _pathWordsCache;
  }

  ContentPack? _pathWordsPack;
  Map<String, PathWord> _pathWordsCache = const {};

  /// Bat/tat Listening. Tat: len lai ke hoach cho phan gio nghi con lai
  /// (bo cau da choi) de khong con cau Listening nao phat ra loa. Bat: chi
  /// ap dung tu lan nghi sau.
  void _toggleRestListening() {
    final enabled = !_restListening;
    WorkoutPrefs.saveRestListening(enabled);
    setState(() => _restListening = enabled);
    if (enabled) return;
    TutorialVoice.shared.stop();
    _endRestGame();
    final controller = _controller;
    if (controller != null && controller.phase == WorkoutPhase.resting) {
      _startRestGame(controller, fresh: false);
      setState(() {});
    }
  }

  void _setRestMode(RestLearnMode mode) {
    TutorialVoice.shared.stop();
    setState(() => _restMode = mode);
    WorkoutPrefs.saveRestLearnMode(mode);
    final controller = _controller;
    if (mode == RestLearnMode.miniGame &&
        controller != null &&
        controller.phase == WorkoutPhase.resting) {
      _startRestGame(controller);
    } else {
      _endRestGame();
    }
  }

  void _setLearnWhileResting(bool enabled) {
    if (!enabled) TutorialVoice.shared.stop();
    setState(() => _learnWhileResting = enabled);
    WorkoutPrefs.saveLearnWhileResting(enabled);
    final controller = _controller;
    if (!enabled) {
      _endRestGame();
    } else if (controller != null && controller.phase == WorkoutPhase.resting) {
      _startRestGame(controller);
    }
  }

  // ---------------------------------------------------------------------
  // Giao dien
  // ---------------------------------------------------------------------

  /// The hoc trong luc nghi (Rest Game / the tu / nut bat) - dung chung cho
  /// giao dien cu va ban redesign.
  Widget? _restLearnCard() {
    final word = _currentWord;
    return !_learnWhileResting
        ? _EnableLearnButton(onTap: () => _setLearnWhileResting(true))
        : _restGame != null
        ? RestGameCard(
            key: ObjectKey(_restGame),
            session: _restGame!,
            words: _pathWords,
            onAnswered: _onRestGameAnswer,
            onUseCards: () => _setRestMode(RestLearnMode.cards),
            listeningEnabled: _restListening,
            onToggleListening: _toggleRestListening,
          )
        : word == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RestVocabCard(
                // Moi the 1 key rieng: tu "Chua
                // nho" gap lai ngay the sau van bat
                // dau o trang thai an nghia.
                key: ValueKey(_wordIndex),
                word: word,
                onKnown: () => _answerWord(known: true),
                onStillLearning: () => _answerWord(known: false),
                onTurnOff: () => _setLearnWhileResting(false),
              ),
              if (_restMode == RestLearnMode.cards)
                TextButton.icon(
                  onPressed: () => _setRestMode(RestLearnMode.miniGame),
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: Text(ref.tr('rest_game_use_game')),
                ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _SignedOutView(onBack: () => Navigator.of(context).pop());
    }
    // Ban redesign (spec #70, #79): cung controller/outbox/Rest Game.
    if (kUseRedesign) return _redesignBuild(controller);
    final resting = controller.phase == WorkoutPhase.resting;

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
                            vocabCard: _restLearnCard(),
                          )
                        : _LoggingView(
                            controller: controller,
                            onOpenCamera:
                                RepPattern.forExercise(
                                      controller.currentBlock.exercise,
                                    ) ==
                                    null
                                ? null
                                : _openRepCamera,
                          ),
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

  /// Man buoi tap ban redesign (README §9): header anh + vach tien do bai,
  /// bang hiep, the "Hoc trong luc nghi" (Rest Game san co), nut chinh theo
  /// [sessionAction]. Moi hanh dong van goi dung [WorkoutController].
  Widget _redesignBuild(WorkoutController controller) {
    final t = context.gt;
    final resting = controller.phase == WorkoutPhase.resting;
    final action = sessionAction(
      resting: resting,
      setNumber: controller.currentSetNumber,
      totalSets: controller.currentTotalSets,
      isLastGroup: controller.isLastGroup,
    );
    final learn = _restLearnCard();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GtSessionHeader(
              controller: controller,
              onClose: _confirmExit,
              onPickRest: _pickRestDuration,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: resting
                    ? _RestingView(
                        controller: controller,
                        vocabCard: learn == null
                            ? null
                            : _GtRestLearnFrame(child: learn),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _GtSetsTable(
                            controller: controller,
                            onTick: controller.completeSet,
                          ),
                          const SizedBox(height: 14),
                          _StepperRow(
                            label: ref.tr('fitness_workout_weight_kg'),
                            value: _LoggingView._formatKg(
                              controller.currentWeightKg,
                            ),
                            onMinus: () => controller.adjustWeight(-2.5),
                            onPlus: () => controller.adjustWeight(2.5),
                          ),
                          const SizedBox(height: 10),
                          _StepperRow(
                            label: ref.tr('fitness_workout_reps'),
                            value: '${controller.currentReps}',
                            onMinus: () => controller.adjustReps(-1),
                            onPlus: () => controller.adjustReps(1),
                          ),
                          if (RepPattern.forExercise(
                                controller.currentBlock.exercise,
                              ) !=
                              null)
                            TextButton.icon(
                              onPressed: _openRepCamera,
                              icon: Icon(Icons.videocam_rounded, color: t.red),
                              label: Text(
                                ref.tr('rep_camera_open'),
                                style: GtText.body(t.red),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (resting)
                      Row(
                        children: [
                          Expanded(
                            child: _GtButton(
                              label: ref.tr('fitness_workout_add_rest'),
                              outline: true,
                              onTap: () => controller.addRestSeconds(15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _GtButton(
                              label: ref.tr('fitness_workout_skip_rest'),
                              onTap: controller.skipRest,
                            ),
                          ),
                        ],
                      )
                    else
                      _GtButton(
                        label: switch (action) {
                          SessionAction.finishWorkout => ref.tr(
                            'gt_workout_finish',
                          ),
                          SessionAction.nextExercise => ref.tr(
                            'gt_workout_next_exercise',
                          ),
                          _ =>
                            ref
                                .tr('gt_workout_complete_set')
                                .replaceFirst(
                                  '{n}',
                                  '${controller.currentSetNumber}',
                                )
                                .replaceFirst(
                                  '{total}',
                                  '${controller.currentTotalSets}',
                                ),
                        },
                        onTap: controller.completeSet,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (controller.canUndo)
                          Expanded(
                            child: TextButton.icon(
                              onPressed: controller.undoLastSet,
                              icon: Icon(Icons.undo_rounded, color: t.tx2),
                              label: Text(
                                ref.tr('fitness_workout_undo_set'),
                                style: GtText.body(t.tx2, size: 13),
                              ),
                            ),
                          ),
                        Expanded(
                          child: TextButton(
                            onPressed: _confirmExit,
                            child: Text(
                              ref.tr('gt_workout_end'),
                              style: GtText.body(t.tx2, size: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  const _LoggingView({required this.controller, this.onOpenCamera});
  final WorkoutController controller;

  /// Mo "Dem rep bang camera" - null khi bai nay chua ho tro (plank...).
  final VoidCallback? onOpenCamera;

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
        if (onOpenCamera != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onOpenCamera,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.fitnessAccentBright,
            ),
            icon: const Icon(Icons.videocam_rounded),
            label: Text(ref.tr('rep_camera_open')),
          ),
        ],
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

// ---------------------------------------------------------------------------
// Ban redesign (spec #70, #79)

class _GtSessionHeader extends ConsumerWidget {
  const _GtSessionHeader({
    required this.controller,
    required this.onClose,
    required this.onPickRest,
  });

  final WorkoutController controller;
  final VoidCallback onClose;
  final VoidCallback onPickRest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final exercise = controller.currentBlock.exercise;
    final lang = ref.watch(appLanguageProvider);
    final segments = exerciseSegments(
      count: controller.groups.length,
      currentIndex: controller.groupIndex,
    );
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 240 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0A0A0A)),
          ExercisePhotoAnimator(
            key: ValueKey(exercise.id),
            assets: exercise.photoAssets,
            height: 240 + top,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0xE6000000),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, top + 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundIconButton(icon: Icons.close_rounded, onTap: onClose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          for (final (i, seg) in segments.indexed) ...[
                            if (i > 0) const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: switch (seg) {
                                    SegmentState.done => Colors.white,
                                    SegmentState.current => t.red,
                                    SegmentState.todo =>
                                      Colors.white.withValues(alpha: 0.25),
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${controller.groupIndex + 1}/${controller.groups.length}',
                      style: GtText.body(Colors.white, weight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    _RoundIconButton(
                      icon: Icons.timer_outlined,
                      onTap: onPickRest,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  exercise.altNameFor(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.body(const Color(0xFFD4D6DA), size: 13),
                ),
                Text(
                  exercise.nameFor(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.cardTitle(Colors.white)
                      .copyWith(fontSize: 28, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bang hiep: HIEP / KG / LAN / tick 44dp (README §9). Hiep da xong lay tu
/// [WorkoutController.loggedSetsInCurrentGroup]; hiep dang tap hien gia tri
/// dang chinh, tick = hoan thanh hiep.
class _GtSetsTable extends ConsumerWidget {
  const _GtSetsTable({required this.controller, required this.onTick});

  final WorkoutController controller;
  final VoidCallback onTick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final logged = {
      for (final s in controller.loggedSetsInCurrentGroup) s.set: s,
    };
    final current = controller.currentSetNumber;
    Widget cell(String text, {Color? color, double size = 24}) => Center(
      child: Text(
        text,
        maxLines: 1,
        style: GtText.ringStat(color ?? t.tx).copyWith(fontSize: size),
      ),
    );
    Widget header(String key) => Center(
      child: Text(
        ref.tr(key),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GtText.overline(t.tx3),
      ),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 52, child: header('gt_workout_col_set')),
              Expanded(child: header('gt_workout_col_kg')),
              Expanded(child: header('gt_workout_col_reps')),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 6),
          for (var n = 1; n <= controller.currentTotalSets; n++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: cell('$n', color: t.tx3, size: 18),
                  ),
                  Expanded(
                    child: cell(
                      logged[n] != null
                          ? _LoggingView._formatKg(logged[n]!.weightKg)
                          : n == current
                          ? _LoggingView._formatKg(controller.currentWeightKg)
                          : '-',
                      color: n == current ? t.tx : t.tx2,
                    ),
                  ),
                  Expanded(
                    child: cell(
                      logged[n] != null
                          ? '${logged[n]!.reps}'
                          : n == current
                          ? '${controller.currentReps}'
                          : '-',
                      color: n == current ? t.tx : t.tx2,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: _GtTick(
                      done: logged[n] != null,
                      active:
                          n == current &&
                          controller.phase == WorkoutPhase.logging,
                      onTap: onTick,
                      label: ref.tr('gt_workout_tick_set'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GtTick extends StatelessWidget {
  const _GtTick({
    required this.done,
    required this.active,
    required this.onTap,
    required this.label,
  });

  final bool done;
  final bool active;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Semantics(
      button: active,
      checked: done,
      label: label,
      child: GestureDetector(
        onTap: active ? onTap : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: done ? t.red : (active ? t.s2 : null),
            borderRadius: BorderRadius.circular(14),
            border: done
                ? null
                : Border.all(color: active ? t.red : t.bd, width: 2),
          ),
          child: Icon(
            Icons.check_rounded,
            color: done ? t.onRed : (active ? t.red : t.tx3),
          ),
        ),
      ),
    );
  }
}

/// Khung "HOC TRONG LUC NGHI" (blueT) boc the Rest Game / the tu san co.
class _GtRestLearnFrame extends ConsumerWidget {
  const _GtRestLearnFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.blueT,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ref.tr('gt_workout_learn_overline'),
            style: GtText.overline(t.blue),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _GtButton extends StatelessWidget {
  const _GtButton({
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GtText.rowTitle(outline ? t.tx : t.onRed),
    );
    return SizedBox(
      height: 56,
      child: outline
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: shape,
                side: BorderSide(color: t.bd, width: 2),
              ),
              onPressed: onTap,
              child: text,
            )
          : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: t.red,
                shape: shape,
              ),
              onPressed: onTap,
              child: text,
            ),
    );
  }
}
