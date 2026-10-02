import 'dart:math' as math;
import 'dart:typed_data';

import 'voice_chat_client.dart';

/// Trang thai PT AI hien cho nguoi dung (spec #96, MO-09): Nghe (mic dang
/// thu) -> Nghi (tu luc tha mic toi goi am thanh AI dau tien) -> Noi (tu goi
/// dau toi het luot).
enum PtVoiceState { idle, connecting, listening, thinking, speaking, error }

/// Suy trang thai hien thi tu trang thai client va viec AI da bat dau tra
/// am thanh cho luot nay chua ([aiSpeaking]: tu goi am thanh AI dau tien toi
/// khi het luot / bi ngat). Nguoi dung bam mic noi chen thi uu tien Nghe.
PtVoiceState ptVoiceState(VoiceChatState client, {required bool aiSpeaking}) =>
    switch (client) {
      VoiceChatState.error => PtVoiceState.error,
      VoiceChatState.connecting => PtVoiceState.connecting,
      VoiceChatState.listening => PtVoiceState.listening,
      VoiceChatState.thinking =>
        aiSpeaking ? PtVoiceState.speaking : PtVoiceState.thinking,
      VoiceChatState.idle =>
        aiSpeaking ? PtVoiceState.speaking : PtVoiceState.idle,
    };

/// Muc am 0..1 cua 1 doan PCM 16-bit little-endian (mic 16 kHz / giong AI
/// 24 kHz): RMS doi ra dBFS, -50 dBFS (gan nhu im) -> 0, 0 dBFS -> 1.
double pcm16Level(Uint8List bytes) {
  final samples = bytes.length ~/ 2;
  if (samples == 0) return 0;
  final data = ByteData.sublistView(bytes, 0, samples * 2);
  var sum = 0.0;
  for (var i = 0; i < samples; i++) {
    final s = data.getInt16(i * 2, Endian.little) / 32768;
    sum += s * s;
  }
  final rms = math.sqrt(sum / samples);
  if (rms <= 0) return 0;
  final db = 20 * math.log(rms) / math.ln10;
  return ((db + 50) / 50).clamp(0.0, 1.0);
}
