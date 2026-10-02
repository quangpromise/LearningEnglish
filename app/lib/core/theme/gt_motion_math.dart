import 'dart:math' as math;

/// Loai chuyen dong theo Material 3 Expressive (spec #96): expressive (co
/// nay, chi cho khoanh khac duoc thuong), standard (khong nay, UI thuong),
/// effects (mau / do mo, khong nay).
enum GtMotionKind { expressive, standard, effects }

enum GtMotionSpeed { fast, normal, slow }

/// Lo xo khoi luong 1: [damping] la ti so tat dan (1 = tat dan toi han).
typedef GtSpring = ({double damping, double stiffness});

/// Token M3 Expressive (androidx `ExpressiveMotionTokens` /
/// `StandardMotionTokens`, xem docs/research-motion-graphics.md).
GtSpring gtSpringToken(GtMotionKind kind, GtMotionSpeed speed) =>
    switch ((kind, speed)) {
      (GtMotionKind.expressive, GtMotionSpeed.fast) => (
        damping: 0.6,
        stiffness: 800.0,
      ),
      (GtMotionKind.expressive, GtMotionSpeed.normal) => (
        damping: 0.8,
        stiffness: 380.0,
      ),
      (GtMotionKind.expressive, GtMotionSpeed.slow) => (
        damping: 0.8,
        stiffness: 200.0,
      ),
      (GtMotionKind.standard, GtMotionSpeed.fast) => (
        damping: 0.9,
        stiffness: 1400.0,
      ),
      (GtMotionKind.standard, GtMotionSpeed.normal) => (
        damping: 0.9,
        stiffness: 700.0,
      ),
      (GtMotionKind.standard, GtMotionSpeed.slow) => (
        damping: 0.9,
        stiffness: 300.0,
      ),
      (GtMotionKind.effects, GtMotionSpeed.fast) => (
        damping: 1.0,
        stiffness: 3800.0,
      ),
      (GtMotionKind.effects, GtMotionSpeed.normal) => (
        damping: 1.0,
        stiffness: 1600.0,
      ),
      (GtMotionKind.effects, GtMotionSpeed.slow) => (
        damping: 1.0,
        stiffness: 800.0,
      ),
    };

/// Vi tri (0 -> 1) cua lo xo tha tu 0 ve dich 1 sau [seconds] giay, van toc
/// ban dau 0. Nghiem dong cua dao dong tat dan.
double springProgress(GtSpring s, double seconds) {
  if (seconds <= 0) return 0;
  final w = math.sqrt(s.stiffness);
  final z = s.damping;
  if (z >= 1) {
    // Tat dan toi han (token effects deu = 1).
    return 1 - math.exp(-w * seconds) * (1 + w * seconds);
  }
  final wd = w * math.sqrt(1 - z * z);
  return 1 -
      math.exp(-z * w * seconds) *
          (math.cos(wd * seconds) + (z * w / wd) * math.sin(wd * seconds));
}

/// Thoi gian (ms) de lo xo on dinh: sai lech voi dich < 0.1% va giu nguyen
/// tu do tro di.
int springSettleMs(GtSpring s) {
  const tolerance = 1e-3;
  const stepMs = 4;
  var lastOutside = 0;
  for (var ms = 0; ms <= 3000; ms += stepMs) {
    if ((1 - springProgress(s, ms / 1000)).abs() > tolerance) lastOutside = ms;
  }
  return lastOutside + stepMs;
}

/// Thoi luong mot chuyen dong. Giam chuyen dong: chuyen dong khong gian
/// (nay, truot, phong, lat) hien ngay; effects (mau / do mo) chi con mo
/// ngan.
int motionDurationMs(
  GtMotionKind kind,
  GtMotionSpeed speed, {
  required bool reduce,
}) {
  if (reduce) return kind == GtMotionKind.effects ? 120 : 0;
  return springSettleMs(gtSpringToken(kind, speed));
}
