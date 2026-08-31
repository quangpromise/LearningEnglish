import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/social_repository.dart';
import 'chat_screen.dart';

/// Am "ding" bao tin nhan (giong Messenger) khi popup trong app hien len -
/// dung rieng 1 AudioPlayer (khac AppTts) vi day la hieu ung UI ngan, khong
/// phai giong noi - tao moi + dispose ngay sau khi phat xong de khong ro ri.
Future<void> _playIncomingMessageSound() async {
  final player = AudioPlayer();
  try {
    await player.setAsset('assets/audio/notification_ding.wav');
    await player.play();
    await player.playerStateStream.firstWhere(
      (s) => s.processingState == ProcessingState.completed,
    );
  } catch (_) {
    // Khong phat duoc am thanh (thiet bi tat am, loi giai ma...) - khong
    // anh huong den viec hien banner.
  } finally {
    await player.dispose();
  }
}

/// Hien pop-up thong bao tin nhan moi kieu Messenger, tron len tren cung
/// man hinh hien tai (bat ke dang o tab nao) trong luc app dang mo - tu
/// bien mat sau 5 giay, bam vao de tra loi nhanh ngay tai cho (khong roi
/// man hinh dang xem), kem am thanh "ding" bao co tin nhan moi. Day la
/// thong bao TRONG APP (chi hoat dong khi app dang chay) - khi app da
/// dong/khoa may, xem ChatPush (push notification he thong qua Firebase
/// Cloud Messaging).
void showIncomingMessageBanner(
  BuildContext context, {
  required SocialUser sender,
  required String preview,
}) {
  _playIncomingMessageSound();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _IncomingMessageBanner(
      sender: sender,
      preview: preview,
      onDismiss: () => entry.remove(),
      onOpenChat: () {
        entry.remove();
        openChatPopup(context, sender);
      },
    ),
  );
  overlay.insert(entry);
}

class _IncomingMessageBanner extends ConsumerStatefulWidget {
  const _IncomingMessageBanner({
    required this.sender,
    required this.preview,
    required this.onDismiss,
    required this.onOpenChat,
  });

  final SocialUser sender;
  final String preview;
  final VoidCallback onDismiss;
  final VoidCallback onOpenChat;

  @override
  ConsumerState<_IncomingMessageBanner> createState() =>
      _IncomingMessageBannerState();
}

class _IncomingMessageBannerState extends ConsumerState<_IncomingMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  final _replyCtrl = TextEditingController();
  final _replyFocus = FocusNode();
  Timer? _autoDismissTimer;
  bool _replying = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _scheduleAutoDismiss();
  }

  void _scheduleAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  /// Bam vao banner - mo che do tra loi nhanh ngay tai cho thay vi chuyen
  /// man hinh, va tam dung dong ho tu tat de nguoi dung co du thoi gian go.
  void _startReplying() {
    _autoDismissTimer?.cancel();
    setState(() => _replying = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _replyFocus.requestFocus(),
    );
  }

  Future<void> _send() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(socialRepositoryProvider)
          .sendMessage(widget.sender.id, text);
      if (!mounted) return;
      _dismiss();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(ref.tr('chat_send_failed'))));
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    _replyCtrl.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Dismissible(
              key: ValueKey(widget.sender.id + widget.preview),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xEB0F1326),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _replying ? null : _startReplying,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _controller.stop();
                              widget.onOpenChat();
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                gradient: AppColors.accentGradient,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: widget.sender.avatarUrl != null
                                  ? Image.network(
                                      widget.sender.avatarUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        widget.sender.label.isNotEmpty
                                            ? widget.sender.label[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.sender.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  widget.preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.muted(size: 12.5),
                                ),
                              ],
                            ),
                          ),
                          if (!_replying) ...[
                            const SizedBox(width: 8),
                            // Nut rieng, ro rang de mo o tra loi nhanh - truoc
                            // day chi bam vao ca hang moi mo duoc, kho nhan
                            // biet la co the tra loi ngay tai day.
                            GestureDetector(
                              onTap: _startReplying,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.reply_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_replying) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GlowBox(
                              borderRadius: 999,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: TextField(
                                controller: _replyCtrl,
                                focusNode: _replyFocus,
                                style: AppTextStyles.body(size: 13),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: ref.tr('chat_input_hint'),
                                  hintStyle: AppTextStyles.muted(size: 13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sending ? null : _send,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                gradient: AppColors.accentGradient,
                                shape: BoxShape.circle,
                              ),
                              child: _sending
                                  ? const Padding(
                                      padding: EdgeInsets.all(9),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
