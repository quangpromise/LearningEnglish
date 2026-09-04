// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'exercise_model.dart';
import 'workout_repository.dart';

/// Nghi mac dinh giua cac set - dung 1 gia tri co dinh cho ca buoi (khong
/// doc rieng tu tung bai tap) giong dung hanh vi runtime that su cua FitViet
/// (Gate 10's post-review fix: estimator/logic dung hang so nay, khong phai
/// suggestedRestSeconds cua tung bai).
const kDefaultRestSeconds = 60;

/// Mac dinh muc ta khi bai tap chua tung duoc log lan nao - port dung gia
/// tri cua FitViet (`ProgramDayWorkoutPlanner`).
const kDefaultRecommendedWeightKg = 20.0;

/// 1 bai tap trong buoi tap hom nay, kem gia tri "goi y" tra ve tu
/// [WorkoutRepository.getRecommendedWeight] - da RESOLVE xong truoc khi vao
/// man log (khong tu goi lai repository giua chung buoi tap).
class WorkoutExerciseBlock {
  const WorkoutExerciseBlock({
    required this.exercise,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.recommendedWeightKg,
  });

  final Exercise exercise;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final double recommendedWeightKg;
}

enum WorkoutPhase { logging, resting, finished }

/// May trang thai 1 buoi tap - port tu WorkoutViewModel cua FitViet (Gate 4):
/// log 1 set -> nghi (dem nguoc, +15s/bo qua) -> set tiep theo -> het bai
/// tap cuoi -> finished. CHI la state cuc bo cua 1 man hinh (khong phai
/// Riverpod provider toan cuc) - dung y cach AiVoiceChatScreen tu quan state
/// phuc tap cua no.
class WorkoutController extends ChangeNotifier {
  // Khong dung initializing formal (this._repository/this._userId) - ten
  // tham so se phai trung ten field RIENG TU, khien noi goi khac file
  // (workout_session_screen.dart) khong the truyen tham so do qua ten
  // (privacy cua Dart chan tham chieu ten bat dau bang "_" tu library
  // khac). Giu ten tham so cong khai (repository/userId) roi tu gan vao
  // field rieng tu trong initializer list ben duoi la cach dung.
  WorkoutController({
    required this.blocks,
    required WorkoutRepository repository,
    required String userId,
    this.programId,
  }) : _repository = repository,
       _userId = userId,
       _startedAt = DateTime.now();

  final List<WorkoutExerciseBlock> blocks;
  final int? programId;
  final WorkoutRepository _repository;
  final String _userId;
  final DateTime _startedAt;

  int? _sessionId;
  Timer? _restTimer;

  int currentExerciseIndex = 0;
  int currentSetIndex = 0;
  WorkoutPhase phase = WorkoutPhase.logging;
  int restSecondsRemaining = 0;

  /// Gia tri dang chinh bang stepper cho set HIEN TAI - khoi tao lai moi khi
  /// chuyen sang 1 set/bai tap moi (xem _resetInputsForCurrentSet()).
  double currentWeightKg = kDefaultRecommendedWeightKg;
  int currentReps = 0;

  double totalVolumeKg = 0;
  int totalSetsLogged = 0;

  WorkoutExerciseBlock get currentBlock => blocks[currentExerciseIndex];
  bool get isLastExercise => currentExerciseIndex == blocks.length - 1;
  bool get isLastSetOfExercise =>
      currentSetIndex == currentBlock.targetSets - 1;

  Future<void> start() async {
    _sessionId = await _repository.startSession(
      userId: _userId,
      programId: programId,
    );
    _resetInputsForCurrentSet();
    notifyListeners();
  }

  void _resetInputsForCurrentSet() {
    currentWeightKg = currentBlock.recommendedWeightKg;
    currentReps = currentBlock.targetRepsMin;
  }

  void adjustWeight(double delta) {
    currentWeightKg = (currentWeightKg + delta).clamp(0, 500);
    notifyListeners();
  }

  void adjustReps(int delta) {
    currentReps = (currentReps + delta).clamp(0, 100);
    notifyListeners();
  }

  /// Ghi nhan set hien tai la xong - luu xuong Supabase NGAY (khong doi den
  /// cuoi buoi moi ghi hang loat) de khong mat du lieu neu app bi thoat giua
  /// chung, dung y triet ly cua SetLogEntity trong FitViet.
  Future<void> completeSet() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    await _repository.logSet(
      sessionId: sessionId,
      userId: _userId,
      exerciseId: currentBlock.exercise.id,
      setIndex: currentSetIndex,
      weightKg: currentWeightKg,
      reps: currentReps,
    );
    totalVolumeKg += currentWeightKg * currentReps;
    totalSetsLogged++;

    if (isLastSetOfExercise) {
      if (isLastExercise) {
        await _finish();
        return;
      }
      currentExerciseIndex++;
      currentSetIndex = 0;
      _resetInputsForCurrentSet();
      phase = WorkoutPhase.logging;
      notifyListeners();
      return;
    }

    currentSetIndex++;
    _resetInputsForCurrentSet();
    _startRest();
  }

  void _startRest() {
    phase = WorkoutPhase.resting;
    restSecondsRemaining = kDefaultRestSeconds;
    notifyListeners();
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      restSecondsRemaining--;
      if (restSecondsRemaining <= 0) {
        _endRest();
      } else {
        notifyListeners();
      }
    });
  }

  void addRestSeconds(int seconds) {
    if (phase != WorkoutPhase.resting) return;
    restSecondsRemaining += seconds;
    notifyListeners();
  }

  void skipRest() => _endRest();

  void _endRest() {
    _restTimer?.cancel();
    _restTimer = null;
    phase = WorkoutPhase.logging;
    restSecondsRemaining = 0;
    notifyListeners();
  }

  Future<void> _finish() async {
    _restTimer?.cancel();
    final sessionId = _sessionId;
    phase = WorkoutPhase.finished;
    notifyListeners();
    if (sessionId == null) return;
    await _repository.finishSession(
      sessionId: sessionId,
      totalVolumeKg: totalVolumeKg,
      durationSeconds: DateTime.now().difference(_startedAt).inSeconds,
    );
  }

  Duration get elapsed => DateTime.now().difference(_startedAt);

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
