import 'package:flutter/widgets.dart';

import 'gt_motion_math.dart';

export 'gt_motion_math.dart';

/// Nguoi dung muon giam chuyen dong: Android "Xoa hieu ung"
/// (`MediaQuery.disableAnimations`) HOAC iOS "Giam chuyen dong" (Flutter
/// khong gop co nay vao `disableAnimations`, phai doc rieng).
bool gtReduceMotion(BuildContext context) {
  if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return true;
  final view = View.maybeOf(context);
  return view?.platformDispatcher.accessibilityFeatures.reduceMotion ?? false;
}

/// Duong cong lo xo M3 Expressive tren khoang [durationMs] (spec #96). Co
/// the vuot qua 1 (nay) voi loai expressive.
class GtSpringCurve extends Curve {
  const GtSpringCurve(this.spring, this.durationMs);

  final GtSpring spring;
  final int durationMs;

  @override
  double transformInternal(double t) =>
      springProgress(spring, t * durationMs / 1000);
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
