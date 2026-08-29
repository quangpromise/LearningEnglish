import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart' as rec;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Trang thai 1 phien AI Voice Chat.
enum VoiceChatState { idle, connecting, listening, error }

/// Ai la nguoi noi ra 1 doan hoi thoai da chuyen thanh text.
enum ChatRole { user, ai }

/// 1 luot noi da duoc nhan dien thanh text (STT) - hien thi giong 1 tin nhan
/// chat. [hasError] danh dau tin nhan cua nguoi dung bi AI phat hien sai ngu
/// phap/phat am o luot do; [correction] la cau noi dung AI goi y (chi co o
/// tin nhan cua AI, trich tu cau tra loi cua no - xem
/// GeminiLiveDirectClient._systemPrompt).
class TranscriptEvent {
  const TranscriptEvent({
    required this.role,
    required this.text,
    this.correction,
    this.hasError = false,
  });

  final ChatRole role;
  final String text;
  final String? correction;
  final bool hasError;

  TranscriptEvent copyWith({bool? hasError}) => TranscriptEvent(
    role: role,
    text: text,
    correction: correction,
    hasError: hasError ?? this.hasError,
  );
}

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

  /// Chi tiet loi gan nhat khi [stateStream] phat ra [VoiceChatState.error] -
  /// man hinh doc gia tri nay de hien thi nguyen nhan that thay vi 1 thong
  /// bao chung chung "da xay ra loi".
  String? get lastError => null;

  /// Text cua tung luot noi (ca nguoi dung lan AI) de hien thi dang chat.
  /// Mac dinh rong - chi GeminiLiveDirectClient ho tro (Gemini Live tra ve
  /// transcription that su); backend/gemini-proxy chua lam viec nay.
  Stream<TranscriptEvent> get transcriptStream =>
      const Stream<TranscriptEvent>.empty();
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
  String? lastError;

  @override
  Stream<TranscriptEvent> get transcriptStream =>
      const Stream<TranscriptEvent>.empty();

  @override
  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      _stateController.add(VoiceChatState.error);
      throw Exception('Microphone permission denied');
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
      onError: (Object e) {
        lastError = 'Server connection error: $e';
        _stateController.add(VoiceChatState.error);
      },
      onDone: () {
        final code = channel.closeCode;
        if (code != null && code != 1000) {
          lastError =
              'Server closed the connection (code $code'
              '${channel.closeReason != null ? ": ${channel.closeReason}" : ""})';
          _stateController.add(VoiceChatState.error);
        } else {
          _stateController.add(VoiceChatState.idle);
        }
      },
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
