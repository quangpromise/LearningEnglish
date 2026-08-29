import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_format.dart';
import '../data/social_repository.dart';
import 'chat_screen.dart';
import 'friends_screen.dart';

/// Man hinh Tin nhan (nut chat o Home mo man nay) - danh sach ban be DA CO
/// hoi thoai, moi dong chi hien tin nhan GAN NHAT (kieu Messenger), bam
/// vao 1 dong se mo pop-up chat voi nguoi do.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(myConversationsProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  ref.tr('home_messages_tooltip'),
                  style: AppTextStyles.heading(size: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FriendsScreen()),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      size: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: conversationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('friends_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('friends_empty'),
                        style: AppTextStyles.muted(),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.blue,
                    onRefresh: () async {
                      ref.invalidate(myConversationsProvider);
                      await ref.read(myConversationsProvider.future);
                    },
                    child: ListView.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _ConversationTile(conversation: conversations[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});
  final ConversationPreview conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friend = conversation.friend;
    final hasUnread = conversation.hasUnread;
    final preview = conversation.lastMessage == null
        ? ref.tr('conversations_no_message')
        : conversation.lastMessageIsMine
        ? '${ref.tr('conversations_you_prefix')}${conversation.lastMessage}'
        : conversation.lastMessage!;

    return GestureDetector(
      onTap: () => openChatPopup(context, friend),
      child: GlowBox(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: friend.avatarUrl != null
                      ? Image.network(friend.avatarUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            friend.label.isNotEmpty
                                ? friend.label[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                if (friend.isOnline)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bgTop, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.label,
                    style: AppTextStyles.body(
                      weight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hasUnread
                        ? AppTextStyles.body(
                            size: 12.5,
                            weight: FontWeight.w700,
                          )
                        : AppTextStyles.muted(size: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageAt != null)
                  Text(
                    formatConversationTime(conversation.lastMessageAt!),
                    style: AppTextStyles.muted(size: 10.5),
                  ),
                if (hasUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
