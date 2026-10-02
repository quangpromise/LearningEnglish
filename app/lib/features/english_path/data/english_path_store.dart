import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cefr_level.dart';
import 'english_path_state.dart';
import 'english_path_sync.dart';
import 'level_test.dart';
import 'placement.dart';

const kEnglishPathPrefKey = 'english_path_v1';

/// Ban sao du lieu hong truoc khi reset, de con cuu duoc neu can.
const kEnglishPathCorruptBackupKey = 'english_path_v1_corrupt';

/// Luu state lo trinh tieng Anh tren may (SharedPreferences). Singleton de
/// man Lo trinh, phien hoc Unit va Rest Game cung ghi 1 cho; UI nghe thay
/// doi qua ChangeNotifier.
class EnglishPathStore extends ChangeNotifier {
  EnglishPathStore._();

  static final EnglishPathStore instance = EnglishPathStore._();

  @visibleForTesting
  factory EnglishPathStore.forTest() => EnglishPathStore._();

  EnglishPathState _state = const EnglishPathState();
  Future<void>? _loading;

  /// true khi tren may co state do ban app MOI HON ghi: giu nguyen du lieu
  /// do, khong bao gio ghi de (spec #45 - version la bo qua an toan). Du
  /// lieu HONG thi khac: sao luu roi bat dau lai tu dau.
  bool _readOnly = false;

  EnglishPathState get state => _state;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kEnglishPathPrefKey);
      if (raw != null) {
        Object? decoded;
        try {
          decoded = jsonDecode(raw);
        } on FormatException {
          decoded = null;
        }
        final migrated = migrateEnglishPathState(decoded);
        if (migrated != null) {
          _state = migrated;
        } else if (isFromNewerVersion(decoded)) {
          _readOnly = true;
        } else {
          await prefs.setString(kEnglishPathCorruptBackupKey, raw);
        }
      }
    } catch (e) {
      debugPrint('EnglishPathStore load failed: $e');
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Dong bo tai khoan (GymTalkSyncService, cot user_gymtalk_state.path)
  // ---------------------------------------------------------------------

  /// Server gan nhat co du lieu do ban app moi hon ghi.
  bool _remoteNewer = false;

  /// Duoc phep day state tren may len server: khong khi du lieu tren may
  /// hoac tren server do ban app MOI HON ghi (spec #45).
  bool get canUpload => !_readOnly && !_remoteNewer;

  Map<String, dynamic> exportJson() => _state.toJson();

  /// Gop state tu server vao may theo luat merge (english_path_sync.dart).
  Future<RemoteMergeResult> mergeRemote(Object? raw) async {
    await ensureLoaded();
    _remoteNewer = false;
    // State tren may do app moi hon ghi: giu nguyen (khong gop, khong ghi).
    if (_readOnly) return RemoteMergeResult.ignored;
    if (isFromNewerVersion(raw)) {
      _remoteNewer = true;
      return RemoteMergeResult.remoteIsNewer;
    }
    final remote = migrateEnglishPathState(raw);
    if (remote == null) return RemoteMergeResult.ignored;
    await _update(mergeEnglishPathState(_state, remote));
    return RemoteMergeResult.merged;
  }

  /// Xoa tien do tren may (dang nhap tai khoan KHAC).
  Future<void> clearLocal() async {
    await ensureLoaded();
    _readOnly = false;
    _remoteNewer = false;
    await _update(const EnglishPathState(), force: true);
  }

  Future<void> recordCorrect(String unitId, String itemId) =>
      _update(_state.recordCorrect(unitId, itemId));

  Future<void> recordWrong(String itemId) =>
      _update(_state.recordWrong(itemId));

  Future<void> setLevel(CefrLevel level) =>
      _update(_state.copyWith(level: level));

  /// Luu ket qua Placement - English Level lay theo ket qua (spec #45).
  Future<void> completePlacement(PlacementRecord record) =>
      _update(_state.withPlacement(record));

  Future<void> skipPlacement() => _update(_state.skipPlacement());

  /// Luu ket qua Level Test (dat thi len Stage ke tiep).
  Future<void> recordLevelTest(LevelTestResult result) =>
      _update(_state.withLevelTest(result));

  Future<void> _writeChain = Future.value();

  Future<void> _update(EnglishPathState next, {bool force = false}) async {
    await ensureLoaded();
    if (!force &&
        (identical(next, _state) ||
            jsonEncode(next.toJson()) == jsonEncode(_state.toJson()))) {
      return;
    }
    _state = next;
    notifyListeners();
    if (_readOnly) return;
    final json = jsonEncode(next.toJson());
    await (_writeChain = _writeChain.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kEnglishPathPrefKey, json);
      } catch (e) {
        debugPrint('EnglishPathStore save failed: $e');
      }
    }));
  }
}
