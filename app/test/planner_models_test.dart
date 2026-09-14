import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/features/planner/data/planner_models.dart';

void main() {
  group('PlannerTask', () {
    test('toJson/fromJson giu nguyen du lieu (roundtrip)', () {
      final task = PlannerTask(
        id: 't1',
        title: 'Học từ vựng',
        appSection: AppSection.fitness,
        start: DateTime(2026, 9, 6, 8, 30),
        end: DateTime(2026, 9, 6, 9, 0),
        status: PlannerTaskStatus.running,
        reminderEnabled: true,
      );
      final restored = PlannerTask.fromJson(task.toJson());
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.appSection, task.appSection);
      expect(restored.start, task.start);
      expect(restored.end, task.end);
      expect(restored.status, task.status);
      expect(restored.reminderEnabled, task.reminderEnabled);
    });

    test('copyWith chi doi truong duoc truyen, giu nguyen id', () {
      final task = PlannerTask(
        id: 't1',
        title: 'A',
        appSection: AppSection.learnEnglish,
        start: DateTime(2026, 1, 1, 8),
        end: DateTime(2026, 1, 1, 9),
      );
      final updated = task.copyWith(status: PlannerTaskStatus.completed);
      expect(updated.id, task.id);
      expect(updated.title, task.title);
      expect(updated.status, PlannerTaskStatus.completed);
    });
  });

  group('Mau trang thai co dinh', () {
    test('moi trang thai co 1 mau rieng, khong trung nhau', () {
      final colors = PlannerTaskStatus.values.map((s) => s.color).toSet();
      expect(colors.length, PlannerTaskStatus.values.length);
    });
  });

  group('ReminderLeadTime', () {
    test('onTime = Duration.zero, cac muc con lai tang dan', () {
      expect(ReminderLeadTime.onTime.leadDuration, Duration.zero);
      expect(
        ReminderLeadTime.min5.leadDuration <
            ReminderLeadTime.min15.leadDuration,
        true,
      );
      expect(
        ReminderLeadTime.min15.leadDuration <
            ReminderLeadTime.min30.leadDuration,
        true,
      );
      expect(
        ReminderLeadTime.min30.leadDuration <
            ReminderLeadTime.hour1.leadDuration,
        true,
      );
    });
  });

  group('PlannerReminderSettings', () {
    test(
      'gia tri mac dinh dung nhu thiet ke (Mac dinh/Dung gio/Rung+Chuong)',
      () {
        const settings = PlannerReminderSettings();
        expect(settings.ringtone, RingtoneChoice.defaultSound);
        expect(settings.leadTime, ReminderLeadTime.onTime);
        expect(settings.mode, ReminderMode.both);
      },
    );

    test('toJson/fromJson giu nguyen du lieu (roundtrip)', () {
      const settings = PlannerReminderSettings(
        ringtone: RingtoneChoice.cheerfulTone,
        leadTime: ReminderLeadTime.min15,
        mode: ReminderMode.vibrateOnly,
      );
      final restored = PlannerReminderSettings.fromJson(settings.toJson());
      expect(restored.ringtone, settings.ringtone);
      expect(restored.leadTime, settings.leadTime);
      expect(restored.mode, settings.mode);
    });

    test('fromJson voi map rong tra ve dung gia tri mac dinh', () {
      final restored = PlannerReminderSettings.fromJson({});
      expect(restored.ringtone, RingtoneChoice.defaultSound);
      expect(restored.leadTime, ReminderLeadTime.onTime);
      expect(restored.mode, ReminderMode.both);
    });
  });

  group('Planner v2 - lap lai / trang thai tu suy / tuong thich nguoc', () {
    PlannerTask base({PlannerRecurrence? rule}) => PlannerTask(
      id: 'r1',
      title: 'Tap',
      appSection: AppSection.fitness,
      start: DateTime(2026, 9, 14, 18), // Thu 2
      end: DateTime(2026, 9, 14, 19),
      recurrence: rule,
    );

    test('JSON cu (khong co truong moi) van doc duoc = viec 1 lan', () {
      final t = PlannerTask.fromJson({
        'id': 'old',
        'title': 'Cu',
        'appSection': 'wealth',
        'start': '2026-09-01T08:00:00.000',
        'end': '2026-09-01T09:00:00.000',
        'status': 'upcoming',
      });
      expect(t.isRecurring, false);
      expect(t.inbox, false);
      expect(t.reminderOffsets, isNull);
      expect(t.occursOn(DateTime(2026, 9, 1)), true);
      expect(t.occursOn(DateTime(2026, 9, 2)), false);
    });

    test('khong bao gio ghi `overdue` ra JSON (APK cu khong doc duoc)', () {
      final t = base().copyWith(status: PlannerTaskStatus.overdue);
      expect(t.toJson()['status'], 'upcoming');
    });

    test('lap hang tuan chi xuat hien dung cac thu da chon', () {
      final t = base(
        rule: const PlannerRecurrence(
          freq: PlannerRepeatFreq.weekly,
          weekdays: [1, 3, 5],
        ),
      );
      expect(t.occursOn(DateTime(2026, 9, 14)), true); // T2
      expect(t.occursOn(DateTime(2026, 9, 15)), false); // T3
      expect(t.occursOn(DateTime(2026, 9, 16)), true); // T4
      expect(t.occursOn(DateTime(2026, 9, 13)), false); // truoc ngay bat dau
    });

    test('lap hang ngay ton trong until + excludedDates', () {
      final t = base(
        rule: PlannerRecurrence(
          freq: PlannerRepeatFreq.daily,
          until: DateTime(2026, 9, 20),
        ),
      ).copyWith(excludedDates: {'2026-09-16'});
      expect(t.occursOn(DateTime(2026, 9, 15)), true);
      expect(t.occursOn(DateTime(2026, 9, 16)), false);
      expect(t.occursOn(DateTime(2026, 9, 20)), true);
      expect(t.occursOn(DateTime(2026, 9, 21)), false);
    });

    test('lap hang thang theo ngay trong thang', () {
      final t = base(
        rule: const PlannerRecurrence(freq: PlannerRepeatFreq.monthly),
      );
      expect(t.occursOn(DateTime(2026, 10, 14)), true);
      expect(t.occursOn(DateTime(2026, 10, 15)), false);
    });

    test('recurrence + tap ngay roundtrip qua JSON', () {
      final t =
          base(
            rule: PlannerRecurrence(
              freq: PlannerRepeatFreq.weekly,
              weekdays: const [2, 4],
              until: DateTime(2026, 12, 31),
            ),
          ).copyWith(
            doneDates: {'2026-09-15'},
            reminderOffsets: [0, 1440],
            notes: 'ghi chu',
            inbox: true,
            source: const PlannerTaskSource(kind: 'k', refId: '1'),
          );
      final r = PlannerTask.fromJson(t.toJson());
      expect(r.recurrence!.freq, PlannerRepeatFreq.weekly);
      expect(r.recurrence!.weekdays, [2, 4]);
      expect(r.recurrence!.until, DateTime(2026, 12, 31));
      expect(r.doneDates, {'2026-09-15'});
      expect(r.reminderOffsets, [0, 1440]);
      expect(r.notes, 'ghi chu');
      expect(r.inbox, true);
      expect(r.source!.sameAs(t.source), true);
    });

    test('trang thai tu suy theo gio: sap toi -> dang chay -> qua han', () {
      final occ = base().occurrenceOn(DateTime(2026, 9, 14));
      expect(
        occ.statusAt(DateTime(2026, 9, 14, 17)),
        PlannerTaskStatus.upcoming,
      );
      expect(
        occ.statusAt(DateTime(2026, 9, 14, 18, 30)),
        PlannerTaskStatus.running,
      );
      expect(
        occ.statusAt(DateTime(2026, 9, 14, 20)),
        PlannerTaskStatus.overdue,
      );
    });

    test('lan lap da hoan thanh giu trang thai Hoan thanh', () {
      final t = base(
        rule: const PlannerRecurrence(freq: PlannerRepeatFreq.daily),
      ).copyWith(doneDates: {'2026-09-15'});
      final occ = t.occurrenceOn(DateTime(2026, 9, 15));
      expect(occ.isDone, true);
      expect(occ.start, DateTime(2026, 9, 15, 18));
      expect(occ.end, DateTime(2026, 9, 15, 19));
      expect(t.occurrenceOn(DateTime(2026, 9, 16)).isDone, false);
    });

    test('mau icon phan loai khong trung mau trang thai', () {
      final statusColors = PlannerTaskStatus.values.map((s) => s.color).toSet();
      for (final ic in PlannerTaskIcon.values) {
        if (ic == PlannerTaskIcon.none) continue;
        expect(statusColors.contains(ic.color), false, reason: ic.name);
      }
    });

    test('chuong bao thuc cua may roundtrip, APK cu doc thanh Mac dinh', () {
      const s = PlannerReminderSettings(
        ringtone: RingtoneChoice.deviceAlarm,
        alarmSoundUri: 'content://media/internal/audio/media/12',
        alarmSoundTitle: 'Morning',
      );
      final json = s.toJson();
      expect(json['ringtone'], 'defaultSound');
      final r = PlannerReminderSettings.fromJson(json);
      expect(r.ringtone, RingtoneChoice.deviceAlarm);
      expect(r.alarmSoundUri, s.alarmSoundUri);
      expect(r.alarmSoundTitle, 'Morning');
    });
  });

  group('Checklist + dong bo', () {
    test('subtasks, tick theo ngay, updatedAt roundtrip qua JSON', () {
      final t = PlannerTask(
        id: 'c1',
        title: 'On tu',
        appSection: AppSection.learnEnglish,
        start: DateTime(2026, 9, 14, 20),
        end: DateTime(2026, 9, 14, 20, 20),
        recurrence: const PlannerRecurrence(freq: PlannerRepeatFreq.daily),
        subtasks: const [
          PlannerSubtask(id: 'a', title: 'Nghe'),
          PlannerSubtask(id: 'b', title: 'Viet'),
        ],
        subtaskDone: const {
          '2026-09-15': {'a'},
        },
        updatedAt: DateTime.utc(2026, 9, 14, 12),
      );
      final r = PlannerTask.fromJson(t.toJson());
      expect(r.subtasks.map((s) => s.title), ['Nghe', 'Viet']);
      expect(r.updatedAt, DateTime.utc(2026, 9, 14, 12));
      expect(r.occurrenceOn(DateTime(2026, 9, 15)).checkedCount, 1);
      // Moi ngay checklist rieng.
      expect(r.occurrenceOn(DateTime(2026, 9, 16)).checkedCount, 0);
    });
  });
}
