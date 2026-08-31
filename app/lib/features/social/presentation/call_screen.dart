import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/config/env.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/call_repository.dart';
import '../data/social_repository.dart';

/// Man hinh dang trong 1 cuoc goi (ca phia goi va phia nhan, sau khi da
/// chap nhan) - noi dung/hinh anh truyen truc tiep qua Agora RTC, Supabase
/// chi dung de bao hieu bat dau/ket thuc (xem call_repository.dart).
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.call,
    required this.peer,
    required this.isCaller,
  });

  final Call call;
  final SocialUser peer;

  /// True neu minh la nguoi GOI (da o man "dang goi..." tu truoc, vao day
  /// ngay sau khi tao cuoc goi) - false neu minh la nguoi NHAN (vua bam
  /// Chap nhan o IncomingCallScreen).
  final bool isCaller;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _joined = false;
  bool _muted = false;
  late bool _videoEnabled;
  bool _frontCamera = true;
  String? _error;
  StreamSubscription<Call>? _callSub;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _videoEnabled = widget.call.type == CallType.video;
    _init();
    // Ben kia tu choi (chua bao gio join kenh Agora nen onUserOffline se
    // KHONG tu ban) hoac cup may - tu dong dong man hinh nay theo.
    _callSub = ref
        .read(callRepositoryProvider)
        .watchCall(widget.call.id)
        .listen((call) {
          if ((call.status == CallStatus.declined ||
                  call.status == CallStatus.ended) &&
              !_ended &&
              mounted) {
            _ended = true;
            Navigator.of(context).maybePop();
          }
        });
  }

  Future<void> _init() async {
    final statuses = await [
      Permission.microphone,
      if (_videoEnabled) Permission.camera,
    ].request();
    if (statuses.values.any((s) => !s.isGranted)) {
      setState(() => _error = ref.tr('call_permission_denied'));
      return;
    }

    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: Env.agoraAppId));
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (mounted) setState(() => _joined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (mounted) setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          // Ben kia da roi kenh (cup may) - tu dong dong man hinh cuoc goi.
          if (mounted) Navigator.of(context).maybePop();
        },
      ),
    );

    if (_videoEnabled) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.disableVideo();
    }

    final myId = ref.read(supabaseClientProvider).auth.currentUser!.id;
    final uid = ref.read(callRepositoryProvider).uidFor(myId);
    try {
      final token = await ref
          .read(callRepositoryProvider)
          .fetchToken(widget.call.channelName, uid);
      await engine.joinChannel(
        token: token,
        channelId: widget.call.channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _error = ref.tr('call_connect_error'));
      return;
    }

    setState(() => _engine = engine);
  }

  Future<void> _endCall() async {
    if (_ended) return;
    _ended = true;
    await ref
        .read(callRepositoryProvider)
        .updateStatus(widget.call.id, CallStatus.ended);
    await _engine?.leaveChannel();
    await _engine?.release();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _callSub?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endCall();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgTop,
        body: SafeArea(
          child: _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(child: _buildRemoteView()),
                    if (_videoEnabled && _engine != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        width: 100,
                        height: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 32,
                      child: _buildControls(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRemoteView() {
    if (_engine == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.blue),
            const SizedBox(height: 16),
            Text(ref.tr('call_connecting'), style: AppTextStyles.muted()),
          ],
        ),
      );
    }
    if (_videoEnabled && _remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.call.channelName),
        ),
      );
    }
    // Goi thoai, hoac video nhung ben kia chua join/da tat camera - hien
    // avatar + trang thai thay vi man hinh den.
    return Container(
      color: AppColors.bgMid,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.peer.avatarUrl != null
                  ? Image.network(widget.peer.avatarUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        widget.peer.label.isNotEmpty
                            ? widget.peer.label[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(widget.peer.label, style: AppTextStyles.heading(size: 18)),
            const SizedBox(height: 6),
            Text(
              _remoteUid != null
                  ? ref.tr('call_in_progress')
                  : (_joined
                        ? ref.tr('call_ringing')
                        : ref.tr('call_connecting')),
              style: AppTextStyles.muted(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlBtn(
          icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
          active: _muted,
          onTap: () {
            setState(() => _muted = !_muted);
            _engine?.muteLocalAudioStream(_muted);
          },
        ),
        const SizedBox(width: 18),
        // "Tat video khi goi" - chuyen 1 cuoc goi video thanh chi con tieng,
        // khong can cup may goi lai.
        _ControlBtn(
          icon: _videoEnabled
              ? Icons.videocam_rounded
              : Icons.videocam_off_rounded,
          active: !_videoEnabled,
          onTap: () async {
            final enable = !_videoEnabled;
            setState(() => _videoEnabled = enable);
            if (enable) {
              await _engine?.enableVideo();
              await _engine?.startPreview();
            } else {
              await _engine?.disableVideo();
            }
          },
        ),
        if (_videoEnabled) ...[
          const SizedBox(width: 18),
          _ControlBtn(
            icon: Icons.cameraswitch_rounded,
            active: false,
            onTap: () {
              setState(() => _frontCamera = !_frontCamera);
              _engine?.switchCamera();
            },
          ),
        ],
        const SizedBox(width: 18),
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.pink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active ? Colors.white : AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.bgTop : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
