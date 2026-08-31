import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
/// bien mat sau vai giay, bam vao de mo ngay khung chat voi nguoi gui, kem
/// am thanh "ding" bao co tin nhan moi. Day la thong bao TRONG APP (chi
/// hoat dong khi app dang chay) - khi app da dong/khoa may, xem ChatPush
/// (push notification he thong qua Firebase Cloud Messaging).
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
      onTap: () {
        entry.remove();
        openChatPopup(context, sender);
      },
    ),
  );
  overlay.insert(entry);
}

class _IncomingMessageBanner extends StatefulWidget {
  const _IncomingMessageBanner({
    required this.sender,
    required this.preview,
    required this.onDismiss,
    required this.onTap,
  });

  final SocialUser sender;
  final String preview;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  @override
  State<_IncomingMessageBanner> createState() => _IncomingMessageBannerState();
}

class _IncomingMessageBannerState extends State<_IncomingMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

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
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              child: GestureDetector(
                onTap: () {
                  _controller.stop();
                  widget.onTap();
                },
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
                  child: Row(
                    children: [
                      Container(
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
                                      ? widget.sender.label[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
