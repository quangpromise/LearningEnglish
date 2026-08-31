import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/social/data/device_token_repository.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/chat_screen.dart';
import '../navigation/nav_keys.dart';

/// Id kenh thong bao rieng cho tin nhan chat, kem am thanh "ding" tuy chinh
/// (file res/raw/notification_ding.wav) - phai tao 1 lan duy nhat truoc khi
/// thong bao dau tien hien (Android khoa cung am thanh cua 1 kenh ngay tu
/// luc tao, doi lai khong an thua). Hau to "_v2": may da cai ban build cu
/// (channel "chat_messages" tao ma chua co am) se KHONG bao gio nhan am moi
/// du sua code, vi Android khong cho doi cau hinh 1 kenh da ton tai - phai
/// dat ten kenh MOI de buoc tao lai tu dau. Neu sau nay con doi am/importance
/// lan nua, tang so o day len (_v3, _v4...).
const kChatMessagesChannelId = 'chat_messages_v2';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Payload gui kem thong bao local de biet bam vao tin nhan cua AI - chi can
/// sender_id, dung chung cho ca duong bam tu background lan tu terminated.
String _payloadFor(String senderId) => senderId;

/// Tai ve dung luong nho de lam anh dai dien tron trong thong bao he thong,
/// giong Messenger - that bai (mat mang, avatar rong...) thi tra ve null,
/// luc do thong bao chi hien icon mac dinh cua app thay vi crash ca luong.
Future<Uint8List?> _downloadAvatar(String? url) async {
  if (url == null || url.isEmpty) return null;
  try {
    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) return null;
    return await _cropToCircle(res.bodyBytes, size: 96);
  } catch (_) {
    return null;
  }
}

/// Cat anh dai dien (thuong la anh vuong/chu nhat full-res tu server) thanh
/// 1 hinh TRON kich thuoc co dinh nho - he thong Android khong tu dong bo
/// tron/thu nho largeIcon nen neu dua thang bytes goc vao se hien vuong va
/// to bat thuong so voi cac phan tu khac cua thong bao (giong Messenger).
Future<Uint8List?> _cropToCircle(Uint8List bytes, {required int size}) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;
    final side = src.width < src.height ? src.width : src.height;
    final srcRect = ui.Rect.fromLTWH(
      (src.width - side) / 2,
      (src.height - side) / 2,
      side.toDouble(),
      side.toDouble(),
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final dstSize = size.toDouble();
    canvas.clipPath(
      ui.Path()..addOval(ui.Rect.fromLTWH(0, 0, dstSize, dstSize)),
    );
    canvas.drawImageRect(
      src,
      srcRect,
      ui.Rect.fromLTWH(0, 0, dstSize, dstSize),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final circular = await recorder.endRecording().toImage(size, size);
    final pngData = await circular.toByteData(format: ui.ImageByteFormat.png);
    return pngData?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}

/// Dung chung cho ca handler foreground/background: dung Firebase data-only
/// message (KHONG dung truong `notification` cua FCM) roi tu dung thong bao
/// bang flutter_local_notifications - day la cach DUY NHAT de gan anh dai
/// dien nguoi gui lam "large icon" tron nhu Messenger, vi FCM tu hien thong
/// bao he thong (khi dung truong `notification`) khong co cho de nhet 1 URL
/// anh rieng cho tung tin, chi co 1 icon nho co dinh cua app.
Future<void> _showChatNotification(RemoteMessage message) async {
  final data = message.data;
  final senderId = data['sender_id'] as String?;
  final senderName = data['sender_name'] as String? ?? 'Bạn bè';
  final content = data['content'] as String? ?? '';
  if (senderId == null || content.isEmpty) return;

  final avatarBytes = await _downloadAvatar(
    data['sender_avatar_url'] as String?,
  );

  await _localNotifications.show(
    // Dung hash cua sender_id lam id - tin nhan moi tu CUNG 1 nguoi se GHI
    // DE thong bao cu thay vi chong chat nhieu thong bao rieng le.
    id: senderId.hashCode,
    title: senderName,
    body: content,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        kChatMessagesChannelId,
        'Tin nhắn',
        channelDescription: 'Thông báo khi có tin nhắn mới từ bạn bè',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: avatarBytes != null
            ? ByteArrayAndroidBitmap(avatarBytes)
            : null,
      ),
    ),
    payload: _payloadFor(senderId),
  );
}

/// PHAI la ham top-level (khong phai method trong class) kem annotation nay
/// - Firebase Messaging chay ham nay trong 1 isolate rieng khi co tin nhan
/// den luc app da bi tat han, tach biet hoan toan voi isolate chinh cua app.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showChatNotification(message);
}

/// PHAI la ham top-level - flutter_local_notifications goi ham nay khi
/// nguoi dung bam vao thong bao TRONG LUC app da bi tat han (khac voi
/// onDidReceiveNotificationResponse chi chay duoc khi isolate chinh con song).
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) {
  final senderId = response.payload;
  if (senderId == null) return;
  ChatPush.instance._openChatWith(senderId);
}

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
    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final senderId = response.payload;
        if (senderId != null) _openChatWith(senderId);
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenForCurrentUser);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Foreground: da co banner + am thanh rieng qua Realtime (xem
    // incoming_message_banner.dart) hien thi tuc thi hon nhieu so voi cho
    // FCM - bo qua data message trung lap luc app dang mo de khong hien 2
    // thong bao cho 1 tin nhan.
    FirebaseMessaging.onMessage.listen((_) {});
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

  /// Bam vao thong bao - mo thang khung chat voi nguoi gui. sender_id chac
  /// chan da la ban be (RLS bang messages chi cho insert giua 2 nguoi da
  /// 'accepted') nen tim thang trong danh sach ban be thay vi phai them 1
  /// RPC tra cuu profile rieng.
  Future<void> _openChatWith(String senderId) async {
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
