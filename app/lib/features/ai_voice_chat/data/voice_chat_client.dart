import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart' as rec;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Trang thai 1 phien AI Voice Chat.
enum VoiceChatState { idle, connecting, listening, error }

/// Giao dien chung cho 1 phien AI Voice Chat - [VoiceChatClient] (qua
/// backend/gemini-proxy, dung lau dai) va [GeminiLiveDirectClient] (ket noi
/// thang, chi dung tam thoi) deu cai giao dien nay, de AiVoiceChatScreen
/// doi qua lai giua 2 kieu ket noi chi bang 1 flag cau hinh.
abstract class VoiceChatSession {
  Stream<VoiceChatState> get stateStream;
  Stream<Uint8List> get incomingAudio;
  Future<void> start();
  Future<void> stop();
  void dispose();
}

/// Ket noi toi backend/gemini-proxy (xem backend/README.md): mo WebSocket,
/// stream audio tho tu mic (PCM 16-bit, 16kHz, mono - dung dinh dang
/// GeminiLiveSession.sendAudioChunk yeu cau ben server), va nhan lai audio
/// phan hoi dang file WAV hoan chinh moi luot noi (ca 2 nhanh Gemini/fallback
/// deu tra ve cung 1 dinh dang - xem geminiClient.js/tts.py ben backend).
class VoiceChatClient implements VoiceChatSession {
  VoiceChatClient({required this.backendUrl, required this.accessToken});

  /// URL WebSocket cua gemini-proxy, vd wss://your-server.example/voice-chat.
  /// Backend chua duoc deploy san - phai tu chay backend/gemini-proxy roi
  /// thay URL that vao day (xem VoiceChatConfig).
  final String backendUrl;
  final String accessToken;

  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _micSub;
  final rec.AudioRecorder _recorder = rec.AudioRecorder();

  final _stateController = StreamController<VoiceChatState>.broadcast();
  @override
  Stream<VoiceChatState> get stateStream => _stateController.stream;

  /// Moi event la 1 file WAV hoan chinh (1 luot AI noi) - san sang de phat
  /// truc tiep qua AudioPlayer.setFilePath sau khi ghi ra file tam.
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
      '$backendUrl?token=${Uri.encodeQueryComponent(accessToken)}',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    channel.stream.listen(
      (data) {
        if (data is List<int>) {
          _audioController.add(Uint8List.fromList(data));
        }
      },
      onError: (_) => _stateController.add(VoiceChatState.error),
      onDone: () => _stateController.add(VoiceChatState.idle),
    );
    await channel.ready;

    final micStream = await _recorder.startStream(
      const rec.RecordConfig(
        encoder: rec.AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _stateController.add(VoiceChatState.listening);
    _micSub = micStream.listen((chunk) => _channel?.sink.add(chunk));
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
