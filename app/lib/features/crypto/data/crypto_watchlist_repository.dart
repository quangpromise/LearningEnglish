import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Danh sach coin id (CoinGecko) nguoi dung "theo doi" - chi de xem gia,
/// KHONG lien quan gi den Portfolio (khong co so luong nam giu, khong tinh
/// lai/lo). Luu tren may (SharedPreferences), khong dong bo server.
class CryptoWatchlistRepository {
  CryptoWatchlistRepository._();

  static const _key = 'crypto_watchlist_v1';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw);
    if (list is! List) return {};
    return list.cast<String>().toSet();
  }

  static Future<void> save(Set<String> coinIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(coinIds.toList()));
  }
}
