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

    test('overdamped springs rise to 1 and match a numeric solution', () {
      const s = (damping: 1.6, stiffness: 400.0);
      var last = 0.0;
      for (var ms = 4; ms <= 3000; ms += 4) {
        final x = springProgress(s, ms / 1000);
        expect(x, inInclusiveRange(last, 1.0), reason: '$ms ms');
        last = x;
      }
      expect(last, closeTo(1, 1e-3));
      // x'' = -k(x - 1) - c x', c = 2 * damping * sqrt(k); 0.2 s.
      var x = 0.0;
      var v = 0.0;
      const dt = 1e-5;
      for (var i = 0; i < 20000; i++) {
        v += (-400 * (x - 1) - 2 * 1.6 * 20 * v) * dt;
        x += v * dt;
      }
      expect(springProgress(s, 0.2), closeTo(x, 1e-3));
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

  group('spring reach time', () {
    test('a bouncy spring reaches its target well before it settles', () {
      final s = gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.normal);
      expect(springReachMs(s), inInclusiveRange(150, 300));
      expect(springReachMs(s), lessThan(springSettleMs(s)));
    });

    test('a non-bouncy spring reaches its target when it settles', () {
      final s = gtSpringToken(GtMotionKind.effects, GtMotionSpeed.normal);
      expect(springReachMs(s), closeTo(springSettleMs(s), 8));
    });
  });
}
