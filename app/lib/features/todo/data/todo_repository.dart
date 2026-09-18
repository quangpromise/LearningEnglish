import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'todo_models.dart';

/// Luu "To do list" CUC BO tren may (SharedPreferences, JSON) - van la nguon
/// doc CHINH nen mo app offline van thay viec ngay lap tuc.
///
/// Dong bo them len bang Supabase `todo_tasks` (xem
/// supabase/migrations/0066_todo_tasks.sql + [TodoRemote]) - cung ly do voi
/// planner: doi may la mat het, va tren web iPhone Safari co the xoa storage
/// sau 7 ngay khong mo trang.
class TodoRepository {
  static const _tasksKey = 'todo_tasks_v1';

  /// id -> thoi diem xoa (UTC). Giu lai de may KHAC cua cung user biet ma xoa
  /// theo - neu chi xoa o may nay thi lan dong bo sau se keo ban cu tu server
  /// ve va viec da xoa "song lai".
  static const _tombstonesKey = 'todo_tombstones_v1';

  /// User dang so huu du lieu cuc bo - doi user (dang xuat, dang nhap nick
  /// khac) thi phai xoa sach du lieu may nay truoc khi keo cua user moi ve.
  static const _ownerKey = 'todo_sync_owner_v1';

  Future<List<TodoTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TodoTask.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Du lieu hong (doi dinh dang, ghi do dang) - tra ve rong thay vi nem
      // loi lam trang man hinh; lan luu sau se ghi de lai ban sach.
      return [];
    }
  }

  Future<void> save(List<TodoTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<Map<String, DateTime>> loadTombstones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tombstonesKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
    } catch (_) {
      return {};
    }
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

  Future<String?> loadOwner() async =>
      (await SharedPreferences.getInstance()).getString(_ownerKey);

  Future<void> saveOwner(String userId) async =>
      (await SharedPreferences.getInstance()).setString(_ownerKey, userId);

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_tombstonesKey);
  }
}

class TodoRemoteRow {
  const TodoRemoteRow({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    this.task,
  });

  final String id;
  final DateTime updatedAt;
  final bool deleted;

  /// null khi [deleted] (hoac JSON hong).
  final TodoTask? task;
}

/// Doc/ghi bang `todo_tasks` - moi viec 1 dong, noi dung = JSON cua
/// [TodoTask] trong cot `data` nen them truong moi khong can migration. RLS
/// chi cho user doc/ghi dong cua chinh minh.
class TodoRemote {
  TodoRemote(this._client);

  final SupabaseClient _client;
  static const _table = 'todo_tasks';

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<TodoRemoteRow>> fetchAll(String userId) async {
    final rows = await _client
        .from(_table)
        .select('id, data, updated_at, deleted')
        .eq('user_id', userId);
    return [
      for (final r in rows)
        TodoRemoteRow(
          id: r['id'] as String,
          updatedAt: DateTime.parse(r['updated_at'] as String),
          deleted: r['deleted'] as bool? ?? false,
          task: _parse(r['data']),
        ),
    ];
  }

  static TodoTask? _parse(dynamic data) {
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    try {
      return TodoTask.fromJson(data);
    } catch (_) {
      // Dong do ban app MOI HON ghi - bo qua thay vi lam hong ca lan dong bo.
      return null;
    }
  }

  Future<void> upsert(
    String userId, {
    required List<TodoTask> tasks,
    required Map<String, DateTime> tombstones,
  }) async {
    final rows = [
      for (final t in tasks)
        {
          'user_id': userId,
          'id': t.id,
          'data': t.toJson(),
          'updated_at': (t.updatedAt ?? t.createdAt).toUtc().toIso8601String(),
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
