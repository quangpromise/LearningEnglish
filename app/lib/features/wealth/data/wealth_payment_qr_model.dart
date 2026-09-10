class WealthPaymentQr {
  const WealthPaymentQr({
    this.imageUrl,
    this.bankName,
    this.accountNumber,
    this.holderName,
  });

  final String? imageUrl;
  final String? bankName;
  final String? accountNumber;
  final String? holderName;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory WealthPaymentQr.fromRow(Map<String, dynamic> row) => WealthPaymentQr(
    imageUrl: row['image_url'] as String?,
    bankName: row['bank_name'] as String?,
    accountNumber: row['account_number'] as String?,
    holderName: row['holder_name'] as String?,
  );
}
