import 'package:flutter/material.dart';

import '../../../core/providers/app_providers.dart';

/// 1 viec trong tinh nang "Lap ke hoach" - dung chung cho ca 3 mini-app,
/// phan biet qua [appSection] (icon + mau rieng trong timeline, xem
/// planner_timeline.dart).
class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.appSection,
    required this.start,
    required this.end,
    this.status = PlannerTaskStatus.upcoming,
    this.reminderEnabled = false,
    this.icon = PlannerTaskIcon.none,
  });

  final String id;
  final String title;
  final AppSection appSection;
  final DateTime start;
  final DateTime end;
  final PlannerTaskStatus status;
  final bool reminderEnabled;

  /// Icon phan loai rieng (cong viec/game/thu gian/...), TACH BIET voi
  /// [appSection] (van dung de loc theo mini-app + mau chrome). `none` =
  /// hien icon mac dinh cua appSection nhu truoc day (tuong thich nguoc voi
  /// du lieu da luu chua co truong nay).
  final PlannerTaskIcon icon;

  PlannerTask copyWith({
    String? title,
    AppSection? appSection,
    DateTime? start,
    DateTime? end,
    PlannerTaskStatus? status,
    bool? reminderEnabled,
    PlannerTaskIcon? icon,
  }) => PlannerTask(
    id: id,
    title: title ?? this.title,
    appSection: appSection ?? this.appSection,
    start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    icon: icon ?? this.icon,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'appSection': appSection.name,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'status': status.name,
    'reminderEnabled': reminderEnabled,
    'icon': icon.name,
  };

  factory PlannerTask.fromJson(Map<String, dynamic> json) => PlannerTask(
    id: json['id'] as String,
    title: json['title'] as String,
    appSection: AppSection.values.byName(json['appSection'] as String),
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    status: PlannerTaskStatus.values.byName(json['status'] as String),
    reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    icon: PlannerTaskIcon.values.byName(
      json['icon'] as String? ?? PlannerTaskIcon.none.name,
    ),
  );
}

/// Icon phan loai viec ngoai 3 app (English/Fitness/Wealth) - yeu cau them
/// nhieu icon hon cho cac loai viec chung nhu game/cong viec/thu gian/khac.
enum PlannerTaskIcon { none, work, game, relax, study, sleep, other }

extension PlannerTaskIconX on PlannerTaskIcon {
  IconData get iconData => switch (this) {
    PlannerTaskIcon.none => Icons.circle,
    PlannerTaskIcon.work => Icons.work_rounded,
    PlannerTaskIcon.game => Icons.sports_esports_rounded,
    PlannerTaskIcon.relax => Icons.spa_rounded,
    PlannerTaskIcon.study => Icons.school_rounded,
    PlannerTaskIcon.sleep => Icons.bedtime_rounded,
    PlannerTaskIcon.other => Icons.label_rounded,
  };

  Color get color => switch (this) {
    PlannerTaskIcon.none => Colors.transparent,
    PlannerTaskIcon.work => const Color(0xFFFFA65C),
    PlannerTaskIcon.game => const Color(0xFF8C6BFF),
    PlannerTaskIcon.relax => const Color(0xFF5BE0D0),
    PlannerTaskIcon.study => const Color(0xFF5B8CFF),
    PlannerTaskIcon.sleep => const Color(0xFF9DA7C7),
    PlannerTaskIcon.other => const Color(0xFFFF6B9D),
  };
}

/// 4 trang thai CO DINH (khong cho tuy bien mau) - xem SKILL.md muc 11: mau
/// rieng biet han voi 3 accent gradient section (English/Fitness/Wealth) de
/// khong bi nham "mau trang thai" voi "mau app dang mo".
enum PlannerTaskStatus { completed, running, rejected, upcoming }

extension PlannerTaskStatusX on PlannerTaskStatus {
  Color get color => switch (this) {
    PlannerTaskStatus.completed => const Color(0xFF5BE0D0),
    PlannerTaskStatus.running => const Color(0xFFA3E635),
    PlannerTaskStatus.rejected => const Color(0xFFFF6B9D),
    PlannerTaskStatus.upcoming => const Color(0xFF8B93A7),
  };
}

/// Nhac truoc bao lau - xem PlannerSettings.dc.html.
enum ReminderLeadTime { onTime, min5, min15, min30, hour1 }

extension ReminderLeadTimeX on ReminderLeadTime {
  Duration get leadDuration => switch (this) {
    ReminderLeadTime.onTime => Duration.zero,
    ReminderLeadTime.min5 => const Duration(minutes: 5),
    ReminderLeadTime.min15 => const Duration(minutes: 15),
    ReminderLeadTime.min30 => const Duration(minutes: 30),
    ReminderLeadTime.hour1 => const Duration(hours: 1),
  };
}

/// Rung/chuong/ca hai/tat - xem PlannerSettings.dc.html.
enum ReminderMode { both, vibrateOnly, soundOnly, off }

/// 2 lua chon chuong THAT SU co san (khong hua hen am thanh chua co san
/// trong app) - "Mac dinh" dung am thanh mac dinh he thong, "Giai dieu vui"
/// tai su dung file notification_tone.mp3 DA CO SAN trong
/// android/app/src/main/res/raw/ (dung chung voi kenh thong bao tin nhan
/// chat, xem chat_push.dart) - khong them file am thanh moi nao.
enum RingtoneChoice { defaultSound, cheerfulTone }

class PlannerReminderSettings {
  const PlannerReminderSettings({
    this.ringtone = RingtoneChoice.defaultSound,
    this.leadTime = ReminderLeadTime.onTime,
    this.mode = ReminderMode.both,
  });

  final RingtoneChoice ringtone;
  final ReminderLeadTime leadTime;
  final ReminderMode mode;

  PlannerReminderSettings copyWith({
    RingtoneChoice? ringtone,
    ReminderLeadTime? leadTime,
    ReminderMode? mode,
  }) => PlannerReminderSettings(
    ringtone: ringtone ?? this.ringtone,
    leadTime: leadTime ?? this.leadTime,
    mode: mode ?? this.mode,
  );

  Map<String, dynamic> toJson() => {
    'ringtone': ringtone.name,
    'leadTime': leadTime.name,
    'mode': mode.name,
  };

  factory PlannerReminderSettings.fromJson(Map<String, dynamic> json) =>
      PlannerReminderSettings(
        ringtone: RingtoneChoice.values.byName(
          json['ringtone'] as String? ?? RingtoneChoice.defaultSound.name,
        ),
        leadTime: ReminderLeadTime.values.byName(
          json['leadTime'] as String? ?? ReminderLeadTime.onTime.name,
        ),
        mode: ReminderMode.values.byName(
          json['mode'] as String? ?? ReminderMode.both.name,
        ),
      );
}
