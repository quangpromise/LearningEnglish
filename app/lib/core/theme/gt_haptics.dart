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

  @visibleForTesting
  static void resetForTest() => _micOwners.clear();

  static Future<void> play(GtHapticEvent event) async {
    if (micActive) return;
    switch (gtHapticLevel(event)) {
      case GtHapticLevel.selection:
        await HapticFeedback.selectionClick();
      case GtHapticLevel.light:
        await HapticFeedback.lightImpact();
      case GtHapticLevel.medium:
        await HapticFeedback.mediumImpact();
      case GtHapticLevel.heavy:
        await HapticFeedback.heavyImpact();
    }
  }
}
