import 'package:supabase_flutter/supabase_flutter.dart';

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

  String get label => displayName?.isNotEmpty == true
      ? displayName!
      : (username?.isNotEmpty == true ? username! : 'User');
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.readAt,
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
  );

  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
}

/// 1 dong trong danh sach hoi thoai (man Tin nhan) - ban be kem tin nhan
/// GAN NHAT va so tin chua doc, xem RPC my_conversations() trong
/// supabase/migrations/0013_conversations_list.sql.
class ConversationPreview {
  const ConversationPreview({
    required this.friend,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageIsMine = false,
    this.unreadCount = 0,
  });

  final SocialUser friend;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool lastMessageIsMine;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;
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
      );
    }).toList();
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

  /// Phat ra 1 su kien moi lan co tin nhan MOI (chua tung thay) gui den
  /// minh - dung de hien pop-up thong bao kieu Messenger tren moi man
  /// hinh, khong chi rieng man Tin nhan. Bo qua lan phat dau tien (snapshot
  /// tin nhan cu co san) - chi bao tin THAT SU moi den sau khi bat dau
  /// theo doi.
  Stream<ChatMessage> watchNewIncomingMessages() {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    final seenIds = <int>{};
    var isFirstSnapshot = true;
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', myId)
        .map((rows) {
          final messages = rows.map(ChatMessage.fromRow).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          if (isFirstSnapshot) {
            isFirstSnapshot = false;
            seenIds.addAll(messages.map((m) => m.id));
            return null;
          }
          ChatMessage? latestNew;
          for (final m in messages) {
            if (seenIds.add(m.id)) latestNew = m;
          }
          return latestNew;
        })
        .where((m) => m != null)
        .cast<ChatMessage>();
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
        ),
        lastMessage: m['last_message'] as String?,
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
