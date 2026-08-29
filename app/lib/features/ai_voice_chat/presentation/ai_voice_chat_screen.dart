import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/gemini_live_direct_client.dart';
import '../data/voice_chat_client.dart';
import '../data/voice_chat_config.dart';

/// AI Voice Chat: tro chuyen tu do bang giong noi voi AI qua backend
/// gemini-proxy (xem backend/README.md ve kien truc + cach deploy). BAT
/// BUOC phai tu deploy backend va thay [kVoiceChatBackendUrl] truoc khi
/// tinh nang nay hoat dong duoc - chua co server nao duoc host san.
class AiVoiceChatScreen extends StatefulWidget {
  const AiVoiceChatScreen({super.key});

  @override
  State<AiVoiceChatScreen> createState() => _AiVoiceChatScreenState();
}

class _AiVoiceChatScreenState extends State<AiVoiceChatScreen> {
  VoiceChatSession? _client;
  StreamSubscription<VoiceChatState>? _stateSub;
  StreamSubscription<List<int>>? _audioSub;
  StreamSubscription<TranscriptEvent>? _transcriptSub;
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollCtrl = ScrollController();
  final List<TranscriptEvent> _messages = [];

  /// Duong dan file WAV vua nhan cho luot hien tai, cho den khi ghep vao
  /// TranscriptEvent cua AI cho luot do (audio luon den truoc transcript
  /// trong cung 1 luot - xem GeminiLiveDirectClient._handleServerMessage).
  String? _pendingAudioPath;

  VoiceChatState _state = VoiceChatState.idle;
  String? _error;

  @override
  void dispose() {
    _stateSub?.cancel();
    _audioSub?.cancel();
    _transcriptSub?.cancel();
    _client?.dispose();
    _player.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    // Dang noi - bam lai nghia la "toi noi xong roi", ket thuc luot nay va
    // cho AI tra loi (khong dong ca phien - xem VoiceChatSession.endTurn).
    if (_state == VoiceChatState.listening) {
      await _client?.endTurn();
      return;
    }
    // Dang ket noi hoac dang cho AI tra loi luot truoc - bo qua, nut da bi
    // vo hieu hoa trong build() nhung chan lai o day cho chac.
    if (_state == VoiceChatState.connecting ||
        _state == VoiceChatState.thinking) {
      return;
    }

    final existing = _client;
    final VoiceChatSession client;
    if (existing != null && _state == VoiceChatState.idle) {
      // Phien van dang mo (vua nhan xong 1 luot tra loi) - tai su dung, chi
      // bat dau ghi am luot moi thay vi tao ket noi moi tu dau.
      client = existing;
    } else {
      if (kUseDirectGeminiConnection) {
        // TAM THOI (xem voice_chat_config.dart) - bo qua dang nhap/backend.
        client = GeminiLiveDirectClient(apiKey: Env.geminiApiKeyDirect);
      } else {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token == null) {
          setState(() {
            _error = 'You need to sign in to use AI Voice Chat';
            _state = VoiceChatState.error;
          });
          return;
        }
        client = VoiceChatClient(
          backendUrl: kVoiceChatBackendUrl,
          accessToken: token,
        );
      }
      _client = client;

      _stateSub?.cancel();
      _stateSub = client.stateStream.listen((s) {
        if (!mounted) return;
        setState(() {
          _state = s;
          if (s == VoiceChatState.error) {
            _error = client.lastError ?? _error ?? 'Something went wrong';
          }
        });
      });
      _audioSub?.cancel();
      _audioSub = client.incomingAudio.listen(_playResponse);
      _transcriptSub?.cancel();
      _transcriptSub = client.transcriptStream.listen(_onTranscript);
    }

    setState(() {
      _error = null;
      _state = VoiceChatState.connecting;
    });

    try {
      await client.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not connect: $e';
          _state = VoiceChatState.error;
        });
      }
    }
  }

  /// Khi AI bao co loi (kem [TranscriptEvent.correction]), boi do luon tin
  /// nhan cua nguoi dung ngay truoc do - do la cau da gay ra loi goi y nay.
  void _onTranscript(TranscriptEvent event) {
    if (!mounted) return;
    setState(() {
      if (event.role == ChatRole.ai &&
          event.correction != null &&
          _messages.isNotEmpty &&
          _messages.last.role == ChatRole.user) {
        _messages[_messages.length - 1] = _messages.last.copyWith(
          hasError: true,
        );
      }
      var toAdd = event;
      if (event.role == ChatRole.ai && _pendingAudioPath != null) {
        toAdd = event.copyWith(audioPath: _pendingAudioPath);
        _pendingAudioPath = null;
      }
      _messages.add(toAdd);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _playResponse(List<int> wavBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_chat_reply_${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).writeAsBytes(wavBytes);
      // Ghi lai duong dan de _onTranscript gan vao tin nhan AI cua dung luot
      // nay, cho phep nghe lai sau nay thay vi chi nghe duoc 1 lan luc AI
      // vua tra loi.
      _pendingAudioPath = path;
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {
      // Loi phat lai khong lam gian doan phien chat - bo qua 1 luot noi.
    }
  }

  Future<void> _replayAudio(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {
      // Bo qua - file tam co the da bi he thong don dep.
    }
  }

  String _statusLabel() {
    switch (_state) {
      case VoiceChatState.idle:
        return 'Tap the mic to start chatting';
      case VoiceChatState.connecting:
        return 'Connecting...';
      case VoiceChatState.listening:
        return 'Recording — tap the mic again when you\'re done talking';
      case VoiceChatState.thinking:
        return 'Thinking...';
      case VoiceChatState.error:
        return _error ?? 'Something went wrong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = _state == VoiceChatState.listening;
    final busy =
        _state == VoiceChatState.connecting ||
        _state == VoiceChatState.thinking;

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.blue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text('AI Voice Chat', style: AppTextStyles.heading(size: 20)),
              ],
            ),
            Text(
              'Chat freely in English — the AI will point out your mistakes',
              style: AppTextStyles.muted(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No conversation yet.\nTap the mic below to start.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _MessageBubble(
                        message: _messages[i],
                        onReplay: _replayAudio,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusLabel(),
              textAlign: TextAlign.center,
              style: _state == VoiceChatState.error
                  ? AppTextStyles.muted().copyWith(color: AppColors.pink)
                  : AppTextStyles.muted(),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: busy ? null : _toggle,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (recording ? AppColors.pink : AppColors.blue)
                            .withValues(alpha: 0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          recording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onReplay});

  final TranscriptEvent message;

  /// Goi khi bam nut nghe lai tren bong bao tra loi tu nhien cua AI -
  /// nhan duong dan file WAV da luu tam cua dung luot noi do (xem
  /// AiVoiceChatScreen._replayAudio).
  final Future<void> Function(String path)? onReplay;

  @override
  Widget build(BuildContext context) {
    final isMine = message.role == ChatRole.user;
    final canReplay = !isMine && message.audioPath != null;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: canReplay ? () => onReplay!(message.audioPath!) : null,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isMine
                    ? (message.hasError
                          ? AppColors.pink.withValues(alpha: 0.18)
                          // Xanh kieu bong chat "cua minh" trong Messenger.
                          : const Color(0xFF0084FF))
                    : AppColors.glassFill,
                border: isMine
                    ? (message.hasError
                          ? Border.all(color: AppColors.pink, width: 1.4)
                          : null)
                    : Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: AppTextStyles.body(
                        color: isMine
                            ? (message.hasError ? AppColors.pink : Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  if (canReplay) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.correction != null)
            GestureDetector(
              onTap: () => AppTts.instance.speak(message.correction!),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Correct way to say it: ${message.correction}',
                        style: AppTextStyles.muted(size: 12)
                            .copyWith(color: AppColors.amber),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.amber,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
