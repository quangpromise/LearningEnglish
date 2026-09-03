/// 1 ma co phieu quoc te nam giu (thu cong - nguoi dung tu nhap so luong +
/// gia von, KHONG tu dong sync giao dich mua/ban that). Gia hien tai lay
/// rieng qua [StockQuote] (stocks_intl_repository.dart), khong luu trong
/// bang nay vi thay doi lien tuc.
class WealthHolding {
  const WealthHolding({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.avgCost,
    required this.currency,
  });

  final String id;
  final String symbol;
  final double quantity;
  final double avgCost;
  final String currency;

  factory WealthHolding.fromRow(Map<String, dynamic> row) {
    return WealthHolding(
      id: row['id'] as String,
      symbol: row['symbol'] as String,
      quantity: (row['quantity'] as num).toDouble(),
      avgCost: (row['avg_cost'] as num).toDouble(),
      currency: row['currency'] as String,
    );
  }

  Map<String, dynamic> toInsertRow(String userId) => {
    'user_id': userId,
    'asset_type': 'stock_intl',
    'symbol': symbol,
    'quantity': quantity,
    'avg_cost': avgCost,
    'currency': currency,
  };
}
