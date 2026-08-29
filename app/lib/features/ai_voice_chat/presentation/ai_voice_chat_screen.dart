import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_theme.dart';
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
  final AudioPlayer _player = AudioPlayer();

  VoiceChatState _state = VoiceChatState.idle;
  String? _error;

  @override
  void dispose() {
    _stateSub?.cancel();
    _audioSub?.cancel();
    _client?.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_state != VoiceChatState.idle && _state != VoiceChatState.error) {
      await _client?.stop();
      return;
    }

    final VoiceChatSession client;
    if (kUseDirectGeminiConnection) {
      // TAM THOI (xem voice_chat_config.dart) - bo qua dang nhap/backend.
      client = GeminiLiveDirectClient(apiKey: Env.geminiApiKeyDirect);
    } else {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) {
        setState(() {
          _error = 'Bạn cần đăng nhập để dùng AI Voice Chat';
          _state = VoiceChatState.error;
        });
        return;
      }
      client = VoiceChatClient(
        backendUrl: kVoiceChatBackendUrl,
        accessToken: token,
      );
    }

    setState(() {
      _error = null;
      _state = VoiceChatState.connecting;
    });
    _client = client;

    _stateSub?.cancel();
    _stateSub = client.stateStream.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _audioSub?.cancel();
    _audioSub = client.incomingAudio.listen(_playResponse);

    try {
      await client.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không kết nối được: $e';
          _state = VoiceChatState.error;
        });
      }
    }
  }

  Future<void> _playResponse(List<int> wavBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_chat_reply_${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).writeAsBytes(wavBytes);
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {
      // Loi phat lai khong lam gian doan phien chat - bo qua 1 luot noi.
    }
  }

  String _statusLabel() {
    switch (_state) {
      case VoiceChatState.idle:
        return 'Bấm micro để bắt đầu trò chuyện';
      case VoiceChatState.connecting:
        return 'Đang kết nối...';
      case VoiceChatState.listening:
        return 'Đang nghe — cứ nói tự nhiên bằng tiếng Anh';
      case VoiceChatState.error:
        return _error ?? 'Đã xảy ra lỗi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final active =
        _state == VoiceChatState.connecting ||
        _state == VoiceChatState.listening;

    return ScreenBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.blue,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('AI Voice Chat', style: AppTextStyles.heading(size: 20)),
              const SizedBox(height: 8),
              Text(
                _statusLabel(),
                textAlign: TextAlign.center,
                style: AppTextStyles.muted(),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _state == VoiceChatState.connecting ? null : _toggle,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (active ? AppColors.pink : AppColors.blue)
                            .withValues(alpha: 0.5),
                        blurRadius: 50,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: _state == VoiceChatState.connecting
                      ? const Padding(
                          padding: EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          active ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
