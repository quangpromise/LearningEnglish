import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/social_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.friend});
  final SocialUser friend;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Danh dau doc ngay khi mo cuoc hoi thoai - unreadMessageCountProvider
    // (Home) tu giam qua realtime stream, khong can invalidate thu cong.
    Future.microtask(
      () => ref.read(socialRepositoryProvider).markConversationRead(widget.friend.id),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _inputCtrl.clear();
    try {
      await ref
          .read(socialRepositoryProvider)
          .sendMessage(widget.friend.id, text);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final messagesStream = ref.watch(
      _conversationStreamProvider(widget.friend.id),
    );

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.friend.label,
                      style: AppTextStyles.heading(size: 16),
                    ),
                    Text(
                      widget.friend.isOnline
                          ? ref.tr('friends_online')
                          : ref.tr('friends_offline'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: messagesStream.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('chat_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (messages) {
                  _scrollToBottom();
                  // Ban nhan tin moi trong luc man hinh dang mo - danh dau
                  // doc ngay, khong doi nguoi dung roi man hinh roi quay lai.
                  if (messages.any(
                    (m) => m.receiverId == myId && m.readAt == null,
                  )) {
                    ref
                        .read(socialRepositoryProvider)
                        .markConversationRead(widget.friend.id);
                  }
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('chat_say_hi'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMine = m.senderId == myId;
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMine ? AppColors.accentGradient : null,
                            color: isMine ? null : AppColors.glassFill,
                            border: isMine
                                ? null
                                : Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            m.content,
                            style: AppTextStyles.body(
                              color: isMine ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GlowBox(
                    borderRadius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _inputCtrl,
                      style: AppTextStyles.body(),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ref.tr('chat_input_hint'),
                        hintStyle: AppTextStyles.muted(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _conversationStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, otherUserId) {
      return ref.watch(socialRepositoryProvider).watchConversation(otherUserId);
    });
