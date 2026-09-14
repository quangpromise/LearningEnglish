import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'planner_models.dart';

/// Luu danh sach viec + cai dat nhac nho CUC BO tren may (SharedPreferences,
/// JSON) - van la nguon doc CHINH (mo app offline van thay ke hoach ngay).
/// Tu ban nay dong bo them len bang Supabase `planner_tasks` (xem
/// supabase/migrations/0063_planner_tasks.sql + [PlannerRemote]) de khong
/// mat du lieu khi doi may / Safari tren iPhone xoa storage cua web sau 7
/// ngay khong mo (docs/research-planner-app-ux.md §7.6).
///
/// Cai dat nhac nho (chuong bao thuc cua MAY NAY...) KHONG dong bo - moi may
/// co danh sach chuong rieng.
class PlannerRepository {
  static const _tasksKey = 'planner_tasks_v1';
  static const _settingsKey = 'planner_reminder_settings_v1';

  /// Id cac viec da sua tren may nhung CHUA day len server duoc.
  static const _dirtyKey = 'planner_sync_dirty_v1';

  /// id -> thoi diem xoa (UTC) cua cac viec da xoa, chua bao len server.
  static const _tombstonesKey = 'planner_sync_tombstones_v1';

  /// User so huu du lieu cuc bo hien tai - null = du lieu tu truoc khi co
  /// dong bo (se duoc "nhan" cho user dang dang nhap o lan dong bo dau).
  static const _ownerKey = 'planner_sync_owner_v1';

  Future<List<PlannerTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PlannerTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<PlannerTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<Set<String>> loadDirty() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_dirtyKey) ?? const []).toSet();
  }

  Future<void> saveDirty(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dirtyKey, ids.toList());
  }

  Future<Map<String, DateTime>> loadTombstones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tombstonesKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, DateTime.parse(v as String)),
    );
  }

  Future<void> saveTombstones(Map<String, DateTime> tombstones) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tombstonesKey,
      jsonEncode(
        tombstones.map((k, v) => MapEntry(k, v.toUtc().toIso8601String())),
      ),
    );
  }

  Future<String?> loadOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ownerKey);
  }

  Future<void> saveOwner(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownerKey, userId);
  }

  Future<PlannerReminderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return const PlannerReminderSettings();
    return PlannerReminderSettings.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(PlannerReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}

/// 1 dong cua bang `planner_tasks` tren server.
class PlannerRemoteRow {
  const PlannerRemoteRow({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    this.task,
  });

  final String id;
  final DateTime updatedAt;
  final bool deleted;

  /// null khi [deleted] (hoac JSON hong).
  final PlannerTask? task;
}

/// Doc/ghi bang `planner_tasks` (moi viec 1 dong, noi dung = JSON cua
/// PlannerTask trong cot `data`, giu nguyen schema cuc bo nen them truong moi
/// khong can migration). RLS chi cho user doc/ghi dong cua chinh minh.
class PlannerRemote {
  PlannerRemote(this._client);

  final SupabaseClient _client;
  static const _table = 'planner_tasks';

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<PlannerRemoteRow>> fetchAll(String userId) async {
    final rows = await _client
        .from(_table)
        .select('id, data, updated_at, deleted')
        .eq('user_id', userId);
    return [
      for (final r in rows)
        PlannerRemoteRow(
          id: r['id'] as String,
          updatedAt: DateTime.parse(r['updated_at'] as String),
          deleted: r['deleted'] as bool? ?? false,
          task: _parse(r['data']),
        ),
    ];
  }

  static PlannerTask? _parse(dynamic data) {
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    try {
      return PlannerTask.fromJson(data);
    } catch (_) {
      // Dong do ban app MOI HON ghi (co gia tri enum ban nay chua biet) -
      // bo qua thay vi lam hong ca lan dong bo.
      return null;
    }
  }

  Future<void> upsert(
    String userId, {
    required List<PlannerTask> tasks,
    required Map<String, DateTime> tombstones,
  }) async {
    final rows = [
      for (final t in tasks)
        {
          'user_id': userId,
          'id': t.id,
          'data': t.toJson(),
          'updated_at': (t.updatedAt ?? DateTime.now())
              .toUtc()
              .toIso8601String(),
          'deleted': false,
        },
      for (final e in tombstones.entries)
        {
          'user_id': userId,
          'id': e.key,
          'data': <String, dynamic>{},
          'updated_at': e.value.toUtc().toIso8601String(),
          'deleted': true,
        },
    ];
    if (rows.isEmpty) return;
    await _client.from(_table).upsert(rows, onConflict: 'user_id,id');
  }
}
