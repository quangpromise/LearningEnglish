import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:record/record.dart' as rec;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'voice_chat_client.dart' show VoiceChatSession, VoiceChatState;

/// TAM THOI: ket noi THANG tu app toi Gemini Live API bang API key nhung
/// cung, BO QUA backend/gemini-proxy - CHI dung de test trong luc chua co
/// server that (xem cuoc trao doi ve Oracle Cloud out-of-capacity). API key
/// nhung trong app se bi lo neu ai decompile file APK - PHAI chuyen lai
/// dung VoiceChatClient (qua backend) truoc khi phat APK cho nhom dung that.
///
/// Giao thuc WebSocket tho (khong qua SDK @google/genai, vi SDK do la
/// Node.js, khong co ban Dart chinh thuc) - xem
/// https://ai.google.dev/api/live va https://ai.google.dev/gemini-api/docs/live-api
class GeminiLiveDirectClient implements VoiceChatSession {
  GeminiLiveDirectClient({required this.apiKey, this.model = _defaultModel});

  final String apiKey;
  final String model;

  static const _defaultModel = 'gemini-3.1-flash-live-preview';
  static const _outputSampleRate = 24000;
  static const _systemPrompt =
      'You are a friendly, patient English-speaking practice partner. Chat '
      'naturally in English with the user (an intermediate English learner). '
      'If they make a clear grammar or word-choice mistake, gently model the '
      'correct way to say it WHILE continuing the conversation naturally '
      '(do not over-explain). Keep replies short and easy to follow.';

  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _micSub;
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final List<int> _turnAudio = [];

  final _stateController = StreamController<VoiceChatState>.broadcast();
  @override
  Stream<VoiceChatState> get stateStream => _stateController.stream;

  final _audioController = StreamController<Uint8List>.broadcast();
  @override
  Stream<Uint8List> get incomingAudio => _audioController.stream;

  @override
  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      _stateController.add(VoiceChatState.error);
      throw Exception('Không có quyền truy cập micro');
    }

    _stateController.add(VoiceChatState.connecting);
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/'
      'google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent'
      '?key=$apiKey',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    await channel.ready;

    channel.sink.add(
      jsonEncode({
        'setup': {
          'model': 'models/$model',
          'generationConfig': {
            'responseModalities': ['AUDIO'],
          },
          'systemInstruction': {
            'parts': [
              {'text': _systemPrompt},
            ],
          },
        },
      }),
    );

    channel.stream.listen(
      _handleServerMessage,
      onError: (_) => _stateController.add(VoiceChatState.error),
      onDone: () => _stateController.add(VoiceChatState.idle),
    );

    final micStream = await _recorder.startStream(
      const rec.RecordConfig(
        encoder: rec.AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _stateController.add(VoiceChatState.listening);
    _micSub = micStream.listen((chunk) {
      _channel?.sink.add(
        jsonEncode({
          'realtimeInput': {
            'audio': {
              'data': base64Encode(chunk),
              'mimeType': 'audio/pcm;rate=16000',
            },
          },
        }),
      );
    });
  }

  void _handleServerMessage(dynamic raw) {
    if (raw is! String) return;
    Map<String, dynamic> message;
    try {
      message = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final serverContent = message['serverContent'] as Map<String, dynamic>?;
    if (serverContent == null) return;

    final parts =
        (serverContent['modelTurn'] as Map<String, dynamic>?)?['parts']
            as List?;
    if (parts != null) {
      for (final part in parts) {
        final inlineData =
            (part as Map<String, dynamic>)['inlineData']
                as Map<String, dynamic>?;
        final data = inlineData?['data'] as String?;
        if (data != null) {
          _turnAudio.addAll(base64Decode(data));
        }
      }
    }

    if (serverContent['turnComplete'] == true && _turnAudio.isNotEmpty) {
      _audioController.add(_pcmToWav(Uint8List.fromList(_turnAudio)));
      _turnAudio.clear();
    }
  }

  /// Boc PCM tho (16-bit, mono, 24kHz - dinh dang Gemini Live tra ve) thanh
  /// 1 file WAV hoan chinh de phat qua just_audio.
  Uint8List _pcmToWav(Uint8List pcm) {
    final byteRate = _outputSampleRate * 2;
    final header = ByteData(44);
    void writeAscii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, _outputSampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);
    return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
  }

  @override
  Future<void> stop() async {
    await _micSub?.cancel();
    _micSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _channel?.sink.close();
    _channel = null;
    _turnAudio.clear();
    _stateController.add(VoiceChatState.idle);
  }

  @override
  void dispose() {
    stop();
    _stateController.close();
    _audioController.close();
    _recorder.dispose();
  }
}
