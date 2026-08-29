import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 1 từ trong danh sách "học hôm nay" - lưu trực tiếp en/vi/ipa (không chỉ
/// tham chiếu vào kVocabTopics) vì từ có thể đến từ bất kỳ đâu người dùng
/// tra cứu (lyric bài hát, sách, AI Voice Chat...), không nhất thiết nằm
/// trong bộ từ vựng theo chủ đề.
class DailyWordEntry {
  const DailyWordEntry({required this.en, required this.vi, this.ipa = ''});

  final String en;
  final String vi;
  final String ipa;

  Map<String, dynamic> toJson() => {'en': en, 'vi': vi, 'ipa': ipa};

  factory DailyWordEntry.fromJson(Map<String, dynamic> json) => DailyWordEntry(
    en: json['en'] as String? ?? '',
    vi: json['vi'] as String? ?? '',
    ipa: json['ipa'] as String? ?? '',
  );
}

/// Lưu danh sách "10 từ học hôm nay" + cấu hình nhắc quiz định kỳ trên máy
/// (SharedPreferences) - cùng khuôn mẫu với CryptoWatchlistRepository.
class DailyWordsRepository {
  DailyWordsRepository._();

  static const _wordsKey = 'daily_words_v1';
  static const _dateKey = 'daily_words_date_v1';
  static const _intervalKey = 'daily_words_interval_minutes_v1';
  static const _activeKey = 'daily_words_active_v1';
  static const _learnedTodayKey = 'daily_words_learned_today_v1';

  static const defaultIntervalMinutes = 60;

  static Future<List<DailyWordEntry>> loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_wordsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw);
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DailyWordEntry.fromJson)
        .toList();
  }

  static Future<void> saveWords(List<DailyWordEntry> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _wordsKey,
      jsonEncode(words.map((w) => w.toJson()).toList()),
    );
  }

  static Future<String?> loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateKey);
  }

  static Future<void> saveDate(String isoDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, isoDate);
  }

  static Future<int> loadIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? defaultIntervalMinutes;
  }

  static Future<void> saveIntervalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, minutes);
  }

  static Future<bool> loadActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_activeKey) ?? false;
  }

  static Future<void> saveActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeKey, active);
  }

  /// Cac tu (theo `en`, chu thuong) da tra loi DUNG trong quiz nhac hom nay
  /// - dung de khong hoi lai tu da hoc trong cac lan nhac tiep theo trong
  /// cung 1 ngay.
  static Future<Set<String>> loadLearnedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_learnedTodayKey);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw);
    if (list is! List) return {};
    return list.cast<String>().toSet();
  }

  static Future<void> saveLearnedToday(Set<String> learnedEnLower) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _learnedTodayKey,
      jsonEncode(learnedEnLower.toList()),
    );
  }
}
