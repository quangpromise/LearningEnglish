import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Muc tieu ngu mac dinh (phut) - 8 tieng, dung lam moc cho vong tron tien
/// do o man Giac ngu. Chua cho tuy chinh theo tung nguoi o phien ban nay.
const kSleepGoalMinutes = 8 * 60;

/// 1 dem ngu da ghi. [date] la ngay THUC DAY (dem 31/5 rang sang 1/6 tinh
/// vao ngay 1/6) de moi ngay chi co toi da 1 ban ghi va khop voi cach nguoi
/// dung nghi ve "dem qua toi ngu may tieng".
class SleepEntry {
  const SleepEntry({
    required this.date,
    required this.bedAt,
    required this.wakeAt,
  });

  final DateTime date;
  final DateTime bedAt;
  final DateTime wakeAt;

  /// Tong so phut ngu. Neu gio thuc day <= gio di ngu thi day la dem qua
  /// nua dem, cong them 1 ngay.
  int get minutes {
    final wake = wakeAt.isAfter(bedAt)
        ? wakeAt
        : wakeAt.add(const Duration(days: 1));
    return wake.difference(bedAt).inMinutes;
  }

  Map<String, dynamic> toJson() => {
    'date': _dateKey(date),
    'bedAt': bedAt.toIso8601String(),
    'wakeAt': wakeAt.toIso8601String(),
  };

  static SleepEntry fromJson(Map<String, dynamic> json) => SleepEntry(
    date: DateTime.parse(json['date'] as String),
    bedAt: DateTime.parse(json['bedAt'] as String),
    wakeAt: DateTime.parse(json['wakeAt'] as String),
  );
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Nhat ky giac ngu - luu tren may giong [HeartRateRepository] (du lieu suc
/// khoe gan voi thiet bi, khong dong bo len server o phien ban nay).
class SleepRepository {
  static const _key = 'fitness_sleep_log_v1';
  static const _maxRecords = 120;

  Future<List<SleepEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final items = <SleepEntry>[];
    for (final entry in raw) {
      try {
        items.add(
          SleepEntry.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // Bo qua ban ghi hong thay vi lam hong ca danh sach.
      }
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Ghi de ban ghi cung ngay neu da co (moi ngay chi 1 dem).
  Future<void> save(SleepEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = (await getHistory())
      ..removeWhere((e) => _dateKey(e.date) == _dateKey(entry.date))
      ..insert(0, entry);
    history.sort((a, b) => b.date.compareTo(a.date));
    await prefs.setStringList(
      _key,
      history.take(_maxRecords).map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<SleepEntry?> getLatest() async {
    final history = await getHistory();
    return history.isEmpty ? null : history.first;
  }

  /// So phut ngu cua 7 ngay gan nhat, index 0 la 6 ngay truoc, index 6 la
  /// hom nay (0 = chua ghi) - dung cho bieu do cot o man Giac ngu.
  Future<List<int>> getLast7Days() async {
    final history = await getHistory();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final byDate = {for (final e in history) _dateKey(e.date): e.minutes};
    return List<int>.generate(7, (i) {
      final day = todayKey.subtract(Duration(days: 6 - i));
      return byDate[_dateKey(day)] ?? 0;
    });
  }
}
