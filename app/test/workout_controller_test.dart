import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/workout_model.dart';
import 'package:learn_english_music/features/fitness/data/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository gia: ghi lai thu tu lenh, co the "mat mang" theo y muon.
class _FakeRepo implements WorkoutRepository {
  bool offline = false;
  final calls = <String>[];
  int _nextId = 100;

  void _check() {
    if (offline) throw Exception('offline');
  }

  @override
  Future<int> startSession({
    required String userId,
    int? programId,
    DateTime? startedAt,
  }) async {
    _check();
    final id = _nextId++;
    calls.add('start:$id');
    return id;
  }

  @override
  Future<void> logSet({
    required int sessionId,
    required String userId,
    required int exerciseId,
    required int setIndex,
    required double weightKg,
    required int reps,
  }) async {
    _check();
    calls.add('set:$sessionId:$exerciseId:$setIndex:$weightKg:$reps');
  }

  @override
  Future<void> deleteSet({
    required int sessionId,
    required int exerciseId,
    required int setIndex,
  }) async {
    _check();
    calls.add('unset:$sessionId:$exerciseId:$setIndex');
  }

  @override
  Future<void> finishSession({
    required int sessionId,
    required double totalVolumeKg,
    required int durationSeconds,
    DateTime? completedAt,
  }) async {
    _check();
    calls.add('finish:$sessionId:$totalVolumeKg');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Exercise _exercise(int id, {String group = 'CHEST'}) => Exercise(
  id: id,
  nameVi: 'Bai $id',
  nameEn: 'Exercise $id',
  primaryMuscle: 'Ngực · chính',
  secondaryMuscles: const [],
  involvementPercents: const [],
  equipment: 'Tạ đòn',
  instructions: const ['Buoc 1'],
  instructionsEn: const ['Step 1'],
  suggestedSetsMin: 3,
  suggestedSetsMax: 4,
  suggestedRepsMin: 8,
  suggestedRepsMax: 12,
  suggestedRestSeconds: 60,
  muscleGroupCode: group,
  movementType: 'COMPOUND',
  difficultyCode: 'BEGINNER',
  photoSlug: 'x',
);

WorkoutExerciseBlock _block(int id, {int sets = 2, double weight = 20}) =>
    WorkoutExerciseBlock(
      exercise: _exercise(id),
      targetSets: sets,
      targetRepsMin: 8,
      targetRepsMax: 12,
      recommendedWeightKg: weight,
    );

/// Cho moi microtask/Future dang cho (ghi SharedPreferences, gui lenh) chay
/// xong.
Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeRepo repo;
  late WorkoutOutbox outbox;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = _FakeRepo();
    outbox = WorkoutOutbox(repository: repo);
    now = DateTime(2026, 9, 24, 18);
  });

  tearDown(() => outbox.dispose());

  WorkoutController makeController(List<WorkoutExerciseBlock> blocks) {
    final c = WorkoutController(
      blocks: blocks,
      outbox: outbox,
      userId: 'u1',
      clock: () => now,
    )..start();
    return c;
  }

  /// Bam "Hoan thanh set" - cach lan truoc 1s de khong bi chan cham dup.
  void tap(WorkoutController c) {
    now = now.add(const Duration(seconds: 1));
    c.completeSet();
  }

  test('offline: chuyen set ngay, gui lai dung thu tu khi co mang', () async {
    repo.offline = true;
    final c = makeController([_block(1, sets: 2)]);
    tap(c);
    expect(c.phase, WorkoutPhase.resting);
    c.skipRest();
    tap(c);
    expect(c.phase, WorkoutPhase.finished);
    expect(c.completedAllSets, isTrue);
    await _settle();
    expect(repo.calls, isEmpty);
    expect(c.syncState, WorkoutSyncState.failed);

    repo.offline = false;
    expect(await outbox.retryNow(), isTrue);
    expect(repo.calls, [
      'start:100',
      'set:100:1:0:20.0:8',
      'set:100:1:1:20.0:8',
      'finish:100:320.0',
    ]);
    expect(c.syncState, WorkoutSyncState.synced);
    c.dispose();
  });

  test('hang doi con nguyen sau khi "tat app" (tao outbox moi)', () async {
    repo.offline = true;
    final c = makeController([_block(1, sets: 1)]);
    tap(c);
    await _settle();
    c.dispose();

    final repo2 = _FakeRepo();
    final outbox2 = WorkoutOutbox(repository: repo2);
    await outbox2.flush();
    expect(repo2.calls, [
      'start:100',
      'set:100:1:0:20.0:8',
      'finish:100:160.0',
    ]);
    outbox2.dispose();
  });

  test('cham dup trong 700ms chi log 1 set', () async {
    final c = makeController([_block(1, sets: 3)]);
    now = now.add(const Duration(seconds: 1));
    c.completeSet();
    c.skipRest();
    now = now.add(const Duration(milliseconds: 200));
    c.completeSet();
    expect(c.totalSetsLogged, 1);
    c.dispose();
  });

  test('hoan tac set chua gui -> go khoi hang doi', () async {
    repo.offline = true;
    final c = makeController([_block(1, sets: 3)]);
    c.adjustReps(2);
    tap(c);
    expect(c.canUndo, isTrue);
    c.undoLastSet();
    expect(c.phase, WorkoutPhase.logging);
    expect(c.currentSetNumber, 1);
    expect(c.currentReps, 10);
    expect(c.totalSetsLogged, 0);
    await _settle();

    repo.offline = false;
    await outbox.retryNow();
    expect(repo.calls, ['start:100']);
    c.dispose();
  });

  test('hoan tac set da gui -> xoa tren server', () async {
    final c = makeController([_block(1, sets: 3)]);
    tap(c);
    await _settle();
    c.undoLastSet();
    await _settle();
    expect(repo.calls, ['start:100', 'set:100:1:0:20.0:8', 'unset:100:1:0']);
    c.dispose();
  });

  test('nghi tinh theo moc thoi gian, het gio goi onRestElapsed', () {
    final c = makeController([_block(1, sets: 3)]);
    var elapsedCalls = 0;
    c.onRestElapsed = () => elapsedCalls++;
    tap(c);
    expect(c.restSecondsRemaining, 60);
    c.addRestSeconds(15);
    expect(c.restTotalSeconds, 75);

    // App vao nen 80s: quay lai la het gio ngay, khong dem tiep tu 60.
    now = now.add(const Duration(seconds: 80));
    c.tickRest();
    expect(c.phase, WorkoutPhase.logging);
    expect(elapsedCalls, 1);

    // Bam "Bo qua" khong tinh la het gio tu nhien.
    tap(c);
    c.skipRest();
    expect(elapsedCalls, 1);
    c.dispose();
  });

  test('doi thoi gian nghi ap dung cho lan nghi dang chay', () {
    final c = makeController([_block(1, sets: 2)]);
    tap(c);
    now = now.add(const Duration(seconds: 10));
    c.setRestDuration(30);
    expect(c.restSecondsRemaining, 20);
    c.dispose();
  });

  test('giu muc ta vua dung cho set sau cua cung bai', () {
    final c = makeController([_block(1, sets: 3, weight: 20)]);
    c.adjustWeight(5);
    tap(c);
    c.skipRest();
    expect(c.currentWeightKg, 25);
    c.dispose();
  });

  test('nghi ca khi chuyen sang bai moi', () {
    final c = makeController([_block(1, sets: 1), _block(2, sets: 1)]);
    tap(c);
    expect(c.phase, WorkoutPhase.resting);
    expect(c.currentBlock.exercise.id, 2);
    c.dispose();
  });

  test('thoat som: 0 set -> bo buoi; co set -> ket thuc som', () async {
    final empty = makeController([_block(1, sets: 3)]);
    empty.finishEarly();
    expect(empty.phase, isNot(WorkoutPhase.finished));
    empty.dispose();

    final c = makeController([_block(2, sets: 3)]);
    tap(c);
    c.finishEarly();
    expect(c.phase, WorkoutPhase.finished);
    expect(c.completedAllSets, isFalse);
    await _settle();
    expect(repo.calls.last, startsWith('finish:'));
    c.dispose();
  });

  test('bo buoi tap: lenh chua gui bi go', () async {
    repo.offline = true;
    final c = makeController([_block(1, sets: 3)]);
    tap(c);
    await _settle();
    c.discard();
    await _settle();
    repo.offline = false;
    await outbox.retryNow();
    expect(repo.calls, isEmpty);
    c.dispose();
  });

  test('tien do buoi tap', () {
    final c = makeController([_block(1, sets: 2), _block(2, sets: 2)]);
    expect(c.progress, 0);
    tap(c);
    expect(c.progress, 0.25);
    c.dispose();
  });
}
