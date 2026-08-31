import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/social/data/call_repository.dart';
import '../../features/social/data/device_token_repository.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/chat_screen.dart';
import '../../features/social/presentation/incoming_call_screen.dart';
import '../config/env.dart';
import '../navigation/nav_keys.dart';

/// Id kenh thong bao rieng cho cuoc goi den - importance/category/
/// fullScreenIntent khac han tin nhan thuong (uu tien cao nhat, co the tu
/// bat man hinh len ca khi dang khoa may, giong 1 cuoc goi dien thoai that).
const kIncomingCallChannelId = 'incoming_call_v1';

/// Id nut "Tra loi" tren chinh thong bao he thong (giong Messenger) - bam
/// vao mo o nhap ngay tren thanh thong bao, KHONG mo app (showsUserInterface:
/// false) - danh cho luc app da dong han/khoa may, khac voi banner tra loi
/// nhanh trong app (incoming_message_banner.dart) chi hoat dong khi app dang mo.
const _kReplyActionId = 'reply_action';

/// Id kenh thong bao rieng cho tin nhan chat, kem am thanh "ding" tuy chinh
/// (file res/raw/notification_ding.wav) - phai tao 1 lan duy nhat truoc khi
/// thong bao dau tien hien (Android khoa cung am thanh cua 1 kenh ngay tu
/// luc tao, doi lai khong an thua). Hau to "_v3": van con nguoi dung khong
/// nghe duoc am du channel "_v2" da co cau hinh am dung tu dau - kha nang
/// cao may do da tao channel "_v2" tu 1 ban build rat som (truoc khi file
/// am thanh duoc them dung cach) nen bi khoa cung KHONG am vinh vien, giong
/// het ly do lan truoc phai doi tu "chat_messages" sang "_v2". Neu sau nay
/// con doi am/importance lan nua, tang tiep len "_v4"...
const kChatMessagesChannelId = 'chat_messages_v3';

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
        largeIcon: const DrawableResourceAndroidBitmap(_kAppLogoDrawable),
        styleInformation: bigPictureBytes != null
            ? BigPictureStyleInformation(
                ByteArrayAndroidBitmap(bigPictureBytes),
                largeIcon: const DrawableResourceAndroidBitmap(
                  _kAppLogoDrawable,
                ),
                contentTitle: senderName,
                summaryText: content,
              )
            : null,
        actions: [
          AndroidNotificationAction(
            _kReplyActionId,
            'Trả lời',
            showsUserInterface: false,
            cancelNotification: true,
            inputs: [AndroidNotificationActionInput(label: 'Nhập tin nhắn...')],
          ),
        ],
      ),
    ),
    payload: _payloadFor(senderId),
  );
}

/// Id 2 nut hanh dong tren thong bao cuoc goi - "Tra loi" MO app (de nguoi
/// dung xac nhan trong IncomingCallScreen, khong tu dong vao thang cuoc goi
/// de tranh accept nham), "Tu choi" xu ly ngam KHONG mo app (giong nut Tra
/// loi nhanh cua tin nhan).
const _kAcceptCallActionId = 'accept_call';
const _kDeclineCallActionId = 'decline_call';

/// Hien thong bao cuoc goi den - dung importance/category cao nhat +
/// fullScreenIntent de Android tu bat man hinh len (giong cuoc goi dien
/// thoai that) ngay ca khi may dang khoa, thay vi chi hien 1 dong o thanh
/// trang thai nhu thong bao thuong.
Future<void> _showIncomingCallNotification(RemoteMessage message) async {
  final data = message.data;
  final callId = data['call_id'] as String?;
  final callerId = data['caller_id'] as String?;
  final callerName = data['caller_name'] as String? ?? 'Bạn bè';
  final callerAvatarUrl = data['caller_avatar_url'] as String? ?? '';
  final channelName = data['channel_name'] as String?;
  final callType = data['call_type'] as String? ?? 'voice';
  if (callId == null || callerId == null || channelName == null) return;

  final payload = jsonEncode({
    'kind': 'call',
    'call_id': callId,
    'caller_id': callerId,
    'caller_name': callerName,
    'caller_avatar_url': callerAvatarUrl,
    'channel_name': channelName,
    'call_type': callType,
  });

  await _localNotifications.show(
    id: callId.hashCode,
    title: callerName,
    body: callType == 'video' ? 'Cuộc gọi video đến' : 'Cuộc gọi thoại đến',
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        kIncomingCallChannelId,
        'Cuộc gọi đến',
        channelDescription: 'Thông báo khi có cuộc gọi thoại/video đến',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        largeIcon: const DrawableResourceAndroidBitmap(_kAppLogoDrawable),
        actions: [
          const AndroidNotificationAction(
            _kAcceptCallActionId,
            'Trả lời',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            _kDeclineCallActionId,
            'Từ chối',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    ),
    payload: payload,
  );
}

/// PHAI la ham top-level (khong phai method trong class) kem annotation nay
/// - Firebase Messaging chay ham nay trong 1 isolate rieng khi co tin nhan
/// den luc app da bi tat han, tach biet hoan toan voi isolate chinh cua app.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'incoming_call') {
    await _showIncomingCallNotification(message);
  } else {
    await _showChatNotification(message);
  }
}

/// Tu choi cuoc goi NGAY TU thong bao, khong mo app - co the chay o isolate
/// NEN (app da dong han) nen phai tu dam bao Supabase da duoc khoi tao,
/// giong het _sendQuickReply() ben duoi.
Future<void> _declineCallInBackground(int callId) async {
  try {
    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
      client = Supabase.instance.client;
    }
    await CallRepository(client).updateStatus(callId, CallStatus.declined);
  } catch (_) {
    // Mat mang... - nguoi goi se tu thay cuoc goi khong duoc bat may sau
    // vai chuc giay (het TTL cua push) thay vi crash 1 isolate nen.
  }
}

/// Gui tin nhan tra loi nhanh ngay tu nut "Tra loi" tren thong bao he
/// thong - co the chay o isolate NEN (app da dong han) nen phai tu dam bao
/// Supabase da duoc khoi tao (main() KHONG chay trong isolate nay) truoc khi
/// dung Supabase.instance.client, khac voi moi noi khac trong app.
Future<void> _sendQuickReply(String receiverId, String content) async {
  try {
    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
      client = Supabase.instance.client;
    }
    await SocialRepository(client).sendMessage(receiverId, content);
  } catch (_) {
    // Mat mang/het session... - im lang bo qua, nguoi dung se thu lai khi
    // mo app binh thuong thay vi lam crash 1 isolate nen khong ai thay duoc.
  }
}

/// Dung chung cho ca 2 duong xu ly bam thong bao (foreground va background) -
/// tu phan biet la thong bao TIN NHAN hay CUOC GOI bang cach thu doc payload
/// dang JSON (cuoc goi) truoc, that bai thi coi payload la senderId thuan
/// (tin nhan, cach cu van giu nguyen de tuong thich nguoc).
void _handleNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null) return;

  Map<String, dynamic>? callData;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map && decoded['kind'] == 'call') {
      callData = decoded.cast<String, dynamic>();
    }
  } catch (_) {
    // Khong phai JSON - la payload tin nhan (senderId thuan), xu ly ben duoi.
  }

  if (callData != null) {
    final callId = int.tryParse(callData['call_id'] as String? ?? '');
    if (callId == null) return;
    if (response.actionId == _kDeclineCallActionId) {
      unawaited(_declineCallInBackground(callId));
    } else {
      // Bam "Tra loi" hoac bam thang vao noi dung thong bao - mo man hinh
      // xac nhan cuoc goi (chi lam duoc ngay neu isolate CHINH con song; neu
      // app da tat han, ChatPush.init() da luu san du lieu nay va RootShell
      // se tu mo lai sau khi khoi dong xong - xem checkPendingCallLaunch()).
      ChatPush.instance._openIncomingCall(callData);
    }
    return;
  }

  final senderId = payload;
  if (response.notificationResponseType ==
          NotificationResponseType.selectedNotificationAction &&
      response.actionId == _kReplyActionId) {
    final text = response.input?.trim();
    if (text != null && text.isNotEmpty) {
      unawaited(_sendQuickReply(senderId, text));
    }
    return;
  }
  ChatPush.instance._openChatWith(senderId);
}

/// PHAI la ham top-level - flutter_local_notifications goi ham nay khi
/// nguoi dung bam vao thong bao TRONG LUC app da bi tat han (khac voi
/// onDidReceiveNotificationResponse chi chay duoc khi isolate chinh con song).
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) =>
    _handleNotificationResponse(response);

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
    const callChannel = AndroidNotificationChannel(
      kIncomingCallChannelId,
      'Cuộc gọi đến',
      description: 'Thông báo khi có cuộc gọi thoại/video đến',
      importance: Importance.max,
    );
    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);
    await androidImpl?.createNotificationChannel(callChannel);

    // App co the da bi TAT HAN va duoc mo lai chinh boi nguoi dung bam vao
    // thong bao cuoc goi nay - luu lai du lieu cuoc goi de RootShell tu mo
    // man hinh xac nhan ngay khi widget tree san sang (xem
    // checkPendingCallLaunch(), goi tu root_shell.dart).
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null) {
      try {
        final decoded = jsonDecode(launchPayload);
        if (decoded is Map && decoded['kind'] == 'call') {
          _pendingCallData = decoded.cast<String, dynamic>();
        }
      } catch (_) {}
    }

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
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

  /// Du lieu cuoc goi tu 1 thong bao da bam NHUNG chua mo duoc man hinh xac
  /// nhan ngay (luc do isolate chinh/widget tree chua san sang - app dang
  /// khoi dong lai tu trang thai da tat han). RootShell tieu thu gia tri
  /// nay 1 lan duy nhat ngay sau frame dau tien (xem checkPendingCallLaunch).
  Map<String, dynamic>? _pendingCallData;

  Future<void> _openIncomingCall(Map<String, dynamic> callData) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _pendingCallData = callData;
      return;
    }
    _pushIncomingCallScreen(context, callData);
  }

  /// Goi tu root_shell.dart ngay sau khi widget tree da dung xong - xu ly
  /// truong hop nguoi dung mo lai app bang cach bam vao thong bao cuoc goi
  /// trong luc app dang o trang thai da tat han (khong con isolate chinh
  /// nao song de _openIncomingCall xu ly ngay luc thong bao vua duoc bam).
  void checkPendingCallLaunch(BuildContext context) {
    final data = _pendingCallData;
    if (data == null) return;
    _pendingCallData = null;
    _pushIncomingCallScreen(context, data);
  }

  void _pushIncomingCallScreen(
    BuildContext context,
    Map<String, dynamic> callData,
  ) {
    final call = Call(
      id: int.parse(callData['call_id'] as String),
      callerId: callData['caller_id'] as String,
      calleeId: Supabase.instance.client.auth.currentUser?.id ?? '',
      channelName: callData['channel_name'] as String,
      type: (callData['call_type'] as String) == 'video'
          ? CallType.video
          : CallType.voice,
      status: CallStatus.ringing,
    );
    final avatarUrl = callData['caller_avatar_url'] as String? ?? '';
    final caller = SocialUser(
      id: callData['caller_id'] as String,
      username: null,
      displayName: callData['caller_name'] as String?,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
    );
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(call: call, caller: caller),
        fullscreenDialog: true,
      ),
    );
  }
}
