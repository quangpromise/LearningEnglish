import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Chuoi hien thi ngan gon cho 1 tin nhan theo loai - dung chung cho danh
/// sach hoi thoai (ConversationPreview) va banner tin nhan moi (root_shell.dart)
/// de khong hien thang URL kho hieu khi tin la anh/sticker/file.
String messageKindPreview({
  required MessageKind kind,
  String? content,
  String? fileName,
}) => switch (kind) {
  MessageKind.sticker => '[Sticker]',
  MessageKind.image => '[Hình ảnh]',
  MessageKind.file => '📎 ${fileName ?? 'Tệp đính kèm'}',
  MessageKind.text => content ?? '',
};

/// 1 user ban tim thay/ban be, kem trang thai quan he va online.
class SocialUser {
  const SocialUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.friendStatus,
    this.isOnline = false,
    this.lastSeenAt,
    this.requestCreatedAt,
    this.nickname,
  });

  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  /// Chi co gia tri khi lay tu searchUsers(): 'none' | 'pending' | 'accepted'.
  final String? friendStatus;
  final bool isOnline;
  final DateTime? lastSeenAt;

  /// Chi co gia tri khi lay tu pendingRequests().
  final DateTime? requestCreatedAt;

  /// Biet danh MINH tu dat cho nguoi nay (chi minh thay, xem
  /// migration 0023_friend_nicknames.sql) - uu tien hien thi cao nhat neu co,
  /// thay the ten that o MOI man hinh (yeu cau: "hien thi bat cu man hinh
  /// nao chu khong phai ten nguoi do").
  final String? nickname;

  String get label => nickname?.isNotEmpty == true
      ? nickname!
      : (displayName?.isNotEmpty == true
            ? displayName!
            : (username?.isNotEmpty == true ? username! : 'User'));
}

/// 'text' - tin nhan chu thuong; 'sticker' - content la URL sticker (GIPHY,
/// anh nen trong suot, khong luu vao storage cua minh nen khong tu het han);
/// 'image'/'file' - content la URL file trong bucket 'chat_media' (tu xoa
/// sau 1 ngay - xem migration 0016_chat_media.sql), fileName chi co gia tri
/// o kind 'file' (ten goc de hien thi, vd "bao-cao.pdf").
enum MessageKind { text, sticker, image, file }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.kind = MessageKind.text,
    this.fileName,
    this.editedAt,
    this.deletedAt,
  });

  factory ChatMessage.fromRow(Map<String, dynamic> row) => ChatMessage(
    id: row['id'] as int,
    senderId: row['sender_id'] as String,
    receiverId: row['receiver_id'] as String,
    content: row['content'] as String,
    createdAt: DateTime.parse(row['created_at'] as String),
    readAt: row['read_at'] != null
        ? DateTime.parse(row['read_at'] as String)
        : null,
    kind: MessageKind.values.firstWhere(
      (k) => k.name == (row['kind'] as String? ?? 'text'),
      orElse: () => MessageKind.text,
    ),
    fileName: row['file_name'] as String?,
    editedAt: row['edited_at'] != null
        ? DateTime.parse(row['edited_at'] as String)
        : null,
    deletedAt: row['deleted_at'] != null
        ? DateTime.parse(row['deleted_at'] as String)
        : null,
  );

  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final MessageKind kind;
  final String? fileName;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;

  /// Tin nhan anh/file (khong phai sticker) qua han 1 ngay - link trong
  /// storage gan nhu chac chan da bi cron don (xem cleanup_expired_chat_media())
  /// nen hien "da het han" ngay thay vi doi tai that bai roi moi fallback.
  bool get isExpiredMedia =>
      (kind == MessageKind.image || kind == MessageKind.file) &&
      DateTime.now().difference(createdAt) > const Duration(days: 1);

  /// Dung cho banner tin nhan moi (kieu Messenger) - "[Hinh anh]"/"[Sticker]"/
  /// ten file thay vi in thang URL.
  String get previewText => isDeleted
      ? 'Tin nhắn đã bị xóa'
      : messageKindPreview(kind: kind, content: content, fileName: fileName);
}

/// 1 luot tha cam xuc (emoji) tren 1 tin nhan - moi nguoi CHI co toi da 1
/// reaction/1 tin nhan (xem migration 0015_message_reactions.sql), bam lai
/// emoji khac se thay the, bam lai cung emoji se bo (xu ly o client).
class MessageReaction {
  const MessageReaction({
    required this.messageId,
    required this.userId,
    required this.emoji,
  });

  factory MessageReaction.fromRow(Map<String, dynamic> row) => MessageReaction(
    messageId: row['message_id'] as int,
    userId: row['user_id'] as String,
    emoji: row['emoji'] as String,
  );

  final int messageId;
  final String userId;
  final String emoji;
}

/// 1 dong trong danh sach hoi thoai (man Tin nhan) - ban be kem tin nhan
/// GAN NHAT va so tin chua doc, xem RPC my_conversations() trong
/// supabase/migrations/0013_conversations_list.sql.
class ConversationPreview {
  const ConversationPreview({
    required this.friend,
    this.lastMessage,
    this.lastMessageKind = MessageKind.text,
    this.lastMessageFileName,
    this.lastMessageAt,
    this.lastMessageIsMine = false,
    this.lastMessageDeleted = false,
    this.unreadCount = 0,
  });

  final SocialUser friend;
  final String? lastMessage;
  final MessageKind lastMessageKind;
  final String? lastMessageFileName;
  final DateTime? lastMessageAt;
  final bool lastMessageIsMine;
  final bool lastMessageDeleted;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;

  String get lastMessagePreview => lastMessageDeleted
      ? 'Tin nhắn đã bị xóa'
      : messageKindPreview(
          kind: lastMessageKind,
          content: lastMessage,
          fileName: lastMessageFileName,
        );
}

/// Ket ban, tin nhan 1-1, va trang thai online - xem
/// supabase/migrations/0011_friends_and_chat.sql cho schema/RPC day du.
class SocialRepository {
  SocialRepository(this._supabase);
  final SupabaseClient _supabase;

  String? get _myId => _supabase.auth.currentUser?.id;

  Future<List<SocialUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _supabase.rpc(
      'search_users',
      params: {'query': query.trim()},
    );
    return (rows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return SocialUser(
        id: m['id'] as String,
        username: m['username'] as String?,
        displayName: m['display_name'] as String?,
        avatarUrl: m['avatar_url'] as String?,
        friendStatus: m['friend_status'] as String?,
      );
    }).toList();
  }

  Future<List<SocialUser>> fetchFriends() async {
    final rows = await _supabase.rpc('my_friends');
    return (rows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return SocialUser(
        id: m['id'] as String,
        username: m['username'] as String?,
        displayName: m['display_name'] as String?,
        avatarUrl: m['avatar_url'] as String?,
        isOnline: m['is_online'] as bool? ?? false,
        lastSeenAt: m['last_seen_at'] != null
            ? DateTime.parse(m['last_seen_at'] as String)
            : null,
        nickname: m['nickname'] as String?,
      );
    }).toList();
  }

  /// Dat/doi biet danh CHO RIENG minh voi 1 nguoi ban - hien thi thay the ten
  /// that o MOI man hinh (xem SocialUser.label), khong anh huong nguoi kia.
  /// Truyen null/rong de xoa biet danh, tra ve hien ten that.
  Future<void> setNickname(String friendId, String? nickname) async {
    final myId = _myId;
    if (myId == null) return;
    final trimmed = nickname?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _supabase
          .from('friend_nicknames')
          .delete()
          .eq('user_id', myId)
          .eq('friend_id', friendId);
    } else {
      await _supabase.from('friend_nicknames').upsert({
        'user_id': myId,
        'friend_id': friendId,
        'nickname': trimmed,
      }, onConflict: 'user_id,friend_id');
    }
  }

  Future<List<SocialUser>> fetchPendingRequests() async {
    final rows = await _supabase.rpc('my_pending_requests');
    return (rows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return SocialUser(
        id: m['id'] as String,
        username: m['username'] as String?,
        displayName: m['display_name'] as String?,
        avatarUrl: m['avatar_url'] as String?,
        requestCreatedAt: DateTime.parse(m['created_at'] as String),
        nickname: m['nickname'] as String?,
      );
    }).toList();
  }

  Future<void> sendFriendRequest(String targetId) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase.from('friendships').insert({
      'requester_id': myId,
      'addressee_id': targetId,
    });
  }

  Future<void> acceptFriendRequest(String requesterId) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('requester_id', requesterId)
        .eq('addressee_id', myId);
  }

  /// Tu choi loi moi HOAC huy ket ban (ca 2 truong hop deu la xoa dong
  /// friendship, bat ke minh la requester hay addressee).
  Future<void> removeFriendship(String otherUserId) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase
        .from('friendships')
        .delete()
        .or(
          'and(requester_id.eq.$myId,addressee_id.eq.$otherUserId),'
          'and(requester_id.eq.$otherUserId,addressee_id.eq.$myId)',
        );
  }

  Future<void> updatePresence() async {
    if (_myId == null) return;
    await _supabase.rpc('update_my_presence');
  }

  Future<int> fetchUnreadCount() async {
    if (_myId == null) return 0;
    final result = await _supabase.rpc('unread_message_count');
    return (result as num?)?.toInt() ?? 0;
  }

  Future<void> markConversationRead(String otherUserId) async {
    if (_myId == null) return;
    await _supabase.rpc(
      'mark_conversation_read',
      params: {'other_user_id': otherUserId},
    );
  }

  /// Realtime: so loi moi ket ban dang cho (nguoi khac gui toi minh, chua
  /// chap nhan/tu choi) - dung cho cham do tren nut "Ban be", tuong tu
  /// watchUnreadCount() ben duoi nhung theo dung bang friendships.
  Stream<int> watchPendingRequestCount() {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    return _supabase
        .from('friendships')
        .stream(primaryKey: ['requester_id', 'addressee_id'])
        .eq('addressee_id', myId)
        .map((rows) => rows.where((r) => r['status'] == 'pending').length);
  }

  /// Realtime: so tin nhan CHUA DOC gui den minh, cap nhat ngay khi co tin
  /// nhan moi hoac khi minh danh dau da doc (khong can poll) - dung cho
  /// badge tren nut tin nhan o Home.
  Stream<int> watchUnreadCount() {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', myId)
        .map((rows) => rows.where((r) => r['read_at'] == null).length);
  }

  /// Realtime: TOAN BO tin nhan gui den minh (khong loc chua doc/da doc) -
  /// cau truc giong het watchUnreadCount() o tren (da xac nhan hoat dong
  /// dung), dung cho banner "tin nhan moi" kieu Messenger o _AuthGate
  /// (main.dart) - noi do tu so sanh voi snapshot TRUOC (qua previous/next
  /// cua Riverpod) de biet id nao la MOI, thay vi tu theo doi trang thai
  /// "da thay chua" ngay trong 1 closure rieng nhu cach cu (da bo, xem
  /// git history watchNewIncomingMessages).
  Stream<List<ChatMessage>> watchIncomingMessages() {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', myId)
        .map(
          (rows) =>
              rows.map(ChatMessage.fromRow).toList()
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        );
  }

  /// Danh sach hoi thoai (ban be + tin nhan gan nhat + so chua doc), sap
  /// xep theo tin moi nhat truoc - dung cho man hinh Tin nhan (thay the
  /// FriendsScreen lam man mac dinh khi bam nut tin nhan o Home).
  Future<List<ConversationPreview>> fetchConversations() async {
    final rows = await _supabase.rpc('my_conversations');
    return (rows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return ConversationPreview(
        friend: SocialUser(
          id: m['id'] as String,
          username: m['username'] as String?,
          displayName: m['display_name'] as String?,
          avatarUrl: m['avatar_url'] as String?,
          isOnline: m['is_online'] as bool? ?? false,
          lastSeenAt: m['last_seen_at'] != null
              ? DateTime.parse(m['last_seen_at'] as String)
              : null,
          nickname: m['nickname'] as String?,
        ),
        lastMessage: m['last_message'] as String?,
        lastMessageKind: MessageKind.values.firstWhere(
          (k) => k.name == (m['last_message_kind'] as String? ?? 'text'),
          orElse: () => MessageKind.text,
        ),
        lastMessageFileName: m['last_message_file_name'] as String?,
        lastMessageDeleted: m['last_message_deleted'] as bool? ?? false,
        lastMessageAt: m['last_message_at'] != null
            ? DateTime.parse(m['last_message_at'] as String)
            : null,
        lastMessageIsMine: m['last_message_is_mine'] as bool? ?? false,
        unreadCount: (m['unread_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<List<ChatMessage>> fetchConversation(String otherUserId) async {
    final myId = _myId;
    if (myId == null) return [];
    final rows = await _supabase
        .from('messages')
        .select()
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$otherUserId),'
          'and(sender_id.eq.$otherUserId,receiver_id.eq.$myId)',
        )
        .order('created_at')
        .limit(200);
    return (rows as List)
        .map((r) => ChatMessage.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _myId;
    if (myId == null || content.trim().isEmpty) return;
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content.trim(),
    });
  }

  /// Sua noi dung 1 tin nhan CHU (kind 'text') CUA CHINH MINH da gui - RLS
  /// (messages_update_own) chan nguoi khac sua tin cua minh. Chi hop ly cho
  /// tin nhan chu - anh/sticker/file khong the "sua" theo nghia nay.
  Future<void> editMessage(int messageId, String newContent) async {
    if (newContent.trim().isEmpty) return;
    await _supabase
        .from('messages')
        .update({
          'content': newContent.trim(),
          'edited_at': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId);
  }

  /// Xoa MEM 1 tin nhan CUA CHINH MINH (danh dau deleted_at, khong xoa dong
  /// that su) - ben con lai thay 1 vet "Tin nhan da bi xoa" giong Messenger,
  /// xem ChatMessage.isDeleted.
  Future<void> deleteMessage(int messageId) async {
    await _supabase
        .from('messages')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }

  /// Gui 1 sticker (URL tu GIPHY) nhu 1 tin nhan rieng - content la URL,
  /// khong can tai len bucket rieng (GIPHY tu host).
  Future<void> sendSticker(String receiverId, String stickerUrl) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': stickerUrl,
      'kind': 'sticker',
    });
  }

  /// Ten file ngau nhien, kho doan - dung cho duong dan trong bucket
  /// 'chat_media' (public=true, xem migration 0016_chat_media.sql) thay vi
  /// them 1 package 'uuid' rieng chi cho viec nay.
  String _randomFileName(String ext) {
    final rand =
        (DateTime.now().microsecondsSinceEpoch ^ identityHashCode(this))
            .toRadixString(36);
    return '$rand.$ext';
  }

  Future<String> _uploadChatMedia(Uint8List bytes, String ext) async {
    final myId = _myId!;
    final path = '$myId/${_randomFileName(ext)}';
    await _supabase.storage
        .from('chat_media')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: false),
        );
    return _supabase.storage.from('chat_media').getPublicUrl(path);
  }

  /// Tai anh len bucket 'chat_media' roi gui nhu 1 tin nhan - file TU XOA
  /// sau 1 ngay (cron server, xem migration) de khong ton dung luong.
  Future<void> sendImage(String receiverId, Uint8List bytes, String ext) async {
    final myId = _myId;
    if (myId == null) return;
    final url = await _uploadChatMedia(bytes, ext);
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': url,
      'kind': 'image',
    });
  }

  /// Tuong tu [sendImage] nhung cho file bat ky (PDF, tai lieu...) - giu lai
  /// [fileName] GOC de hien thi (URL trong storage la ten ngau nhien).
  Future<void> sendFile(
    String receiverId,
    Uint8List bytes,
    String ext,
    String fileName,
  ) async {
    final myId = _myId;
    if (myId == null) return;
    final url = await _uploadChatMedia(bytes, ext);
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': url,
      'kind': 'file',
      'file_name': fileName,
    });
  }

  /// Dat/thay reaction CUA MINH tren 1 tin nhan - upsert nen bam emoji khac
  /// se tu thay the reaction cu, khong can xoa truoc.
  Future<void> setReaction(int messageId, String emoji) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase.from('message_reactions').upsert({
      'message_id': messageId,
      'user_id': myId,
      'emoji': emoji,
    }, onConflict: 'message_id,user_id');
  }

  /// Bo reaction CUA MINH tren 1 tin nhan (bam lai dung emoji da tha).
  Future<void> removeReaction(int messageId) async {
    final myId = _myId;
    if (myId == null) return;
    await _supabase
        .from('message_reactions')
        .delete()
        .eq('message_id', messageId)
        .eq('user_id', myId);
  }

  /// Realtime: TOAN BO reaction ma minh co quyen xem (RLS da gioi han chi
  /// nhung tin nhan thuoc cuoc hoi thoai cua minh) - loc theo messageId cua
  /// 1 cuoc hoi thoai cu the o phia UI (xem chat_screen.dart), giong cach
  /// watchUnreadCount()/watchPendingRequestCount() da lam voi cac bang khac.
  Stream<List<MessageReaction>> watchReactions() {
    if (_myId == null) return const Stream.empty();
    return _supabase
        .from('message_reactions')
        .stream(primaryKey: ['message_id', 'user_id'])
        .map((rows) => rows.map(MessageReaction.fromRow).toList());
  }

  /// Realtime: moi lan co thay doi (tin nhan moi...), tra ve LAI TOAN BO
  /// hoi thoai voi [otherUserId] (da loc + sap xep) - Supabase Realtime
  /// stream() phat snapshot day du moi lan thay doi chu khong phai delta,
  /// va Postgres Changes filter khong ho tro dieu kien OR giua 2 cot nen
  /// phai loc thu cong o client (RLS da dam bao chi nhan duoc tin nhan cua
  /// chinh minh, khong lo du lieu nguoi khac).
  Stream<List<ChatMessage>> watchConversation(String otherUserId) {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map(
          (rows) =>
              rows
                  .map(ChatMessage.fromRow)
                  .where(
                    (m) =>
                        (m.senderId == myId && m.receiverId == otherUserId) ||
                        (m.senderId == otherUserId && m.receiverId == myId),
                  )
                  .toList()
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        );
  }
}
