import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'planner_models.dart';

/// Luu danh sach viec + cai dat nhac nho CUC BO tren may (SharedPreferences,
/// JSON) - v1 chua dong bo qua Supabase, moi nguoi dung tu quan ly ke hoach
/// tren chinh may cua ho. Co the nang cap len bang Supabase rieng sau nay
/// neu can dong bo nhieu thiet bi (giong cac *_repository.dart khac trong
/// app/lib/core/providers/app_providers.dart).
class PlannerRepository {
  static const _tasksKey = 'planner_tasks_v1';
  static const _settingsKey = 'planner_reminder_settings_v1';

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
