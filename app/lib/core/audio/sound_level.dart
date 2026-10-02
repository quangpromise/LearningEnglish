import 'dart:math' as math;

/// Chuan hoa muc am (dB) cua thu vien nhan giong ve 0..1 cho vong mic (spec
/// #96). Thang do khac nhau theo may: Android rmsdB ~ -2..10, iOS dBFS am
/// (~ -60..0) - nen tu hieu chinh theo khoang gap trong lan nghe:
/// - moc cao nhat dan nhanh ([highDecay]) ve phia mau moi: 1 tieng "bip" to
///   luc bat dau khong ghim thang do suot lan nghe;
/// - moc thap (nen on) nhich len cham ([lowRise]): noi lien tuc khong bi
///   coi la tieng on;
/// - mau duoi [silenceBelow] dB (buffer im tuyet doi tren iOS ~ -120) la im
///   lang, khong lam lech thang do;
/// - khoang toi thieu theo thang do: [minSpanRms] (Android) hoac
///   [minSpanDbfs] (dBFS, moc cao <= 0) de tieng on nho khong lam day vong;
/// - lam muot theo [smoothing] (trong so mau moi).
class SoundLevelMeter {
  SoundLevelMeter({
    this.minSpanRms = 8,
    this.minSpanDbfs = 20,
    this.silenceBelow = -90,
    this.highDecay = 0.08,
    this.lowRise = 0.01,
    this.smoothing = 0.4,
  }) : assert(minSpanRms > 0 && minSpanDbfs > 0),
       assert(highDecay >= 0 && highDecay <= 1),
       assert(lowRise >= 0 && lowRise <= 1),
       assert(smoothing > 0 && smoothing <= 1);

  final double minSpanRms;
  final double minSpanDbfs;
  final double silenceBelow;
  final double highDecay;
  final double lowRise;
  final double smoothing;

  double? _low;
  double? _high;
  double _level = 0;

  /// Muc hien tai 0..1.
  double get level => _level;

  /// Them 1 mau dB, tra ve muc 0..1 da lam muot.
  double add(double db) {
    if (db.isNaN) return _level;
    if (db < silenceBelow) {
      // Im tuyet doi: vong ve 0, thang do giu nguyen.
      _level -= _level * smoothing;
      return _level;
    }
    if (!db.isFinite) return _level;
    final prevHigh = _high;
    final high = _high = prevHigh == null || db >= prevHigh
        ? db
        : prevHigh - highDecay * (prevHigh - db);
    final prevLow = _low;
    final low = _low = prevLow == null || db <= prevLow
        ? db
        : prevLow + lowRise * (db - prevLow);
    final minSpan = high <= 0 ? minSpanDbfs : minSpanRms;
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
