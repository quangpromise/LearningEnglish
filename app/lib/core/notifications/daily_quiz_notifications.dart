import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/vocabulary/presentation/daily_quiz_popup_screen.dart';
import '../navigation/nav_keys.dart';
import '../utils/vn_time.dart';

/// Nhac hoc "10 tu hom nay" bang thong bao he thong dat lich truoc - hoat
/// dong ca khi app da bi dong/khoa may, vi lich duoc AlarmManager (Android)
/// giu san chu khong phu thuoc tien trinh app con song. Xem
/// docs/research-notifications.md de biet ly do chon package nay thay vi
/// Timer trong app, va cac gioi han quyen lien quan.
class DailyQuizNotifications {
  DailyQuizNotifications._();
  static final instance = DailyQuizNotifications._();

  static const _channelId = 'daily_quiz_reminder';
  static const _channelName = 'Nhắc học từ vựng';
  static const _channelDesc =
      'Thông báo nhắc làm quiz cho các từ đang học hôm nay';
  static const _idBase = 9000;
  static const _maxScheduled = 48;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTap,
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

  static void _onTap(NotificationResponse response) {
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const DailyQuizPopupScreen()),
    );
  }

  /// Dat lich thong bao moi [intervalMinutes] phut, tu bay gio den het ngay
  /// hom nay (khong lap sang ngay mai) - toi da [_maxScheduled] thong bao de
  /// tranh dat qua nhieu alarm cung luc.
  Future<void> scheduleReminders({required int intervalMinutes}) async {
    await cancelReminders();
    if (intervalMinutes <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    // Gioi han theo NUA DEM GIO VIET NAM (khong phai gio thiet bi) - dung
    // yeu cau "het ngay gio Viet Nam thi tu dong ket thuc".
    final endOfDay = nextVnMidnightInstant();
    var occurrence = now.add(Duration(minutes: intervalMinutes));
    var count = 0;
    while (occurrence.isBefore(endOfDay) && count < _maxScheduled) {
      // TZDateTime.from doi theo THOI DIEM tuyet doi cua DateTime goc, nen
      // dung tz.UTC lam Location khong lam sai gio bao thuc te - khong can
      // them package do mui gio thiet bi (flutter_timezone) chi de tinh
      // "bay gio + X phut".
      final scheduled = tz.TZDateTime.from(occurrence, tz.UTC);
      await _scheduleOne(_idBase + count, scheduled, details);
      occurrence = occurrence.add(Duration(minutes: intervalMinutes));
      count++;
    }
  }

  Future<void> _scheduleOne(
    int id,
    tz.TZDateTime scheduled,
    NotificationDetails details,
  ) async {
    const title = 'Đến giờ ôn từ vựng!';
    const body = 'Chạm để làm quiz nhanh cho các từ bạn đang học hôm nay';
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // He thong tu choi exact alarm (thieu quyen "Alarms & reminders") -
      // thu lai kieu khong chinh xac tuyet doi, thong bao van hien nhung co
      // the tre vai phut so voi lich dat.
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelReminders() async {
    for (var i = 0; i < _maxScheduled; i++) {
      await _plugin.cancel(id: _idBase + i);
    }
  }
}
