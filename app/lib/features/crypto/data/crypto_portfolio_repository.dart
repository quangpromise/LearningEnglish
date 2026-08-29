import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 1 dong nam giu trong danh muc crypto ca nhan - luu tren may (khong dong
/// bo server), theo dung coin id cua CoinGecko (on dinh hon ten/ky hieu).
class CryptoHolding {
  const CryptoHolding({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.quantity,
  });

  final String coinId;
  final String symbol;
  final String name;
  final String imageUrl;
  final double quantity;

  CryptoHolding copyWith({double? quantity}) => CryptoHolding(
    coinId: coinId,
    symbol: symbol,
    name: name,
    imageUrl: imageUrl,
    quantity: quantity ?? this.quantity,
  );

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'symbol': symbol,
    'name': name,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory CryptoHolding.fromJson(Map<String, dynamic> json) => CryptoHolding(
    coinId: json['coinId'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    name: json['name'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
  );
}

/// Luu danh muc crypto ca nhan tren may (SharedPreferences) - day chi la 1
/// so tay theo doi ca nhan, khong phai vi/giao dich thuc.
class CryptoPortfolioRepository {
  CryptoPortfolioRepository._();

  static const _key = 'crypto_portfolio_v1';

  static Future<List<CryptoHolding>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw);
    if (list is! List) return [];
    return list
        .cast<Map<String, dynamic>>()
        .map(CryptoHolding.fromJson)
        .toList();
  }

  static Future<void> save(List<CryptoHolding> holdings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(holdings.map((h) => h.toJson()).toList()),
    );
  }
}
