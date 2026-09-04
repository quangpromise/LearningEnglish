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
    this.supersetGroup,
  });

  final Exercise exercise;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final double recommendedWeightKg;

  /// 2 bai tap CUNG mot buoi, ke lien tiep nhau, cung mang gia tri nay ->
  /// ghep thanh 1 sieu set (xem [resolveGroupings]). Null nghia la bai
  /// straight-set binh thuong.
  final String? supersetGroup;
}

/// 1 nhom bai tap da duoc "giai quyet" tu danh sach [WorkoutExerciseBlock]
/// phang - port tinh than `ResolvedGrouping` cua FitViet (Gate 48):
/// [SoloBlock] (1 bai binh thuong) hoac [PairedBlock] (2 bai sieu set, tap
/// lien tiep KHONG nghi giua, roi nghi sau khi xong ca 2).
sealed class WorkoutBlockGroup {
  const WorkoutBlockGroup();
}

class SoloBlock extends WorkoutBlockGroup {
  const SoloBlock(this.exercise);
  final WorkoutExerciseBlock exercise;
}

class PairedBlock extends WorkoutBlockGroup {
  const PairedBlock(this.first, this.second);
  final WorkoutExerciseBlock first;
  final WorkoutExerciseBlock second;

  /// So vong ghep cap = gia tri targetSets THAP HON trong 2 bai - port dung
  /// `toSupersetBlock()` cua FitViet (2 bai co the duoc tac gia dinh nghia
  /// so set khac nhau, lay gia tri nho hon lam so vong chung).
  int get totalRounds => first.targetSets < second.targetSets
      ? first.targetSets
      : second.targetSets;
}

/// Ghep 2 bai tap LIEN TIEP nhau (theo thu tu trong danh sach) neu chung
/// chia se cung 1 [WorkoutExerciseBlock.supersetGroup] khac null - port dung
/// thuat toan quet trai-sang-phai cua FitViet (Gate 48): CHI ghep dung khi
/// co dung 2 bai lien tiep cung nhom; 3+ bai cung nhom, nhom khong lien tiep,
/// hoac 1 bai le deu tu dong roi ve straight-set (SoloBlock) thay vi bao loi.
List<WorkoutBlockGroup> resolveGroupings(List<WorkoutExerciseBlock> blocks) {
  final groups = <WorkoutBlockGroup>[];
  var i = 0;
  while (i < blocks.length) {
    final current = blocks[i];
    final next = i + 1 < blocks.length ? blocks[i + 1] : null;
    if (current.supersetGroup != null &&
        next != null &&
        next.supersetGroup == current.supersetGroup) {
      groups.add(PairedBlock(current, next));
      i += 2;
    } else {
      groups.add(SoloBlock(current));
      i += 1;
    }
  }
  return groups;
}

enum WorkoutPhase { logging, resting, finished }

/// May trang thai 1 buoi tap - port tu WorkoutViewModel cua FitViet (Gate 4,
/// mo rong sieu set o Gate 47/48): log 1 set -> nghi (dem nguoc, +15s/bo
/// qua) -> set tiep theo -> het nhom bai tap cuoi -> finished. Voi
/// [PairedBlock]: log bai A (KHONG nghi) -> log bai B (nghi) -> lap lai cho
/// [PairedBlock.totalRounds] vong -> chuyen nhom tiep theo. CHI la state cuc
/// bo cua 1 man hinh (khong phai Riverpod provider toan cuc), dung y cach
/// AiVoiceChatScreen tu quan state phuc tap cua no.
class WorkoutController extends ChangeNotifier {
  // Khong dung initializing formal (this._repository/this._userId) - ten
  // tham so se phai trung ten field RIENG TU, khien noi goi khac file
  // (workout_session_screen.dart) khong the truyen tham so do qua ten
  // (privacy cua Dart chan tham chieu ten bat dau bang "_" tu library
  // khac). Giu ten tham so cong khai (repository/userId) roi tu gan vao
  // field rieng tu trong initializer list ben duoi la cach dung.
  WorkoutController({
    required List<WorkoutExerciseBlock> blocks,
    required WorkoutRepository repository,
    required String userId,
    this.programId,
  }) : groups = resolveGroupings(blocks),
       _repository = repository,
       _userId = userId,
       _startedAt = DateTime.now();

  final List<WorkoutBlockGroup> groups;
  final int? programId;
  final WorkoutRepository _repository;
  final String _userId;
  final DateTime _startedAt;

  int? _sessionId;
  Timer? _restTimer;

  int groupIndex = 0;

  /// Dung cho [SoloBlock]: chi so set hien tai (0-based). Dung cho
  /// [PairedBlock]: chi so VONG hien tai (0-based) - xem [subIndex] de biet
  /// dang o bai A hay bai B trong vong do.
  int setOrRoundIndex = 0;

  /// CHI co y nghia khi nhom hien tai la [PairedBlock]: 0 = bai dau (A),
  /// 1 = bai sau (B).
  int subIndex = 0;

  WorkoutPhase phase = WorkoutPhase.logging;
  int restSecondsRemaining = 0;

  /// Gia tri dang chinh bang stepper cho set HIEN TAI - khoi tao lai moi khi
  /// chuyen sang 1 set/bai tap moi (xem _resetInputsForCurrentSet()).
  double currentWeightKg = kDefaultRecommendedWeightKg;
  int currentReps = 0;

  double totalVolumeKg = 0;
  int totalSetsLogged = 0;

  WorkoutBlockGroup get currentGroup => groups[groupIndex];
  bool get isLastGroup => groupIndex == groups.length - 1;

  /// Bai tap DANG hien thi/log - o [PairedBlock] la bai A hoac B tuy
  /// [subIndex].
  WorkoutExerciseBlock get currentBlock {
    final group = currentGroup;
    return switch (group) {
      SoloBlock() => group.exercise,
      PairedBlock() => subIndex == 0 ? group.first : group.second,
    };
  }

  int get currentSetNumber => setOrRoundIndex + 1;
  int get currentTotalSets => switch (currentGroup) {
    SoloBlock(:final exercise) => exercise.targetSets,
    PairedBlock(:final totalRounds) => totalRounds,
  };

  /// True khi nhom hien tai la sieu set - man hinh dung de hien badge
  /// "A1"/"A2" thay vi chi so set thuong.
  bool get isPairedGroup => currentGroup is PairedBlock;
  int get pairSubIndex => subIndex;

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
      setIndex: setOrRoundIndex,
      weightKg: currentWeightKg,
      reps: currentReps,
    );
    totalVolumeKg += currentWeightKg * currentReps;
    totalSetsLogged++;

    final group = currentGroup;
    if (group is SoloBlock) {
      if (setOrRoundIndex == group.exercise.targetSets - 1) {
        await _advanceGroupOrFinish();
        return;
      }
      setOrRoundIndex++;
      _resetInputsForCurrentSet();
      _startRest();
      return;
    }

    // PairedBlock.
    group as PairedBlock;
    if (subIndex == 0) {
      // Vua xong bai A - sang thang bai B, KHONG nghi.
      subIndex = 1;
      _resetInputsForCurrentSet();
      phase = WorkoutPhase.logging;
      notifyListeners();
      return;
    }
    // Vua xong bai B - het 1 vong.
    if (setOrRoundIndex == group.totalRounds - 1) {
      await _advanceGroupOrFinish();
      return;
    }
    setOrRoundIndex++;
    subIndex = 0;
    _resetInputsForCurrentSet();
    _startRest();
  }

  Future<void> _advanceGroupOrFinish() async {
    if (isLastGroup) {
      await _finish();
      return;
    }
    groupIndex++;
    setOrRoundIndex = 0;
    subIndex = 0;
    _resetInputsForCurrentSet();
    phase = WorkoutPhase.logging;
    notifyListeners();
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
