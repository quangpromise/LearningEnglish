import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Danh sach "theo doi" DUNG CHUNG cho Co phieu + Kim loai (Crypto da co
/// [CryptoWatchlistRepository] rieng, khong dong bo lai o day) - moi item la
/// 1 key dang "type:id" (vd "stock:AAPL", "metal:gold_sjc") de gop chung
/// vao 1 tab Watchlist duy nhat o man Market. Luu SharedPreferences, chi
/// tren may, khong dong bo server (giong crypto watchlist).
class AssetWatchlistRepository {
  AssetWatchlistRepository._();

  static const _key = 'wealth_asset_watchlist_v1';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw);
    if (list is! List) return {};
    return list.cast<String>().toSet();
  }

  static Future<void> save(Set<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(keys.toList()));
  }
}
