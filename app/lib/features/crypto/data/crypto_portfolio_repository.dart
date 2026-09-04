import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 dong nam giu trong danh muc crypto ca nhan - dong bo qua Supabase
/// (bang wealth_holdings, asset_type='crypto', symbol=coinId cua CoinGecko
/// vi on dinh hon ky hieu). TRUOC DAY luu SharedPreferences chi tren may -
/// da chuyen sang day de dong bo da thiet bi, nhat quan voi phan con lai cua
/// Vi (xem ke hoach build lai Wealth).
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

  factory CryptoHolding.fromRow(Map<String, dynamic> row) {
    final parts = (row['name'] as String? ?? '|').split('|');
    return CryptoHolding(
      coinId: row['symbol'] as String,
      symbol: parts.isNotEmpty ? parts[0] : '',
      name: parts.length > 1 ? parts[1] : '',
      imageUrl: row['image_url'] as String? ?? '',
      quantity: (row['quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toRow(String userId) => {
    'user_id': userId,
    'asset_type': 'crypto',
    'symbol': coinId,
    // wealth_holdings chi co 1 cot `name` - ghep ca ky hieu (BTC) lan ten
    // day du (Bitcoin) vao day, tach lai bang '|' khi doc, thay vi them 1
    // cot rieng cho 1 truong hop dung nay.
    'name': '$symbol|$name',
    'image_url': imageUrl,
    'quantity': quantity,
    'currency': 'USD',
  };
}

class CryptoPortfolioRepository {
  CryptoPortfolioRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<CryptoHolding>> load(String userId) async {
    final rows = await _supabase
        .from('wealth_holdings')
        .select()
        .eq('user_id', userId)
        .eq('asset_type', 'crypto')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => CryptoHolding.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsert(String userId, CryptoHolding holding) async {
    await _supabase
        .from('wealth_holdings')
        .upsert(holding.toRow(userId), onConflict: 'user_id,asset_type,symbol');
  }

  Future<void> remove(String userId, String coinId) async {
    await _supabase
        .from('wealth_holdings')
        .delete()
        .eq('user_id', userId)
        .eq('asset_type', 'crypto')
        .eq('symbol', coinId);
  }
}
