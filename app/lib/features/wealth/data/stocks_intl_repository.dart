import 'package:supabase_flutter/supabase_flutter.dart';

class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.currency,
    this.name,
    this.tradingValue,
  });

  final String symbol;
  final double price;
  final double changePercent;
  final String currency;
  // Ten cong ty day du - CHI co tu stocks-vn (HOSE tra ve san), stocks-intl
  // (Twelve Data) khong tra ve truong nay. Dung de hien thi trong picker
  // tim kiem co phieu VN, khong dung cho cac man hien co (van chi hien ma).
  final String? name;
  // Tong gia tri khop lenh trong phien (VND) - CHI co tu stocks-vn, dung lam
  // PROXY cho "quy mo giao dich" de sap xep Market > Chung khoan VN, KHONG
  // PHAI von hoa thi truong that (HOSE khong cong bo so co phieu luu hanh
  // qua API nay nen khong tinh duoc von hoa that).
  final double? tradingValue;

  factory StockQuote.fromJson(Map<String, dynamic> json) => StockQuote(
    symbol: json['symbol'] as String,
    price: (json['price'] as num).toDouble(),
    changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USD',
    name: json['name'] as String?,
    tradingValue: (json['tradingValue'] as num?)?.toDouble(),
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
