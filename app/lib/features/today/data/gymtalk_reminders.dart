import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/i18n/app_strings.dart';
import '../../../core/notifications/local_notifications_core.dart';
import '../../../core/providers/app_providers.dart';
import '../../fitness/data/program_model.dart';
import '../../srs/data/srs_store.dart';

/// Cai dat nhac hang ngay.
@immutable
class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });
  final bool enabled;
  final int hour;
  final int minute;
}

/// Noi dung 1 thong bao nhac trong ngay - tach rieng de test.
@immutable
class ReminderMessage {
  const ReminderMessage({required this.titleKey, required this.bodyKey});
  final String titleKey;
  final String bodyKey;
}

/// Chon noi dung nhac cho 1 ngay theo lich giao an: ngay tap -> goi y on
/// tu truoc khi tap; ngay nghi -> on tu den han; chua co giao an -> nhac
/// chung.
ReminderMessage reminderFor({
  required Program? program,
  required DateTime day,
}) {
  if (program == null) {
    return const ReminderMessage(
      titleKey: 'remind_generic_title',
      bodyKey: 'remind_generic_body',
    );
  }
  final ProgramDay plan;
  try {
    plan = program.dayFor(day);
  } on StateError {
    // Giao an khong co dong nao cho thu nay -> coi nhu ngay nghi.
    return const ReminderMessage(
      titleKey: 'remind_rest_title',
      bodyKey: 'remind_rest_body',
    );
  }
  if (plan.isRestDay) {
    return const ReminderMessage(
      titleKey: 'remind_rest_title',
      bodyKey: 'remind_rest_body',
    );
  }
  return const ReminderMessage(
    titleKey: 'remind_workout_title',
    bodyKey: 'remind_workout_body',
  );
}

/// Nhac tap + hoc hang ngay THEO LICH GIAO AN (7 ngay toi, dat lai moi lan
/// mo app / doi cai dat). Cham thong bao -> mo tab Hom nay (payload
/// [payload], xu ly trong chat_push.dart.handleNotificationAction).
class GymTalkReminders {
  GymTalkReminders._();
  static final GymTalkReminders instance = GymTalkReminders._();

  static const payload = 'gymtalk:today';
  static const _idBase = 9100;
  static const _days = 7;
  static const _channelId = 'gymtalk_daily_v1';
  static const _prefEnabled = 'gymtalk_reminder_enabled';
  static const _prefHour = 'gymtalk_reminder_hour';
  static const _prefMinute = 'gymtalk_reminder_minute';

  /// Tang moi khi nguoi dung cham thong bao - RootShell nghe de chuyen sang
  /// tab Hom nay (thong bao duoc xu ly ngoai cay widget, khong co ref).
  final ValueNotifier<int> openTodayRequests = ValueNotifier(0);

  bool _tzReady = false;

  Future<ReminderSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return ReminderSettings(
        enabled: prefs.getBool(_prefEnabled) ?? false,
        hour: prefs.getInt(_prefHour) ?? 18,
        minute: prefs.getInt(_prefMinute) ?? 0,
      );
    } catch (_) {
      return const ReminderSettings(enabled: false, hour: 18, minute: 0);
    }
  }

  Future<void> saveSettings(WidgetRef ref, ReminderSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabled, settings.enabled);
      await prefs.setInt(_prefHour, settings.hour);
      await prefs.setInt(_prefMinute, settings.minute);
    } catch (_) {}
    await rescheduleFromPrefs(ref);
  }

  /// Dat lai 7 thong bao toi theo cai dat + giao an dang theo. Goi khi mo
  /// app va khi doi cai dat/giao an. Loi (web, thieu quyen...) chi log.
  Future<void> rescheduleFromPrefs(WidgetRef ref) async {
    if (kIsWeb) return;
    try {
      final settings = await loadSettings();
      await _cancelAll();
      if (!settings.enabled) return;

      // Doc truc tiep repository (khong qua provider autoDispose de khong
      // bi huy giua chung khi goi ngoai build).
      final lang = ref.read(appLanguageProvider);
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      Program? program;
      if (userId != null) {
        final activeId = await ref
            .read(workoutRepositoryProvider)
            .getActiveProgramId(userId);
        if (activeId != null) {
          final programs = await ref
              .read(programRepositoryProvider)
              .getAllPrograms();
          for (final p in programs) {
            if (p.id == activeId) program = p;
          }
        }
      }
      await SrsStore.instance.ensureLoaded();
      final due = SrsStore.instance.dueCount(DateTime.now());

      if (!_tzReady) {
        tzdata.initializeTimeZones();
        _tzReady = true;
      }
      final now = DateTime.now();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'GymTalk',
          channelDescription: 'Nhắc tập và học tiếng Anh mỗi ngày',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      for (var i = 0; i < _days; i++) {
        final day = DateTime(now.year, now.month, now.day + i);
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          settings.hour,
          settings.minute,
        );
        if (!at.isAfter(now)) continue;
        final message = reminderFor(program: program, day: day);
        final body = AppStrings.t(
          message.bodyKey,
          lang,
        ).replaceFirst('{count}', '${i == 0 ? due : 5}');
        await _schedule(
          id: _idBase + i,
          title: AppStrings.t(message.titleKey, lang),
          body: body,
          // TZDateTime.from giu dung THOI DIEM tuyet doi - dung tz.UTC nhu
          // DailyQuizNotifications, khong can biet mui gio may.
          when: tz.TZDateTime.from(at, tz.UTC),
          details: details,
        );
      }
    } catch (e) {
      debugPrint('GymTalkReminders reschedule failed: $e');
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required NotificationDetails details,
  }) async {
    try {
      await localNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {
      // Thieu quyen exact alarm -> nhac khong chinh xac tuyet doi.
      try {
        await localNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {}
    }
  }

  Future<void> _cancelAll() async {
    for (var i = 0; i < _days; i++) {
      await localNotificationsPlugin.cancel(id: _idBase + i);
    }
  }

  /// Nguoi dung cham thong bao.
  void handleTap() => openTodayRequests.value++;
}
