import 'dart:convert';

import 'package:http/http.dart' as http;

/// 1 dong coin trong bang xep hang top 100 theo von hoa.
class CryptoCoin {
  const CryptoCoin({
    required this.rank,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.priceUsd,
    required this.change24hPercent,
    required this.marketCapUsd,
  });

  final int rank;
  final String symbol;
  final String name;
  final String imageUrl;
  final double priceUsd;
  final double change24hPercent;
  final double marketCapUsd;

  factory CryptoCoin.fromJson(Map<String, dynamic> json) => CryptoCoin(
    rank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
    symbol: (json['symbol'] as String? ?? '').toUpperCase(),
    name: json['name'] as String? ?? '',
    imageUrl: json['image'] as String? ?? '',
    priceUsd: (json['current_price'] as num?)?.toDouble() ?? 0,
    change24hPercent:
        (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
    marketCapUsd: (json['market_cap'] as num?)?.toDouble() ?? 0,
  );
}

/// Lay top 100 coin theo von hoa tu CoinGecko - API cong khai, MIEN PHI,
/// KHONG can dang ky/API key, du dung cho hien thi bang xep hang don gian.
/// Xem docs/research-crypto-api.md ve ly do chon CoinGecko thay vi
/// CoinMarketCap (CoinMarketCap yeu cau API key rieng cho tung ung dung,
/// khong phu hop goi thang tu client khong co backend).
class CryptoRepository {
  CryptoRepository._();

  static const _endpoint =
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd&order=market_cap_desc&per_page=100&page=1'
      '&sparkline=false&price_change_percentage=24h';

  static Future<List<CryptoCoin>> fetchTop100() async {
    final res = await http
        .get(Uri.parse(_endpoint))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('CoinGecko trả lỗi ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('Dữ liệu không hợp lệ');
    return data.cast<Map<String, dynamic>>().map(CryptoCoin.fromJson).toList();
  }
}
