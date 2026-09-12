import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Instance FlutterLocalNotificationsPlugin DUY NHAT dung CHUNG cho TOAN BO
/// app (DailyQuizNotifications, PlannerNotificationService, ChatPush) - xem
/// initLocalNotifications() ben duoi de biet ly do BAT BUOC chi 1 instance +
/// 1 lan goi initialize() duy nhat trong toan app.
final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

bool _initialized = false;

/// Goi 1 LAN DUY NHAT, CANG SOM CANG TOT trong main() (KHONG phu thuoc
/// Firebase/mang - phai chay xong duoc ngay ca khi Firebase chua cau hinh
/// hoac that bai) - dang ky dispatcher CHUNG cho MOI loai thong bao local
/// trong app (nhac hoc tu vung, Lap ke hoach, chat, nhac han dich vu, thong
/// bao gia).
///
/// LY DO can tach rieng file nay: flutter_local_notifications chi giu duoc
/// DUY NHAT 1 onDidReceiveNotificationResponse dang hoat dong tren toan app
/// tai 1 thoi diem (goi initialize() nhieu lan se GHI DE callback cua lan
/// truoc, ke ca goi initialize() KHONG truyen callback nao cung XOA MAT
/// callback dang co). Truoc day 3 noi (DailyQuizNotifications,
/// PlannerNotificationService, ChatPush) deu tu tao FlutterLocalNotificationsPlugin()
/// rieng roi tu goi initialize() rieng - te hai nhat la dispatcher DUNG
/// (trong ChatPush) lai bi dat SAU await Firebase.initializeApp() trong
/// ChatPush.init(): neu Firebase that bai/chua cau hinh xong, ChatPush.init()
/// return SOM va KHONG BAO GIO dang ky duoc dispatcher, khien MOI thong bao
/// local trong app (ke ca nhac hoc tu vung - tinh nang KHONG lien quan gi
/// Firebase) bam vao chi mo lai app ma khong dieu huong di dau ca. Gio viec
/// dang ky nay tach rieng, chay NGAY TU DAU trong main(), khong phu thuoc
/// Firebase.
Future<void> initLocalNotifications({
  required void Function(NotificationResponse) onTap,
  required void Function(NotificationResponse) onBackgroundTap,
}) async {
  if (_initialized) return;
  const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notify');
  await localNotificationsPlugin.initialize(
    settings: const InitializationSettings(android: androidInit),
    onDidReceiveNotificationResponse: onTap,
    onDidReceiveBackgroundNotificationResponse: onBackgroundTap,
  );

  final androidImpl = localNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  try {
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  } catch (_) {
    // Thiet bi/OS cu khong ho tro 1 trong 2 quyen nay - bo qua, thong bao
    // van hoat dong (chi khong chinh xac tuyet doi ve gio neu thieu quyen
    // exact alarm).
  }

  _initialized = true;
}
