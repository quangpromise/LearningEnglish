import 'dart:math';

import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_progress.dart';
import 'english_path_state.dart';

/// Level Test cuoi Stage (CONTEXT.md, spec #45).
const kLevelTestQuestions = 20;
const kLevelTestCooldown = Duration(hours: 24);

/// Ket qua 1 lan lam Level Test.
class LevelTestResult {
  const LevelTestResult({
    required this.stage,
    required this.correct,
    required this.total,
    required this.takenAt,
    required this.wrongItemIds,
  });

  factory LevelTestResult.fromJson(Map<String, dynamic> json) =>
      LevelTestResult(
        stage: CefrLevel.fromCode(json['stage'] as String),
        correct: json['correct'] as int,
        total: json['total'] as int,
        takenAt: DateTime.parse(json['takenAt'] as String),
        wrongItemIds: (json['wrongItemIds'] as List).cast<String>(),
      );

  final CefrLevel stage;
  final int correct;
  final int total;
  final DateTime takenAt;

  /// Cau sai - dung cho phien on tap trung truoc khi lam lai.
  final List<String> wrongItemIds;

  /// Dat khi >= 80% - so sanh so nguyen.
  bool get passed => total > 0 && correct * 5 >= total * 4;

  double? get estimatedBand => estimatedBandFor(stage, correct, total);

  Map<String, dynamic> toJson() => {
    'stage': stage.code,
    'correct': correct,
    'total': total,
    'takenAt': takenAt.toIso8601String(),
    'wrongItemIds': wrongItemIds,
  };
}

/// Khoang band tham chieu cua Stage, don vi NUA band (vd 9 = 4.5):
/// (band o 80%, band o 100%). Chi B1-C1 (spec #45).
const _bandRangeHalves = {
  CefrLevel.b1: (9, 10),
  CefrLevel.b2: (11, 13),
  CefrLevel.c1: (14, 15),
};

/// Estimated Band - chi de tham khao, KHONG phai diem IELTS chinh thuc.
/// Cong thuc spec #45: min + (score - 0.80) / 0.20 * (max - min), lam tron
/// XUONG toi 0.5; tinh bang so nguyen tu [correct]/[total] nen cac diem bien
/// (89.9%, 90%...) khong lech vi sai so so thuc. null khi A1/A2 hoac < 80%.
double? estimatedBandFor(CefrLevel stage, int correct, int total) {
  final range = _bandRangeHalves[stage];
  if (range == null || total <= 0 || correct * 5 < total * 4) return null;
  final (minHalves, maxHalves) = range;
  // (score - 0.8) / 0.2 = (5*correct - 4*total) / total
  final extraHalves =
      (5 * correct - 4 * total) * (maxHalves - minHalves) ~/ total;
  return (minHalves + extraHalves) / 2;
}

enum LevelTestStatus { locked, ready, coolingDown }

/// Thoi diem duoc lam lai sau khi truot; null neu chua truot.
DateTime? retryAt(EnglishPathState state, CefrLevel stage) {
  final last = state.levelTests[stage];
  if (last == null || last.passed) return null;
  return last.takenAt.add(kLevelTestCooldown);
}

LevelTestStatus levelTestStatus(
  ContentPack pack,
  EnglishPathState state,
  DateTime now, {
  CefrLevel? stage,
}) {
  final s = stage ?? state.level ?? CefrLevel.a1;
  if (!allUnitsComplete(pack, s, state)) return LevelTestStatus.locked;
  final retry = retryAt(state, s);
  if (retry != null && now.isBefore(retry)) return LevelTestStatus.coolingDown;
  return LevelTestStatus.ready;
}

/// 20 cau rai deu qua cac Unit cua Stage (lan luot tung Unit, moi Unit xao
/// tron); it hon 20 item thi lay het.
List<PracticeItem> buildLevelTest(
  ContentPack pack,
  CefrLevel stage,
  Random random,
) {
  final units = [
    for (final s in pack.stages)
      if (s.stage == stage) ...s.units,
  ];
  final queues = [
    for (final u in units) ([...u.items]..shuffle(random)),
  ];
  final out = <PracticeItem>[];
  var round = 0;
  while (out.length < kLevelTestQuestions) {
    var added = false;
    for (final q in queues) {
      if (round < q.length && out.length < kLevelTestQuestions) {
        out.add(q[round]);
        added = true;
      }
    }
    if (!added) break;
    round++;
  }
  return out..shuffle(random);
}

/// Cham bai: [answers][i] la dap an chon cho [items][i].
LevelTestResult scoreLevelTest({
  required CefrLevel stage,
  required List<PracticeItem> items,
  required List<int> answers,
  required DateTime takenAt,
}) {
  final wrong = <String>[];
  var correct = 0;
  for (var i = 0; i < items.length; i++) {
    if (i < answers.length && answers[i] == items[i].answerIndex) {
      correct++;
    } else {
      wrong.add(items[i].id);
    }
  }
  return LevelTestResult(
    stage: stage,
    correct: correct,
    total: items.length,
    takenAt: takenAt,
    wrongItemIds: wrong,
  );
}
