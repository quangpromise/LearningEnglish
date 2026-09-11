/// 1 lan chia tien bill da luu (xem wealth_split_bill_screen.dart) - tong
/// tien + phuong thuc thanh toan da dung. Danh sach nguoi/so tien tung
/// nguoi nam o [WealthSplitBillShare] rieng (1-nhieu, xem
/// wealthSplitBillSharesProvider).
class WealthSplitBill {
  const WealthSplitBill({
    required this.id,
    required this.totalAmount,
    required this.currency,
    required this.paymentAccountType,
    required this.occurredAt,
    this.paymentBankCode,
    this.paymentBankName,
    this.transactionId,
    this.note,
  });

  final String id;
  final double totalAmount;
  final String currency;
  final String paymentAccountType; // 'cash' | 'bank'
  final String? paymentBankCode;
  final String? paymentBankName;
  final DateTime occurredAt;
  // Lien ket sang wealth_transactions (khoan Chi tieu tru tong tien bill
  // khoi Cash/Bank) - can de XOA CASCADE khi nguoi dung xoa ca bill (xem
  // WealthSplitBillDetailScreen/_deleteBill trong wealth_split_bill_history_
  // screen.dart).
  final String? transactionId;
  final String? note;

  factory WealthSplitBill.fromRow(Map<String, dynamic> row) => WealthSplitBill(
    id: row['id'] as String,
    totalAmount: (row['total_amount'] as num).toDouble(),
    currency: row['currency'] as String,
    paymentAccountType: row['payment_account_type'] as String,
    paymentBankCode: row['payment_bank_code'] as String?,
    paymentBankName: row['payment_bank_name'] as String?,
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    transactionId: row['transaction_id'] as String?,
    note: row['note'] as String?,
  );
}

/// 1 nguoi trong 1 lan chia bill - `status`: 'pending' (chua xu ly, chi ap
/// dung cho nguoi KHAC "Toi"), 'debt' (da ghi no owed_to_me, xem [debtId]),
/// 'paid' (da cong lai tien vao Vi).
class WealthSplitBillShare {
  const WealthSplitBillShare({
    required this.id,
    required this.billId,
    required this.personName,
    required this.isMe,
    required this.amount,
    required this.status,
    this.debtId,
  });

  final String id;
  final String billId;
  final String personName;
  final bool isMe;
  final double amount;
  final String status; // 'pending' | 'debt' | 'paid'
  final String? debtId;

  factory WealthSplitBillShare.fromRow(Map<String, dynamic> row) =>
      WealthSplitBillShare(
        id: row['id'] as String,
        billId: row['bill_id'] as String,
        personName: row['person_name'] as String,
        isMe: row['is_me'] as bool,
        amount: (row['amount'] as num).toDouble(),
        status: row['status'] as String,
        debtId: row['debt_id'] as String?,
      );
}
