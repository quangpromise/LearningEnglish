import 'package:supabase_flutter/supabase_flutter.dart';

class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.currency,
  });

  final String symbol;
  final double price;
  final double changePercent;
  final String currency;

  factory StockQuote.fromJson(Map<String, dynamic> json) => StockQuote(
    symbol: json['symbol'] as String,
    price: (json['price'] as num).toDouble(),
    changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USD',
  );
}

/// Goi Edge Function `stocks-intl` (supabase/functions/stocks-intl) - KHONG
/// goi thang Twelve Data tu client vi can API key giau phia server (khac
/// crypto/CoinGecko khong can key - xem docs/research-wealth-stock-apis.md).
class StocksIntlRepository {
  StocksIntlRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<StockQuote>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];
    final res = await _supabase.functions.invoke(
      'stocks-intl',
      method: HttpMethod.get,
      queryParameters: {'symbols': symbols.join(',')},
    );
    if (res.status != 200) {
      throw Exception('stocks-intl trả lỗi ${res.status}');
    }
    final data = res.data;
    if (data is! List) {
      throw Exception('stocks-intl trả dữ liệu sai định dạng');
    }
    return data.cast<Map<String, dynamic>>().map(StockQuote.fromJson).toList();
  }
}
