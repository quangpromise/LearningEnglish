import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Widget hien avatar sieu thuc Anam.ai (video WebRTC, lipsync realtime) bang
/// cach nhung file assets/anam/anam_bridge.html qua InAppWebView. Day KHONG
/// tu phat audio nhan tu Gemini qua loa Flutter - chinh video WebRTC nay da
/// mang ca tieng lan hinh dong bo san (xem anam_bridge.html), nen man goi
/// AnamLiveAvatar PHAI tu tat phat lai audio rieng (vd _player.play trong
/// AiVoiceChatScreen) trong luc avatar dang bat, tranh phat trung 2 lan/lech
/// dong bo.
///
/// Cach dung: giu 1 `GlobalKey<AnamLiveAvatarState>`, goi
/// `key.currentState?.sendAudioChunk(pcmBytes)` moi khi
/// GeminiLiveDirectClient.liveAudioChunks phat 1 chunk moi, va
/// `key.currentState?.endTurn()` khi GeminiLiveDirectClient.turnAudioEnd bao
/// het 1 luot AI noi.
class AnamLiveAvatar extends StatefulWidget {
  const AnamLiveAvatar({
    super.key,
    required this.sessionTokenProvider,
    this.onReady,
    this.onError,
  });

  /// Ham tra ve 1 session token MOI moi lan widget can (re)connect - thuong
  /// la AnamSessionApi.fetchSessionToken(...). KHONG truyen thang API key
  /// that vao day.
  final Future<String> Function() sessionTokenProvider;

  final VoidCallback? onReady;
  final void Function(String message)? onError;

  @override
  State<AnamLiveAvatar> createState() => AnamLiveAvatarState();
}

class AnamLiveAvatarState extends State<AnamLiveAvatar> {
  InAppWebViewController? _controller;
  bool _ready = false;

  /// Nap 1 chunk PCM16 (24kHz, mono - dung dinh dang Gemini Live tra ve) vao
  /// mieng avatar de lipsync realtime. An toan khi goi truoc luc avatar san
  /// sang (_ready = false) - se bi bo qua lang le thay vi nem loi, vi audio
  /// co the toi truoc ca khi WebView tai xong lan dau.
  Future<void> sendAudioChunk(Uint8List pcm16) async {
    final controller = _controller;
    if (controller == null || !_ready || pcm16.isEmpty) return;
    final base64Chunk = base64Encode(pcm16);
    await controller.evaluateJavascript(
      source: "sendGeminiStreamToAnam('$base64Chunk');",
    );
  }

  /// Bao Anam biet 1 luot AI noi da het audio - goi khi
  /// GeminiLiveDirectClient bao turnComplete.
  Future<void> endTurn() async {
    if (!_ready) return;
    await _controller?.evaluateJavascript(source: 'endAnamTurn();');
  }

  Future<void> _connect() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final token = await widget.sessionTokenProvider();
      await controller.evaluateJavascript(source: "initAnam('$token');");
    } catch (e) {
      widget.onError?.call('Khong lay duoc Anam session token: $e');
    }
  }

  @override
  void dispose() {
    // Dong WebRTC phia JS truoc khi WebView bi huy - khong await duoc trong
    // dispose() nen chay "best-effort", khong cho ket qua.
    _controller?.evaluateJavascript(source: 'stopAnam();');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: 'assets/anam/anam_bridge.html',
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
        // Anam can quyen tu phat audio/video WebRTC (autoplay) ma khong cho
        // nguoi dung bam truoc - da co _player/mic o tang Flutter xin quyen
        // roi nen an toan bat luon o day.
        allowsInlineMediaPlayback: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        controller.addJavaScriptHandler(
          handlerName: 'anamEvent',
          callback: (args) {
            final type = args.isNotEmpty ? args[0] as String? : null;
            switch (type) {
              case 'ready':
                _ready = true;
                widget.onReady?.call();
                break;
              case 'error':
                _ready = false;
                final detail = args.length > 1 ? args[1]?.toString() : null;
                widget.onError?.call(detail ?? 'Anam avatar loi khong ro');
                break;
              default:
                break;
            }
          },
        );
      },
      onLoadStop: (controller, url) => _connect(),
    );
  }
}
