import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:record/record.dart' as rec;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'gemini_voices.dart' show kDefaultGeminiVoiceName;
import 'voice_chat_client.dart'
    show ChatRole, TranscriptEvent, VoiceChatSession, VoiceChatState;

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
  GeminiLiveDirectClient({
    required this.apiKey,
    this.model = _defaultModel,
    this.voiceName = kDefaultGeminiVoiceName,
  });

  final String apiKey;
  final String model;

  /// Ten 1 trong 30 giong dung san Gemini Live ho tro (xem gemini_voices.dart)
  /// - chi co tac dung luc gui setup luc bat dau ket noi, doi giong giua
  /// chung phien dang mo se khong co tac dung cho toi lan ket noi tiep theo.
  final String voiceName;

  static const _defaultModel = 'gemini-3.1-flash-live-preview';
  static const _outputSampleRate = 24000;

  /// Yeu cau AI noi ro cau "Correction: ..." khi bat loi - day la cach duy
  /// nhat de client doc duoc goi y sua loi dang text, vi phien Live nay chi
  /// tra ve audio (responseModalities: AUDIO) + ban transcribe lai giong noi
  /// cua no (outputTranscription), khong co kenh text rieng. Client se do
  /// tim cum "Correction: ..." trong ban transcribe do (xem
  /// _extractCorrection) de boi do tin nhan cua nguoi dung va hien goi y sua.
  /// Day la giai phap "best-effort" - phu thuoc model co tuan thu dung mau
  /// cau nay khi noi hay khong, khong dam bao 100%.
  static const _systemPrompt =
      'You are a friendly, patient English-speaking practice partner having '
      'a natural voice conversation with an intermediate English learner. '
      'You have ONE job on top of chatting: catch mistakes. Listen closely '
      'to every sentence the user says for grammar mistakes (verb tense, '
      'articles, word order, subject-verb agreement), wrong word choice or '
      'spelling, and pronunciation that a native speaker would not '
      'recognize. This check is MANDATORY for every single user turn, even '
      'though it may feel unnatural to break your reply this way - always '
      'do it anyway, exactly as instructed below.\n\n'
      'If the user made a mistake: reply normally and naturally to what '
      'they said first, then, as a separate final sentence, say exactly: '
      '"Correction: " followed by the full corrected sentence. Do this '
      'every time you notice a mistake, without exception.\n'
      'Example 1 (grammar) - user says "I go to store yesterday and buyed '
      'some milk": you could reply "Nice, what else did you get? '
      'Correction: I went to the store yesterday and bought some milk."\n'
      'Example 2 (wrong word / misspoken word) - user says "I am very '
      'confusing about this lesson" (they meant "confused"): you could '
      'reply "Which part is tricky? Correction: I am very confused about '
      'this lesson."\n\n'
      'If the user did not make any mistake, just reply normally and never '
      'say the word "Correction". Keep the normal part of your reply short.';

  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _micSub;
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final List<int> _turnAudio = [];
  final StringBuffer _inputText = StringBuffer();
  final StringBuffer _outputText = StringBuffer();

  static final RegExp _correctionPattern = RegExp(
    r'correction:\s*(.+?)(?:[.!?]\s|$)',
    caseSensitive: false,
  );

  /// Chi tiet loi gan nhat (ma dong WebSocket, ly do server tra ve...) -
  /// man hinh doc gia tri nay khi state chuyen sang error de hien thi thay
  /// vi 1 thong bao chung chung.
  @override
  String? lastError;

  final _stateController = StreamController<VoiceChatState>.broadcast();
  @override
  Stream<VoiceChatState> get stateStream => _stateController.stream;

  final _audioController = StreamController<Uint8List>.broadcast();
  @override
  Stream<Uint8List> get incomingAudio => _audioController.stream;

  final _transcriptController = StreamController<TranscriptEvent>.broadcast();
  @override
  Stream<TranscriptEvent> get transcriptStream => _transcriptController.stream;

  @override
  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      _stateController.add(VoiceChatState.error);
      throw Exception('Microphone permission denied');
    }

    // Chi mo ket noi moi lan dau (hoac sau khi loi/stop() dat _channel ve
    // null) - cac luot noi tiep theo trong cung 1 phien chat tai su dung
    // channel da mo, khong reconnect lai tu dau.
    if (_channel == null) {
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
              'speechConfig': {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': voiceName},
                },
              },
            },
            'systemInstruction': {
              'parts': [
                {'text': _systemPrompt},
              ],
            },
            // Bat transcription 2 chieu de hien thi hoi thoai dang text tren
            // man hinh (xem AiVoiceChatScreen) - khong anh huong toi audio.
            'inputAudioTranscription': <String, dynamic>{},
            'outputAudioTranscription': <String, dynamic>{},
            // Tat VAD tu dong phia server - nguoi dung tu bao luc bat dau/
            // ket thuc noi (activityStart/activityEnd trong start()/
            // endTurn()) thay vi de Gemini tu doan luc nao im lang la het
            // luot. Truoc day dung VAD tu dong khien AI khong bao gio ("hoac
            // rat lau") tra loi vi khong doan dung luc nguoi dung ngung noi.
            'realtimeInputConfig': {
              'automaticActivityDetection': {'disabled': true},
            },
          },
        }),
      );

      channel.stream.listen(
        _handleServerMessage,
        onError: (Object e) {
          lastError = 'Gemini Live connection error: $e';
          _stateController.add(VoiceChatState.error);
        },
        onDone: () {
          // Neu server tu dong dong ket noi (vd sai model, sai API key, het
          // quota) ma khong phai do nguoi dung bam dung, closeCode se khac
          // 1000 (normal closure) - phai bao loi ro rang thay vi im lang tro
          // ve idle, neu khong nguoi dung se tuong minh dang noi ma "khong ai
          // phan hoi" trong khi thuc ra ket noi da chet tu truoc.
          final code = channel.closeCode;
          if (code != null && code != 1000) {
            lastError =
                'Gemini Live closed the connection (code $code'
                '${channel.closeReason != null ? ": ${channel.closeReason}" : ""})';
            _stateController.add(VoiceChatState.error);
          } else {
            _stateController.add(VoiceChatState.idle);
          }
          _channel = null;
        },
      );
    }

    // Bao AI biet nguoi dung bat dau 1 luot noi moi - bat buoc phai gui
    // truoc audio vi automaticActivityDetection da bi tat o tren.
    _channel!.sink.add(
      jsonEncode({
        'realtimeInput': {'activityStart': <String, dynamic>{}},
      }),
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

  @override
  Future<void> endTurn() async {
    await _micSub?.cancel();
    _micSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    // Bao AI biet nguoi dung noi xong luot nay - vi da tat auto-VAD, khong
    // co tin hieu nay thi AI se cho mai khong bao gio tra loi.
    _channel?.sink.add(
      jsonEncode({
        'realtimeInput': {'activityEnd': <String, dynamic>{}},
      }),
    );
    _stateController.add(VoiceChatState.thinking);
  }

  void _handleServerMessage(dynamic raw) {
    // Server co the tra ve JSON qua text frame (String) HOAC binary frame
    // (List<int>/Uint8List) tuy engine WebSocket - truoc day chi xu ly
    // String nen khi server gui binary frame, moi phan hoi bi am tham bo qua
    // hoan toan (khong loi, khong audio, khong transcript - dung trieu chung
    // "bam mic nhung AI khong bao gio tra loi" du cho da doi rat lau).
    String text;
    if (raw is String) {
      text = raw;
    } else if (raw is List<int>) {
      try {
        text = utf8.decode(raw);
      } catch (_) {
        return;
      }
    } else {
      return;
    }

    Map<String, dynamic> message;
    try {
      message = jsonDecode(text) as Map<String, dynamic>;
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

    final inputChunk =
        (serverContent['inputTranscription'] as Map<String, dynamic>?)?['text']
            as String?;
    if (inputChunk != null) _inputText.write(inputChunk);

    final outputChunk =
        (serverContent['outputTranscription'] as Map<String, dynamic>?)?['text']
            as String?;
    if (outputChunk != null) _outputText.write(outputChunk);

    if (serverContent['turnComplete'] == true) {
      if (_turnAudio.isNotEmpty) {
        _audioController.add(_pcmToWav(Uint8List.fromList(_turnAudio)));
        _turnAudio.clear();
      }

      final userText = _inputText.toString().trim();
      _inputText.clear();
      if (userText.isNotEmpty) {
        _transcriptController.add(
          TranscriptEvent(role: ChatRole.user, text: userText),
        );
      }

      var aiText = _outputText.toString().trim();
      _outputText.clear();
      if (aiText.isNotEmpty) {
        final correction = _extractCorrection(aiText);
        if (correction != null) {
          aiText = aiText.replaceFirst(_correctionPattern, '').trim();
        }
        _transcriptController.add(
          TranscriptEvent(
            role: ChatRole.ai,
            text: aiText.isEmpty ? (correction ?? '') : aiText,
            correction: correction,
          ),
        );
      }

      // AI da tra loi xong luot nay - san sang cho nguoi dung bam mic noi
      // luot tiep theo (van dung chung 1 ket noi, khong reconnect lai).
      _stateController.add(VoiceChatState.idle);
    }
  }

  /// Tim cum "Correction: ..." (cau dung) trong ban transcribe loi noi cua
  /// AI - tra ve null neu AI khong bat loi nao o luot nay (xem _systemPrompt).
  String? _extractCorrection(String aiText) {
    final match = _correctionPattern.firstMatch(aiText);
    return match?.group(1)?.trim();
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
    _inputText.clear();
    _outputText.clear();
    _stateController.add(VoiceChatState.idle);
  }

  @override
  void dispose() {
    stop();
    _stateController.close();
    _audioController.close();
    _transcriptController.close();
    _recorder.dispose();
  }
}
