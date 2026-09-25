import 'cefr_level.dart';

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
