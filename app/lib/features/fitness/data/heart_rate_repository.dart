import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'heart_rate_model.dart';

/// Lich su do nhip tim - luu TREN MAY (shared_preferences) chu khong phai
/// Supabase nhu workout/nutrition.
///
/// Ly do: day la du lieu suc khoe do bang cam bien cua chinh chiec may do,
/// gan lien voi thiet bi, va nguoi dung chua he dong y cho no roi khoi may.
/// Neu sau nay can dong bo da thiet bi thi them 1 bang Supabase + lop repo
/// moi, giu nguyen giao dien ben duoi.
class HeartRateRepository {
  static const _key = 'fitness_heart_rate_history_v1';

  /// Gioi han so ban ghi giu lai - du cho bieu do "30 ngay" ma khong phinh
  /// file preferences vo han.
  static const _maxRecords = 200;

  Future<List<HeartRateMeasurement>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final items = <HeartRateMeasurement>[];
    for (final entry in raw) {
      try {
        items.add(
          HeartRateMeasurement.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // Bo qua ban ghi hong (doi dinh dang giua cac phien ban) thay vi
        // lam hong ca danh sach.
      }
    }
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> save(HeartRateMeasurement measurement) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory()
      ..insert(0, measurement);
    final trimmed = history.take(_maxRecords).toList();
    await prefs.setStringList(
      _key,
      trimmed.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = (await getHistory())..removeWhere((m) => m.id == id);
    await prefs.setStringList(
      _key,
      history.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  /// Cac lan do TRONG NGAY hom nay, moi nhat truoc.
  Future<List<HeartRateMeasurement>> getToday() async {
    final now = DateTime.now();
    final history = await getHistory();
    return history
        .where(
          (m) =>
              m.timestamp.year == now.year &&
              m.timestamp.month == now.month &&
              m.timestamp.day == now.day,
        )
        .toList();
  }
}
