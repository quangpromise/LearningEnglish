import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Danh sach "theo doi" DUNG CHUNG cho Co phieu + Kim loai (Crypto da co
/// [CryptoWatchlistRepository] rieng, khong dong bo lai o day) - moi item la
/// 1 key dang "type:id" (vd "stock_okx:AAPL", "stock_vn:VNM",
/// "metal:gold_sjc") de gop chung vao 1 tab Watchlist duy nhat o man Market.
/// Luu SharedPreferences la CHINH (UI doc/ghi nhanh, offline duoc), dong thoi
/// dong bo THEM 1 ban ghi server qua [syncAdd]/[syncRemove] cho 2 loai
/// "stock_okx"/"stock_vn" (co san %thay doi 24h) de tinh nang Thong bao gia
/// bien dong >5% biet duoc ai theo doi ma nao - "metal" CHUA dong bo (chua co
/// nguon %thay doi cho Vang) - xem supabase/migrations/0054_price_alerts.sql.
class AssetWatchlistRepository {
  AssetWatchlistRepository._();

  static const _key = 'wealth_asset_watchlist_v1';

  /// Cac tien to "type:" duoc Edge Function thong bao gia ho tro - phai khop
  /// dung gia tri cot asset_type cho phep trong migration 0054.
  static const _kSyncablePrefixes = {'stock_okx', 'stock_vn'};

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

  /// `key` dang "type:symbol" (vd "stock_okx:AAPL") - bo qua neu type khong
  /// nam trong [_kSyncablePrefixes] (vd "metal:...", chua co nguon %thay doi).
  static Future<void> syncAdd(String key) async {
    final parsed = _parseSyncable(key);
    if (parsed == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client.from('price_alert_watchlist').upsert({
        'user_id': userId,
        'asset_type': parsed.$1,
        'symbol': parsed.$2,
      });
    } catch (_) {}
  }

  static Future<void> syncRemove(String key) async {
    final parsed = _parseSyncable(key);
    if (parsed == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('price_alert_watchlist')
          .delete()
          .eq('user_id', userId)
          .eq('asset_type', parsed.$1)
          .eq('symbol', parsed.$2);
    } catch (_) {}
  }

  static (String, String)? _parseSyncable(String key) {
    final sep = key.indexOf(':');
    if (sep < 0) return null;
    final type = key.substring(0, sep);
    final symbol = key.substring(sep + 1);
    if (!_kSyncablePrefixes.contains(type) || symbol.isEmpty) return null;
    return (type, symbol.toUpperCase());
  }
}
