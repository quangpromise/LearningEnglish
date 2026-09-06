import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'planner_models.dart';

/// Dat/huy thong bao he thong khi den gio 1 viec trong Lap ke hoach - dung
/// chung engine voi DailyQuizNotifications
/// (core/notifications/daily_quiz_notifications.dart: flutter_local_notifications
/// + timezone, 2 package DA CO SAN trong pubspec.yaml, khong them moi) nhung
/// kenh + dai id rieng de khong dam vao lich nhac hoc tu vung. Hoat dong ca
/// khi app da dong/khoa may (AlarmManager giu lich, khong phu thuoc tien
/// trinh app con song).
class PlannerNotificationService {
  PlannerNotificationService._();
  static final instance = PlannerNotificationService._();

  static const _channelDesc = 'Thông báo khi đến giờ 1 việc trong Lập kế hoạch';

  // QUAN TRONG: tren Android, am thanh cua 1 notification channel bi "dong
  // cung" ngay LAN DAU channel duoc tao - goi lai voi AndroidNotificationDetails
  // co `sound` KHAC DI sau do KHONG lam doi am thanh (gioi han cua he dieu
  // hanh, khong phai loi cua plugin). Vi vay moi loai chuong PHAI co 1
  // channel ID rieng biet co dinh (khong dung chung 1 channel roi doi
  // `sound` moi lan) - neu khong, doi cai dat "Loai chuong" trong
  // planner_settings_sheet.dart se KHONG co tac dung thuc te len thong bao
  // that, va nut "Nghe thu" se luon phat dung 1 am da tao truoc do.
  static const _channelIdDefault = 'planner_reminder_default';
  static const _channelIdCheerful = 'planner_reminder_cheerful';

  String _channelIdFor(RingtoneChoice ringtone) => switch (ringtone) {
    RingtoneChoice.defaultSound => _channelIdDefault,
    RingtoneChoice.cheerfulTone => _channelIdCheerful,
  };

  String _channelNameFor(RingtoneChoice ringtone) => switch (ringtone) {
    RingtoneChoice.defaultSound => 'Nhắc việc Lập kế hoạch (Mặc định)',
    RingtoneChoice.cheerfulTone => 'Nhắc việc Lập kế hoạch (Giai điệu vui)',
  };

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_stat_notify',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );
    final androidImpl = _plugin
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

  /// Id thong bao on dinh suy tu id viec (khong can tu luu 1 counter rieng) -
  /// xac suat trung giua 2 viec khac nhau trong thuc te bang 0, & voi so
  /// duong 31-bit de tuong thich gioi han int cua plugin tren Android.
  int _notificationId(String taskId) => taskId.hashCode & 0x7fffffff;

  AndroidNotificationDetails _detailsFor(PlannerReminderSettings settings) {
    return AndroidNotificationDetails(
      _channelIdFor(settings.ringtone),
      _channelNameFor(settings.ringtone),
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: settings.mode != ReminderMode.vibrateOnly,
      enableVibration: settings.mode != ReminderMode.soundOnly,
      sound: settings.ringtone == RingtoneChoice.cheerfulTone
          ? const RawResourceAndroidNotificationSound('notification_tone')
          : null,
    );
  }

  Future<void> schedule(
    PlannerTask task,
    PlannerReminderSettings settings,
  ) async {
    final id = _notificationId(task.id);
    await _plugin.cancel(id: id);
    if (!task.reminderEnabled || settings.mode == ReminderMode.off) return;

    final fireAt = task.start.subtract(settings.leadTime.leadDuration);
    if (fireAt.isBefore(DateTime.now())) return;

    final details = NotificationDetails(android: _detailsFor(settings));
    // TZDateTime.from doi theo THOI DIEM tuyet doi cua DateTime goc, nen
    // dung tz.UTC lam Location khong lam sai gio bao thuc te - cung cach lam
    // voi DailyQuizNotifications, khong can cau hinh tz.setLocalLocation.
    final scheduled = tz.TZDateTime.from(fireAt, tz.UTC);
    final body = settings.leadTime == ReminderLeadTime.onTime
        ? 'Đến giờ: ${task.title}'
        : 'Sắp đến giờ: ${task.title}';

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'Lập kế hoạch',
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: 'Lập kế hoạch',
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
    }
  }

  Future<void> cancel(String taskId) async {
    await _plugin.cancel(id: _notificationId(taskId));
  }

  /// Id rieng cho thong bao "Nghe thu" - co dinh, khong dam vao dai id cua
  /// viec that (xem [_notificationId]) vi id viec suy tu hashCode nen ve ly
  /// thuyet co the (du cuc hiem) trung voi so am.
  static const _previewId = -1001;

  /// Ban 1 thong bao NGAY LAP TUC (khong dat lich) chi de nguoi dung nghe
  /// thu am thanh cua [ringtone] + [mode] TRUOC khi luu cai dat - dung dung
  /// channel se dung that (xem [_channelIdFor]) nen nghe dung 100% giong luc
  /// thong bao that su bat len, khong phai phat lai file audio roi (am
  /// luong/kenh am thanh cua notification khac voi phat nhac thong thuong).
  Future<void> preview({
    required RingtoneChoice ringtone,
    required ReminderMode mode,
  }) async {
    if (mode == ReminderMode.off) return;
    final settings = PlannerReminderSettings(ringtone: ringtone, mode: mode);
    await _plugin.show(
      id: _previewId,
      title: 'Lập kế hoạch',
      body: 'Đây là âm thanh nhắc nhở của bạn',
      notificationDetails: NotificationDetails(android: _detailsFor(settings)),
    );
  }
}
