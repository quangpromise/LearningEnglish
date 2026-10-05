import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Su kien co rung phan hoi (spec #96, quyet dinh #4). Moi cho rung trong
/// app deu di qua day de theo co mic va khoang tro (#124).
enum GtHapticEvent {
  cardGraded,
  setTicked,
  questCompleted,
  ringCompleted,
  pronunciationGood,
  chestOpened,
  celebration,

  /// Nut ⚡ Quick Start o thanh tab.
  quickStart,

  /// Chon dap an (chua cham) / cham 1 chu khi xep tu.
  answerPicked,
  answerRight,
  answerWrong,

  /// Camera dem rep vua dem 1 rep.
  repCounted,

  /// 3-2-1 cuoi gio nghi.
  restCountdown,

  /// Het gio nghi - bao hieu, xem [gtHapticIsAlert].
  restEnded,

  /// So bac tren the Rank trong man chuc mung doi sang bac moi (#121).
  rankUp,

  /// Vong Tap · Hoc · Noi khep lai trong Launch Intro (#137).
  launchRing,
}

enum GtHapticLevel { selection, light, medium, heavy }

/// Muc rung cua tung su kien.
GtHapticLevel gtHapticLevel(GtHapticEvent event) => switch (event) {
  GtHapticEvent.cardGraded ||
  GtHapticEvent.answerPicked ||
  GtHapticEvent.restCountdown => GtHapticLevel.selection,
  GtHapticEvent.setTicked ||
  GtHapticEvent.answerRight ||
  GtHapticEvent.repCounted ||
  GtHapticEvent.rankUp ||
  GtHapticEvent.launchRing => GtHapticLevel.light,
  GtHapticEvent.questCompleted ||
  GtHapticEvent.ringCompleted ||
  GtHapticEvent.pronunciationGood ||
  GtHapticEvent.quickStart => GtHapticLevel.medium,
  GtHapticEvent.chestOpened ||
  GtHapticEvent.celebration ||
  GtHapticEvent.answerWrong ||
  GtHapticEvent.restEnded => GtHapticLevel.heavy,
};

/// Bao hieu nguoi dung phai biet NGAY (het gio nghi): rung ca khi dang co
/// phien thu mic (vd dang noi voi PT AI luc nghi) va khong bi khoang tro bo -
/// mat rung la lo gio. 1 nhip rung lot vao mic chap nhan duoc.
bool gtHapticIsAlert(GtHapticEvent event) => event == GtHapticEvent.restEnded;

/// Rung phan hoi dung chung. Khong rung khi dang co phien thu mic (rung lot
/// vao ban ghi va lam nhieu nhan giong) - man thu mic goi [micStarted] /
/// [micStopped] voi chinh no lam "chu" phien (goi them ca trong dispose).
/// Tru bao hieu ([gtHapticIsAlert]).
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
  static Duration? _lastFrame;

  /// Dong ho that cho khoang tro (test thay duoc).
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  /// Moc khung hinh gan nhat (theo thoi gian gia trong test).
  static Duration _frameStamp() =>
      SchedulerBinding.instance.currentSystemFrameTimeStamp;

  /// Sau 1 lan rung, su kien KHONG manh hon trong khoang nay bi bo: 1 viec
  /// (vd xong nhiem vu On the va vong Hoc cham 100% ~0.2 s sau) chi rung 1
  /// lan. Su kien manh hon van rung. Rieng chuoi nhip nhe lien tiep (vd cham
  /// tung chu) thi moi cham 1 nhip.
  static const refractory = Duration(milliseconds: 350);

  @visibleForTesting
  static void resetForTest() {
    _micOwners.clear();
    _queued = null;
    _flush = null;
    _lastLevel = null;
    _lastAt = null;
    _lastFrame = null;
    now = DateTime.now;
  }

  /// Rung cho [event]. Cac lan goi truoc khi microtask rung chay (vd nhieu
  /// the cung build) gop thanh 1 lan o muc manh nhat; them [refractory] de
  /// khong rung chong. Co mic dang thu luc rung (ke ca vua bat ngay sau lan
  /// goi) thi im lang. Bao hieu ([gtHapticIsAlert]) thi rung ngay.
  static Future<void> play(GtHapticEvent event) {
    final level = gtHapticLevel(event);
    if (gtHapticIsAlert(event)) {
      _lastAt = now();
      _lastFrame = _frameStamp();
      _lastLevel = level;
      return _vibrate(level);
    }
    if (micActive) return Future.value();
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
      final frame = _frameStamp();
      final lastAt = _lastAt;
      final lastLevel = _lastLevel;
      final lastFrame = _lastFrame;
      // "Vua rung" chi khi CA dong ho that LAN dong ho khung hinh deu thay
      // gan: test (thoi gian gia, chay rat nhanh) va luc man hinh dung yen
      // (khong co khung hinh moi) deu dung.
      final frameGap = lastFrame == null ? Duration.zero : frame - lastFrame;
      final recent =
          lastAt != null &&
          at.difference(lastAt) < refractory &&
          !frameGap.isNegative &&
          frameGap < refractory;
      final tapAfterTap =
          strongest == GtHapticLevel.selection &&
          lastLevel == GtHapticLevel.selection;
      if (recent &&
          !tapAfterTap &&
          lastLevel != null &&
          strongest.index <= lastLevel.index) {
        return;
      }
      _lastAt = at;
      _lastFrame = frame;
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
