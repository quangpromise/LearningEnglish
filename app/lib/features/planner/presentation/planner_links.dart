import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../data/planner_models.dart';
import 'planner_providers.dart';

/// Cau noi 3 mini-app -> Lap ke hoach (docs/research-planner-app-ux.md §7.4).
///
/// Chieu phu thuoc CHI 1 chieu: mini-app import file nay, planner KHONG
/// import nguoc bat ky feature nao (giu dung tinh than feature-first/nhieu
/// nguoi code song song) - vi vay cac ham chi nhan kieu nguyen thuy (id,
/// ten, thu trong tuan...) thay vi model cua tung mini-app.
///
/// Planner chi luu THAM CHIEU ([PlannerTaskSource]), khong sao chep du lieu
/// nghiep vu (so tien, danh sach bai tap...).
abstract final class PlannerSourceKinds {
  static const fitnessProgram = 'fitness_program';
  static const englishVocabReview = 'english_vocab_review';
  static const wealthServiceRenewal = 'wealth_service_renewal';
}

String _newId() => '${DateTime.now().microsecondsSinceEpoch}';

DateTime _at(DateTime day, TimeOfDay time) =>
    DateTime(day.year, day.month, day.day, time.hour, time.minute);

/// Viec do [kind]/[refId] da co trong ke hoach chua - de nut "Them vao ke
/// hoach" o mini-app doi thanh "Da co trong ke hoach".
bool plannerHasSource(WidgetRef ref, String kind, String refId) {
  final probe = PlannerTaskSource(kind: kind, refId: refId);
  return ref.watch(plannerTasksProvider).any((t) => probe.sameAs(t.source));
}

/// Fitness: 1 viec lap HANG TUAN vao cac thu co tap cua chuong trinh (ngay
/// nghi = khong co viec). Bam lai lan 2 = cap nhat, khong tao trung.
Future<void> addFitnessProgramToPlanner(
  WidgetRef ref, {
  required int programId,
  required String programTitle,
  required List<int> trainingWeekdays,
  TimeOfDay time = const TimeOfDay(hour: 18, minute: 0),
  Duration duration = const Duration(minutes: 60),
}) async {
  if (trainingWeekdays.isEmpty) return;
  final start = _at(DateTime.now(), time);
  await ref
      .read(plannerTasksProvider.notifier)
      .upsertBySource(
        PlannerTask(
          id: _newId(),
          title: AppStrings.t(
            'planner_src_workout_title',
            ref.read(appLanguageProvider),
          ).replaceAll('{name}', programTitle),
          appSection: AppSection.fitness,
          start: start,
          end: start.add(duration),
          reminderEnabled: true,
          recurrence: PlannerRecurrence(
            freq: PlannerRepeatFreq.weekly,
            weekdays: [...trainingWeekdays]..sort(),
          ),
          source: PlannerTaskSource(
            kind: PlannerSourceKinds.fitnessProgram,
            refId: '$programId',
          ),
        ),
      );
}

/// Goi khi ket thuc 1 buoi tap (WorkoutFinishedScreen) - tu tick Hoan thanh
/// lan tap cua hom nay neu chuong trinh da duoc them vao ke hoach.
Future<void> completeFitnessProgramToday(WidgetRef ref, int programId) => ref
    .read(plannerTasksProvider.notifier)
    .completeBySource(
      PlannerSourceKinds.fitnessProgram,
      '$programId',
      DateTime.now(),
    );

/// English: viec lap HANG NGAY "On tu vung hom nay".
Future<void> addVocabReviewToPlanner(
  WidgetRef ref, {
  TimeOfDay time = const TimeOfDay(hour: 20, minute: 0),
}) async {
  final start = _at(DateTime.now(), time);
  await ref
      .read(plannerTasksProvider.notifier)
      .upsertBySource(
        PlannerTask(
          id: _newId(),
          title: AppStrings.t(
            'planner_src_vocab_title',
            ref.read(appLanguageProvider),
          ),
          appSection: AppSection.learnEnglish,
          start: start,
          end: start.add(const Duration(minutes: 20)),
          icon: PlannerTaskIcon.study,
          reminderEnabled: true,
          recurrence: const PlannerRecurrence(freq: PlannerRepeatFreq.daily),
          source: const PlannerTaskSource(
            kind: PlannerSourceKinds.englishVocabReview,
            refId: 'daily',
          ),
        ),
      );
}

/// Goi khi da on het tu cua hom nay - tu tick Hoan thanh.
Future<void> completeVocabReviewToday(WidgetRef ref) => ref
    .read(plannerTasksProvider.notifier)
    .completeBySource(
      PlannerSourceKinds.englishVocabReview,
      'daily',
      DateTime.now(),
    );

/// Wealth: viec "Gia han [ten dich vu]" vao ngay (het han - so ngay nhac truoc),
/// 9h sang, nhac dung gio + truoc 1 ngay. Dich vu da gan cho Fitness/English
/// (vd goi tap, khoa hoc) thi viec cung gan dung mini-app do de loc dung.
Future<void> addServiceRenewalToPlanner(
  WidgetRef ref, {
  required String serviceId,
  required String serviceName,
  required DateTime expiryDate,
  required int reminderLeadDays,
  AppSection section = AppSection.wealth,
}) async {
  var day = expiryDate.subtract(Duration(days: reminderLeadDays));
  final today = plannerDateOnly(DateTime.now());
  if (day.isBefore(today)) day = today;
  final start = _at(day, const TimeOfDay(hour: 9, minute: 0));
  await ref
      .read(plannerTasksProvider.notifier)
      .upsertBySource(
        PlannerTask(
          id: _newId(),
          title: AppStrings.t(
            'planner_src_renew_title',
            ref.read(appLanguageProvider),
          ).replaceAll('{name}', serviceName),
          appSection: section,
          start: start,
          end: start.add(const Duration(minutes: 15)),
          reminderEnabled: true,
          reminderOffsets: const [0, 1440],
          source: PlannerTaskSource(
            kind: PlannerSourceKinds.wealthServiceRenewal,
            refId: serviceId,
          ),
        ),
      );
}

/// Goi khi da gia han xong - tu tick Hoan thanh viec gia han (bat ke ngay).
Future<void> completeServiceRenewal(WidgetRef ref, String serviceId) async {
  final notifier = ref.read(plannerTasksProvider.notifier);
  final task = notifier.findBySource(
    PlannerSourceKinds.wealthServiceRenewal,
    serviceId,
  );
  if (task == null || task.inbox) return;
  final occ = task.occurrenceOn(task.start);
  if (occ.isDone) return;
  await notifier.settle(occ, PlannerTaskStatus.completed);
}
