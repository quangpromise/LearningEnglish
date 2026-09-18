import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../planner/presentation/planner_providers.dart' show plannerNow;
import '../data/todo_models.dart';
import '../data/todo_repository.dart';

final todoRepositoryProvider = Provider((ref) => TodoRepository());

final todoRemoteProvider = Provider(
  (ref) => TodoRemote(ref.watch(supabaseClientProvider)),
);

/// Ngay dang xem tren thanh chon ngay - mac dinh hom nay.
final todoSelectedDateProvider = StateProvider<DateTime>(
  (ref) => todoDayKey(DateTime.now()),
);

class TodoTasksNotifier extends StateNotifier<List<TodoTask>> {
  TodoTasksNotifier(this._repo, this._remote) : super(const []) {
    _init();
  }

  final TodoRepository _repo;
  final TodoRemote _remote;

  Map<String, DateTime> _tombstones = {};

  Future<void> _init() async {
    _tombstones = await _repo.loadTombstones();
    state = await _repo.load();
    // Dong bo chay NGAM sau khi da hien du lieu cuc bo - khong bat nguoi dung
    // doi mang moi thay duoc danh sach viec.
    unawaited(sync());
  }

  Future<void> _persist(List<TodoTask> next) async {
    state = next;
    await _repo.save(next);
    unawaited(sync());
  }

  Future<TodoTask> add({required String title, required DateTime dueAt}) async {
    final now = DateTime.now();
    final task = TodoTask(
      id: '${now.microsecondsSinceEpoch}',
      title: title,
      dueAt: dueAt,
      createdAt: now,
      updatedAt: now,
    );
    await _persist([...state, task]);
    return task;
  }

  Future<void> update(String id, {String? title, DateTime? dueAt}) => _persist([
    for (final t in state)
      if (t.id == id) t.copyWith(title: title, dueAt: dueAt) else t,
  ]);

  /// Danh dau xong / bo danh dau. Giu nguyen id + createdAt + dueAt goc.
  Future<void> toggleDone(String id) => _persist([
    for (final t in state)
      if (t.id == id)
        t.copyWith(completedAt: t.isCompleted ? null : DateTime.now())
      else
        t,
  ]);

  Future<void> remove(String id) async {
    _tombstones = {..._tombstones, id: DateTime.now()};
    await _repo.saveTombstones(_tombstones);
    await _persist([
      for (final t in state)
        if (t.id != id) t,
    ]);
  }

  /// Gop du lieu may <-> server theo `updatedAt` (ban sua sau cung thang).
  ///
  /// Chua dang nhap / mat mang thi BO QUA im lang - du lieu cuc bo van la
  /// nguon doc chinh, lan sau vao co mang se day len sau.
  Future<void> sync() async {
    final userId = _remote.currentUserId;
    if (userId == null) return;

    // Doi user: du lieu cuc bo la cua nguoi khac, xoa sach truoc khi keo du
    // lieu cua user dang dang nhap ve - tranh tron viec cua 2 tai khoan.
    final owner = await _repo.loadOwner();
    if (owner != null && owner != userId) {
      await _repo.clearLocal();
      _tombstones = {};
      state = const [];
    }

    try {
      final remoteRows = await _remote.fetchAll(userId);

      final merged = <String, TodoTask>{for (final t in state) t.id: t};
      final tombstones = {..._tombstones};

      for (final row in remoteRows) {
        if (row.deleted) {
          // Server bao da xoa: chi xoa ban cuc bo neu ban cuc bo KHONG moi
          // hon (nguoi dung vua tao lai/sua lai viec do tren may nay).
          final local = merged[row.id];
          final localAt = local?.updatedAt ?? local?.createdAt;
          if (local == null || !localAt!.isAfter(row.updatedAt)) {
            merged.remove(row.id);
            tombstones[row.id] = row.updatedAt;
          }
          continue;
        }
        final remoteTask = row.task;
        if (remoteTask == null) continue;

        // Da xoa tren may nay SAU khi server ghi -> giu nguyen viec xoa.
        final deletedAt = tombstones[row.id];
        if (deletedAt != null && deletedAt.isAfter(row.updatedAt)) continue;

        final local = merged[row.id];
        final localAt = local?.updatedAt ?? local?.createdAt;
        if (local == null || row.updatedAt.isAfter(localAt!)) {
          merged[row.id] = remoteTask;
          tombstones.remove(row.id);
        }
      }

      final next = merged.values.toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

      _tombstones = tombstones;
      await _repo.saveTombstones(tombstones);
      await _repo.save(next);
      state = next;

      await _remote.upsert(userId, tasks: next, tombstones: tombstones);
      await _repo.saveOwner(userId);
    } catch (_) {
      // Mat mang / RLS tu choi / bang chua tao: bo qua, giu nguyen ban cuc
      // bo. KHONG nem loi ra UI vi day la viec chay ngam.
    }
  }
}

final todoTasksProvider =
    StateNotifierProvider<TodoTasksNotifier, List<TodoTask>>(
      (ref) => TodoTasksNotifier(
        ref.watch(todoRepositoryProvider),
        ref.watch(todoRemoteProvider),
      ),
    );

/// Viec hien tren 1 ngay, da sap xep theo gio.
///
/// Viec CHUA xong cua ngay truoc tu don sang HOM NAY (xem
/// [TodoTaskX.isCarriedOver]) nen: khong hien lai o ngay goc da qua, va chi
/// don toi hom nay chu khong don toi 1 ngay tuong lai dang xem.
final todoTasksForDayProvider = Provider.family<List<TodoTask>, DateTime>((
  ref,
  day,
) {
  final now = plannerNow(ref);
  final key = todoDayKey(day);
  final list =
      ref
          .watch(todoTasksProvider)
          .where((t) => t.effectiveDay(now) == key)
          .toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  return list;
});

final todoTasksForSelectedDateProvider = Provider<List<TodoTask>>(
  (ref) =>
      ref.watch(todoTasksForDayProvider(ref.watch(todoSelectedDateProvider))),
);

/// So lieu tom tat cua ngay dang xem - dung cho phan "Tien do hom nay".
class TodoDaySummary {
  const TodoDaySummary({
    required this.total,
    required this.completed,
    required this.overdue,
  });

  final int total;
  final int completed;
  final int overdue;

  int get remaining => total - completed;
  double get ratio => total == 0 ? 0 : completed / total;
  int get percent => (ratio * 100).round();
}

final todoDaySummaryProvider = Provider.family<TodoDaySummary, DateTime>((
  ref,
  day,
) {
  final now = plannerNow(ref);
  final tasks = ref.watch(todoTasksForDayProvider(day));
  return TodoDaySummary(
    total: tasks.length,
    completed: tasks.where((t) => t.isCompleted).length,
    overdue: tasks
        .where(
          (t) =>
              t.statusAt(now) == TodoStatus.overdue ||
              t.statusAt(now) == TodoStatus.carriedOver,
        )
        .length,
  );
});

/// 7 ngay cua tuan chua ngay dang xem (T2 -> CN) kem ti le hoan thanh moi
/// ngay - dung cho dai "Tuan nay" duoi bao cao.
final todoWeekSummaryProvider = Provider<List<(DateTime, TodoDaySummary)>>((
  ref,
) {
  final selected = todoDayKey(ref.watch(todoSelectedDateProvider));
  final monday = selected.subtract(Duration(days: selected.weekday - 1));
  return [
    for (var i = 0; i < 7; i++)
      (
        monday.add(Duration(days: i)),
        ref.watch(todoDaySummaryProvider(monday.add(Duration(days: i)))),
      ),
  ];
});
