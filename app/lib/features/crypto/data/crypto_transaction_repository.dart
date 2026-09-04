import 'package:supabase_flutter/supabase_flutter.dart';

enum CryptoTransactionType { buy, sell }

/// 1 lan mua/ban trong danh muc crypto ca nhan - dong bo qua Supabase (bang
/// wealth_investment_transactions, asset_type='crypto') - TRUOC DAY luu
/// SharedPreferences chi tren may.
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

  factory CryptoTransaction.fromRow(Map<String, dynamic> row) =>
      CryptoTransaction(
        coinId: row['symbol'] as String? ?? '',
        symbol: row['symbol'] as String? ?? '',
        name: row['name'] as String? ?? '',
        imageUrl: row['image_url'] as String? ?? '',
        type: (row['action'] as String?) == 'sell'
            ? CryptoTransactionType.sell
            : CryptoTransactionType.buy,
        quantity: (row['quantity'] as num?)?.toDouble() ?? 0,
        priceAtTime: (row['price'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.parse(row['occurred_at'] as String),
      );

  Map<String, dynamic> toRow(String userId) => {
    'user_id': userId,
    'asset_type': 'crypto',
    'symbol': coinId,
    'name': name,
    'image_url': imageUrl,
    'action': type.name,
    'quantity': quantity,
    'price': priceAtTime,
    'currency': 'USD',
    'occurred_at': timestamp.toIso8601String(),
  };
}

class CryptoTransactionRepository {
  CryptoTransactionRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<CryptoTransaction>> load(String userId) async {
    final rows = await _supabase
        .from('wealth_investment_transactions')
        .select()
        .eq('user_id', userId)
        .eq('asset_type', 'crypto')
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => CryptoTransaction.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> record(String userId, CryptoTransaction transaction) async {
    await _supabase
        .from('wealth_investment_transactions')
        .insert(transaction.toRow(userId));
  }
}
