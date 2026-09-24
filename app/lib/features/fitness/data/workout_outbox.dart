// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'workout_repository.dart';

/// Trang thai dong bo du lieu 1 buoi tap len Supabase.
enum WorkoutSyncState { synced, pending, failed }

/// Hang doi ghi buoi tap LUU TREN MAY (SharedPreferences) roi gui dan len
/// Supabase theo dung thu tu: tao buoi -> log/go set -> ket thuc buoi.
///
/// Vi sao can: phong gym hay mat song. Truoc day man tap `await` thang lenh
/// insert nen mat mang la man hinh ket cung; gio moi thao tac duoc ghi vao
/// hang doi truoc (khong chan giao dien), gui ngay neu co mang, loi thi tu
/// thu lai theo backoff. Hang doi duoc luu xuong may sau MOI thay doi nen
/// app bi tat giua buoi van gui tiep duoc o lan mo Fitness sau (xem
/// FitnessShell goi [flush]).
///
/// Moi buoi tap co 1 id CUC BO (`local`) do may khach sinh ra; id that tren
/// server chi co sau khi lenh 'start' thanh cong va duoc luu vao
/// [_serverIds] de cac lenh sau dung.
///
/// Gioi han da biet: neu lenh insert thanh cong nhung phan hoi bi mat (dut
/// mang dung luc), lan thu lai co the tao ban ghi trung.
class WorkoutOutbox extends ChangeNotifier {
  WorkoutOutbox({required WorkoutRepository repository})
    : _repository = repository;

  static const _prefKey = 'fitness_workout_outbox_v1';

  final WorkoutRepository _repository;

  List<Map<String, dynamic>> _ops = [];
  Map<String, int> _serverIds = {};
  Future<void>? _loading;
  Future<void>? _flushFuture;
  Map<String, dynamic>? _inFlight;
  Timer? _retryTimer;
  int _retryAttempt = 0;
  bool _lastFlushFailed = false;
  bool _disposed = false;
  int _opCounter = 0;

  /// Sinh id cuc bo cho 1 buoi tap moi.
  static String newLocalSessionId() =>
      '${DateTime.now().microsecondsSinceEpoch}-'
      '${Random().nextInt(1 << 30)}';

  Future<void> _ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final loadedOps = [
        for (final op in decoded['ops'] as List? ?? const [])
          Map<String, dynamic>.from(op as Map),
      ];
      final loadedIds = {
        for (final e in (decoded['serverIds'] as Map? ?? const {}).entries)
          e.key as String: (e.value as num).toInt(),
      };
      // Giu lai lenh da duoc xep vao TRUOC khi doc xong file (neu co).
      _ops = [...loadedOps, ..._ops];
      _serverIds = {...loadedIds, ..._serverIds};
    } catch (e) {
      debugPrint('WorkoutOutbox load failed: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        jsonEncode({'ops': _ops, 'serverIds': _serverIds}),
      );
    } catch (e) {
      debugPrint('WorkoutOutbox persist failed: $e');
    }
  }

  bool _hasOpsFor(String local) => _ops.any((op) => op['local'] == local);

  /// Trang thai dong bo cua 1 buoi tap (theo id cuc bo).
  WorkoutSyncState stateFor(String local) {
    if (!_hasOpsFor(local)) return WorkoutSyncState.synced;
    return _lastFlushFailed
        ? WorkoutSyncState.failed
        : WorkoutSyncState.pending;
  }

  // ---------------------------------------------------------------------
  // Xep lenh
  // ---------------------------------------------------------------------

  Future<void> startSession({
    required String local,
    required String userId,
    int? programId,
    required DateTime startedAt,
  }) => _enqueue({
    'type': 'start',
    'local': local,
    'userId': userId,
    'programId': programId,
    'startedAt': startedAt.toIso8601String(),
  });

  /// Tra ve id cua lenh (dung cho [cancelSet]).
  String logSet({
    required String local,
    required String userId,
    required int exerciseId,
    required int setIndex,
    required double weightKg,
    required int reps,
  }) {
    final id = 'set-${DateTime.now().microsecondsSinceEpoch}-${_opCounter++}';
    _enqueue({
      'type': 'set',
      'id': id,
      'local': local,
      'userId': userId,
      'exerciseId': exerciseId,
      'setIndex': setIndex,
      'weightKg': weightKg,
      'reps': reps,
    });
    return id;
  }

  /// Hoan tac 1 set: con nam trong hang doi (chua gui) thi go khoi hang
  /// doi; da gui/dang gui thi xep lenh xoa tren server.
  Future<void> cancelSet({
    required String local,
    required String setOpId,
    required int exerciseId,
    required int setIndex,
  }) async {
    await _ensureLoaded();
    final index = _ops.indexWhere((op) => op['id'] == setOpId);
    if (index >= 0 && !identical(_ops[index], _inFlight)) {
      _ops.removeAt(index);
      await _persist();
      notifyListeners();
      return;
    }
    await _enqueue({
      'type': 'unset',
      'local': local,
      'exerciseId': exerciseId,
      'setIndex': setIndex,
    });
  }

  Future<void> finishSession({
    required String local,
    required double totalVolumeKg,
    required int durationSeconds,
    required DateTime completedAt,
  }) => _enqueue({
    'type': 'finish',
    'local': local,
    'totalVolumeKg': totalVolumeKg,
    'durationSeconds': durationSeconds,
    'completedAt': completedAt.toIso8601String(),
  });

  /// Bo buoi tap: go moi lenh CHUA gui cua buoi nay (tru lenh dang gui).
  /// Phan da len server giu nguyen voi completed_at = null - moi thong ke
  /// chi tinh buoi da hoan thanh nen khong bi dem.
  Future<void> discardSession(String local) async {
    await _ensureLoaded();
    _ops.removeWhere((op) => op['local'] == local && !identical(op, _inFlight));
    if (!_hasOpsFor(local)) _serverIds.remove(local);
    await _persist();
    notifyListeners();
  }

  Future<void> _enqueue(Map<String, dynamic> op) async {
    // Them vao bo nho NGAY (dong bo) de thu tu lenh dung theo thu tu goi,
    // ke ca khi file tren may chua doc xong.
    _ops.add(op);
    notifyListeners();
    await _ensureLoaded();
    await _persist();
    unawaited(flush());
  }

  // ---------------------------------------------------------------------
  // Gui len server
  // ---------------------------------------------------------------------

  /// Gui lan luot moi lenh dang cho. An toan khi goi nhieu lan: chi 1 vong
  /// gui chay tai 1 thoi diem, loi goi trong luc dang gui nhan lai CHINH
  /// Future cua vong do (cho duoc den khi gui xong).
  Future<void> flush() => _flushFuture ??= _runFlush().whenComplete(() {
    _flushFuture = null;
    // Lenh duoc xep vao dung luc vong gui vua ket thuc -> gui tiep.
    if (_ops.isNotEmpty && !_lastFlushFailed) scheduleMicrotask(flush);
  });

  Future<void> _runFlush() async {
    await _ensureLoaded();
    _retryTimer?.cancel();
    try {
      while (_ops.isNotEmpty) {
        final op = _ops.first;
        _inFlight = op;
        await _run(op);
        _inFlight = null;
        _ops.remove(op);
        _forgetIfDone(op);
        await _persist();
        notifyListeners();
      }
      _lastFlushFailed = false;
      _retryAttempt = 0;
    } catch (e) {
      debugPrint('WorkoutOutbox flush failed: $e');
      _inFlight = null;
      _lastFlushFailed = true;
      _scheduleRetry();
    }
    notifyListeners();
  }

  /// Nut "Thu lai" - gui ngay, bo qua thoi gian cho backoff.
  Future<bool> retryNow() async {
    _retryAttempt = 0;
    await flush();
    return !_lastFlushFailed;
  }

  void _scheduleRetry() {
    if (_disposed) return;
    _retryAttempt++;
    // 5s, 10s, 20s, 40s, roi giu 60s.
    final seconds = min(60, 5 * (1 << min(_retryAttempt - 1, 4)));
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), flush);
  }

  Future<void> _run(Map<String, dynamic> op) async {
    final local = op['local'] as String;
    switch (op['type']) {
      case 'start':
        if (_serverIds.containsKey(local)) return;
        final id = await _repository.startSession(
          userId: op['userId'] as String,
          programId: (op['programId'] as num?)?.toInt(),
          startedAt: DateTime.parse(op['startedAt'] as String),
        );
        _serverIds[local] = id;
        // Luu id NGAY - neu app chet truoc khi go lenh 'start' khoi hang doi
        // thi lan sau van biet buoi da ton tai, khong tao trung.
        await _persist();
      case 'set':
        final sessionId = _serverIds[local];
        if (sessionId == null) return; // Mat lenh 'start' (du lieu hong).
        await _repository.logSet(
          sessionId: sessionId,
          userId: op['userId'] as String,
          exerciseId: (op['exerciseId'] as num).toInt(),
          setIndex: (op['setIndex'] as num).toInt(),
          weightKg: (op['weightKg'] as num).toDouble(),
          reps: (op['reps'] as num).toInt(),
        );
      case 'unset':
        final sessionId = _serverIds[local];
        if (sessionId == null) return;
        await _repository.deleteSet(
          sessionId: sessionId,
          exerciseId: (op['exerciseId'] as num).toInt(),
          setIndex: (op['setIndex'] as num).toInt(),
        );
      case 'finish':
        final sessionId = _serverIds[local];
        if (sessionId == null) return;
        await _repository.finishSession(
          sessionId: sessionId,
          totalVolumeKg: (op['totalVolumeKg'] as num).toDouble(),
          durationSeconds: (op['durationSeconds'] as num).toInt(),
          completedAt: DateTime.parse(op['completedAt'] as String),
        );
      default:
        debugPrint('WorkoutOutbox: bo qua lenh la ${op['type']}');
    }
  }

  /// Lenh 'finish' da gui xong va buoi khong con lenh nao -> khong can nho
  /// id server nua (tranh [_serverIds] phinh ra theo thoi gian).
  void _forgetIfDone(Map<String, dynamic> op) {
    final local = op['local'] as String;
    if (op['type'] == 'finish' && !_hasOpsFor(local)) {
      _serverIds.remove(local);
    }
  }

  /// Vong gui dang chay co the ket thuc SAU khi dispose (vd provider bi huy
  /// giua chung) - bo qua thong bao thay vi nem loi "used after disposed".
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    super.dispose();
  }
}
