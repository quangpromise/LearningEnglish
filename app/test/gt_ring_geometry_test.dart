import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/today/data/ring_geometry.dart';

double _deg(double rad) => rad * 180 / math.pi;

void main() {
  group('one ring split into 3 arcs (ADR-0007)', () {
    test('Tap starts at 12 o\'clock, arcs go clockwise in order', () {
      final arcs = segmentedRing([0, 0, 0], gapRadians: 0, capRadians: 0);
      expect(arcs, hasLength(3));
      expect(_deg(arcs[0].start), closeTo(-90, 1e-9));
      expect(_deg(arcs[1].start), closeTo(30, 1e-9));
      expect(_deg(arcs[2].start), closeTo(150, 1e-9));
      for (final a in arcs) {
        expect(_deg(a.span), closeTo(120, 1e-9));
      }
    });

    test('visible gap stays the same with round caps', () {
      const gap = 10 * math.pi / 180;
      const cap = 5 * math.pi / 180;
      final arcs = segmentedRing([1, 1, 1], gapRadians: gap, capRadians: cap);
      // Cuoi cung 1 (ke ca dau tron) toi dau cung 2 (ke ca dau tron).
      final end0 = arcs[0].start + arcs[0].span + cap;
      final start1 = arcs[1].start - cap;
      expect(_deg(start1 - end0), closeTo(10, 1e-9));
      expect(_deg(arcs[0].span), closeTo(120 - 10 - 10, 1e-9));
    });

    test('fill is proportional and clamped to the arc', () {
      final arcs = segmentedRing(
        [0.5, 1.4, -0.2],
        gapRadians: 0,
        capRadians: 0,
      );
      expect(_deg(arcs[0].fill), closeTo(60, 1e-9));
      expect(arcs[1].fill, arcs[1].span);
      expect(arcs[2].fill, 0);
    });
  });

  group('arcs that just completed', () {
    test('only arcs crossing to 100% count', () {
      expect(arcsJustCompleted([0.9, 1, 0.2], [1, 1, 0.6]), {0});
      expect(arcsJustCompleted([0, 0, 0], [1, 0.5, 1]), {0, 2});
    });

    test('nothing when already full or not full yet', () {
      expect(arcsJustCompleted([1, 1, 1], [1, 1, 1]), isEmpty);
      expect(arcsJustCompleted([0.2, 0.4, 0.6], [0.3, 0.5, 0.9]), isEmpty);
    });
  });
}
