import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_currency.dart';

/// 1 dong coin trong bang xep hang top 100 theo von hoa.
class CryptoCoin {
  const CryptoCoin({
    required this.id,
    required this.rank,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.change24hPercent,
    required this.marketCap,
    required this.circulatingSupply,
  });

  final String id;
  final int rank;
  final String symbol;
  final String name;
  final String imageUrl;
  final double price;
  final double change24hPercent;
  final double marketCap;
  final double circulatingSupply;

  factory CryptoCoin.fromJson(Map<String, dynamic> json) => CryptoCoin(
    id: json['id'] as String? ?? '',
    rank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
    symbol: (json['symbol'] as String? ?? '').toUpperCase(),
    name: json['name'] as String? ?? '',
    imageUrl: json['image'] as String? ?? '',
    price: (json['current_price'] as num?)?.toDouble() ?? 0,
    change24hPercent:
        (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
    marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
    circulatingSupply: (json['circulating_supply'] as num?)?.toDouble() ?? 0,
  );
}

/// Lay top 100 coin theo von hoa tu CoinGecko - API cong khai, MIEN PHI,
/// KHONG can dang ky/API key, du dung cho hien thi bang xep hang don gian.
/// Xem docs/research-crypto-api.md ve ly do chon CoinGecko thay vi
/// CoinMarketCap (CoinMarketCap yeu cau API key rieng cho tung ung dung,
/// khong phu hop goi thang tu client khong co backend). CoinGecko ho tro
/// truyen thang vs_currency=usd/vnd nen khong can tu quy doi ty gia.
class CryptoRepository {
  CryptoRepository._();

  static Future<List<CryptoCoin>> fetchTop100({
    required CryptoCurrency currency,
  }) async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=${currency.code}&order=market_cap_desc&per_page=100'
      '&page=1&sparkline=false&price_change_percentage=24h',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('CoinGecko trả lỗi ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('Dữ liệu không hợp lệ');
    return data.cast<Map<String, dynamic>>().map(CryptoCoin.fromJson).toList();
  }
}
