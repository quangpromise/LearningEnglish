import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/call_repository.dart';
import '../data/social_repository.dart';
import 'call_screen.dart';

/// Man hinh toan man "co cuoc goi den" - hien tren BAT KY man hinh nao dang
/// mo (xem root_shell.dart), giong incoming_message_banner.dart nhung
/// chiem toan man vi cuoc goi can hanh dong dut khoat (Chap nhan/Tu choi)
/// thay vi co the bo qua nhu tin nhan.
class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({
    super.key,
    required this.call,
    required this.caller,
  });

  final Call call;
  final SocialUser caller;

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  StreamSubscription<Call>? _callSub;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    // Ben goi co the tu huy (thoat man "dang goi...") truoc khi minh kip
    // bam gi - tu dong dong man hinh nay theo, khong de "cuoc goi ma" dung
    // yen mai tren man hinh.
    _callSub = ref
        .read(callRepositoryProvider)
        .watchCall(widget.call.id)
        .listen((call) {
          if (call.status != CallStatus.ringing && !_handled && mounted) {
            Navigator.of(context).maybePop();
          }
        });
  }

  @override
  void dispose() {
    _callSub?.cancel();
    super.dispose();
  }

  Future<void> _decline() async {
    _handled = true;
    await ref
        .read(callRepositoryProvider)
        .updateStatus(widget.call.id, CallStatus.declined);
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _accept() async {
    _handled = true;
    await ref
        .read(callRepositoryProvider)
        .updateStatus(widget.call.id, CallStatus.accepted);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            CallScreen(call: widget.call, peer: widget.caller, isCaller: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgTop,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.caller.avatarUrl != null
                      ? Image.network(
                          widget.caller.avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            widget.caller.label.isNotEmpty
                                ? widget.caller.label[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.caller.label,
                  style: AppTextStyles.heading(size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.call.type == CallType.video
                      ? ref.tr('call_incoming_video')
                      : ref.tr('call_incoming_voice'),
                  style: AppTextStyles.muted(),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _decline,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ref.tr('call_decline'),
                          style: AppTextStyles.muted(),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _accept,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ref.tr('call_accept'),
                          style: AppTextStyles.muted(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
