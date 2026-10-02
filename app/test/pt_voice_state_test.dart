import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/ai_voice_chat/data/pt_voice_state.dart';
import 'package:learn_english_music/features/ai_voice_chat/data/voice_chat_client.dart';

/// PCM16 little-endian: [count] mau, luan phien +/-[amplitude].
Uint8List _square(int amplitude, {int count = 400}) {
  final data = ByteData(count * 2);
  for (var i = 0; i < count; i++) {
    data.setInt16(i * 2, i.isEven ? amplitude : -amplitude, Endian.little);
  }
  return data.buffer.asUint8List();
}

void main() {
  group('PT AI display state', () {
    test(
      'listening, then thinking until the first AI audio, then speaking',
      () {
        expect(
          ptVoiceState(VoiceChatState.listening, aiSpeaking: false),
          PtVoiceState.listening,
        );
        expect(
          ptVoiceState(VoiceChatState.thinking, aiSpeaking: false),
          PtVoiceState.thinking,
        );
        expect(
          ptVoiceState(VoiceChatState.thinking, aiSpeaking: true),
          PtVoiceState.speaking,
        );
      },
    );

    test('the reply can keep playing after the turn is idle', () {
      expect(
        ptVoiceState(VoiceChatState.idle, aiSpeaking: true),
        PtVoiceState.speaking,
      );
      expect(
        ptVoiceState(VoiceChatState.idle, aiSpeaking: false),
        PtVoiceState.idle,
      );
    });

    test('the user talking over the coach wins', () {
      expect(
        ptVoiceState(VoiceChatState.listening, aiSpeaking: true),
        PtVoiceState.listening,
      );
    });

    test('connecting and errors pass through', () {
      for (final speaking in [true, false]) {
        expect(
          ptVoiceState(VoiceChatState.connecting, aiSpeaking: speaking),
          PtVoiceState.connecting,
        );
        expect(
          ptVoiceState(VoiceChatState.error, aiSpeaking: speaking),
          PtVoiceState.error,
        );
      }
    });
  });

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
}
