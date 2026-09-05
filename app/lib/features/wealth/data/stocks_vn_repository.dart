import 'package:supabase_flutter/supabase_flutter.dart';

import 'stocks_intl_repository.dart';

/// Goi Edge Function `stocks-vn` (supabase/functions/stocks-vn) - lay gia
/// "khop lenh gan nhat" cong khai tu chinh API cua San GDCK TP.HCM (HOSE),
/// KHONG can API key. Tra ve cung shape [StockQuote] nhu stocks-intl (chi
/// khac currency='VND') de tai su dung UI hien co. Xem ghi chu do tin cay du
/// lieu trong file Edge Function va docs/research-wealth-stock-apis.md.
class StocksVnRepository {
  StocksVnRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<StockQuote>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];
    final res = await _supabase.functions.invoke(
      'stocks-vn',
      method: HttpMethod.get,
      queryParameters: {'symbols': symbols.join(',')},
    );
    if (res.status != 200) {
      throw Exception('stocks-vn trả lỗi ${res.status}');
    }
    final data = res.data;
    if (data is! List) {
      throw Exception('stocks-vn trả dữ liệu sai định dạng');
    }
    return data.cast<Map<String, dynamic>>().map(StockQuote.fromJson).toList();
  }

  /// Toan bo ma dang giao dich tren HOSE (kem ten cong ty) - dung de tim
  /// kiem/chon khi them co phieu VN vao Portfolio, khac [fetchQuotes] chi
  /// tra dung nhung ma da yeu cau san.
  Future<List<StockQuote>> fetchAll() async {
    final res = await _supabase.functions.invoke(
      'stocks-vn',
      method: HttpMethod.get,
      queryParameters: {'all': 'true'},
    );
    if (res.status != 200) {
      throw Exception('stocks-vn trả lỗi ${res.status}');
    }
    final data = res.data;
    if (data is! List) {
      throw Exception('stocks-vn trả dữ liệu sai định dạng');
    }
    return data.cast<Map<String, dynamic>>().map(StockQuote.fromJson).toList();
  }
}
