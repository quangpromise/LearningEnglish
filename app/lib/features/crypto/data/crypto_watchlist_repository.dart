import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Danh sach coin id (CoinGecko) nguoi dung "theo doi" - chi de xem gia,
/// KHONG lien quan gi den Portfolio (khong co so luong nam giu, khong tinh
/// lai/lo). Luu tren may (SharedPreferences) la CHINH (UI doc/ghi nhanh,
/// offline duoc), dong thoi dong bo THEM 1 ban ghi server (bang
/// price_alert_watchlist) qua [syncAdd]/[syncRemove] de tinh nang Thong bao
/// gia bien dong >5% (Edge Function chay nen, khong co user dang nhap) biet
/// duoc ai dang theo doi coin nao - xem supabase/migrations/0054_price_alerts.sql.
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

  /// Ghi 1 dong watchlist server cho ma OKX thuc su (KHONG phai id CoinGecko)
  /// - goi ngay luc nguoi dung bam sao, vi day la thoi diem DUY NHAT UI chac
  /// chan co san ca id lan symbol cua coin. Best-effort: nuot loi neu offline/
  /// chua dang nhap, khong lam gian doan thao tac sao cuc bo.
  static Future<void> syncAdd({required String symbol}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client.from('price_alert_watchlist').upsert({
        'user_id': userId,
        'asset_type': 'crypto',
        'symbol': symbol.toUpperCase(),
      });
    } catch (_) {}
  }

  static Future<void> syncRemove({required String symbol}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('price_alert_watchlist')
          .delete()
          .eq('user_id', userId)
          .eq('asset_type', 'crypto')
          .eq('symbol', symbol.toUpperCase());
    } catch (_) {}
  }
}
