import 'dart:math' as math;

/// Khe hien thi giua 2 cung cua Daily Rings (~10 do, spec #96 #13).
const kRingGapRadians = 10 * math.pi / 180;

/// 1 cung: goc bat dau, do dai toan cung va phan da lap day (radian, chieu
/// kim dong ho, 0 = 3 gio).
typedef RingArc = ({double start, double span, double fill});

/// Daily Rings ve thanh MOT vong chia [ratios].length cung (ADR-0007): cung
/// dau bat dau o 12 gio, theo chieu kim dong ho. [capRadians] = nua do day
/// net quy ra goc (dau tron cua net an vao khe) - tru di de khe NHIN THAY
/// van dung [gapRadians].
List<RingArc> segmentedRing(
  List<double> ratios, {
  double gapRadians = kRingGapRadians,
  double capRadians = 0,
}) {
  final slot = 2 * math.pi / ratios.length;
  final span = slot - gapRadians - 2 * capRadians;
  return [
    for (var i = 0; i < ratios.length; i++)
      (
        start: -math.pi / 2 + i * slot + gapRadians / 2 + capRadians,
        span: span,
        fill: span * ratios[i].clamp(0.0, 1.0),
      ),
  ];
}

/// Chi so cac cung vua cham 100% (truoc < 1, gio >= 1) - de loe sang + rung
/// dung 1 lan.
Set<int> arcsJustCompleted(List<double> before, List<double> after) => {
  for (var i = 0; i < after.length && i < before.length; i++)
    if (before[i] < 1 && after[i] >= 1) i,
};
