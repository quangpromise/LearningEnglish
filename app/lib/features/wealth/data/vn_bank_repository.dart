import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'vn_bank_model.dart';

/// Danh sach ngan hang VN de chon khi them so du "Tien ngan hang" - uu tien
/// goi API cong khai cua VietQR (khong can key, tra ve ca logo PNG), fallback
/// sang 1 ban JSON tinh da bundle san (`assets/wealth/vn_banks_fallback.json`,
/// snapshot luc build app) khi mat mang/API loi, de man chon ngan hang luon
/// dung duoc ca offline.
class VnBankRepository {
  List<VnBank>? _cache;

  Future<List<VnBank>> getAll() async {
    if (_cache != null) return _cache!;
    List<VnBank> banks;
    try {
      banks = await _fetchLive();
    } catch (_) {
      banks = await _loadFallback();
    }
    _cache = [...banks, VnBank.other];
    return _cache!;
  }

  Future<List<VnBank>> _fetchLive() async {
    final res = await http
        .get(Uri.parse('https://api.vietqr.io/v2/banks'))
        .timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) {
      throw Exception('VietQR status ${res.statusCode}');
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final rows = json['data'] as List;
    return rows
        .map(
          (r) => VnBank(
            code: r['code'] as String,
            shortName: r['shortName'] as String,
            name: r['name'] as String,
            logoUrl: r['logo'] as String?,
          ),
        )
        .toList();
  }

  Future<List<VnBank>> _loadFallback() async {
    final raw = await rootBundle.loadString(
      'assets/wealth/vn_banks_fallback.json',
    );
    final rows = jsonDecode(raw) as List;
    return rows.map((r) => VnBank.fromJson(r as Map<String, dynamic>)).toList();
  }
}
