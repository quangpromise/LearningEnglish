/// 1 dong lich su mua/ban/dinh gia lai cho 1 khoan dau tu (Co phieu/Vang-
/// Bac-Dong/Nha dat) - `action='revalue'` danh cho Nha dat (khong co khai
/// niem so luong, chi tu cap nhat gia tri).
class WealthInvestmentTransaction {
  const WealthInvestmentTransaction({
    required this.id,
    required this.assetType,
    required this.action,
    required this.currency,
    required this.occurredAt,
    this.symbol,
    this.quantity,
    this.price,
    this.amount,
    this.note,
    this.sourceTransactionId,
  });

  final String id;
  final String assetType;
  final String? symbol;
  final String action; // 'buy' | 'sell' | 'revalue'
  final double? quantity;
  final double? price;
  final double? amount;
  final String currency;
  final String? note;
  final DateTime occurredAt;

  /// Dong chi tieu "Dau tu" da sinh ra dong lich su nay (xem migration
  /// 0067). Xoa dong lich su thi phai xoa luon khoan chi tieu do, neu khong
  /// tien van bi tru khoi Vi ma khong con dau vet mua gi.
  final String? sourceTransactionId;

  factory WealthInvestmentTransaction.fromRow(Map<String, dynamic> row) {
    return WealthInvestmentTransaction(
      id: row['id'] as String,
      assetType: row['asset_type'] as String,
      symbol: row['symbol'] as String?,
      action: row['action'] as String,
      quantity: (row['quantity'] as num?)?.toDouble(),
      price: (row['price'] as num?)?.toDouble(),
      amount: (row['amount'] as num?)?.toDouble(),
      currency: row['currency'] as String,
      note: row['note'] as String?,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      sourceTransactionId: row['source_transaction_id'] as String?,
    );
  }
}
