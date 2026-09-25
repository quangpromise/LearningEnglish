import 'dart:math';

import 'cefr_level.dart';
import 'content_pack.dart';

/// So cau hoi moi Stage va so cau dung toi thieu de "dat" (spec #45).
const kPlacementItemsPerStage = 3;
const kPlacementPassCount = 2;

/// Toi da 5 Stage x 3 cau.
final kPlacementMaxQuestions =
    CefrLevel.values.length * kPlacementItemsPerStage;

/// Ly do dung Placement Test (luu vao ban ghi de audit).
/// - bracketed: da kep giua 1 Stage dat va 1 Stage khong dat.
/// - floorA1 / ceilingC1: cham bien duoi / bien tren.
/// - noContent: Stage ke tiep chua co noi dung trong Content Pack (bo sung
///   ngoai spec #45 vi pack chua du 5 Stage - ghi nhan o issue #49).
enum PlacementStopReason { bracketed, floorA1, ceilingC1, noContent }

enum PlacementConfidence { high, low }

class PlacementAnswer {
  const PlacementAnswer({
    required this.itemId,
    required this.stage,
    required this.correct,
    required this.at,
  });

  factory PlacementAnswer.fromJson(Map<String, dynamic> json) =>
      PlacementAnswer(
        itemId: json['itemId'] as String,
        stage: CefrLevel.fromCode(json['stage'] as String),
        correct: json['correct'] as bool,
        at: DateTime.parse(json['at'] as String),
      );

  final String itemId;
  final CefrLevel stage;
  final bool correct;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'stage': stage.code,
    'correct': correct,
    'at': at.toIso8601String(),
  };
}

/// Ban ghi audit cua 1 lan lam Placement Test.
class PlacementRecord {
  const PlacementRecord({
    required this.packVersion,
    required this.startStage,
    required this.result,
    required this.stopReason,
    required this.confidence,
    required this.answers,
    required this.stageResults,
    required this.startedAt,
    required this.finishedAt,
  });

  factory PlacementRecord.fromJson(
    Map<String, dynamic> json,
  ) => PlacementRecord(
    packVersion: json['packVersion'] as String,
    startStage: CefrLevel.fromCode(json['startStage'] as String),
    result: CefrLevel.fromCode(json['result'] as String),
    stopReason: PlacementStopReason.values.byName(json['stopReason'] as String),
    confidence: PlacementConfidence.values.byName(json['confidence'] as String),
    answers: [
      for (final a in json['answers'] as List)
        PlacementAnswer.fromJson(Map<String, dynamic>.from(a as Map)),
    ],
    stageResults: {
      for (final e in (json['stageResults'] as Map).entries)
        CefrLevel.fromCode(e.key as String): e.value as bool,
    },
    startedAt: DateTime.parse(json['startedAt'] as String),
    finishedAt: DateTime.parse(json['finishedAt'] as String),
  );

  final String packVersion;
  final CefrLevel startStage;
  final CefrLevel result;
  final PlacementStopReason stopReason;
  final PlacementConfidence confidence;
  final List<PlacementAnswer> answers;

  /// Stage da danh gia -> dat (>= 2/3) hay khong.
  final Map<CefrLevel, bool> stageResults;
  final DateTime startedAt;
  final DateTime finishedAt;

  Map<String, dynamic> toJson() => {
    'packVersion': packVersion,
    'startStage': startStage.code,
    'result': result.code,
    'stopReason': stopReason.name,
    'confidence': confidence.name,
    'answers': [for (final a in answers) a.toJson()],
    'stageResults': {for (final e in stageResults.entries) e.key.code: e.value},
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt.toIso8601String(),
  };
}

/// Placement Test thich ung kieu bac thang (spec #45): moi buoc hoi 3 cau
/// cua Stage hien tai; dat thi len, khong dat thi xuong; dung khi kep duoc
/// hoac cham bien A1/C1. Khong hoi lai Stage da danh gia -> toi da 15 cau.
class PlacementSession {
  PlacementSession({
    required CefrLevel start,
    required Map<CefrLevel, List<PracticeItem>> pool,
    required this.packVersion,
    Random? random,
    DateTime Function()? clock,
  }) : _pool = pool,
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now {
    if (!canRunPlacement(pool)) {
      throw StateError('Content Pack has no stage with enough items');
    }
    _startedAt = _clock();
    // Stage xuat phat theo Persona; neu Stage do chua co noi dung thi lui
    // xuong Stage cao nhat co noi dung (hoac len, neu duoi khong con Stage
    // nao) - startStage trong ban ghi la Stage thuc su bat dau.
    final withContent = CefrLevel.values.where(_hasContent).toList();
    final atOrBelow = withContent.where((s) => s.index <= start.index);
    _startStage = atOrBelow.isNotEmpty ? atOrBelow.last : withContent.first;
    _enter(_startStage);
  }

  final Map<CefrLevel, List<PracticeItem>> _pool;
  final Random _random;
  final DateTime Function() _clock;
  final String packVersion;

  late final DateTime _startedAt;
  late final CefrLevel _startStage;
  late CefrLevel _stage;
  List<PracticeItem> _stageItems = const [];
  int _stageAsked = 0;
  int _stageCorrect = 0;
  final List<PlacementAnswer> _answers = [];
  final Map<CefrLevel, bool> _results = {};
  PlacementRecord? _record;

  bool get isFinished => _record != null;
  PlacementRecord? get record => _record;
  CefrLevel get currentStage => _stage;

  /// So cau da tra loi.
  int get asked => _answers.length;

  PracticeItem? get current => isFinished ? null : _stageItems[_stageAsked];

  bool _hasContent(CefrLevel s) =>
      (_pool[s]?.length ?? 0) >= kPlacementItemsPerStage;

  void _enter(CefrLevel s) {
    _stage = s;
    _stageItems = ([
      ..._pool[s]!,
    ]..shuffle(_random)).take(kPlacementItemsPerStage).toList();
    _stageAsked = 0;
    _stageCorrect = 0;
  }

  /// Tra loi cau hien tai bang [optionIndex].
  void answer(int optionIndex) {
    final item = current;
    if (item == null) return;
    final correct = optionIndex == item.answerIndex;
    _answers.add(
      PlacementAnswer(
        itemId: item.id,
        stage: _stage,
        correct: correct,
        at: _clock(),
      ),
    );
    _stageAsked++;
    if (correct) _stageCorrect++;
    if (_stageAsked == kPlacementItemsPerStage) _evaluateStage();
  }

  void _evaluateStage() {
    final s = _stage;
    final passed = _stageCorrect >= kPlacementPassCount;
    _results[s] = passed;
    if (passed) {
      final up = s == CefrLevel.c1 ? null : CefrLevel.values[s.index + 1];
      if (up == null) {
        _finish(s, PlacementStopReason.ceilingC1);
      } else if (_results[up] == false) {
        _finish(s, PlacementStopReason.bracketed);
      } else if (!_hasContent(up)) {
        _finish(s, PlacementStopReason.noContent);
      } else {
        _enter(up);
      }
      return;
    }
    final down = s == CefrLevel.a1 ? null : CefrLevel.values[s.index - 1];
    if (down == null) {
      _finish(s, PlacementStopReason.floorA1);
    } else if (_results[down] == true) {
      _finish(down, PlacementStopReason.bracketed);
    } else if (!_hasContent(down)) {
      // Khong con Stage thap hon de kiem tra: xep vao Stage thap nhat co
      // noi dung (chinh Stage vua lam), confidence thap.
      _finish(s, PlacementStopReason.noContent);
    } else {
      _enter(down);
    }
  }

  void _finish(CefrLevel result, PlacementStopReason reason) {
    final confidence =
        reason != PlacementStopReason.noContent && _results.length >= 2
        ? PlacementConfidence.high
        : PlacementConfidence.low;
    _record = PlacementRecord(
      packVersion: packVersion,
      startStage: _startStage,
      result: result,
      stopReason: reason,
      confidence: confidence,
      answers: List.unmodifiable(_answers),
      stageResults: Map.unmodifiable(_results),
      startedAt: _startedAt,
      finishedAt: _clock(),
    );
  }
}

/// Co it nhat 1 Stage du cau hoi de lam Placement.
bool canRunPlacement(Map<CefrLevel, List<PracticeItem>> pool) =>
    pool.values.any((items) => items.length >= kPlacementItemsPerStage);

/// So cau dung / so cau da hoi cua tung Stage (de hien ket qua).
Map<CefrLevel, ({int correct, int asked})> placementStageScores(
  PlacementRecord record,
) {
  final out = <CefrLevel, ({int correct, int asked})>{};
  for (final a in record.answers) {
    final prev = out[a.stage] ?? (correct: 0, asked: 0);
    out[a.stage] = (
      correct: prev.correct + (a.correct ? 1 : 0),
      asked: prev.asked + 1,
    );
  }
  return out;
}

/// Pool cau hoi Placement tu Content Pack: moi Practice Item cua tung Stage.
Map<CefrLevel, List<PracticeItem>> placementPool(ContentPack pack) => {
  for (final s in pack.stages) s.stage: [for (final u in s.units) ...u.items],
};
