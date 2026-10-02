import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'milestones.dart';

/// Ban ghi Milestone da chuc mung, luu TREN MAY theo tung tai khoan (doi tai
/// khoan khong lan) - khong dong bo giua cac may (spec #96, ngoai pham vi).
abstract final class MilestoneStore {
  static String _key(String userId) => 'gt_milestones_v1_$userId';

  static Future<MilestoneRecord> load(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(userId));
      if (raw == null) return const MilestoneRecord();
      return MilestoneRecord.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (e) {
      debugPrint('MilestoneStore load failed: $e');
      return const MilestoneRecord();
    }
  }

  static Future<void> save(String userId, MilestoneRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(userId), jsonEncode(record.toJson()));
    } catch (e) {
      debugPrint('MilestoneStore save failed: $e');
    }
  }
}
