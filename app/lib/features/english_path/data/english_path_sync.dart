import 'cefr_level.dart';
import 'english_path_state.dart';
import 'level_test_result.dart';

/// Gop state lo trinh cua 2 may (spec #45 - luat merge):
/// - item da dung / item tung sai: lay HOP;
/// - English Level: lay bac CAO hon;
/// - Level Test tung Stage, Placement: lay ban MOI hon;
/// - da bo qua Placement: HOAC;
/// - cau tung sai: HOP, TRU cau ma 1 ben da sua dung (co trong item dung
///   va khong con trong danh sach sai cua ben do) - de cau da on dung tren
///   may nay khong "song lai" tu may kia. Chi la tin hieu on tap nen chap
///   nhan le hiem (sai lai tren may kia SAU khi da sua dung o may nay).
/// Giao hoan va luy dang (gop lai bao nhieu lan cung ra 1 ket qua).
EnglishPathState mergeEnglishPathState(EnglishPathState a, EnglishPathState b) {
  final units = {...a.correctItems.keys, ...b.correctItems.keys};
  final stages = {...a.levelTests.keys, ...b.levelTests.keys};
  final pa = a.placement;
  final pb = b.placement;
  return EnglishPathState(
    level: _higher(a.level, b.level),
    correctItems: {
      for (final u in units) u: {...?a.correctItems[u], ...?b.correctItems[u]},
    },
    placement:
        pa == null || (pb != null && pb.finishedAt.isAfter(pa.finishedAt))
        ? pb
        : pa,
    placementSkipped: a.placementSkipped || b.placementSkipped,
    levelTests: {
      for (final s in stages) s: _newer(a.levelTests[s], b.levelTests[s])!,
    },
    wrongItems: {...a.wrongItems, ...b.wrongItems}
      ..removeAll(_cleared(a))
      ..removeAll(_cleared(b)),
  );
}

/// Item ben [s] da tra loi dung va khong con danh dau sai.
Set<String> _cleared(EnglishPathState s) => {
  for (final ids in s.correctItems.values)
    for (final id in ids)
      if (!s.wrongItems.contains(id)) id,
};

CefrLevel? _higher(CefrLevel? a, CefrLevel? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.index >= b.index ? a : b;
}

LevelTestResult? _newer(LevelTestResult? a, LevelTestResult? b) {
  if (a == null) return b;
  if (b == null) return a;
  return b.takenAt.isAfter(a.takenAt) ? b : a;
}

/// Ket qua gop du lieu lo trinh tu server.
enum RemoteMergeResult {
  /// Da gop vao may.
  merged,

  /// Du lieu server do ban app MOI HON ghi: giu nguyen may, KHONG ghi de
  /// server.
  remoteIsNewer,

  /// Server chua co / du lieu hong: bo qua, van day ban tren may len.
  ignored,
}
