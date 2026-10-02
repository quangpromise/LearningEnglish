import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_motion_math.dart';

void main() {
  group('spring tokens (Material 3 Expressive)', () {
    test('expressive default is the published 0.8 / 380 spring', () {
      final s = gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.normal);
      expect(s.damping, 0.8);
      expect(s.stiffness, 380);
    });

    test('standard default 0.9 / 700, effects default 1.0 / 1600', () {
      final std = gtSpringToken(GtMotionKind.standard, GtMotionSpeed.normal);
      expect((std.damping, std.stiffness), (0.9, 700.0));
      final fx = gtSpringToken(GtMotionKind.effects, GtMotionSpeed.normal);
      expect((fx.damping, fx.stiffness), (1.0, 1600.0));
    });
  });

  group('spring progress', () {
    test('starts at 0 and settles at 1', () {
      for (final kind in GtMotionKind.values) {
        final s = gtSpringToken(kind, GtMotionSpeed.normal);
        expect(springProgress(s, 0), closeTo(0, 1e-9), reason: '$kind');
        expect(springProgress(s, 3), closeTo(1, 1e-3), reason: '$kind');
      }
    });

    test('expressive overshoots, effects never does', () {
      final ex = gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.fast);
      final fx = gtSpringToken(GtMotionKind.effects, GtMotionSpeed.normal);
      double peak(GtSpring s) =>
          [for (var i = 0; i <= 600; i++) springProgress(s, i / 600)]
              .reduce((a, b) => a > b ? a : b);
      expect(peak(ex), greaterThan(1.01));
      expect(peak(fx), lessThanOrEqualTo(1.0 + 1e-9));
    });
  });

  group('settle duration', () {
    test('fast < normal < slow for every kind', () {
      for (final kind in GtMotionKind.values) {
        final f = springSettleMs(gtSpringToken(kind, GtMotionSpeed.fast));
        final n = springSettleMs(gtSpringToken(kind, GtMotionSpeed.normal));
        final s = springSettleMs(gtSpringToken(kind, GtMotionSpeed.slow));
        expect(f < n && n < s, isTrue, reason: '$kind: $f $n $s');
      }
    });

    test('stays within a sensible UI range', () {
      for (final kind in GtMotionKind.values) {
        for (final speed in GtMotionSpeed.values) {
          final ms = springSettleMs(gtSpringToken(kind, speed));
          expect(ms, inInclusiveRange(80, 1200), reason: '$kind $speed');
        }
      }
    });
  });

  group('reduced motion', () {
    test('spatial motion becomes instant', () {
      for (final kind in [GtMotionKind.expressive, GtMotionKind.standard]) {
        expect(motionDurationMs(kind, GtMotionSpeed.normal, reduce: true), 0);
      }
    });

    test('effects keep only a short fade', () {
      final ms = motionDurationMs(
        GtMotionKind.effects,
        GtMotionSpeed.normal,
        reduce: true,
      );
      expect(ms, inInclusiveRange(1, 150));
    });

    test('without reduced motion the spring settle time is used', () {
      final s = gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.normal);
      expect(
        motionDurationMs(
          GtMotionKind.expressive,
          GtMotionSpeed.normal,
          reduce: false,
        ),
        springSettleMs(s),
      );
    });
  });
}
