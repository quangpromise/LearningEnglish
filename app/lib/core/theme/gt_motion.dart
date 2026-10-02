import 'package:flutter/widgets.dart';

import 'gt_motion_math.dart';

export 'gt_motion_math.dart';

/// Nguoi dung muon giam chuyen dong: Android "Xoa hieu ung"
/// (`MediaQuery.disableAnimations`) HOAC iOS "Giam chuyen dong" (Flutter
/// khong gop co nay vao `disableAnimations`, phai doc rieng).
///
/// Han che (iOS, giai doan 2): co iOS doc truc tiep tu View nen bat/tat giua
/// phien khong tu build lai - can 1 observer `didChangeAccessibilityFeatures`
/// o goc app khi phat hanh iOS.
bool gtReduceMotion(BuildContext context) {
  if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return true;
  final view = View.maybeOf(context);
  return view?.platformDispatcher.accessibilityFeatures.reduceMotion ?? false;
}

/// Duong cong lo xo M3 Expressive tren khoang [durationMs] (spec #96).
///
/// Gia tri co the vuot qua 1: expressive toi ~1.095, standard ~1.0015. Chi
/// dung truc tiep cho vi tri / ti le / goc; do mo (Opacity) hay chuoi
/// `CurveTween` se bao loi khi > 1 -> dung loai effects, hoac kep gia tri.
class GtSpringCurve extends Curve {
  const GtSpringCurve(this.spring, this.durationMs);

  final GtSpring spring;
  final int durationMs;

  @override
  double transformInternal(double t) =>
      springProgress(spring, t * durationMs / 1000);

  // So sanh theo gia tri: widget an (TweenAnimationBuilder...) khong dung
  // lai CurvedAnimation moi lan build.
  @override
  bool operator ==(Object other) =>
      other is GtSpringCurve &&
      other.spring == spring &&
      other.durationMs == durationMs;

  @override
  int get hashCode => Object.hash(spring, durationMs);
}

/// Duong cong lo xo cua 1 token tren dung thoi gian on dinh cua no (dung khi
/// controller cua cho dung chay theo thoi luong token).
GtSpringCurve gtSpringCurve(GtMotionKind kind, GtMotionSpeed speed) {
  final spring = gtSpringToken(kind, speed);
  return GtSpringCurve(spring, springSettleMs(spring));
}

/// Thoi luong + duong cong cho 1 chuyen dong theo loai/toc do va che do
/// giam chuyen dong. Giam chuyen dong: khong gian -> 0 ms (hien ngay),
/// effects -> mo ngan tuyen tinh.
///
/// Moi hoat anh moi lay thong so qua day. Luu y: `AnimationController`
/// mac dinh (AnimationBehavior.normal) tu rut thoi luong ~20 lan khi
/// Android tat hieu ung - controller nao dung de DEM THOI GIAN hien thi
/// (vd toast) phai dat `AnimationBehavior.preserve`.
({Duration duration, Curve curve}) gtMotion(
  BuildContext context,
  GtMotionKind kind, [
  GtMotionSpeed speed = GtMotionSpeed.normal,
]) {
  final reduce = gtReduceMotion(context);
  final ms = motionDurationMs(kind, speed, reduce: reduce);
  return (
    duration: Duration(milliseconds: ms),
    curve: reduce || ms == 0
        ? Curves.linear
        : GtSpringCurve(gtSpringToken(kind, speed), ms),
  );
}
