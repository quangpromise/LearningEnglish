import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/speaking/data/sound_level.dart';

void main() {
  group('sound level (dB -> 0..1)', () {
    test('silence stays at 0, the loudest so far reaches toward 1', () {
      final meter = SoundLevelMeter(smoothing: 1);
      expect(meter.add(-2), 0);
      expect(meter.add(10), 1);
      expect(meter.add(4), closeTo(0.5, 1e-9));
    });

    test('works on both Android (~-2..10 dB) and iOS (~-50..0 dB) scales', () {
      final android = SoundLevelMeter(smoothing: 1)..add(-2);
      final ios = SoundLevelMeter(smoothing: 1)..add(-50);
      expect(android.add(10), 1);
      expect(ios.add(0), 1);
      expect(android.add(4), closeTo(ios.add(-25), 1e-9));
    });

    test('small noise does not fill the ring (minimum span)', () {
      final meter = SoundLevelMeter(smoothing: 1, minSpan: 8);
      meter.add(0);
      expect(meter.add(1), closeTo(1 / 8, 1e-9));
    });

    test('smoothing moves part of the way per sample', () {
      final meter = SoundLevelMeter(smoothing: 0.5)..add(0);
      meter.add(-8);
      expect(meter.add(0), closeTo(0.5, 1e-9));
      expect(meter.add(0), closeTo(0.75, 1e-9));
    });

    test('ignores non-finite samples and resets between listens', () {
      final meter = SoundLevelMeter(smoothing: 1)..add(0);
      meter.add(10);
      expect(meter.add(double.nan), 1);
      expect(meter.add(double.negativeInfinity), 1);
      meter.reset();
      expect(meter.level, 0);
      expect(meter.add(-40), 0);
    });

    test('always within 0..1', () {
      final meter = SoundLevelMeter();
      for (final db in [-60.0, 30.0, -5.0, 12.0, -100.0, 50.0]) {
        expect(meter.add(db), inInclusiveRange(0.0, 1.0));
      }
    });
  });
}
