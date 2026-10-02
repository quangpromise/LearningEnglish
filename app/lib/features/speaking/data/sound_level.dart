import 'dart:math' as math;

/// Chuan hoa muc am (dB) cua thu vien nhan giong ve 0..1 cho vong mic (spec
/// #96). Thang do khac nhau theo may: Android ~ -2..10 dB, iOS am (~ -50..0
/// dB) - nen tu hieu chinh theo khoang da gap trong lan nghe, toi thieu
/// [minSpan] dB de tieng on nho khong lam vong nhay het co. Lam muot theo
/// [smoothing] (trong so mau moi) de vong khong giat.
class SoundLevelMeter {
  SoundLevelMeter({this.minSpan = 8, this.smoothing = 0.4});

  final double minSpan;
  final double smoothing;

  double? _low;
  double? _high;
  double _level = 0;

  /// Muc hien tai 0..1.
  double get level => _level;

  /// Them 1 mau dB, tra ve muc 0..1 da lam muot.
  double add(double db) {
    if (!db.isFinite) return _level;
    final low = _low = math.min(_low ?? db, db);
    final high = _high = math.max(_high ?? db, db);
    final span = math.max(minSpan, high - low);
    final raw = ((db - low) / span).clamp(0.0, 1.0);
    _level += (raw - _level) * smoothing;
    return _level;
  }

  /// Lan nghe moi: quen khoang cu.
  void reset() {
    _low = null;
    _high = null;
    _level = 0;
  }
}
