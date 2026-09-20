import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/heart_rate_model.dart';
import 'package:learn_english_music/features/fitness/data/ppg_analyzer.dart';

/// Sinh chuoi mau gia lap giong tin hieu camera that: 1 song hinh sin o
/// nhip [bpm], cong them do troi nen (ngon tay an chat dan lam khung hinh
/// sang len) va nhieu nho.
List<PpgSample> _fakeSignal({
  required int bpm,
  int seconds = 30,
  int fps = 30,
  double noise = 0.0,
  double drift = 12,
}) {
  final random = math.Random(42);
  final total = seconds * fps;
  return List<PpgSample>.generate(total, (i) {
    final t = i / fps;
    final pulse = 6 * math.sin(2 * math.pi * bpm / 60 * t);
    final baseline = 140 + drift * t / seconds;
    final jitter = noise * (random.nextDouble() - 0.5);
    return PpgSample((t * 1000).round(), baseline + pulse + jitter);
  });
}

void main() {
  group('analyzePpg', () {
    test('doc dung nhip tim tu tin hieu sach', () {
      for (final bpm in [48, 62, 75, 96, 120]) {
        final result = analyzePpg(_fakeSignal(bpm: bpm));
        expect(
          result.bpm,
          isNotNull,
          reason: 'phai doc duoc nhip tim o $bpm bpm',
        );
        // Sai so 3 bpm: mau lay o 30 khung/giay nen khoang cach giua 2 dinh
        // chi co the do chinh xac toi ~33ms.
        expect((result.bpm! - bpm).abs(), lessThanOrEqualTo(3));
      }
    });

    test('khu duoc do troi nen (ngon tay an chat dan)', () {
      final result = analyzePpg(_fakeSignal(bpm: 72, drift: 60));
      expect(result.bpm, isNotNull);
      expect((result.bpm! - 72).abs(), lessThanOrEqualTo(3));
    });

    test('bao nhieu thay vi doan bua khi tin hieu phang', () {
      final flat = List<PpgSample>.generate(900, (i) => PpgSample(i * 33, 20));
      final result = analyzePpg(flat);
      expect(result.bpm, isNull);
      expect(result.failure, HeartRateFailure.signalTooNoisy);
    });

    test('bao nhieu khi chi toan nhieu ngau nhien', () {
      final random = math.Random(7);
      final noisy = List<PpgSample>.generate(
        900,
        (i) => PpgSample(i * 33, 140 + 30 * random.nextDouble()),
      );
      final result = analyzePpg(noisy);
      expect(result.bpm, isNull);
      expect(result.failure, isNotNull);
    });

    test('khong tra ve ket qua khi qua it mau', () {
      final result = analyzePpg(_fakeSignal(bpm: 72, seconds: 1, fps: 10));
      expect(result.bpm, isNull);
      expect(result.failure, HeartRateFailure.signalTooNoisy);
    });

    test('tin hieu tra ve da duoc chuan hoa ve [-1, 1]', () {
      final result = analyzePpg(_fakeSignal(bpm: 72));
      expect(result.waveform, isNotEmpty);
      for (final v in result.waveform) {
        expect(v, inInclusiveRange(-1.0, 1.0));
      }
    });
  });
}
