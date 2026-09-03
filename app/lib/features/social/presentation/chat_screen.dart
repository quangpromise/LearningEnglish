import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_format.dart';
import '../data/chat_theme.dart';
import '../data/social_repository.dart';
import 'emoji_reaction_picker.dart';
import 'sticker_picker_sheet.dart';

/// Mở khung chat với 1 người bạn dưới dạng pop-up (bottom sheet cao gần
/// hết màn hình) thay vì chuyển hẳn sang màn hình mới - dùng ở cả danh
/// sách hội thoại lẫn danh sách bạn bè để trải nghiệm nhất quán.
Future<void> openChatPopup(BuildContext context, SocialUser friend) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // showModalBottomSheet KHONG tu dong tranh ban phim (Flutter khong lam
    // dieu nay san cho bottom sheet, khac voi Scaffold thuong) - phai tu tru
    // chieu cao ban phim vao day, neu khong o nhap tin nhan se bi ban phim
    // che khuat hoan toan khi go chu.
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: ChatScreen(friend: friend),
        ),
      ),
    ),
  );
}

/// Mo anh o che do toan man hinh, nen den, cho phep pinch-zoom (InteractiveViewer)
/// va vuot xuong/bam nut dong de thoat - giong cach xem anh cua Messenger/Zalo.
void _openFullScreenImage(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (context, _, _) => _FullScreenImageViewer(url: imageUrl),
    ),
  );
}

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

  /// Khac null khi dang sua 1 tin nhan chu da gui - o nhap luc nay hien noi
  /// dung cu de sua thay vi go tin moi, nut Gui doi thanh Luu (xem
  /// _send()/_startEditing()/_cancelEditing()).
  int? _editingMessageId;

  /// Lan dau tien co du lieu tin nhan sau khi mo man hinh - nhay THANG xuong
  /// cuoi (khong hieu ung truot, tranh nguoi dung thay canh truot dai tu tin
  /// nhan cu nhat len). Cac lan sau (tin nhan MOI den trong luc dang xem)
  /// moi dung hieu ung truot muot nhu Messenger.
  bool _hasScrolledInitially = false;

  @override
  void initState() {
    super.initState();
    // Danh dau doc ngay khi mo cuoc hoi thoai - unreadMessageCountProvider
    // (Home) tu giam qua realtime stream, khong can invalidate thu cong.
    Future.microtask(
      () => ref
          .read(socialRepositoryProvider)
          .markConversationRead(widget.friend.id),
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
    final editingId = _editingMessageId;
    _editingMessageId = null;
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (editingId != null) {
        await repo.editMessage(editingId, text);
      } else {
        await repo.sendMessage(widget.friend.id, text);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startEditing(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _inputCtrl.text = message.content;
      _inputCtrl.selection = TextSelection.collapsed(
        offset: _inputCtrl.text.length,
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _inputCtrl.clear();
    });
  }

  Future<void> _confirmDelete(int messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: Text(
          ref.tr('chat_delete_title'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(ref.tr('chat_delete_body'), style: AppTextStyles.muted()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              ref.tr('chat_delete_confirm'),
              style: const TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(socialRepositoryProvider).deleteMessage(messageId);
    }
  }

  void _showMessageActions(
    ChatMessage message,
    bool isMine,
    VoidCallback onReactTap,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xEB0F1326),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.add_reaction_outlined,
                  color: AppColors.textPrimary,
                ),
                title: Text(ref.tr('chat_react'), style: AppTextStyles.body()),
                onTap: () {
                  Navigator.of(context).pop();
                  onReactTap();
                },
              ),
              if (isMine && message.kind == MessageKind.text) ...[
                ListTile(
                  leading: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(ref.tr('chat_edit'), style: AppTextStyles.body()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _startEditing(message);
                  },
                ),
              ],
              if (isMine)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.pink,
                  ),
                  title: Text(
                    ref.tr('chat_delete'),
                    style: AppTextStyles.body(color: AppColors.pink),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(message.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xEB0F1326),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.image_rounded,
                  color: AppColors.textPrimary,
                ),
                title: Text(
                  ref.tr('chat_pick_image'),
                  style: AppTextStyles.body(),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndSendImage();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.textPrimary,
                ),
                title: Text(
                  ref.tr('chat_pick_file'),
                  style: AppTextStyles.body(),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndSendFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    try {
      await ref
          .read(socialRepositoryProvider)
          .sendImage(widget.friend.id, bytes, ext);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ref.tr('chat_upload_error'))));
      }
    }
  }

  Future<void> _pickAndSendFile() async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.extension ?? 'bin';
    try {
      await ref
          .read(socialRepositoryProvider)
          .sendFile(widget.friend.id, bytes, ext, picked.name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ref.tr('chat_upload_error'))));
      }
    }
  }

  Future<void> _openFile(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ref.tr('chat_open_file_error'))));
    }
  }

  /// [animate] = false cho lan mo man hinh dau tien (nhay thang xuong cuoi,
  /// khong hieu ung truot) - dung true (mac dinh) cho tin nhan MOI den trong
  /// luc dang xem (truot muot nhu Messenger).
  void _scrollToBottom({bool animate = true}) {
    // KHONG kiem tra hasClients truoc khi dang ky postFrameCallback - lan
    // goi DAU TIEN (ngay sau khi mo man hinh) ListView chua kip gan vao
    // controller luc ham nay chay (dang giua build()), nen hasClients luon
    // false va ham thoat som, KHONG BAO GIO cuon xuong duoc - day chinh la
    // ly do mo lai 1 doan chat cu khong tu truot xuong tin nhan moi nhat.
    // Chi kiem tra hasClients BEN TRONG callback (sau khi frame da layout xong).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animate) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final messagesStream = ref.watch(
      _conversationStreamProvider(widget.friend.id),
    );
    final reactions =
        ref.watch(_reactionsStreamProvider).valueOrNull ?? const [];
    final reactionsByMessage = <int, List<MessageReaction>>{};
    for (final r in reactions) {
      reactionsByMessage.putIfAbsent(r.messageId, () => []).add(r);
    }
    final themeId = ref.watch(chatThemeProvider(widget.friend.id));

    return ScreenBackground(
      gradient: themeById(themeId).gradient,
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
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.friend.avatarUrl != null
                          ? Image.network(
                              widget.friend.avatarUrl!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                widget.friend.label.isNotEmpty
                                    ? widget.friend.label[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          // Xanh la khi online, xam khi offline - giong
                          // Messenger: luon co 1 cham trang thai.
                          color: widget.friend.isOnline
                              ? AppColors.teal
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgTop, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
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
                  _scrollToBottom(animate: _hasScrolledInitially);
                  _hasScrolledInitially = true;
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
                  // Chi hien "Da xem" duoi tin nhan CUA MINH moi nhat da
                  // duoc doc, giong Messenger - khong lap lai o moi tin.
                  var lastMyReadIndex = -1;
                  for (var i = 0; i < messages.length; i++) {
                    if (messages[i].senderId == myId &&
                        messages[i].readAt != null) {
                      lastMyReadIndex = i;
                    }
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMine = m.senderId == myId;
                      final msgReactions = reactionsByMessage[m.id] ?? const [];
                      final myReaction = msgReactions
                          .where((r) => r.userId == myId)
                          .firstOrNull
                          ?.emoji;
                      void onReact(String emoji) {
                        final repo = ref.read(socialRepositoryProvider);
                        if (emoji == myReaction) {
                          repo.removeReaction(m.id);
                        } else {
                          repo.setReaction(m.id, emoji);
                        }
                      }

                      return Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: m.isDeleted
                                ? null
                                : () => _showMessageActions(
                                    m,
                                    isMine,
                                    () => showEmojiReactionPicker(
                                      context,
                                      onSelected: onReact,
                                    ),
                                  ),
                            child: Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: _MessageBubble(
                                message: m,
                                isMine: isMine,
                                onOpenFile: _openFile,
                              ),
                            ),
                          ),
                          if (msgReactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.glassFill,
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  msgReactions.map((r) => r.emoji).join(),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2,
                              bottom: 4,
                              left: 4,
                              right: 4,
                            ),
                            child: Text(
                              m.isEdited && !m.isDeleted
                                  ? '${formatBubbleTime(m.createdAt)} · ${ref.tr('chat_edited')}'
                                  : formatBubbleTime(m.createdAt),
                              style: AppTextStyles.muted(size: 10),
                            ),
                          ),
                          if (i == lastMyReadIndex)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 6,
                                right: 4,
                              ),
                              child: Text(
                                ref.tr('chat_seen'),
                                style: AppTextStyles.muted(size: 10)
                                    .copyWith(color: AppColors.teal),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_editingMessageId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ref.tr('chat_editing_hint'),
                        style: AppTextStyles.muted(size: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelEditing,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _showAttachSheet,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => showStickerPicker(
                    context,
                    onPicked: (url) => ref
                        .read(socialRepositoryProvider)
                        .sendSticker(widget.friend.id, url),
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                    child: Icon(
                      _editingMessageId != null
                          ? Icons.check_rounded
                          : Icons.send_rounded,
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

final _reactionsStreamProvider =
    StreamProvider.autoDispose<List<MessageReaction>>(
      (ref) => ref.watch(socialRepositoryProvider).watchReactions(),
    );

/// Noi dung 1 bubble tin nhan - re nhanh theo [ChatMessage.kind]: chu thuong
/// van la Text nhu truoc, anh/GIF hien truc tiep (Image.network ho tro GIF
/// dong san), file la 1 the co icon+ten bam de mo, va rieng anh/file (khong
/// phai GIF) tu bao "het han" sau 1 ngay THAY VI cho toi khi tai that bai
/// (server da xoa that qua cron - xem migration 0016_chat_media.sql).
class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onOpenFile,
  });

  final ChatMessage message;
  final bool isMine;
  final ValueChanged<String> onOpenFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    if (message.isDeleted) {
      return _bubbleContainer(
        isMine,
        maxWidth,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block_rounded,
              size: 15,
              color: isMine ? Colors.white70 : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              ref.tr('chat_message_deleted'),
              style: AppTextStyles.body(
                size: 12.5,
                color: isMine ? Colors.white70 : AppColors.textMuted,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    if (message.isExpiredMedia) {
      return _bubbleContainer(
        isMine,
        maxWidth,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off_rounded,
              size: 16,
              color: isMine ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                ref.tr('chat_media_expired'),
                style: AppTextStyles.body(
                  size: 12.5,
                  color: isMine ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    switch (message.kind) {
      case MessageKind.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: () => _openFullScreenImage(context, message.content),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 240),
              child: Image.network(
                message.content,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _bubbleContainer(
                  isMine,
                  maxWidth,
                  Text(
                    ref.tr('chat_media_expired'),
                    style: AppTextStyles.body(
                      size: 12.5,
                      color: isMine ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case MessageKind.sticker:
        // Khong dung bubble nen (mau/gradient) - sticker von la anh nen
        // trong suot, giong cach Zalo/Messenger hien sticker.
        return SizedBox(
          width: 128,
          height: 128,
          child: Image.network(
            message.content,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.image_not_supported_rounded,
              color: AppColors.textMuted,
            ),
          ),
        );
      case MessageKind.file:
        return GestureDetector(
          onTap: () => onOpenFile(message.content),
          child: _bubbleContainer(
            isMine,
            maxWidth,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file_rounded,
                  size: 20,
                  color: isMine ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.fileName ?? 'Tệp đính kèm',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      color: isMine ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case MessageKind.text:
        return _bubbleContainer(
          isMine,
          maxWidth,
          Text(
            message.content,
            style: AppTextStyles.body(color: isMine ? Colors.white : null),
          ),
        );
    }
  }

  Widget _bubbleContainer(bool isMine, double maxWidth, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        gradient: isMine ? AppColors.accentGradient : null,
        color: isMine ? null : AppColors.glassFill,
        border: isMine ? null : Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// Man hinh xem anh chat o che do toan man hinh - InteractiveViewer cho phep
/// pinch-zoom (2 ngon tay) + keo di chuyen khi da zoom, giong Messenger/Zalo.
/// Bam vao anh (khong keo/zoom) hoac nut dong de thoat.
class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    url,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
