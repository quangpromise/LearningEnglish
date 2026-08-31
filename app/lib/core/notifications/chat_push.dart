import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/social/data/device_token_repository.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/chat_screen.dart';
import '../navigation/nav_keys.dart';

/// Id kenh thong bao rieng cho tin nhan chat, kem am thanh "ding" tuy chinh
/// (file res/raw/notification_ding.wav) - PHAI trung voi `channel_id` ma
/// Edge Function send-chat-push dat trong payload FCM (xem
/// supabase/functions/send-chat-push/index.ts), neu khong Android se dung
/// kenh mac dinh (van co am nhung la am chuong mac dinh cua may, khong phai
/// am rieng cua app).
const kChatMessagesChannelId = 'chat_messages';

/// Push notification cho tin nhan chat qua Firebase Cloud Messaging - hoat
/// dong ca khi app da dong han/khoa may (khac voi DailyQuizNotifications:
/// lich nhac hoc tu vung biet truoc GIO chay nen dat lich CUC BO la du, con
/// tin nhan chat co the den bat ky luc nao nen can server chu dong "danh
/// thuc" thiet bi qua FCM). Xem docs/setup-firebase-chat-push.md.
class ChatPush {
  ChatPush._();
  static final instance = ChatPush._();

  bool _firebaseReady = false;
  bool _registeredThisSession = false;

  /// Goi 1 lan luc app khoi dong (main()). Neu chua tao Firebase project /
  /// chua co google-services.json, Firebase.initializeApp() nem loi - bo
  /// qua trong im lang de khong lam crash app, tinh nang push don gian
  /// chua hoat dong cho toi khi setup xong (xem docs/setup-firebase-chat-push.md).
  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (_) {
      return;
    }

    // Tao truoc kenh thong bao kem am thanh rieng - PHAI tao truoc khi
    // thong bao dau tien den, vi Android khoa cung cau hinh 1 kenh (bao
    // gom am thanh) ngay tu lan tao dau tien, sau do co doi channel_id
    // trong payload cung khong doi duoc am thanh cua kenh da ton tai.
    const channel = AndroidNotificationChannel(
      kChatMessagesChannelId,
      'Tin nhắn',
      description: 'Thông báo khi có tin nhắn mới từ bạn bè',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_ding'),
    );
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenForCurrentUser);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) await _handleTap(initialMessage);
  }

  /// Goi ngay sau khi dang nhap thanh cong - xin quyen thong bao (bat buoc
  /// tu Android 13+) va luu token thiet bi hien tai vao Supabase.
  Future<void> registerCurrentUser() async {
    if (!_firebaseReady) return;
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveTokenForCurrentUser(token);
    _registeredThisSession = true;
  }

  /// Goi 1 lan luc RootShell mo (initState) - phu cho truong hop tai khoan
  /// da dang nhap TU TRUOC (session duoc phuc hoi luc mo app khong phat ra
  /// event AuthChangeEvent.signedIn, chi phat signedIn that su khi nguoi
  /// dung chu dong dang nhap - xem _AuthGate trong main.dart).
  Future<void> registerIfSignedInAndNotYet() async {
    if (_registeredThisSession) return;
    if (Supabase.instance.client.auth.currentSession == null) return;
    await registerCurrentUser();
  }

  /// Goi luc dang xuat - xoa token khoi Supabase de tai khoan khac dung
  /// chung may khong bi nhan nham push cua tai khoan vua dang xuat.
  Future<void> unregister() async {
    _registeredThisSession = false;
    if (!_firebaseReady) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await DeviceTokenRepository.deleteToken(token);
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await DeviceTokenRepository.saveToken(userId: userId, token: token);
  }

  /// Bam vao thong bao (tu background hoac tu app da bi tat han) - mo thang
  /// khung chat voi nguoi gui. sender_id chac chan da la ban be (RLS bang
  /// messages chi cho insert giua 2 nguoi da 'accepted') nen tim thang trong
  /// danh sach ban be thay vi phai them 1 RPC tra cuu profile rieng.
  Future<void> _handleTap(RemoteMessage message) async {
    final senderId = message.data['sender_id'] as String?;
    if (senderId == null) return;
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final friends = await SocialRepository(Supabase.instance.client)
        .fetchFriends();
    SocialUser? friend;
    for (final f in friends) {
      if (f.id == senderId) {
        friend = f;
        break;
      }
    }
    if (friend == null || !context.mounted) return;
    await openChatPopup(context, friend);
  }
}
