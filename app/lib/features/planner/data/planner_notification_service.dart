import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/notifications/local_notifications_core.dart';
import 'planner_models.dart';

/// Dat/huy thong bao he thong khi den gio 1 viec trong Lap ke hoach - dung
/// chung engine voi DailyQuizNotifications
/// (core/notifications/daily_quiz_notifications.dart: flutter_local_notifications
/// + timezone, 2 package DA CO SAN trong pubspec.yaml, khong them moi) nhung
/// kenh + dai id rieng de khong dam vao lich nhac hoc tu vung. Hoat dong ca
/// khi app da dong/khoa may (AlarmManager giu lich, khong phu thuoc tien
/// trinh app con song).
///
/// Ban web: plugin khong dat lich duoc - [isSupported] = false de UI bao ro
/// cho nguoi dung thay vi im lang (docs/research-planner-app-ux.md §7.5).
class PlannerNotificationService {
  PlannerNotificationService._();
  static final instance = PlannerNotificationService._();

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Tien to payload - xem handleNotificationAction trong chat_push.dart.
  /// Dang day du: `planner:<taskId>|<yyyy-MM-dd>`.
  static const payloadPrefix = 'planner:';

  static const _channelDesc = 'Thông báo khi đến giờ 1 việc trong Lập kế hoạch';

  /// Viec lap lai chi dat lich cho cac lan trong [_recurringWindowDays] ngay
  /// toi (dat lai moi lan mo app, xem PlannerTasksNotifier._restore) - tranh
  /// vuot gioi han so thong bao cho cua he dieu hanh.
  static const _recurringWindowDays = 7;
  static const _maxOffsets = 3;
  static const _slotsPerTask = _recurringWindowDays * _maxOffsets;

  // QUAN TRONG: tren Android, am thanh + rung cua 1 notification channel bi
  // "dong cung" ngay LAN DAU channel duoc tao - goi lai voi
  // AndroidNotificationDetails co `sound`/`enableVibration` KHAC DI sau do
  // KHONG lam doi gi (gioi han cua he dieu hanh, khong phai loi plugin). Vi
  // vay channel ID phai GHEP tu (loai chuong + kieu nhac): moi to hop 1
  // channel rieng co dinh - neu khong, doi "Loai chuong"/"Kieu nhac" trong
  // planner_settings_sheet.dart se KHONG co tac dung thuc te.
  String _channelIdFor(PlannerReminderSettings s) {
    final sound = switch (s.ringtone) {
      RingtoneChoice.defaultSound => 'default',
      RingtoneChoice.cheerfulTone => 'cheerful',
      RingtoneChoice.deviceAlarm =>
        'alarm_${_stableHash(s.alarmSoundUri ?? '')}',
    };
    // Giu nguyen id cu cho to hop mac dinh (ca hai) de khong sinh kenh thua
    // tren may da cai ban truoc.
    if (s.mode == ReminderMode.both &&
        s.ringtone != RingtoneChoice.deviceAlarm) {
      return 'planner_reminder_$sound';
    }
    return 'planner_reminder_${sound}_${s.mode.name}';
  }

  String _channelNameFor(PlannerReminderSettings s) {
    final sound = switch (s.ringtone) {
      RingtoneChoice.defaultSound => 'Mặc định',
      RingtoneChoice.cheerfulTone => 'Giai điệu vui',
      RingtoneChoice.deviceAlarm => 'Báo thức: ${s.alarmSoundTitle ?? ''}',
    };
    return 'Nhắc việc Lập kế hoạch ($sound)';
  }

  // Alias toi instance CHUNG (xem local_notifications_core.dart) - KHONG
  // con tu tao FlutterLocalNotificationsPlugin() rieng o day nua. Truoc day
  // goi _plugin.initialize() rieng O DAY (KHONG truyen callback nao) co the
  // XOA MAT dispatcher tap-thong-bao dang hoat dong (dang ky boi noi khac -
  // xem local_notifications_core.dart) neu ham nay chay SAU noi do.
  final _plugin = localNotificationsPlugin;
  bool _initialized = false;

  /// KHONG con tu goi _plugin.initialize() o day nua - da chuyen sang
  /// initLocalNotifications() trong main.dart (goi 1 LAN DUY NHAT cho toan
  /// app) - xem local_notifications_core.dart. init() o day chi con lo tz +
  /// xin quyen (vo hai neu xin lai lan nua, Android tu bo qua neu da co).
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
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

  /// FNV-1a 31-bit - ON DINH giua cac phien ban Dart (khac String.hashCode,
  /// Dart khong cam ket gia tri hashCode giu nguyen sau khi nang SDK -> co the
  /// khong huy duoc thong bao cu, xem §7.6).
  static int _stableHash(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h & 0x7fffffff;
  }

  int _slotId(String taskId, int slot) => _stableHash('$taskId#$slot');

  /// Id cu (ban truoc dung String.hashCode) - van huy de khong con thong bao
  /// "mo coi" tu ban cu sau khi cap nhat app.
  int _legacyId(String taskId) => taskId.hashCode & 0x7fffffff;

  AndroidNotificationDetails _detailsFor(PlannerReminderSettings settings) {
    final alarmUri = settings.ringtone == RingtoneChoice.deviceAlarm
        ? settings.alarmSoundUri
        : null;
    return AndroidNotificationDetails(
      _channelIdFor(settings),
      _channelNameFor(settings),
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: settings.mode != ReminderMode.vibrateOnly,
      enableVibration: settings.mode != ReminderMode.soundOnly,
      sound: alarmUri != null
          ? UriAndroidNotificationSound(alarmUri)
          : settings.ringtone == RingtoneChoice.cheerfulTone
          ? const RawResourceAndroidNotificationSound('notification_tone')
          : null,
      // Chuong bao thuc phat qua luong am thanh BAO THUC (theo am luong bao
      // thuc cua may) giong app Dong ho, khong phai am luong thong bao.
      audioAttributesUsage: alarmUri != null
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      category: alarmUri != null
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
    );
  }

  List<int> _offsetsFor(PlannerTask task, PlannerReminderSettings settings) {
    if (!task.reminderEnabled) return const [];
    final offsets =
        task.reminderOffsets ?? [settings.leadTime.leadDuration.inMinutes];
    return offsets.take(_maxOffsets).toList();
  }

  String _bodyFor(PlannerTask task, int offsetMinutes) {
    if (offsetMinutes == 0) return 'Đến giờ: ${task.title}';
    if (offsetMinutes >= 1440) return 'Ngày mai: ${task.title}';
    if (offsetMinutes >= 60) {
      return '${offsetMinutes ~/ 60} giờ nữa: ${task.title}';
    }
    return '$offsetMinutes phút nữa: ${task.title}';
  }

  Future<void> schedule(
    PlannerTask task,
    PlannerReminderSettings settings,
  ) async {
    if (!isSupported) return;
    await cancel(task.id);
    if (task.inbox || settings.mode == ReminderMode.off) return;
    final offsets = _offsetsFor(task, settings);
    if (offsets.isEmpty) return;

    final now = DateTime.now();
    final occurrences = <PlannerOccurrence>[];
    if (task.isRecurring) {
      final today = plannerDateOnly(now);
      for (var i = 0; i < _recurringWindowDays; i++) {
        final day = today.add(Duration(days: i));
        if (!task.occursOn(day)) continue;
        final occ = task.occurrenceOn(day);
        if (occ.settledStatus == null) occurrences.add(occ);
      }
    } else if (task.occurrenceOn(task.start).settledStatus == null) {
      occurrences.add(task.occurrenceOn(task.start));
    }

    final details = NotificationDetails(android: _detailsFor(settings));
    var slot = 0;
    for (final occ in occurrences) {
      for (final offset in offsets) {
        final id = _slotId(task.id, slot++);
        final fireAt = occ.start.subtract(Duration(minutes: offset));
        if (fireAt.isBefore(now)) continue;
        await _zonedSchedule(
          id: id,
          body: _bodyFor(task, offset),
          fireAt: fireAt,
          details: details,
          payload: '$payloadPrefix${task.id}|${occ.dayKey}',
        );
      }
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required String body,
    required DateTime fireAt,
    required NotificationDetails details,
    required String payload,
  }) async {
    // TZDateTime.from doi theo THOI DIEM tuyet doi cua DateTime goc, nen
    // dung tz.UTC lam Location khong lam sai gio bao thuc te - cung cach lam
    // voi DailyQuizNotifications, khong can cau hinh tz.setLocalLocation.
    final scheduled = tz.TZDateTime.from(fireAt, tz.UTC);
    for (final mode in [
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ]) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: 'Lập kế hoạch',
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: mode,
          payload: payload,
        );
        return;
      } catch (_) {}
    }
  }

  Future<void> cancel(String taskId) async {
    if (!isSupported) return;
    await _plugin.cancel(id: _legacyId(taskId));
    for (var slot = 0; slot < _slotsPerTask; slot++) {
      await _plugin.cancel(id: _slotId(taskId, slot));
    }
  }

  /// Id rieng cho thong bao "Nghe thu" - co dinh, khong dam vao dai id cua
  /// viec that.
  static const _previewId = -1001;

  /// Ban 1 thong bao NGAY LAP TUC (khong dat lich) chi de nguoi dung nghe
  /// thu am thanh + kieu nhac TRUOC khi luu cai dat - dung dung channel se
  /// dung that (xem [_channelIdFor]) nen nghe dung 100% giong luc thong bao
  /// that su bat len.
  Future<void> preview(PlannerReminderSettings settings) async {
    if (!isSupported || settings.mode == ReminderMode.off) return;
    await _plugin.show(
      id: _previewId,
      title: 'Lập kế hoạch',
      body: 'Đây là âm thanh nhắc nhở của bạn',
      notificationDetails: NotificationDetails(android: _detailsFor(settings)),
    );
  }
}
