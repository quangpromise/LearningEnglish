import 'package:flutter/material.dart';

import '../../../core/providers/app_providers.dart';

/// Khoa ngay 'yyyy-MM-dd' - dung cho cac tap ngay rieng cua viec lap lai
/// (doneDates/skippedDates/excludedDates) va payload thong bao.
String plannerDayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime plannerDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool plannerSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Tan suat lap lai - tap con tuong thich RRULE (RFC 5545: FREQ=DAILY/
/// WEEKLY/MONTHLY + BYDAY + UNTIL) de sau nay xuat ICS khong phai doi schema
/// (xem docs/research-planner-app-ux.md §7.3 muc 2).
enum PlannerRepeatFreq { daily, weekly, monthly }

class PlannerRecurrence {
  const PlannerRecurrence({
    required this.freq,
    this.weekdays = const [],
    this.until,
  });

  final PlannerRepeatFreq freq;

  /// 1 = Thu 2 ... 7 = Chu nhat (giong DateTime.weekday). Chi dung khi
  /// [freq] = weekly; rong = lap dung thu cua ngay bat dau.
  final List<int> weekdays;

  /// Ngay cuoi cung con lap (tinh ca ngay nay); null = khong bao gio het.
  final DateTime? until;

  Map<String, dynamic> toJson() => {
    'freq': freq.name,
    'weekdays': weekdays,
    if (until != null) 'until': plannerDayKey(until!),
  };

  factory PlannerRecurrence.fromJson(Map<String, dynamic> json) =>
      PlannerRecurrence(
        freq: PlannerRepeatFreq.values.byName(json['freq'] as String),
        weekdays:
            (json['weekdays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        until: json['until'] == null
            ? null
            : DateTime.parse(json['until'] as String),
      );
}

/// Tham chieu toi noi dung goc trong 1 mini-app (buoi tap, on tu, dich vu
/// can gia han...) - planner CHI luu tham chieu, khong sao chep du lieu
/// nghiep vu (xem docs/research-planner-app-ux.md §7.4). [kind] + [refId]
/// la khoa chong tao trung khi mini-app bam "Them vao ke hoach" nhieu lan.
class PlannerTaskSource {
  const PlannerTaskSource({required this.kind, required this.refId});

  final String kind;
  final String refId;

  Map<String, dynamic> toJson() => {'kind': kind, 'refId': refId};

  factory PlannerTaskSource.fromJson(Map<String, dynamic> json) =>
      PlannerTaskSource(
        kind: json['kind'] as String,
        refId: json['refId'] as String,
      );

  bool sameAs(PlannerTaskSource? other) =>
      other != null && other.kind == kind && other.refId == refId;
}

/// 1 viec trong tinh nang "Lap ke hoach" - dung chung cho ca 3 mini-app,
/// phan biet qua [appSection] (icon + mau rieng trong timeline, xem
/// planner_timeline.dart).
///
/// TUONG THICH NGUOC: moi truong moi (tu [notes] tro xuong) deu co gia tri
/// mac dinh khi JSON cu khong co - du lieu da luu tu ban truoc van doc duoc.
/// Nguoc lai [status] chi bao gio GHI 1 trong 4 gia tri cu (khong ghi
/// `overdue` - trang thai do chi TINH luc hien thi) nen APK cu van doc duoc
/// file do ban moi ghi ra.
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
    this.notes = '',
    this.recurrence,
    this.doneDates = const {},
    this.skippedDates = const {},
    this.excludedDates = const {},
    this.reminderOffsets,
    this.inbox = false,
    this.source,
  });

  final String id;
  final String title;
  final AppSection appSection;

  /// Voi viec lap lai: ngay cua [start] la NGAY BAT DAU chuoi, gio/phut cua
  /// [start]/[end] la khung gio cua MOI lan lap. Voi viec trong Inbox:
  /// [end] - [start] = thoi luong du kien khi xep vao timeline.
  final DateTime start;
  final DateTime end;

  /// Trang thai NGUOI DUNG CHOT (completed/rejected) cho viec 1 lan. Cac gia
  /// tri upcoming/running cu coi nhu "chua chot" - trang thai hien thi tu
  /// suy theo gio (xem [PlannerOccurrence.statusAt]).
  final PlannerTaskStatus status;
  final bool reminderEnabled;

  /// Icon phan loai rieng (cong viec/game/thu gian/...), TACH BIET voi
  /// [appSection] (van dung de loc theo mini-app + mau chrome). `none` =
  /// hien icon mac dinh cua appSection nhu truoc day (tuong thich nguoc voi
  /// du lieu da luu chua co truong nay).
  final PlannerTaskIcon icon;

  final String notes;

  /// null = viec 1 lan.
  final PlannerRecurrence? recurrence;

  /// Cac lan lap (khoa [plannerDayKey]) da hoan thanh / bo qua / da xoa rieng
  /// le - luu trang thai tung lan ma KHONG sinh san ban sao moi lan lap
  /// (tranh phinh JSON trong SharedPreferences).
  final Set<String> doneDates;
  final Set<String> skippedDates;
  final Set<String> excludedDates;

  /// So phut nhac TRUOC gio bat dau (0 = dung gio, 1440 = truoc 1 ngay).
  /// null = dung "Nhac truoc" trong cai dat chung.
  final List<int>? reminderOffsets;

  /// true = viec nam trong "Chua xep gio" (Inbox), khong hien tren timeline.
  final bool inbox;

  final PlannerTaskSource? source;

  bool get isRecurring => recurrence != null;
  Duration get duration => end.difference(start);

  /// Viec co xuat hien vao ngay [day] khong (khong xet Inbox).
  bool occursOn(DateTime day) {
    final d = plannerDateOnly(day);
    final first = plannerDateOnly(start);
    final rule = recurrence;
    if (rule == null) return d == first;
    if (d.isBefore(first)) return false;
    if (rule.until != null && d.isAfter(plannerDateOnly(rule.until!))) {
      return false;
    }
    if (excludedDates.contains(plannerDayKey(d))) return false;
    return switch (rule.freq) {
      PlannerRepeatFreq.daily => true,
      PlannerRepeatFreq.weekly =>
        (rule.weekdays.isEmpty ? [first.weekday] : rule.weekdays).contains(
          d.weekday,
        ),
      PlannerRepeatFreq.monthly => d.day == first.day,
    };
  }

  PlannerOccurrence occurrenceOn(DateTime day) => PlannerOccurrence(
    task: this,
    day: plannerDateOnly(day),
    start: DateTime(day.year, day.month, day.day, start.hour, start.minute),
  );

  PlannerTask copyWith({
    String? id,
    String? title,
    AppSection? appSection,
    DateTime? start,
    DateTime? end,
    PlannerTaskStatus? status,
    bool? reminderEnabled,
    PlannerTaskIcon? icon,
    String? notes,
    PlannerRecurrence? recurrence,
    bool clearRecurrence = false,
    Set<String>? doneDates,
    Set<String>? skippedDates,
    Set<String>? excludedDates,
    List<int>? reminderOffsets,
    bool clearReminderOffsets = false,
    bool? inbox,
    PlannerTaskSource? source,
  }) => PlannerTask(
    id: id ?? this.id,
    title: title ?? this.title,
    appSection: appSection ?? this.appSection,
    start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    icon: icon ?? this.icon,
    notes: notes ?? this.notes,
    recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
    doneDates: doneDates ?? this.doneDates,
    skippedDates: skippedDates ?? this.skippedDates,
    excludedDates: excludedDates ?? this.excludedDates,
    reminderOffsets: clearReminderOffsets
        ? null
        : (reminderOffsets ?? this.reminderOffsets),
    inbox: inbox ?? this.inbox,
    source: source ?? this.source,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'appSection': appSection.name,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    // KHONG BAO GIO ghi `overdue` (APK cu khong co gia tri nay trong enum).
    'status': status == PlannerTaskStatus.overdue
        ? PlannerTaskStatus.upcoming.name
        : status.name,
    'reminderEnabled': reminderEnabled,
    'icon': icon.name,
    if (notes.isNotEmpty) 'notes': notes,
    if (recurrence != null) 'recurrence': recurrence!.toJson(),
    if (doneDates.isNotEmpty) 'doneDates': doneDates.toList(),
    if (skippedDates.isNotEmpty) 'skippedDates': skippedDates.toList(),
    if (excludedDates.isNotEmpty) 'excludedDates': excludedDates.toList(),
    if (reminderOffsets != null) 'reminderOffsets': reminderOffsets,
    if (inbox) 'inbox': true,
    if (source != null) 'source': source!.toJson(),
  };

  static Set<String> _stringSet(dynamic raw) =>
      (raw as List<dynamic>?)?.map((e) => e as String).toSet() ?? const {};

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
    notes: json['notes'] as String? ?? '',
    recurrence: json['recurrence'] == null
        ? null
        : PlannerRecurrence.fromJson(
            json['recurrence'] as Map<String, dynamic>,
          ),
    doneDates: _stringSet(json['doneDates']),
    skippedDates: _stringSet(json['skippedDates']),
    excludedDates: _stringSet(json['excludedDates']),
    reminderOffsets: (json['reminderOffsets'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList(),
    inbox: json['inbox'] as bool? ?? false,
    source: json['source'] == null
        ? null
        : PlannerTaskSource.fromJson(json['source'] as Map<String, dynamic>),
  );
}

/// 1 LAN XUAT HIEN cu the cua 1 viec vao 1 ngay - viec 1 lan co dung 1 lan
/// xuat hien, viec lap lai sinh lan xuat hien KHI HIEN THI (khong luu).
class PlannerOccurrence {
  const PlannerOccurrence({
    required this.task,
    required this.day,
    required this.start,
  });

  final PlannerTask task;
  final DateTime day;
  final DateTime start;

  DateTime get end => start.add(task.duration);
  String get dayKey => plannerDayKey(day);

  /// Trang thai nguoi dung da chot (null = chua chot, se tu suy theo gio).
  PlannerTaskStatus? get settledStatus {
    if (task.isRecurring) {
      if (task.doneDates.contains(dayKey)) return PlannerTaskStatus.completed;
      if (task.skippedDates.contains(dayKey)) return PlannerTaskStatus.rejected;
      return null;
    }
    return switch (task.status) {
      PlannerTaskStatus.completed || PlannerTaskStatus.rejected => task.status,
      _ => null,
    };
  }

  bool get isDone => settledStatus == PlannerTaskStatus.completed;

  /// Trang thai HIEN THI: da chot thi giu, chua chot thi suy theo gio hien
  /// tai - Sap toi / Dang chay / Qua han (khong con phai nhap tay).
  PlannerTaskStatus statusAt(DateTime now) {
    final settled = settledStatus;
    if (settled != null) return settled;
    if (now.isBefore(start)) return PlannerTaskStatus.upcoming;
    if (now.isBefore(end)) return PlannerTaskStatus.running;
    return PlannerTaskStatus.overdue;
  }
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

  /// KHONG duoc trung ma mau voi [PlannerTaskStatusX.color] - truoc day
  /// relax = completed (0xFF5BE0D0) va other = rejected (0xFFFF6B9D) khien
  /// card "Thu gian" nhin nhu "Hoan thanh" (docs/research-planner-app-ux.md
  /// §7.5 muc 7).
  Color get color => switch (this) {
    PlannerTaskIcon.none => Colors.transparent,
    PlannerTaskIcon.work => const Color(0xFFFFA65C),
    PlannerTaskIcon.game => const Color(0xFF8C6BFF),
    PlannerTaskIcon.relax => const Color(0xFF4FC3F7),
    PlannerTaskIcon.study => const Color(0xFF5B8CFF),
    PlannerTaskIcon.sleep => const Color(0xFF9DA7C7),
    PlannerTaskIcon.other => const Color(0xFFD48CFF),
  };
}

/// Trang thai CO DINH (khong cho tuy bien mau) - xem SKILL.md muc 11: mau
/// rieng biet han voi 3 accent gradient section (English/Fitness/Wealth) de
/// khong bi nham "mau trang thai" voi "mau app dang mo".
///
/// [overdue] KHONG BAO GIO duoc luu (chi tinh luc hien thi, xem
/// [PlannerOccurrence.statusAt]); [running]/[upcoming] cung tu suy theo gio.
/// Nguoi dung chi chot [completed] hoac [rejected].
enum PlannerTaskStatus { completed, running, rejected, upcoming, overdue }

extension PlannerTaskStatusX on PlannerTaskStatus {
  Color get color => switch (this) {
    PlannerTaskStatus.completed => const Color(0xFF5BE0D0),
    PlannerTaskStatus.running => const Color(0xFFA3E635),
    PlannerTaskStatus.rejected => const Color(0xFFFF6B9D),
    PlannerTaskStatus.upcoming => const Color(0xFF8B93A7),
    PlannerTaskStatus.overdue => const Color(0xFFFFB547),
  };

  String get labelKey => switch (this) {
    PlannerTaskStatus.completed => 'planner_status_completed',
    PlannerTaskStatus.running => 'planner_status_running',
    PlannerTaskStatus.rejected => 'planner_status_rejected',
    PlannerTaskStatus.upcoming => 'planner_status_upcoming',
    PlannerTaskStatus.overdue => 'planner_status_overdue',
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

/// Cac moc "nhac truoc" cho TUNG viec (phut) - them moc 1 ngay truoc cho
/// viec quan trong nhu gia han dich vu/tra no (§7.3 muc 5).
const plannerReminderOffsetChoices = [0, 5, 15, 30, 60, 1440];

/// Rung/chuong/ca hai/tat - xem PlannerSettings.dc.html.
enum ReminderMode { both, vibrateOnly, soundOnly, off }

/// [defaultSound]/[cheerfulTone] la 2 lua chon cu (giu de doc duoc cai dat
/// da luu). [deviceAlarm] = 1 chuong BAO THUC co san tren may (lay tu
/// RingtoneManager.TYPE_ALARM qua kenh native, xem device_alarm_sounds.dart)
/// - uri/ten luu trong [PlannerReminderSettings.alarmSoundUri]/
/// [PlannerReminderSettings.alarmSoundTitle].
enum RingtoneChoice { defaultSound, cheerfulTone, deviceAlarm }

class PlannerReminderSettings {
  const PlannerReminderSettings({
    this.ringtone = RingtoneChoice.defaultSound,
    this.leadTime = ReminderLeadTime.onTime,
    this.mode = ReminderMode.both,
    this.alarmSoundUri,
    this.alarmSoundTitle,
  });

  final RingtoneChoice ringtone;
  final ReminderLeadTime leadTime;
  final ReminderMode mode;
  final String? alarmSoundUri;
  final String? alarmSoundTitle;

  PlannerReminderSettings copyWith({
    RingtoneChoice? ringtone,
    ReminderLeadTime? leadTime,
    ReminderMode? mode,
    String? alarmSoundUri,
    String? alarmSoundTitle,
  }) => PlannerReminderSettings(
    ringtone: ringtone ?? this.ringtone,
    leadTime: leadTime ?? this.leadTime,
    mode: mode ?? this.mode,
    alarmSoundUri: alarmSoundUri ?? this.alarmSoundUri,
    alarmSoundTitle: alarmSoundTitle ?? this.alarmSoundTitle,
  );

  // `deviceAlarm` ghi thanh 'defaultSound' + co `useDeviceAlarm` rieng: APK
  // cu khong co gia tri enum moi, byName se nem loi neu doc phai.
  Map<String, dynamic> toJson() => {
    'ringtone': ringtone == RingtoneChoice.deviceAlarm
        ? RingtoneChoice.defaultSound.name
        : ringtone.name,
    if (ringtone == RingtoneChoice.deviceAlarm) 'useDeviceAlarm': true,
    'leadTime': leadTime.name,
    'mode': mode.name,
    if (alarmSoundUri != null) 'alarmSoundUri': alarmSoundUri,
    if (alarmSoundTitle != null) 'alarmSoundTitle': alarmSoundTitle,
  };

  factory PlannerReminderSettings.fromJson(Map<String, dynamic> json) =>
      PlannerReminderSettings(
        ringtone: json['useDeviceAlarm'] == true
            ? RingtoneChoice.deviceAlarm
            : RingtoneChoice.values.byName(
                json['ringtone'] as String? ?? RingtoneChoice.defaultSound.name,
              ),
        leadTime: ReminderLeadTime.values.byName(
          json['leadTime'] as String? ?? ReminderLeadTime.onTime.name,
        ),
        mode: ReminderMode.values.byName(
          json['mode'] as String? ?? ReminderMode.both.name,
        ),
        alarmSoundUri: json['alarmSoundUri'] as String?,
        alarmSoundTitle: json['alarmSoundTitle'] as String?,
      );
}
