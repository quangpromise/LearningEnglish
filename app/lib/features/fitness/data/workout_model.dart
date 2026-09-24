// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'exercise_model.dart';
import 'workout_outbox.dart';

export 'workout_outbox.dart' show WorkoutOutbox, WorkoutSyncState;

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

/// Cac muc thoi gian nghi cho nguoi dung chon (giay).
const kRestDurationOptions = [30, 45, 60, 90, 120];

/// Anh chup trang thai TRUOC 1 lan "Hoan thanh set" - de hoan tac.
class _SetSnapshot {
  const _SetSnapshot({
    required this.groupIndex,
    required this.setOrRoundIndex,
    required this.subIndex,
    required this.weightKg,
    required this.reps,
    required this.totalVolumeKg,
    required this.totalSetsLogged,
    required this.setOpId,
    required this.exerciseId,
  });
  final int groupIndex;
  final int setOrRoundIndex;
  final int subIndex;
  final double weightKg;
  final int reps;
  final double totalVolumeKg;
  final int totalSetsLogged;
  final String setOpId;
  final int exerciseId;
}

/// May trang thai 1 buoi tap - port tu WorkoutViewModel cua FitViet (Gate 4,
/// mo rong sieu set o Gate 47/48): log 1 set -> nghi (dem nguoc, +15s/bo
/// qua) -> set tiep theo -> het nhom bai tap cuoi -> finished. Voi
/// [PairedBlock]: log bai A (KHONG nghi) -> log bai B (nghi) -> lap lai cho
/// [PairedBlock.totalRounds] vong -> chuyen nhom tiep theo. CHI la state cuc
/// bo cua 1 man hinh (khong phai Riverpod provider toan cuc), dung y cach
/// AiVoiceChatScreen tu quan state phuc tap cua no.
///
/// GHI LAC QUAN: bam "Hoan thanh set" chuyen trang thai NGAY; lenh ghi
/// Supabase di qua [WorkoutOutbox] (hang doi luu tren may, tu thu lai) - truoc
/// day `await` thang lenh insert nen mat mang la man hinh ket cung.
class WorkoutController extends ChangeNotifier {
  // Khong dung initializing formal (this._outbox/this._userId) - ten tham so
  // se phai trung ten field RIENG TU, khien noi goi khac file
  // (workout_session_screen.dart) khong the truyen tham so do qua ten
  // (privacy cua Dart chan tham chieu ten bat dau bang "_" tu library
  // khac). Giu ten tham so cong khai (outbox/userId) roi tu gan vao field
  // rieng tu trong initializer list ben duoi la cach dung.
  WorkoutController({
    required List<WorkoutExerciseBlock> blocks,
    required WorkoutOutbox outbox,
    required String userId,
    this.programId,
    int restSeconds = kDefaultRestSeconds,
    DateTime Function()? clock,
  }) : groups = resolveGroupings(blocks),
       _outbox = outbox,
       _userId = userId,
       _clock = clock ?? DateTime.now,
       restDurationSeconds = restSeconds,
       localSessionId = WorkoutOutbox.newLocalSessionId() {
    _startedAt = _clock();
  }

  final List<WorkoutBlockGroup> groups;
  final int? programId;
  final WorkoutOutbox _outbox;
  final String _userId;
  final DateTime Function() _clock;
  late final DateTime _startedAt;
  DateTime? _finishedAt;

  /// Id cuc bo cua buoi tap trong [WorkoutOutbox].
  final String localSessionId;

  Timer? _restTimer;
  DateTime? _restStartedAt;
  DateTime? _restEndsAt;
  DateTime? _lastCompleteAt;
  bool _disposed = false;
  final List<_SetSnapshot> _history = [];

  /// Muc ta vua dung gan nhat cho tung bai - set sau cua CUNG bai giu nguyen
  /// muc nay thay vi quay ve muc goi y (nguoi dung vua tang/giam ta).
  final Map<int, double> _lastWeightByExercise = {};

  /// Goi khi het gio nghi TU NHIEN (khong goi khi bam "Bo qua") - man hinh
  /// dung de rung/phat am bao.
  VoidCallback? onRestElapsed;

  int groupIndex = 0;

  /// Dung cho [SoloBlock]: chi so set hien tai (0-based). Dung cho
  /// [PairedBlock]: chi so VONG hien tai (0-based) - xem [subIndex] de biet
  /// dang o bai A hay bai B trong vong do.
  int setOrRoundIndex = 0;

  /// CHI co y nghia khi nhom hien tai la [PairedBlock]: 0 = bai dau (A),
  /// 1 = bai sau (B).
  int subIndex = 0;

  WorkoutPhase phase = WorkoutPhase.logging;

  /// Thoi gian nghi cho CAC LAN NGHI (nguoi dung chon o man tap).
  int restDurationSeconds;

  /// Gia tri dang chinh bang stepper cho set HIEN TAI - khoi tao lai moi khi
  /// chuyen sang 1 set/bai tap moi (xem _resetInputsForCurrentSet()).
  double currentWeightKg = kDefaultRecommendedWeightKg;
  int currentReps = 0;

  double totalVolumeKg = 0;
  int totalSetsLogged = 0;

  /// True khi buoi ket thuc vi da lam HET moi set (khong phai thoat som) -
  /// chi khi do moi tu tick "Hoan thanh" trong Lap ke hoach.
  bool completedAllSets = false;

  WorkoutBlockGroup get currentGroup => groups[groupIndex];
  bool get isLastGroup => groupIndex == groups.length - 1;

  /// Bai tap DANG hien thi/log - o [PairedBlock] la bai A hoac B tuy
  /// [subIndex]. Trong luc nghi, day chinh la bai/set SAP TOI.
  WorkoutExerciseBlock get currentBlock {
    final group = currentGroup;
    return switch (group) {
      SoloBlock() => group.exercise,
      PairedBlock() => subIndex == 0 ? group.first : group.second,
    };
  }

  /// Tat ca bai tap cua buoi (theo thu tu) - dung de chon tu vung.
  List<Exercise> get exercises => [
    for (final g in groups)
      ...switch (g) {
        SoloBlock(:final exercise) => [exercise.exercise],
        PairedBlock(:final first, :final second) => [
          first.exercise,
          second.exercise,
        ],
      },
  ];

  int get currentSetNumber => setOrRoundIndex + 1;
  int get currentTotalSets => switch (currentGroup) {
    SoloBlock(:final exercise) => exercise.targetSets,
    PairedBlock(:final totalRounds) => totalRounds,
  };

  /// True khi nhom hien tai la sieu set - man hinh dung de hien badge
  /// "A1"/"A2" thay vi chi so set thuong.
  bool get isPairedGroup => currentGroup is PairedBlock;
  int get pairSubIndex => subIndex;

  /// Ty le hoan thanh buoi tap (0..1) theo so set da log tren tong so set -
  /// dung cho thanh tien do o dau man tap.
  double get progress {
    if (phase == WorkoutPhase.finished) return 1;
    var total = 0;
    var done = 0;
    for (var i = 0; i < groups.length; i++) {
      final (rounds, perRound) = switch (groups[i]) {
        SoloBlock(:final exercise) => (exercise.targetSets, 1),
        PairedBlock(:final totalRounds) => (totalRounds, 2),
      };
      total += rounds * perRound;
      if (i < groupIndex) {
        done += rounds * perRound;
      } else if (i == groupIndex) {
        done += setOrRoundIndex * perRound + subIndex;
      }
    }
    return total == 0 ? 0 : (done / total).clamp(0.0, 1.0);
  }

  bool get canUndo => _history.isNotEmpty && phase != WorkoutPhase.finished;

  WorkoutSyncState get syncState => _outbox.stateFor(localSessionId);

  /// Bat dau buoi tap: xep lenh tao dong workout_sessions (khong chan giao
  /// dien - mat mang van tap binh thuong, hang doi tu gui sau).
  void start() {
    _resetInputsForCurrentSet();
    notifyListeners();
    unawaited(
      _outbox.startSession(
        local: localSessionId,
        userId: _userId,
        programId: programId,
        startedAt: _startedAt,
      ),
    );
  }

  void _resetInputsForCurrentSet() {
    final block = currentBlock;
    currentWeightKg =
        _lastWeightByExercise[block.exercise.id] ?? block.recommendedWeightKg;
    currentReps = block.targetRepsMin;
  }

  void adjustWeight(double delta) {
    currentWeightKg = (currentWeightKg + delta).clamp(0.0, 500.0);
    notifyListeners();
  }

  void adjustReps(int delta) {
    currentReps = (currentReps + delta).clamp(0, 100);
    notifyListeners();
  }

  /// Ghi nhan set hien tai la xong. Trang thai chuyen NGAY, lenh ghi set vao
  /// [WorkoutOutbox] - van ghi tung set ngay khi xong thay vi doi cuoi buoi,
  /// dung triet ly SetLogEntity cua FitViet.
  ///
  /// Bo qua lan bam thu 2 trong vong 700ms (cham dup tay luc dang met) -
  /// tranh log nham set ke tiep cua bai sau.
  void completeSet() {
    if (phase != WorkoutPhase.logging) return;
    final now = _clock();
    final last = _lastCompleteAt;
    if (last != null && now.difference(last).inMilliseconds.abs() < 700) {
      return;
    }
    _lastCompleteAt = now;

    final exerciseId = currentBlock.exercise.id;
    final weightKg = currentWeightKg;
    final reps = currentReps;
    final setOpId = _outbox.logSet(
      local: localSessionId,
      userId: _userId,
      exerciseId: exerciseId,
      setIndex: setOrRoundIndex,
      weightKg: weightKg,
      reps: reps,
    );
    _history.add(
      _SetSnapshot(
        groupIndex: groupIndex,
        setOrRoundIndex: setOrRoundIndex,
        subIndex: subIndex,
        weightKg: weightKg,
        reps: reps,
        totalVolumeKg: totalVolumeKg,
        totalSetsLogged: totalSetsLogged,
        setOpId: setOpId,
        exerciseId: exerciseId,
      ),
    );
    _lastWeightByExercise[exerciseId] = weightKg;
    totalVolumeKg += weightKg * reps;
    totalSetsLogged++;

    final group = currentGroup;
    if (group is SoloBlock) {
      if (setOrRoundIndex == group.exercise.targetSets - 1) {
        _advanceGroupOrFinish();
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
      notifyListeners();
      return;
    }
    // Vua xong bai B - het 1 vong.
    if (setOrRoundIndex == group.totalRounds - 1) {
      _advanceGroupOrFinish();
      return;
    }
    setOrRoundIndex++;
    subIndex = 0;
    _resetInputsForCurrentSet();
    _startRest();
  }

  /// Hoan tac set vua ghi (bam nham, nhap sai reps...): quay lai dung set
  /// do voi gia tri da nhap, go set khoi hang doi/server.
  void undoLastSet() {
    if (!canUndo) return;
    final snap = _history.removeLast();
    _cancelRestTimer();
    groupIndex = snap.groupIndex;
    setOrRoundIndex = snap.setOrRoundIndex;
    subIndex = snap.subIndex;
    currentWeightKg = snap.weightKg;
    currentReps = snap.reps;
    totalVolumeKg = snap.totalVolumeKg;
    totalSetsLogged = snap.totalSetsLogged;
    phase = WorkoutPhase.logging;
    _lastCompleteAt = null;
    notifyListeners();
    unawaited(
      _outbox.cancelSet(
        local: localSessionId,
        setOpId: snap.setOpId,
        exerciseId: snap.exerciseId,
        setIndex: snap.setOrRoundIndex,
      ),
    );
  }

  void _advanceGroupOrFinish() {
    if (isLastGroup) {
      completedAllSets = true;
      _finish();
      return;
    }
    groupIndex++;
    setOrRoundIndex = 0;
    subIndex = 0;
    _resetInputsForCurrentSet();
    // Nghi ca khi chuyen sang bai moi (truoc day chuyen thang, khong nghi) -
    // day cung la luc chuan bi dung cu cho bai tiep theo.
    _startRest();
  }

  // ---------------------------------------------------------------------
  // Nghi giua set - tinh theo MOC THOI GIAN KET THUC (khong tru dan tung
  // giay) de khong bi lech khi app vao nen/Timer bi tre.
  // ---------------------------------------------------------------------

  int get restSecondsRemaining {
    final endsAt = _restEndsAt;
    if (phase != WorkoutPhase.resting || endsAt == null) return 0;
    final ms = endsAt.difference(_clock()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  /// Tong thoi gian cua lan nghi hien tai (ke ca phan +15s) - dung ve vong
  /// dem nguoc.
  int get restTotalSeconds {
    final start = _restStartedAt;
    final end = _restEndsAt;
    if (start == null || end == null) return restDurationSeconds;
    return max(1, (end.difference(start).inMilliseconds / 1000).round());
  }

  void _startRest() {
    phase = WorkoutPhase.resting;
    final startedAt = _clock();
    _restStartedAt = startedAt;
    _restEndsAt = startedAt.add(Duration(seconds: restDurationSeconds));
    notifyListeners();
    _restTimer?.cancel();
    _restTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => tickRest(),
    );
  }

  /// Cap nhat dem nguoc - Timer goi dinh ky; test goi truc tiep sau khi tua
  /// dong ho gia.
  void tickRest() {
    if (phase != WorkoutPhase.resting) return;
    if (restSecondsRemaining <= 0) {
      _endRest();
      onRestElapsed?.call();
    } else {
      notifyListeners();
    }
  }

  void addRestSeconds(int seconds) {
    final endsAt = _restEndsAt;
    if (phase != WorkoutPhase.resting || endsAt == null) return;
    _restEndsAt = endsAt.add(Duration(seconds: seconds));
    notifyListeners();
  }

  /// Doi thoi gian nghi. Neu DANG nghi thi ap dung luon cho lan nghi nay
  /// (tinh tu luc bat dau nghi).
  void setRestDuration(int seconds) {
    restDurationSeconds = seconds;
    final start = _restStartedAt;
    if (phase == WorkoutPhase.resting && start != null) {
      _restEndsAt = start.add(Duration(seconds: seconds));
      tickRest();
    } else {
      notifyListeners();
    }
  }

  void skipRest() {
    if (phase != WorkoutPhase.resting) return;
    _endRest();
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _restStartedAt = null;
    _restEndsAt = null;
  }

  void _endRest() {
    _cancelRestTimer();
    phase = WorkoutPhase.logging;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Ket thuc
  // ---------------------------------------------------------------------

  void _finish() {
    _cancelRestTimer();
    final finishedAt = _clock();
    _finishedAt = finishedAt;
    phase = WorkoutPhase.finished;
    unawaited(
      _outbox.finishSession(
        local: localSessionId,
        totalVolumeKg: totalVolumeKg,
        durationSeconds: finishedAt.difference(_startedAt).inSeconds,
        completedAt: finishedAt,
      ),
    );
    notifyListeners();
  }

  /// Nguoi dung chon "Luu & ket thuc" giua chung: ket thuc SOM, van luu
  /// cac set da log (buoi van tinh vao thong ke nhung KHONG tick hoan thanh
  /// trong Lap ke hoach - xem [completedAllSets]). Chua log set nao thi coi
  /// nhu bo buoi.
  void finishEarly() {
    if (phase == WorkoutPhase.finished) return;
    if (totalSetsLogged == 0) {
      discard();
      return;
    }
    _finish();
  }

  /// Nguoi dung chon "Bo buoi tap": khong danh dau hoan thanh, go cac lenh
  /// chua gui. Phan da len server co completed_at = null nen moi thong ke
  /// (chi tinh buoi da hoan thanh) deu bo qua.
  void discard() {
    _cancelRestTimer();
    unawaited(_outbox.discardSession(localSessionId));
  }

  Duration get elapsed => (_finishedAt ?? _clock()).difference(_startedAt);

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelRestTimer();
    super.dispose();
  }
}
