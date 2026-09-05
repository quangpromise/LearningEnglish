import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Danh sach MA ngan hang (VnBank.code) nguoi dung chon "dang su dung" trong
/// man Cai dat Quan ly tai san - luu tren may (SharedPreferences), khong can
/// dong bo Supabase vi day chi la 1 tuy chinh hien thi. Tap RONG (chua tung
/// vao Cai dat) nghia la "chua loc gi ca" - hien THI TAT CA ngan hang nhu
/// truoc day, tranh lam nguoi dung cu bong nhien mat het lua chon quen thuoc.
class UsedBankRepository {
  UsedBankRepository._();

  static const _key = 'wealth_used_bank_codes_v1';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw);
    if (list is! List) return {};
    return list.cast<String>().toSet();
  }

  static Future<void> save(Set<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(codes.toList()));
  }
}
