import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/planner_models.dart';
import '../data/planner_notification_service.dart';
import '../data/planner_repository.dart';

final plannerRepositoryProvider = Provider((ref) => PlannerRepository());

/// Ngay dang xem tren timeline (mac dinh hom nay) - doi khi bam ngay khac o
/// date-strip, hoac khi bam loi tat "Hom nay" o menu noi.
final plannerSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// null = hien tat ca; khac null = chi hien viec cua cac AppSection co trong
/// set (loi tat "Loc mini-app" o menu noi AssistiveTouch).
final plannerSectionFilterProvider = StateProvider<Set<AppSection>?>(
  (ref) => null,
);

class PlannerTasksNotifier extends StateNotifier<List<PlannerTask>> {
  PlannerTasksNotifier(this._repo) : super([]) {
    _restore();
  }

  final PlannerRepository _repo;

  Future<void> _restore() async {
    state = await _repo.loadTasks();
  }

  Future<void> _scheduleOne(PlannerTask task) async {
    final settings = await _repo.loadSettings();
    await PlannerNotificationService.instance.schedule(task, settings);
  }

  Future<void> add(PlannerTask task) async {
    state = [...state, task];
    await _repo.saveTasks(state);
    await _scheduleOne(task);
  }

  Future<void> update(PlannerTask task) async {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
    await _repo.saveTasks(state);
    await _scheduleOne(task);
  }

  Future<void> remove(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _repo.saveTasks(state);
    await PlannerNotificationService.instance.cancel(id);
  }

  /// Doi gio 1 viec bang keo-tha tren timeline - giu nguyen thoi luong ban
  /// dau (end - start), chi doi diem bat dau.
  Future<void> reschedule(String id, DateTime newStart) async {
    final task = state.firstWhere((t) => t.id == id);
    final duration = task.end.difference(task.start);
    await update(task.copyWith(start: newStart, end: newStart.add(duration)));
  }

  /// Dat lai TOAN BO thong bao theo cai dat moi - goi tu
  /// PlannerReminderSettingsNotifier moi khi nguoi dung doi cai dat, vi doi
  /// vd "Tat ca hai" phai huy het thong bao dang cho cua moi viec cung luc.
  Future<void> rescheduleAllNotifications(
    PlannerReminderSettings settings,
  ) async {
    for (final t in state) {
      await PlannerNotificationService.instance.schedule(t, settings);
    }
  }
}

final plannerTasksProvider =
    StateNotifierProvider<PlannerTasksNotifier, List<PlannerTask>>(
      (ref) => PlannerTasksNotifier(ref.watch(plannerRepositoryProvider)),
    );

/// Viec cua dung ngay dang chon, da loc theo [plannerSectionFilterProvider],
/// sap xep theo gio bat dau - nguon du lieu chinh cho planner_timeline.dart.
final plannerTasksForSelectedDateProvider = Provider<List<PlannerTask>>((ref) {
  final date = ref.watch(plannerSelectedDateProvider);
  final filter = ref.watch(plannerSectionFilterProvider);
  final tasks =
      ref
          .watch(plannerTasksProvider)
          .where(
            (t) =>
                t.start.year == date.year &&
                t.start.month == date.month &&
                t.start.day == date.day,
          )
          .where((t) => filter == null || filter.contains(t.appSection))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
  return tasks;
});

class PlannerReminderSettingsNotifier
    extends StateNotifier<PlannerReminderSettings> {
  PlannerReminderSettingsNotifier(this._repo, this._ref)
    : super(const PlannerReminderSettings()) {
    _restore();
  }

  final PlannerRepository _repo;
  final Ref _ref;

  Future<void> _restore() async {
    state = await _repo.loadSettings();
  }

  Future<void> update(PlannerReminderSettings settings) async {
    state = settings;
    await _repo.saveSettings(settings);
    await _ref
        .read(plannerTasksProvider.notifier)
        .rescheduleAllNotifications(settings);
  }
}

final plannerReminderSettingsProvider =
    StateNotifierProvider<
      PlannerReminderSettingsNotifier,
      PlannerReminderSettings
    >(
      (ref) => PlannerReminderSettingsNotifier(
        ref.watch(plannerRepositoryProvider),
        ref,
      ),
    );
