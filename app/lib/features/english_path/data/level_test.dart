import 'dart:math';

import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_progress.dart';
import 'english_path_state.dart';
import 'level_test_result.dart';

export 'level_test_result.dart';

/// Level Test cuoi Stage (CONTEXT.md, spec #45).
const kLevelTestQuestions = 20;
const kLevelTestCooldown = Duration(hours: 24);

enum LevelTestStatus { locked, ready, coolingDown }

/// Da qua Level Test cua Stage cuoi (C1) - het noi dung, khong lam lai.
bool passedFinalStage(EnglishPathState state) =>
    state.levelTests[CefrLevel.values.last]?.passed ?? false;

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
  required CefrLevel stage,
}) {
  final s = stage;
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
  final units = unitsOf(pack, stage);
  // B1+: giu cho 1 bai doc IELTS Micro tron ven (moi cau cua 1 doan van,
  // spec #45 "B1+ co them 1 bai IELTS Micro Exercise dang doc").
  final passages = [
    for (final u in units)
      [
        for (final i in u.items)
          if (i.type == PracticeItemType.ieltsMicro) i,
      ],
  ].where((p) => p.isNotEmpty).toList();
  final out = <PracticeItem>[
    if (stage.index >= CefrLevel.b1.index && passages.isNotEmpty)
      ...passages[random.nextInt(passages.length)],
  ];
  final queues = [
    for (final u in units)
      ([
        for (final i in u.items)
          if (i.type != PracticeItemType.ieltsMicro) i,
      ]..shuffle(random)),
  ];
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
