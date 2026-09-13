import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Widget hien avatar sieu thuc Anam.ai (video WebRTC, lipsync realtime) bang
/// cach nhung file assets/anam/anam_bridge.html qua InAppWebView.
///
/// Cach dung: giu 1 `GlobalKey<AnamLiveAvatarState>`, goi
/// `key.currentState?.sendAudioChunk(pcmBytes)` moi khi
/// GeminiLiveDirectClient.liveAudioChunks phat 1 chunk moi (NON-BLOCKING),
/// `key.currentState?.interruptPersona()` khi nguoi dung noi ngat loi (barge-in),
/// va `key.currentState?.endTurn()` khi luot AI noi ket thuc.
class AnamLiveAvatar extends StatefulWidget {
  const AnamLiveAvatar({
    super.key,
    required this.avatarId,
    required this.sessionTokenProvider,
    this.onReady,
    this.onError,
    this.staticPreviewAsset,
  });

  /// ID avatar Anam MUON dung hien tai - doi theo GeminiGender (xem
  /// AiVoiceChatScreen._currentAnamAvatarId). Widget tu phat hien thay doi
  /// (didUpdateWidget) va goi lai restartAnamSession voi token moi cho dung
  /// avatarId nay - xem _onAvatarIdChanged.
  final String avatarId;

  /// Ham tra ve 1 session token MOI cho [avatarId] duoc truyen vao - goi
  /// lai moi lan widget can (re)connect hoac doi avatar.
  final Future<String> Function(String avatarId) sessionTokenProvider;

  final VoidCallback? onReady;
  final void Function(String message)? onError;

  /// Anh tinh (asset) cua nhan vat, che phia tren WebView trong luc cho
  /// video WebRTC tai khung hinh dau tien (~vai giay) - fade dan bang
  /// AnimatedOpacity khi nhan tin hieu 'avatarReady' tu anam_bridge.html
  /// (xem AnamLiveAvatarState). Truyen null (mac dinh) neu chua co san anh
  /// chup nhan vat - se hien 1 placeholder don gian thay vi anh that.
  final String? staticPreviewAsset;

  @override
  State<AnamLiveAvatar> createState() => AnamLiveAvatarState();
}

class AnamLiveAvatarState extends State<AnamLiveAvatar> {
  InAppWebViewController? _controller;
  bool _ready = false;
  // Rieng voi _ready (an toan de goi JS) - bao video WebRTC da hien khung
  // hinh dau tien THUC SU (VIDEO_PLAY_STARTED, xem anam_bridge.html), dung
  // de fade an anh tinh che WebView luc dang tai (toi uu cam giac "tai
  // cham" - trang den ~5s truoc do gio duoc che bang anh tinh + fade muot).
  bool _videoReady = false;

  /// Non-blocking: nap ngay 1 chunk PCM16 (24kHz mono) sang WebView de Anam
  /// lipsync realtime. KHONG tu phat am thanh o tang Dart/Flutter - video
  /// WebRTC cua Anam (xem anam_bridge.html) da tu mang san audio dong bo voi
  /// hinh, khong can lam gi them ngoai goi ham nay.
  void sendAudioChunk(Uint8List pcm16) {
    final controller = _controller;
    if (controller == null || !_ready || pcm16.isEmpty) return;
    final base64Chunk = base64Encode(pcm16);
    unawaited(
      controller.evaluateJavascript(
        source: "sendGeminiStreamToAnam('$base64Chunk');",
      ),
    );
  }

  /// Ngắt lời (Barge-in): Dừng ngay lập tức âm thanh đang phát & avatar Anam khi người dùng nói cắt ngang
  void interruptPersona() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    unawaited(controller.evaluateJavascript(source: 'interruptPersona();'));
  }

  /// Báo Anam biết 1 lượt AI nói đã hết audio
  void endTurn() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    unawaited(controller.evaluateJavascript(source: 'endAnamTurn();'));
  }

  Future<void> _connect() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final token = await widget.sessionTokenProvider(widget.avatarId);
      await controller.evaluateJavascript(
        source: "initAnam('$token', '${widget.avatarId}');",
      );
    } catch (e) {
      widget.onError?.call('Khong lay duoc Anam session token: $e');
    }
  }

  /// Goi khi [AnamLiveAvatar.avatarId] doi (vd nguoi dung doi giong Gemini
  /// Live sang gioi tinh khac, xem AiVoiceChatScreen._onVoiceChanged) - xin
  /// token MOI cho avatarId moi roi restart toan bo phien WebRTC, vi Anam
  /// khong co API doi avatar giua chung 1 phien dang mo.
  @override
  void didUpdateWidget(covariant AnamLiveAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarId != widget.avatarId) {
      unawaited(_onSessionExpired());
    }
  }

  /// Goi khi WebView bao hieu 'anamSessionExpired' (xem
  /// anam_bridge.html - CONNECTION_CLOSED khong phai do chinh Flutter chu
  /// dong dong) - thuong xay ra sau ~3 phut voi goi Free cua Anam
  /// (maxSessionLengthSeconds trong anam_vercel_server/api/main.py). Xin
  /// ngay 1 session token moi roi day sang lai cho WebView de noi lai
  /// stream, khong can nguoi dung tu bam gi hay app phai reload man hinh.
  Future<void> _onSessionExpired() async {
    final controller = _controller;
    if (controller == null) return;
    _ready = false;
    try {
      final token = await widget.sessionTokenProvider(widget.avatarId);
      await controller.evaluateJavascript(
        source: "restartAnamSession('$token', '${widget.avatarId}');",
      );
    } catch (e) {
      widget.onError?.call('Khong xin duoc token moi de noi lai Anam: $e');
    }
  }

  @override
  void dispose() {
    _controller?.evaluateJavascript(source: 'stopAnam();');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildWebView(),
        // Anh tinh che WebView trong luc cho video WebRTC tai khung hinh
        // dau tien - fade dan 300ms khi _videoReady = true thay vi bien mat
        // dot ngot, giam cam giac "khung" luc chuyen tu anh sang video that.
        // IgnorePointer sau khi fade xong de khong chan cham vao video ben
        // duoi (video von da pointer-events:none nhung Positioned.fill cua
        // Flutter van co the nhan tap neu khong ignore).
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _videoReady,
            child: AnimatedOpacity(
              opacity: _videoReady ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: _buildStaticPreview(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticPreview() {
    final asset = widget.staticPreviewAsset;
    return ColoredBox(
      color: Colors.black,
      child: asset != null
          ? Image.asset(
              asset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialFile: 'assets/anam/anam_bridge.html',
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
      ),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
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
        // Kenh RIENG (khac 'anamEvent') cho tin hieu "phien Anam vua bi dong
        // ngoai y muon" (het han goi Free ~3 phut) - xem
        // anamClient.addListener(AnamEvent.CONNECTION_CLOSED, ...) trong
        // anam_bridge.html.
        controller.addJavaScriptHandler(
          handlerName: 'anamSessionExpired',
          callback: (args) {
            unawaited(_onSessionExpired());
          },
        );
        // Tin hieu RIENG bao khung hinh video dau tien da thuc su hien
        // (VIDEO_PLAY_STARTED ben JS) - dung de fade an anh tinh, khac voi
        // 'ready' (chi bao da an toan de goi sendAudioChunk/interruptPersona).
        controller.addJavaScriptHandler(
          handlerName: 'avatarReady',
          callback: (args) {
            if (mounted) setState(() => _videoReady = true);
          },
        );
      },
      onLoadStop: (controller, url) => _connect(),
    );
  }
}
