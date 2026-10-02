import 'dart:math' as math;
import 'dart:typed_data';

/// Muc am 0..1 cua 1 doan PCM 16-bit little-endian (mic 16 kHz / giong AI
/// 24 kHz): RMS doi ra dBFS, -50 dBFS (gan nhu im) -> 0, 0 dBFS -> 1.
double pcm16Level(Uint8List bytes) => _level(bytes, 0, bytes.length ~/ 2);

/// Muc am tung cua so [window] cua PCM 16-bit ([samplesPerSecond] = tan so
/// mau x so kenh) - de thanh song di theo dung thoi diem dang phat.
List<double> pcm16Envelope(
  Uint8List pcm, {
  required int samplesPerSecond,
  Duration window = const Duration(milliseconds: 50),
}) {
  final total = pcm.length ~/ 2;
  final perWindow = math.max(
    1,
    samplesPerSecond * window.inMicroseconds ~/ Duration.microsecondsPerSecond,
  );
  return [
    for (var start = 0; start < total; start += perWindow)
      _level(pcm, start, math.min(perWindow, total - start)),
  ];
}

/// Phan PCM 16-bit cua 1 file WAV kem so mau moi giay (tan so x so kenh);
/// null neu khong phai WAV PCM 16-bit doc duoc.
({Uint8List pcm, int samplesPerSecond})? wavPcm16(Uint8List wav) {
  if (wav.length < 12 ||
      String.fromCharCodes(wav, 0, 4) != 'RIFF' ||
      String.fromCharCodes(wav, 8, 12) != 'WAVE') {
    return null;
  }
  final data = ByteData.sublistView(wav);
  var perSecond = 0;
  var bits = 0;
  var offset = 12;
  while (offset + 8 <= wav.length) {
    final id = String.fromCharCodes(wav, offset, offset + 4);
    final size = data.getUint32(offset + 4, Endian.little);
    final body = offset + 8;
    if (id == 'fmt ' && body + 16 <= wav.length) {
      final channels = data.getUint16(body + 2, Endian.little);
      perSecond = data.getUint32(body + 4, Endian.little) * channels;
      bits = data.getUint16(body + 14, Endian.little);
    } else if (id == 'data') {
      if (perSecond <= 0 || bits != 16) return null;
      return (
        pcm: Uint8List.sublistView(
          wav,
          body,
          math.min(wav.length, body + size),
        ),
        samplesPerSecond: perSecond,
      );
    }
    // Khoi co do dai le duoc dem them 1 byte (chuan RIFF).
    offset = body + size + (size.isOdd ? 1 : 0);
  }
  return null;
}

/// Muc am cua [count] mau tinh tu mau thu [start].
double _level(Uint8List bytes, int start, int count) {
  if (count <= 0) return 0;
  final data = ByteData.sublistView(bytes);
  var sum = 0.0;
  for (var i = start; i < start + count; i++) {
    final s = data.getInt16(i * 2, Endian.little) / 32768;
    sum += s * s;
  }
  final rms = math.sqrt(sum / count);
  if (rms <= 0) return 0;
  final db = 20 * math.log(rms) / math.ln10;
  return ((db + 50) / 50).clamp(0.0, 1.0);
}
