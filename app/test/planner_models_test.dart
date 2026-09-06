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

  group('4 mau trang thai co dinh', () {
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
}
