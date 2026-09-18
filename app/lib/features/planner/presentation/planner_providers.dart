import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/device_alarm_sounds.dart';
import '../data/planner_models.dart';
import '../data/planner_notification_service.dart';
import '../data/planner_repository.dart';

final plannerRepositoryProvider = Provider((ref) => PlannerRepository());

/// Ngay dang xem tren timeline (mac dinh hom nay) - la COT GIUA cua timeline
/// 3 cot; doi khi bam ngay khac o date-strip hoac vuot ngang timeline.
final plannerSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// "Bay gio", cap nhat moi phut - de trang thai tu suy (Sap toi/Dang chay/
/// Qua han) va vach gio hien tai tren timeline tu doi ma khong can mo lai.
final plannerNowProvider = StreamProvider<DateTime>(
  (ref) => Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  ).asBroadcastStream(),
);

DateTime plannerNow(Ref ref) =>
    ref.watch(plannerNowProvider).valueOrNull ?? DateTime.now();

String _newId() => '${DateTime.now().microsecondsSinceEpoch}';

class PlannerTasksNotifier extends StateNotifier<List<PlannerTask>> {
  PlannerTasksNotifier(this._repo, this._remote) : super([]) {
    _restore();
  }

  final PlannerRepository _repo;

  /// null = Supabase chua khoi tao (vd build thieu SUPABASE_URL) - planner
  /// van chay binh thuong, chi luu tren may.
  final PlannerRemote? _remote;

  /// Id viec da sua chua day len server + viec da xoa chua bao len server -
  /// giu trong bo nho (dong bo voi SharedPreferences) de phan gop du lieu
  /// chay DONG BO (khong await xen giua) sau khi tai ve, tranh de mat thay
  /// doi nguoi dung vua lam trong luc dang dong bo.
  Set<String> _dirty = {};
  Map<String, DateTime> _tombstones = {};
  Timer? _syncDebounce;
  bool _syncing = false;
  bool _syncAgain = false;

  Future<void> _restore() async {
    state = await _repo.loadTasks();
    _dirty = await _repo.loadDirty();
    _tombstones = await _repo.loadTombstones();
    // Viec lap lai chi dat lich thong bao cho vai lan sap toi (xem
    // PlannerNotificationService.schedule) - moi lan mo app dat lai de cua so
    // do luon "truot" theo ngay hien tai.
    await rescheduleAllNotifications(await _repo.loadSettings());
    await syncNow();
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }

  Future<void> _saveSyncMeta() async {
    await _repo.saveDirty(_dirty);
    await _repo.saveTombstones(_tombstones);
  }

  static String _content(PlannerTask t) =>
      jsonEncode(t.toJson()..remove('updatedAt'));

  /// DIEM GHI DUY NHAT cua moi thay doi: dong dau `updatedAt` cho viec
  /// them/sua, ghi dau xoa cho viec bi xoa, luu may, hen dong bo sau 2 giay
  /// (gom nhieu thao tac lien tiep thanh 1 lan goi server).
  Future<void> _commit(List<PlannerTask> next) async {
    final prev = {for (final t in state) t.id: t};
    final now = DateTime.now().toUtc();
    final nextIds = <String>{};
    final stamped = <PlannerTask>[];
    for (final t in next) {
      nextIds.add(t.id);
      final old = prev[t.id];
      if (old == null || _content(old) != _content(t)) {
        stamped.add(t.copyWith(updatedAt: now));
        _dirty.add(t.id);
        _tombstones.remove(t.id);
      } else {
        stamped.add(t);
      }
    }
    for (final id in prev.keys) {
      if (!nextIds.contains(id)) {
        _tombstones[id] = now;
        _dirty.remove(id);
      }
    }
    state = stamped;
    await _repo.saveTasks(state);
    await _saveSyncMeta();
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), syncNow);
  }

  /// Dong bo 2 chieu voi bang `planner_tasks`: tai ve -> gop theo ban sua sau
  /// cung -> day cac thay doi chua gui. Loi (mat mang, chua chay migration
  /// 0063...) bo qua trong im lang - thay doi van nam trong hang cho, lan sau
  /// gui tiep.
  Future<void> syncNow() async {
    final remote = _remote;
    final userId = remote?.currentUserId;
    if (remote == null || userId == null) return;
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    _syncing = true;
    try {
      final owner = await _repo.loadOwner();
      final rows = await remote.fetchAll(userId);

      // ---- Tu day toi het phan gop KHONG co await: doc/ghi state 1 lan ----
      final before = {for (final t in state) t.id: t};
      var local = state;
      if (owner == null) {
        // Du lieu tu truoc khi co dong bo -> nhan cho user hien tai.
        _dirty.addAll(local.map((t) => t.id));
      } else if (owner != userId) {
        // May nay vua doi tai khoan: du lieu cuc bo la cua tai khoan cu (da
        // co tren server cua ho) - bo di, lay ke hoach cua tai khoan moi.
        local = const [];
        _dirty = {};
        _tombstones = {};
      }
      final byId = {for (final t in local) t.id: t};
      final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      for (final r in rows) {
        final tomb = _tombstones[r.id];
        if (tomb != null && !tomb.isBefore(r.updatedAt)) continue;
        final mine = byId[r.id];
        if (mine != null && !(mine.updatedAt ?? epoch).isBefore(r.updatedAt)) {
          continue;
        }
        // Ban tren server moi hon.
        if (r.deleted) {
          byId.remove(r.id);
        } else if (r.task != null) {
          byId[r.id] = r.task!.copyWith(updatedAt: r.updatedAt);
        } else {
          continue;
        }
        _dirty.remove(r.id);
        _tombstones.remove(r.id);
      }
      final merged = byId.values.toList();
      state = merged;
      // ---- Het phan gop ----

      await _repo.saveTasks(merged);
      await _saveSyncMeta();

      final pushTasks = merged.where((t) => _dirty.contains(t.id)).toList();
      final pushTombs = Map.of(_tombstones);
      await remote.upsert(userId, tasks: pushTasks, tombstones: pushTombs);
      // Chi xoa khoi hang cho nhung muc KHONG bi sua them trong luc dang gui.
      final current = {for (final t in state) t.id: t};
      for (final t in pushTasks) {
        if (current[t.id]?.updatedAt == t.updatedAt) _dirty.remove(t.id);
      }
      pushTombs.forEach((id, at) {
        if (_tombstones[id] == at) _tombstones.remove(id);
      });
      await _saveSyncMeta();
      await _repo.saveOwner(userId);

      // Dat lai thong bao cho viec vua doi tu may khac.
      final settings = await _repo.loadSettings();
      final after = {for (final t in merged) t.id: t};
      for (final id in before.keys) {
        if (!after.containsKey(id)) {
          await PlannerNotificationService.instance.cancel(id);
        }
      }
      for (final t in merged) {
        final old = before[t.id];
        if (old == null || _content(old) != _content(t)) {
          await PlannerNotificationService.instance.schedule(t, settings);
        }
      }
    } catch (_) {
      // Mat mang / bang chua ton tai / het phien dang nhap - thu lai lan sau.
    } finally {
      _syncing = false;
      if (_syncAgain) {
        _syncAgain = false;
        unawaited(syncNow());
      }
    }
  }

  Future<void> _scheduleOne(PlannerTask task) async {
    final settings = await _repo.loadSettings();
    await PlannerNotificationService.instance.schedule(task, settings);
  }

  PlannerTask? byId(String id) {
    for (final t in state) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> add(PlannerTask task) async {
    await _commit([...state, task]);
    await _scheduleOne(task);
  }

  Future<void> update(PlannerTask task) async {
    await _commit([
      for (final t in state)
        if (t.id == task.id) task else t,
    ]);
    await _scheduleOne(task);
  }

  Future<void> remove(String id) async {
    await _commit(state.where((t) => t.id != id).toList());
    await PlannerNotificationService.instance.cancel(id);
  }

  /// Chup lai toan bo danh sach TRUOC 1 thao tac de "Hoan tac" tra ve dung
  /// trang thai cu (xoa, hoan thanh, keo-tha, doi sang Inbox...).
  List<PlannerTask> snapshot() => List.of(state);

  Future<void> restoreSnapshot(List<PlannerTask> previous) async {
    final removedIds = state
        .map((t) => t.id)
        .toSet()
        .difference(previous.map((t) => t.id).toSet());
    await _commit(previous);
    for (final id in removedIds) {
      await PlannerNotificationService.instance.cancel(id);
    }
    await rescheduleAllNotifications(await _repo.loadSettings());
  }

  /// Chot trang thai 1 lan xuat hien: completed/rejected, hoac null = bo chot
  /// (tro lai tu suy theo gio).
  Future<void> settle(PlannerOccurrence occ, PlannerTaskStatus? status) async {
    final task = byId(occ.task.id);
    if (task == null) return;
    if (task.isRecurring) {
      final done = {...task.doneDates}..remove(occ.dayKey);
      final skipped = {...task.skippedDates}..remove(occ.dayKey);
      if (status == PlannerTaskStatus.completed) done.add(occ.dayKey);
      if (status == PlannerTaskStatus.rejected) skipped.add(occ.dayKey);
      await update(task.copyWith(doneDates: done, skippedDates: skipped));
    } else {
      await update(task.copyWith(status: status ?? PlannerTaskStatus.upcoming));
    }
  }

  Future<void> toggleDone(PlannerOccurrence occ) =>
      settle(occ, occ.isDone ? null : PlannerTaskStatus.completed);

  /// Tick/bo tick 1 buoc trong checklist cua lan xuat hien [occ].
  Future<void> toggleSubtask(PlannerOccurrence occ, String subtaskId) async {
    final task = byId(occ.task.id);
    if (task == null) return;
    final day = {...?task.subtaskDone[occ.dayKey]};
    if (!day.remove(subtaskId)) day.add(subtaskId);
    final all = {...task.subtaskDone};
    if (day.isEmpty) {
      all.remove(occ.dayKey);
    } else {
      all[occ.dayKey] = day;
    }
    await update(task.copyWith(subtaskDone: all));
  }

  /// Viec lap lai: tach RIENG lan nay thanh 1 viec 1 lan (bo lan nay khoi
  /// chuoi) roi ap [change] len ban tach - dung cho keo-tha/doi sang mai/
  /// dua ve Inbox 1 lan lap ma khong lam doi ca chuoi.
  Future<void> _detachOccurrence(
    PlannerOccurrence occ,
    PlannerTask Function(PlannerTask single) change,
  ) async {
    final series = byId(occ.task.id);
    if (series == null) return;
    final checked = series.subtaskDone[occ.dayKey];
    final single = PlannerTask(
      id: _newId(),
      title: series.title,
      appSection: series.appSection,
      start: occ.start,
      end: occ.end,
      reminderEnabled: series.reminderEnabled,
      icon: series.icon,
      notes: series.notes,
      reminderOffsets: series.reminderOffsets,
      source: series.source,
      subtasks: series.subtasks,
    );
    final detached = change(single);
    await _commit([
      for (final t in state)
        if (t.id == series.id)
          t.copyWith(excludedDates: {...t.excludedDates, occ.dayKey})
        else
          t,
      // Giu cac buoc da tick cua lan nay (theo ngay MOI neu bi doi ngay).
      if (checked != null && checked.isNotEmpty)
        detached.copyWith(subtaskDone: {plannerDayKey(detached.start): checked})
      else
        detached,
    ]);
    final settings = await _repo.loadSettings();
    await PlannerNotificationService.instance.schedule(
      byId(series.id)!,
      settings,
    );
    await PlannerNotificationService.instance.schedule(state.last, settings);
  }

  /// Doi gio (va co the doi ngay) 1 lan xuat hien - giu nguyen thoi luong.
  Future<void> moveOccurrence(PlannerOccurrence occ, DateTime newStart) async {
    final duration = occ.task.duration;
    PlannerTask moved(PlannerTask t) =>
        t.copyWith(start: newStart, end: newStart.add(duration), inbox: false);
    if (occ.task.isRecurring) {
      await _detachOccurrence(occ, moved);
    } else {
      final task = byId(occ.task.id);
      if (task != null) await update(moved(task));
    }
  }

  Future<void> postponeOneDay(PlannerOccurrence occ) =>
      moveOccurrence(occ, occ.start.add(const Duration(days: 1)));

  Future<void> sendToInbox(PlannerOccurrence occ) async {
    if (occ.task.isRecurring) {
      await _detachOccurrence(occ, (t) => t.copyWith(inbox: true));
    } else {
      final task = byId(occ.task.id);
      if (task == null) return;
      await update(task.copyWith(inbox: true));
      await PlannerNotificationService.instance.cancel(task.id);
    }
  }

  /// Xep 1 viec tu Inbox vao timeline tai [start] (giu thoi luong du kien).
  Future<void> scheduleFromInbox(PlannerTask task, DateTime start) => update(
    task.copyWith(start: start, end: start.add(task.duration), inbox: false),
  );

  /// Xoa 1 lan xuat hien. Viec lap lai + ![wholeSeries] = chi bo lan nay.
  Future<void> deleteOccurrence(
    PlannerOccurrence occ, {
    bool wholeSeries = false,
  }) async {
    final task = byId(occ.task.id);
    if (task == null) return;
    if (task.isRecurring && !wholeSeries) {
      await update(
        task.copyWith(excludedDates: {...task.excludedDates, occ.dayKey}),
      );
    } else {
      await remove(task.id);
    }
  }

  /// Them hoac cap nhat viec do 1 mini-app tao (khoa chong trung =
  /// source.kind + source.refId) - giu nguyen id + cac lan da hoan thanh
  /// cua viec cu de khong mat lich su khi bam "Them vao ke hoach" lan 2.
  Future<PlannerTask> upsertBySource(PlannerTask task) async {
    final source = task.source;
    PlannerTask? existing;
    if (source != null) {
      for (final t in state) {
        if (source.sameAs(t.source)) existing = t;
      }
    }
    if (existing == null) {
      await add(task);
      return task;
    }
    final merged = task.copyWith(
      id: existing.id,
      doneDates: existing.doneDates,
      skippedDates: existing.skippedDates,
      excludedDates: existing.excludedDates,
      subtasks: existing.subtasks,
      subtaskDone: existing.subtaskDone,
    );
    await update(merged);
    return merged;
  }

  PlannerTask? findBySource(String kind, String refId) {
    final probe = PlannerTaskSource(kind: kind, refId: refId);
    for (final t in state) {
      if (probe.sameAs(t.source)) return t;
    }
    return null;
  }

  /// Mini-app bao da xong (vd ket thuc buoi tap, on xong tu hom nay) - tu
  /// danh dau lan xuat hien cua ngay [day] la Hoan thanh neu co.
  Future<void> completeBySource(String kind, String refId, DateTime day) async {
    final task = findBySource(kind, refId);
    if (task == null || task.inbox || !task.occursOn(day)) return;
    final occ = task.occurrenceOn(day);
    if (occ.isDone) return;
    await settle(occ, PlannerTaskStatus.completed);
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

/// Supabase co the chua khoi tao (build thieu cau hinh) - khi do planner chi
/// luu tren may, khong dong bo.
PlannerRemote? _plannerRemoteOrNull(Ref ref) {
  try {
    return PlannerRemote(ref.read(supabaseClientProvider));
  } catch (_) {
    return null;
  }
}

final plannerTasksProvider =
    StateNotifierProvider<PlannerTasksNotifier, List<PlannerTask>>(
      (ref) => PlannerTasksNotifier(
        ref.watch(plannerRepositoryProvider),
        _plannerRemoteOrNull(ref),
      ),
    );

/// Tat ca viec. TRUOC DAY co loc theo mini-app (Tat ca/Hoc Tieng Anh/
/// Fitness/Quan ly tai san) qua plannerSectionFilterProvider - da BO theo yeu
/// cau nguoi dung: ke hoach trong ngay nen xem lien mach 1 danh sach, viec
/// phai nho minh dang bat bo loc nao chi lam roi.
final plannerFilteredTasksProvider = Provider<List<PlannerTask>>(
  (ref) => ref.watch(plannerTasksProvider),
);

/// Cac lan xuat hien trong 1 ngay (da loc, bo Inbox), sap theo gio bat dau -
/// nguon du lieu cua tung cot trong planner_timeline.dart.
final plannerOccurrencesForDayProvider =
    Provider.family<List<PlannerOccurrence>, DateTime>((ref, day) {
      final d = plannerDateOnly(day);
      return ref
          .watch(plannerFilteredTasksProvider)
          .where((t) => !t.inbox && t.occursOn(d))
          .map((t) => t.occurrenceOn(d))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
    });

final plannerTasksForSelectedDateProvider = Provider<List<PlannerOccurrence>>(
  (ref) => ref.watch(
    plannerOccurrencesForDayProvider(ref.watch(plannerSelectedDateProvider)),
  ),
);

/// Viec "Chua xep gio" (Inbox) - khong loc theo mini-app de khong "mat" viec
/// vua ghi nhanh chi vi dang bat bo loc.
final plannerInboxProvider = Provider<List<PlannerTask>>(
  (ref) => ref.watch(plannerTasksProvider).where((t) => t.inbox).toList(),
);

/// Viec 1 lan cua 14 ngay truoc hom nay chua chot (khong Xong, khong Bo qua)
/// - nguon cho banner + sheet xu ly viec qua han. Viec lap lai KHONG tinh
/// (lo 1 lan tap hang ngay chi hien "Qua han" tai ngay do, khong don lai).
final plannerOverdueProvider = Provider<List<PlannerOccurrence>>((ref) {
  final now = plannerNow(ref);
  final today = plannerDateOnly(now);
  final from = today.subtract(const Duration(days: 14));
  return ref
      .watch(plannerTasksProvider)
      .where(
        (t) =>
            !t.inbox &&
            !t.isRecurring &&
            t.start.isBefore(today) &&
            !t.start.isBefore(from),
      )
      .map((t) => t.occurrenceOn(t.start))
      .where((o) => o.settledStatus == null)
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
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
    final loaded = await _repo.loadSettings();
    state = loaded;
    // Chuong nhac mac dinh = chuong BAO THUC mac dinh cua may (yeu cau: "doi
    // chuong thanh chuong bao thuc theo may") - chi tu chuyen 1 lan cho cai
    // dat cu con dung 2 chuong co dinh truoc day; sau do nguoi dung tu chon
    // trong danh sach chuong bao thuc cua may.
    if (loaded.ringtone == RingtoneChoice.deviceAlarm ||
        !DeviceAlarmSounds.isSupported) {
      return;
    }
    final sounds = await DeviceAlarmSounds.list();
    if (sounds.isEmpty) return;
    final pick = sounds.firstWhere(
      (s) => s.isDefault,
      orElse: () => sounds.first,
    );
    await update(
      state.copyWith(
        ringtone: RingtoneChoice.deviceAlarm,
        alarmSoundUri: pick.uri,
        alarmSoundTitle: pick.title,
      ),
    );
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
