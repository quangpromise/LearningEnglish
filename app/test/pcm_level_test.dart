import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/audio/pcm_level.dart';

/// PCM16 little-endian: [count] mau, luan phien +/-[amplitude].
Uint8List _square(int amplitude, {int count = 400}) {
  final data = ByteData(count * 2);
  for (var i = 0; i < count; i++) {
    data.setInt16(i * 2, i.isEven ? amplitude : -amplitude, Endian.little);
  }
  return data.buffer.asUint8List();
}

/// File WAV PCM 16-bit; [extra] = 1 khoi phu (vd LIST) truoc khoi data.
Uint8List _wav(
  Uint8List pcm, {
  required int rate,
  int channels = 1,
  List<int> extra = const [],
}) {
  final out = BytesBuilder();
  void tag(String s) => out.add(ascii.encode(s));
  void u32(int v) => out.add(
    (ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List(),
  );
  void u16(int v) => out.add(
    (ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List(),
  );
  tag('RIFF');
  u32(36 + extra.length + pcm.length);
  tag('WAVE');
  tag('fmt ');
  u32(16);
  u16(1);
  u16(channels);
  u32(rate);
  u32(rate * channels * 2);
  u16(channels * 2);
  u16(16);
  out.add(extra);
  tag('data');
  u32(pcm.length);
  out.add(pcm);
  return out.toBytes();
}

void main() {
  group('PCM16 level', () {
    test('silence and empty chunks are 0', () {
      expect(pcm16Level(Uint8List(0)), 0);
      expect(pcm16Level(Uint8List(800)), 0);
    });

    test('full scale is 1, half scale about -6 dB', () {
      expect(pcm16Level(_square(32767)), closeTo(1, 1e-3));
      // -6 dBFS -> (50 - 6) / 50.
      expect(pcm16Level(_square(16384)), closeTo(0.88, 0.01));
    });

    test('very quiet audio stays near 0, never below', () {
      expect(pcm16Level(_square(30)), 0);
      expect(pcm16Level(_square(300)), inInclusiveRange(0.0, 0.25));
    });

    test('an odd trailing byte is ignored', () {
      final odd = Uint8List.fromList([..._square(16384, count: 10), 0x7f]);
      expect(pcm16Level(odd), closeTo(0.88, 0.01));
    });
  });

  group('envelope', () {
    test('one level per 50 ms window, the last one partial', () {
      // 24 kHz: 1200 mau = 50 ms.
      final pcm = Uint8List.fromList([
        ..._square(16384, count: 1200),
        ..._square(0, count: 1200),
        ..._square(32767, count: 600),
      ]);
      final levels = pcm16Envelope(pcm, samplesPerSecond: 24000);
      expect(levels, hasLength(3));
      expect(levels[0], closeTo(0.88, 0.01));
      expect(levels[1], 0);
      expect(levels[2], closeTo(1, 1e-3));
    });

    test('empty audio has no levels', () {
      expect(pcm16Envelope(Uint8List(0), samplesPerSecond: 24000), isEmpty);
    });
  });

  group('WAV', () {
    test('PCM and rate come from the header', () {
      final pcm = _square(16384, count: 2400);
      final parsed = wavPcm16(_wav(pcm, rate: 24000))!;
      expect(parsed.samplesPerSecond, 24000);
      expect(parsed.pcm, pcm);
    });

    test('stereo counts both channels, extra chunks are skipped', () {
      final pcm = _square(16384, count: 100);
      final parsed = wavPcm16(
        _wav(
          pcm,
          rate: 22050,
          channels: 2,
          extra: [...ascii.encode('LIST'), 3, 0, 0, 0, 1, 2, 3, 0],
        ),
      )!;
      expect(parsed.samplesPerSecond, 44100);
      expect(parsed.pcm, pcm);
    });

    test('anything else is not read', () {
      expect(
        wavPcm16(Uint8List.fromList(utf8.encode('not a wav file'))),
        isNull,
      );
      expect(wavPcm16(Uint8List(0)), isNull);
    });
  });
}
