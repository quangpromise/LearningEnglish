/// 1 khoan nam giu trong Portfolio dau tu - dung CHUNG cho moi loai tai san
/// (truoc day chi co stock_intl). `quantity`/`avgCost` null cho `real_estate`
/// (dung `manualValue` - gia tri tu nhap truc tiep thay vi so luong x gia).
class WealthHolding {
  const WealthHolding({
    required this.id,
    required this.assetType,
    required this.currency,
    this.symbol,
    this.name,
    this.imageUrl,
    this.quantity,
    this.avgCost,
    this.manualValue,
  });

  final String id;
  final String
  assetType; // 'stock_intl' | 'gold' | 'silver' | 'copper' | 'real_estate'
  final String? symbol;
  final String? name;
  final String? imageUrl;
  final double? quantity;
  final double? avgCost;
  final double? manualValue;
  final String currency;

  factory WealthHolding.fromRow(Map<String, dynamic> row) {
    return WealthHolding(
      id: row['id'] as String,
      assetType: row['asset_type'] as String,
      symbol: row['symbol'] as String?,
      name: row['name'] as String?,
      imageUrl: row['image_url'] as String?,
      quantity: (row['quantity'] as num?)?.toDouble(),
      avgCost: (row['avg_cost'] as num?)?.toDouble(),
      manualValue: (row['manual_value'] as num?)?.toDouble(),
      currency: row['currency'] as String,
    );
  }

  Map<String, dynamic> toInsertRow(String userId) => {
    'user_id': userId,
    'asset_type': assetType,
    if (symbol != null) 'symbol': symbol,
    if (name != null) 'name': name,
    if (imageUrl != null) 'image_url': imageUrl,
    if (quantity != null) 'quantity': quantity,
    if (avgCost != null) 'avg_cost': avgCost,
    if (manualValue != null) 'manual_value': manualValue,
    'currency': currency,
  };
}
