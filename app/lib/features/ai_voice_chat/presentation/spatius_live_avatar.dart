import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// 'ConnectionState' trung ten voi package:flutter/src/widgets/async.dart
// (AsyncSnapshot) - chi lay rieng ten do qua prefix 'spatius', phan con lai
// import binh thuong.
import 'package:spatius_avatarkit/spatius_avatarkit.dart' hide ConnectionState;
import 'package:spatius_avatarkit/spatius_avatarkit.dart'
    as spatius
    show ConnectionState;

/// Widget hien avatar Spatius AI - render NATIVE tren GPU may (3D Gaussian
/// Splatting) qua goi spatius_avatarkit, KHAC voi AnamLiveAvatar (WebView +
/// WebRTC). Dung lam du phong (failover) khi Anam loi khong the phuc hoi -
/// xem AiVoiceChatScreen._onAnamUnrecoverable.
///
/// Cung interface voi AnamLiveAvatar (sendAudioChunk/endTurn/interruptPersona)
/// de screen code goi doi xung du dang dung provider nao.
class SpatiusLiveAvatar extends StatefulWidget {
  const SpatiusLiveAvatar({
    super.key,
    required this.appId,
    required this.avatarId,
    required this.sessionTokenProvider,
    this.onReady,
    this.onError,
  });

  final String appId;
  final String avatarId;

  /// Ham tra ve 1 session token MOI moi lan widget can (re)connect.
  final Future<String> Function() sessionTokenProvider;

  final VoidCallback? onReady;
  final void Function(String message)? onError;

  @override
  State<SpatiusLiveAvatar> createState() => SpatiusLiveAvatarState();
}

class SpatiusLiveAvatarState extends State<SpatiusLiveAvatar> {
  AvatarController? _controller;
  Avatar? _avatar;
  bool _ready = false;
  bool _initializing = false;
  bool _sdkInitialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_connect());
  }

  /// Khoi tao AvatarSDK (1 LAN duy nhat - session token KHONG gan voi 1
  /// avatarId cu the, xem docs.spatius.ai/api-reference/api-reference: body
  /// chi co expireAt/modelVersion) roi tai avatar theo gioi tinh hien tai.
  Future<void> _connect() async {
    if (_initializing) return;
    _initializing = true;
    try {
      if (!_sdkInitialized) {
        final token = await widget.sessionTokenProvider();
        // Gemini Live tra ve PCM16 24kHz mono (xem
        // GeminiLiveDirectClient.liveAudioChunks) - dat sampleRate = 24000
        // de gui thang khong can resample.
        await AvatarSDK.initialize(
          appID: widget.appId,
          configuration: Configuration(
            audioFormat: const AudioFormat(sampleRate: 24000),
            drivingServiceMode: DrivingServiceMode.direct,
            logLevel: LogLevel.all,
          ),
        );
        await AvatarSDK.setSessionToken(token);
        _sdkInitialized = true;
      }
      await initSpatiusAvatarSession(widget.avatarId);
    } catch (e) {
      widget.onError?.call('Khong khoi tao duoc Spatius: $e');
    } finally {
      _initializing = false;
    }
  }

  /// Tai (hoac doi sang) avatar co [avatarId] - dat ten doi xung voi
  /// AnamLiveAvatar.initAnam/restartAnamSession (JS) de code goi tu
  /// AiVoiceChatScreen nhat quan giua 2 nha cung cap. Dong controller cu
  /// truoc khi tao AvatarWidget moi (moi avatar = 1 platform view rieng),
  /// tranh ro ri tai nguyen native.
  Future<void> initSpatiusAvatarSession(String avatarId) async {
    await _controller?.close();
    _controller = null;
    _ready = false;
    final avatar = await AvatarManager.shared.load(id: avatarId);
    if (!mounted) return;
    setState(() => _avatar = avatar);
  }

  /// Goi khi [SpatiusLiveAvatar.avatarId] doi (vd nguoi dung doi giong
  /// Gemini Live sang gioi tinh khac, xem AiVoiceChatScreen._onVoiceChanged).
  @override
  void didUpdateWidget(covariant SpatiusLiveAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarId != widget.avatarId && _sdkInitialized) {
      unawaited(initSpatiusAvatarSession(widget.avatarId));
    }
  }

  void _onAvatarViewCreated(AvatarController controller) {
    _controller = controller;
    controller.onConnectionState = (state, errorMessage) {
      if (state == spatius.ConnectionState.failed) {
        widget.onError?.call(
          'Spatius connection failed: ${errorMessage ?? "unknown"}',
        );
      }
    };
    // onError tra ve enum AvatarError, khong phai String - xem
    // spatius_avatarkit_plugin.dart (sessionTokenExpired, insufficientBalance...).
    controller.onError = (error) {
      widget.onError?.call('Spatius loi: ${error.name}');
    };
    unawaited(
      controller.start().then((_) {
        _ready = true;
        widget.onReady?.call();
      }),
    );
  }

  /// Non-blocking: nap 1 chunk PCM16 24kHz cho Spatius de lipsync realtime -
  /// cung chunk dang gui song song cho Anam qua GeminiLiveDirectClient.
  /// liveAudioChunks, xem AiVoiceChatScreen. `controller.send()` tra ve
  /// `Future<String>` (conversationID) - khong can cho ket qua, non-blocking.
  void sendAudioChunk(Uint8List pcm16) {
    final controller = _controller;
    if (controller == null || !_ready || pcm16.isEmpty) return;
    unawaited(controller.send(pcm16, end: false));
  }

  /// Bao 1 luot AI noi da het audio.
  void endTurn() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    unawaited(controller.send(Uint8List(0), end: true));
  }

  /// Ngat loi (barge-in) - AvatarController co san method rieng cho viec
  /// nay (khac Anam phai goi interruptPersona() ben JS).
  void interruptPersona() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    unawaited(controller.interrupt());
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;
    if (avatar == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }
    return AvatarWidget(
      avatar: avatar,
      onPlatformViewCreated: _onAvatarViewCreated,
    );
  }
}
