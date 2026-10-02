import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/audio/sound_level.dart';

void main() {
  group('sound level (dB -> 0..1)', () {
    test('quiet stays at 0, the loudest so far is near 1, mid is mid', () {
      final meter = SoundLevelMeter(smoothing: 1);
      expect(meter.add(-2), 0);
      expect(meter.add(10), closeTo(1, 1e-9));
      expect(meter.add(4), inInclusiveRange(0.35, 0.65));
    });

    test('works on both Android (~-2..10 dB) and iOS (~-60..0 dB)', () {
      final android = SoundLevelMeter(smoothing: 1)..add(-2);
      final ios = SoundLevelMeter(smoothing: 1)..add(-60);
      expect(android.add(10), closeTo(1, 1e-9));
      expect(ios.add(0), closeTo(1, 1e-9));
      expect(android.add(4), closeTo(ios.add(-30), 0.1));
    });

    test('small noise does not fill the ring (minimum span)', () {
      final meter = SoundLevelMeter(smoothing: 1, minSpanRms: 8);
      meter.add(0);
      expect(meter.add(1), lessThan(0.2));
    });

    test('smoothing moves part of the way per sample', () {
      final meter = SoundLevelMeter(smoothing: 0.5)..add(0);
      final first = meter.add(10);
      expect(first, closeTo(0.5, 0.05));
      expect(meter.add(10), greaterThan(first));
    });

    test('a loud first transient does not pin the scale (Android)', () {
      final meter = SoundLevelMeter(smoothing: 1);
      meter.add(-2);
      meter.add(12); // tieng bip / tieng go luc bat dau
      var peak = 0.0;
      for (var i = 0; i < 40; i++) {
        final level = meter.add(i.isEven ? 7 : 5);
        if (level > peak) peak = level;
      }
      expect(peak, greaterThan(0.6));
    });

    test('iOS: one silent buffer is ignored, room noise stays low', () {
      final meter = SoundLevelMeter(smoothing: 1);
      expect(meter.add(-120), 0); // buffer im tuyet doi dau tien
      var noise = 0.0;
      for (var i = 0; i < 20; i++) {
        noise = meter.add(i.isEven ? -58 : -52); // on phong
      }
      expect(noise, lessThan(0.5));
      expect(meter.add(-15), greaterThan(0.9));
    });

    test('ignores NaN, treats -inf as silence, resets between listens', () {
      final meter = SoundLevelMeter(smoothing: 1)..add(0);
      meter.add(10);
      expect(meter.add(double.nan), closeTo(1, 1e-9));
      expect(meter.add(double.negativeInfinity), 0);
      meter.reset();
      expect(meter.level, 0);
      expect(meter.add(-40), 0);
    });

    test('always within 0..1', () {
      final meter = SoundLevelMeter();
      for (final db in [-60.0, 30.0, -5.0, 12.0, -100.0, 50.0, -200.0]) {
        expect(meter.add(db), inInclusiveRange(0.0, 1.0));
      }
    });
  });
}
