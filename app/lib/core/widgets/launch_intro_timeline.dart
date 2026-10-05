import 'dart:math' as math;

import '../theme/gt_motion_math.dart';

/// Ban Launch Intro (CONTEXT.md): day du co ten tac gia, hoac ngan.
enum LaunchIntroVariant { full, short }

/// Ban day du khi build hien tai khac build da thay (lan mo dau tien sau khi
/// cai / cap nhat), ban ngan khi giong (spec #135, quyet dinh #1).
LaunchIntroVariant launchIntroVariant({
  required String? seenBuild,
  required String currentBuild,
}) => seenBuild == currentBuild
    ? LaunchIntroVariant.short
    : LaunchIntroVariant.full;

/// 3 cung Tap · Hoc · Noi cua vong intro: giong Daily Rings (cung dau o 12
/// gio, khe ~10 do - xem ring_geometry.dart), tru phan dau tron cua net.
List<({double start, double span})> launchRingArcs({
  required double radius,
  required double stroke,
}) {
  const gap = 10 * math.pi / 180;
  final cap = (stroke / 2) / radius;
  const slot = 2 * math.pi / 3;
  final span = slot - gap - 2 * cap;
  return [
    for (var i = 0; i < 3; i++)
      (start: -math.pi / 2 + i * slot + gap / 2 + cap, span: span),
  ];
}

/// Dong thoi gian Launch Intro (spec #135): moi gia tri la ham thuan cua thoi
/// gian `t` (ms ke tu khung dau) - widget chi viec ve. Thong so lay tu token
/// lo xo (gt_motion), khop ban xem thu da duyet.
class LaunchIntroTimeline {
  LaunchIntroTimeline(this.variant, {this.reduce = false});

  final LaunchIntroVariant variant;

  /// Giam chuyen dong: khung tinh roi mo dan, khong truot / nay / bay.
  final bool reduce;

  static final _eFast = gtSpringToken(
    GtMotionKind.expressive,
    GtMotionSpeed.fast,
  );
  static final _eNormal = gtSpringToken(
    GtMotionKind.expressive,
    GtMotionSpeed.normal,
  );
  static final _eSlow = gtSpringToken(
    GtMotionKind.expressive,
    GtMotionSpeed.slow,
  );
  static final _sNormal = gtSpringToken(
    GtMotionKind.standard,
    GtMotionSpeed.normal,
  );
  static final _sSlow = gtSpringToken(
    GtMotionKind.standard,
    GtMotionSpeed.slow,
  );
  static final _fFast = gtSpringToken(GtMotionKind.effects, GtMotionSpeed.fast);
  static final _fNormal = gtSpringToken(
    GtMotionKind.effects,
    GtMotionSpeed.normal,
  );
  static final _fSlow = gtSpringToken(GtMotionKind.effects, GtMotionSpeed.slow);

  /// Chu GymTalk + tagline + ten tac gia: chi ban day du.
  bool get hasWords => variant == LaunchIntroVariant.full;

  int get _ringStart => hasWords ? 400 : 150;
  int get _ringStep => hasWords ? 90 : 60;
  GtSpring get _ring => hasWords ? _eNormal : _eFast;
  GtSpring get _sweep => hasWords ? _sSlow : _sNormal;
  GtSpring get _push => hasWords ? _eSlow : _eNormal;
  double get _pushBy => hasWords ? 0.06 : 0.04;

  /// Giam chuyen dong: thoi gian giu khung tinh truoc khi mo (spec #135).
  static const _holdMs = 800;

  /// Luc bat dau roi man (vong bay vao the Daily Rings).
  int get exitMs => hasWords ? 2100 : 600;

  /// Luc vong khep: cung cuoi cham dich lan dau.
  int get closeAtMs => _ringStart + 2 * _ringStep + springReachMs(_ring);

  /// 1 nhip rung nhe (rung khong phai chuyen dong - giam chuyen dong van rung).
  int get hapticAtMs => reduce ? (_holdMs * 0.4).round() : closeAtMs;

  /// Luc intro xong han (go khoi cay widget).
  int get endMs =>
      reduce ? _holdMs + 120 : exitMs + springSettleMs(_sNormal) + 40;

  double _at(int start, GtSpring spring, double t) =>
      springProgress(spring, (t - start) / 1000);

  static double _c(double x) => x.clamp(0.0, 1.0);

  // ----------------------------------------------------------- logo + vet sang

  /// Nen + vien sang hien dan tu nen navy phang cua man cho he thong (khung
  /// dau khop han man cho).
  double ramp(double t) => reduce ? _c(t / 120) : _c(_at(0, _fNormal, t));

  /// Vi tri vet sang quet qua logo (0 -> 1).
  double sweep(double t) => reduce ? 0 : _at(0, _sweep, t);

  double sweepOpacity(double t) =>
      reduce ? 0 : 1 - _c(_at(_ringStart + 300, _fNormal, t));

  /// Do sang vien cam (0 = diu, 1 = dinh luc vet sang qua giua).
  double rim(double t) =>
      reduce ? 0.9 : _c(math.sin(math.pi * _c(sweep(t) * 1.05)));

  /// Camera day nhe vao (ti le).
  double push(double t) => reduce ? 1 : 1 + _pushBy * _at(0, _push, t);

  /// Logo nang tu giua man (cho man cho he thong de lai) len cho bo cuc
  /// (0 -> 1); ban ngan giu o giua.
  double lift(double t) {
    if (!hasWords) return 0;
    return reduce ? 1 : _at(0, _sNormal, t);
  }

  // ---------------------------------------------------------------------- vong

  /// Phan da ve cua cung [i] (0 -> 1).
  double arc(int i, double t) =>
      reduce ? 1 : _c(_at(_ringStart + i * _ringStep, _ring, t));

  /// Vong xoay vao vi tri (do).
  double spinDeg(double t) =>
      reduce ? 0 : -55 * (1 - _at(_ringStart, _sNormal, t));

  /// Loe sang khi vong khep: 0 -> dinh -> 0 (hieu 2 lo xo effects).
  double flash(double t) => reduce
      ? 0
      : _c(
          springProgress(_fFast, (t - closeAtMs) / 1000) -
              springProgress(_fSlow, (t - closeAtMs - 60) / 1000),
        );

  // ------------------------------------------------------------------- chu

  /// Ky tu [i] cua "GymTalk": do lech len (dp, theo man 400dp) va do mo.
  double letterY(int i, double t) =>
      reduce ? 0 : 26 * (1 - _at(900 + i * 40, _eNormal, t));

  double letterOpacity(int i, double t) =>
      reduce ? 1 : _c(_at(900 + i * 40, _fNormal, t));

  double taglineY(double t) => reduce ? 0 : 10 * (1 - _at(1150, _sNormal, t));

  double taglineOpacity(double t) => reduce ? 1 : _c(_at(1150, _fNormal, t));

  // -------------------------------------------------------------- tac gia

  double byOpacity(double t) => reduce ? 1 : _c(_at(1400, _fNormal, t));

  /// "Quang Promise" truot vao tu trai (dp).
  double nameLX(double t) => reduce ? 0 : -44 * (1 - _at(1450, _eNormal, t));

  double namesOpacity(double t) => reduce ? 1 : _c(_at(1450, _fNormal, t));

  /// "Tung Micky" truot vao tu phai (dp).
  double nameRX(double t) => reduce ? 0 : 44 * (1 - _at(1510, _eNormal, t));

  double nameROpacity(double t) => reduce ? 1 : _c(_at(1510, _fNormal, t));

  double timesScale(double t) => reduce ? 1 : 0.4 + 0.6 * _at(1600, _eFast, t);

  double timesOpacity(double t) => reduce ? 1 : _c(_at(1600, _fFast, t));

  /// Net chu ky vang duoi 2 ten (0 -> 1).
  double sign(double t) => reduce ? 1 : _c(_at(1680, _sSlow, t));

  // ---------------------------------------------------------------- roi man

  /// Logo, chu, ten tac gia mo dan khi roi man.
  double contentOpacity(double t) =>
      reduce ? 1 : 1 - _c(_at(exitMs, _fNormal, t));

  double contentScale(double t) =>
      reduce ? 1 : 1 - 0.04 * _at(exitMs, _sNormal, t);

  double skyOpacity(double t) =>
      reduce ? 1 : 1 - _c(_at(exitMs + 60, _fNormal, t));

  /// Vong bay vao the Daily Rings (0 -> 1).
  double flight(double t) => reduce ? 0 : _c(_at(exitMs, _sNormal, t));

  /// Cham the: vong intro nhuong cho vong tien do that.
  double ringOpacity(double t) =>
      reduce ? 1 : 1 - _c((flight(t) - 0.82) / 0.18);

  /// Do mo ca lop phu (giam chuyen dong: mo tuyen tinh 120 ms).
  double overlayOpacity(double t) {
    if (reduce) return 1 - _c((t - _holdMs) / 120);
    return t >= endMs ? 0 : 1;
  }

  // ------------------------------------------------------------------ bo qua

  /// Cham de bo qua luc [skipAtMs]: mo nhanh roi go.
  int skipEndMs(int skipAtMs) => skipAtMs + 170;

  double skipOpacity(int skipAtMs, double t) =>
      1 - _c(springProgress(_fFast, (t - skipAtMs) / 1000));
}
