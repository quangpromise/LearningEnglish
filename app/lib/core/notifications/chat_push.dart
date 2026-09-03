import 'dart:async';
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

/// Id kenh thong bao rieng cho tin nhan chat, kem am thanh tuy chinh (file
/// res/raw/notification_tone.mp3) - phai tao 1 lan duy nhat truoc khi thong
/// bao dau tien hien (Android khoa cung am thanh cua 1 kenh ngay tu luc tao,
/// doi lai khong an thua). Hau to "_v4": doi am thanh tu notification_ding
/// sang notification_tone - BAT BUOC tang hau to (giong 2 lan truoc, "_v2"
/// roi "_v3") vi may nguoi dung DA CO channel "_v3" bi khoa cung am cu tu
/// truoc, doi code ma khong doi ten channel se khong co tac dung gi (Android
/// tiep tuc dung am da khoa cua channel cu). Neu sau nay con doi am/
/// importance lan nua, tang tiep len "_v5"...
const kChatMessagesChannelId = 'chat_messages_v4';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Payload gui kem thong bao local de biet bam vao tin nhan cua AI - chi can
/// sender_id, dung chung cho ca duong bam tu background lan tu terminated.
String _payloadFor(String senderId) => senderId;

/// Tai ve 1 anh/sticker (khong bo tron, khong resize vuong) lam anh xem
/// truoc lon trong thong bao (BigPictureStyle) - voi sticker dong chi lay
/// duoc KHUNG HINH DAU TIEN (thong bao he thong Android khong the hien anh
/// dong), nhung nhu vay van du de nguoi dung "thay luon" noi dung thay vi
/// phai mo app.
Future<Uint8List?> _downloadBigPicture(String? url) async {
  if (url == null || url.isEmpty) return null;
  try {
    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) return null;
    final codec = await ui.instantiateImageCodec(res.bodyBytes);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}

/// Ten drawable resource logo app (android/app/src/main/res/drawable-xxxhdpi/
/// chat_app_logo.png) - dung lam largeIcon CHINH cua thong bao (vi tri to,
/// noi bat) thay cho avatar nguoi gui, theo yeu cau doi cho.
const _kAppLogoDrawable = 'chat_app_logo';

/// Dung chung cho ca handler foreground/background: dung Firebase data-only
/// message (KHONG dung truong `notification` cua FCM) roi tu dung thong bao
/// bang flutter_local_notifications.
Future<void> _showChatNotification(RemoteMessage message) async {
  final data = message.data;
  final senderId = data['sender_id'] as String?;
  final senderName = data['sender_name'] as String? ?? 'Bạn bè';
  final content = data['content'] as String? ?? '';
  if (senderId == null || content.isEmpty) return;

  // Tin nhan anh/sticker - server (send-chat-push) da dien san media_url,
  // con tin nhan chu/file thi bo trong (khong can anh xem truoc lon).
  final bigPictureBytes = await _downloadBigPicture(
    data['media_url'] as String?,
  );
  // Anh dai dien NGUOI GUI - hien o vi tri largeIcon (to, noi bat) giong moi
  // app chat khac (Messenger/Zalo...). Rong neu ho chua dat avatar -> fallback
  // ve logo app thay vi de trong.
  final avatarBytes = await _downloadBigPicture(
    data['sender_avatar_url'] as String?,
  );
  final AndroidBitmap<Object> largeIcon = avatarBytes != null
      ? ByteArrayAndroidBitmap(avatarBytes)
      : const DrawableResourceAndroidBitmap(_kAppLogoDrawable);

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
        largeIcon: largeIcon,
        styleInformation: bigPictureBytes != null
            ? BigPictureStyleInformation(
                ByteArrayAndroidBitmap(bigPictureBytes),
                largeIcon: largeIcon,
                contentTitle: senderName,
                summaryText: content,
              )
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

/// Dung chung cho ca 2 duong xu ly thong bao (foreground va background/da
/// tat han): bam vao than thong bao -> mo khung chat.
///
/// GHI CHU: tinh nang "Tra loi" ngay tren thong bao (RemoteInput, khong can
/// mo app) DA TUNG duoc them roi go bo lai theo yeu cau nguoi dung - hanh
/// dong do chay trong 1 isolate/tien trinh nen rieng (BroadcastReceiver cua
/// flutter_local_notifications, khong goi goAsync()) nen khong dam bao gui
/// xong truoc khi bi he thong dung, gay mat tin nhan am tham khong on dinh.
/// KHONG them lai neu chua co giai phap kien truc khac dang tin cay hon.
void _handleNotificationAction(NotificationResponse response) {
  final senderId = response.payload;
  if (senderId == null) return;
  ChatPush.instance._openChatWith(senderId);
}

/// PHAI la ham top-level - flutter_local_notifications goi ham nay khi
/// nguoi dung tuong tac voi thong bao TRONG LUC app da bi tat han (khac voi
/// onDidReceiveNotificationResponse chi chay duoc khi isolate chinh con song).
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) =>
    _handleNotificationAction(response);

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
      sound: RawResourceAndroidNotificationSound('notification_tone'),
    );
    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        // Icon nho tren thanh trang thai PHAI la 1 hinh trang/trong suot don
        // gian - Android tu bo mau, chi giu kenh alpha de ve mau trang len
        // nen thong bao. Dung thang icon app day mau (@mipmap/ic_launcher,
        // nen xanh navy dac) se bi Android render thanh 1 khoi dac gan nhu
        // vuong, trong nhu 1 bieu tuong khac hoan toan (nguoi dung bao "giong
        // logo Apple") thay vi logo GymTalk - xem drawable-*/ic_stat_notify.png
        // (duong net trang tren nen trong suot, tach tu chinh app icon).
        android: AndroidInitializationSettings('@drawable/ic_stat_notify'),
      ),
      onDidReceiveNotificationResponse: _handleNotificationAction,
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
