import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Su kien co rung phan hoi (spec #96, quyet dinh #4).
enum GtHapticEvent {
  cardGraded,
  setTicked,
  questCompleted,
  ringCompleted,
  pronunciationGood,
  chestOpened,
  celebration,
}

enum GtHapticLevel { selection, light, medium, heavy }

/// Muc rung cua tung su kien.
GtHapticLevel gtHapticLevel(GtHapticEvent event) => switch (event) {
  GtHapticEvent.cardGraded => GtHapticLevel.selection,
  GtHapticEvent.setTicked => GtHapticLevel.light,
  GtHapticEvent.questCompleted ||
  GtHapticEvent.ringCompleted ||
  GtHapticEvent.pronunciationGood => GtHapticLevel.medium,
  GtHapticEvent.chestOpened || GtHapticEvent.celebration => GtHapticLevel.heavy,
};

/// Rung phan hoi dung chung. Khong rung khi dang co phien thu mic (rung lot
/// vao ban ghi va lam nhieu nhan giong) - man thu mic goi [micStarted] /
/// [micStopped] voi chinh no lam "chu" phien (goi them ca trong dispose).
/// Cai dat "phan hoi cham" cua he dieu hanh van quyet dinh co rung hay khong.
abstract final class GtHaptics {
  static final Set<Object> _micOwners = {};

  static bool get micActive => _micOwners.isNotEmpty;

  /// Theo chu, khong dem: goi lap lai (vd trang thai "dang nghe" ban lai khi
  /// tu khoi dong lai) khong lam lech, 1 lan [micStopped] la du.
  static void micStarted(Object owner) => _micOwners.add(owner);

  static void micStopped(Object owner) => _micOwners.remove(owner);

  static GtHapticLevel? _queued;
  static Future<void>? _flush;
  static GtHapticLevel? _lastLevel;
  static DateTime? _lastAt;

  /// Dong ho cho khoang tro (test thay duoc).
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  /// Sau 1 lan rung, su kien KHONG manh hon trong khoang nay bi bo: 1 viec
  /// (vd xong nhiem vu On the va vong Hoc cham 100% ~0.2 s sau) chi rung 1
  /// lan. Su kien manh hon van rung.
  static const refractory = Duration(milliseconds: 350);

  @visibleForTesting
  static void resetForTest() {
    _micOwners.clear();
    _queued = null;
    _flush = null;
    _lastLevel = null;
    _lastAt = null;
    now = DateTime.now;
  }

  /// Rung cho [event]. Cac lan goi truoc khi microtask rung chay (vd nhieu
  /// the cung build) gop thanh 1 lan o muc manh nhat; them [refractory] de
  /// khong rung chong. Co mic dang thu luc rung (ke ca vua bat ngay sau lan
  /// goi) thi im lang.
  static Future<void> play(GtHapticEvent event) {
    if (micActive) return Future.value();
    final level = gtHapticLevel(event);
    final queued = _queued;
    if (queued != null) {
      if (level.index > queued.index) _queued = level;
      return _flush ?? Future.value();
    }
    _queued = level;
    return _flush = Future.microtask(() async {
      final strongest = _queued;
      _queued = null;
      _flush = null;
      if (strongest == null || micActive) return;
      final at = now();
      final lastAt = _lastAt;
      final lastLevel = _lastLevel;
      if (lastAt != null &&
          lastLevel != null &&
          at.difference(lastAt) < refractory &&
          strongest.index <= lastLevel.index) {
        return;
      }
      _lastAt = at;
      _lastLevel = strongest;
      await _vibrate(strongest);
    });
  }

  static Future<void> _vibrate(GtHapticLevel level) => switch (level) {
    GtHapticLevel.selection => HapticFeedback.selectionClick(),
    GtHapticLevel.light => HapticFeedback.lightImpact(),
    GtHapticLevel.medium => HapticFeedback.mediumImpact(),
    GtHapticLevel.heavy => HapticFeedback.heavyImpact(),
  };
}
