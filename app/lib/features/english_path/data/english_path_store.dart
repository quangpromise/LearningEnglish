import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cefr_level.dart';
import 'english_path_state.dart';

const kEnglishPathPrefKey = 'english_path_v1';

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
  /// do, khong bao gio ghi de (spec #45 - version la bo qua an toan).
  bool _readOnly = false;

  EnglishPathState get state => _state;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kEnglishPathPrefKey);
      if (raw != null) {
        final migrated = migrateEnglishPathState(jsonDecode(raw));
        if (migrated == null) {
          _readOnly = true;
        } else {
          _state = migrated;
        }
      }
    } catch (e) {
      _readOnly = true;
      debugPrint('EnglishPathStore load failed: $e');
    }
    notifyListeners();
  }

  Future<void> recordCorrect(String unitId, String itemId) =>
      _update(_state.recordCorrect(unitId, itemId));

  Future<void> setLevel(CefrLevel level) =>
      _update(_state.copyWith(level: level));

  Future<void> _writeChain = Future.value();

  Future<void> _update(EnglishPathState next) async {
    await ensureLoaded();
    if (identical(next, _state)) return;
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
