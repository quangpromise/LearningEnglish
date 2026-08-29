import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum CryptoTransactionType { buy, sell }

/// 1 lan mua/ban trong danh muc crypto ca nhan - luu lai de xem lich su,
/// khong phai giao dich tren san that.
class CryptoTransaction {
  const CryptoTransaction({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.quantity,
    required this.priceAtTime,
    required this.timestamp,
  });

  final String coinId;
  final String symbol;
  final String name;
  final String imageUrl;
  final CryptoTransactionType type;
  final double quantity;
  final double priceAtTime;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'symbol': symbol,
    'name': name,
    'imageUrl': imageUrl,
    'type': type.name,
    'quantity': quantity,
    'priceAtTime': priceAtTime,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CryptoTransaction.fromJson(Map<String, dynamic> json) =>
      CryptoTransaction(
        coinId: json['coinId'] as String? ?? '',
        symbol: json['symbol'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        type: (json['type'] as String?) == 'sell'
            ? CryptoTransactionType.sell
            : CryptoTransactionType.buy,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        priceAtTime: (json['priceAtTime'] as num?)?.toDouble() ?? 0,
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Luu lich su mua/ban tren may (SharedPreferences), moi nhat len dau.
class CryptoTransactionRepository {
  CryptoTransactionRepository._();

  static const _key = 'crypto_transactions_v1';

  static Future<List<CryptoTransaction>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw);
    if (list is! List) return [];
    return list
        .cast<Map<String, dynamic>>()
        .map(CryptoTransaction.fromJson)
        .toList();
  }

  static Future<void> _save(List<CryptoTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(transactions.map((t) => t.toJson()).toList()),
    );
  }

  static Future<List<CryptoTransaction>> record(
    CryptoTransaction transaction,
  ) async {
    final list = await load();
    list.insert(0, transaction);
    await _save(list);
    return list;
  }
}
