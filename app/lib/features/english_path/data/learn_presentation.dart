import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_progress.dart';
import 'english_path_state.dart';
import 'level_test.dart';

/// Loi nhan cua the English Level - khop voi man Lo trinh (khong bao "lam
/// Level Test" khi dang cho lam lai hoac da xong C1).
enum LevelCardState { noContent, learning, testReady, coolingDown, allDone }

LevelCardState levelCardState(
  ContentPack? pack,
  CefrLevel level,
  EnglishPathState state,
  DateTime now,
) {
  if (passedFinalStage(state)) return LevelCardState.allDone;
  if (pack == null) return LevelCardState.noContent;
  final progress = levelTestProgress(pack, level, state);
  if (progress == null) return LevelCardState.noContent;
  if (!progress.ready) return LevelCardState.learning;
  return switch (levelTestStatus(pack, state, now, stage: level)) {
    LevelTestStatus.coolingDown => LevelCardState.coolingDown,
    _ => LevelCardState.testReady,
  };
}

/// Tien do toi Level Test cua Stage [level] (the English Level o tab Hoc):
/// so Unit da xong / tong Unit, [fraction] cong them phan le cua Unit dang
/// hoc. null khi pack chua co noi dung cho Stage do - khi do KHONG ve thanh
/// tien do (spec #70: khong co % gia).
({int done, int total, double fraction, bool ready})? levelTestProgress(
  ContentPack pack,
  CefrLevel level,
  EnglishPathState state,
) {
  final units = unitsOf(pack, level);
  if (units.isEmpty) return null;
  final done = units.where((u) => isUnitComplete(u, state)).length;
  final ready = done == units.length;
  final current = nextUnit(pack, level, state);
  final partial = current == null ? 0.0 : unitProgress(current, state);
  final fraction = ready ? 1.0 : (done + partial) / units.length;
  return (done: done, total: units.length, fraction: fraction, ready: ready);
}
