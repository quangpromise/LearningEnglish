import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_format.dart';
import '../data/wealth_payment_qr_model.dart';

/// 1 nguoi de hien trong [SplitBillReceiptCard] - callback [onDebt]/[onPaid]
/// null = an nut hanh dong (dung cho "Toi" hoac nguoi da xu ly xong khi
/// khong con can bam lai).
class ReceiptPersonView {
  const ReceiptPersonView({
    required this.name,
    required this.amount,
    required this.isMe,
    required this.status,
    this.onDebt,
    this.onPaid,
  });
  final String name;
  final double amount;
  final bool isMe;
  final String status; // 'pending' | 'debt' | 'paid'
  final VoidCallback? onDebt;
  final VoidCallback? onPaid;
}

/// The "hoa don" (bill) chia tien - nen TRANG rieng biet voi giao dien toi
/// cua ca app de trong giong 1 to bien lai in ra that, dung CHUNG cho ca man
/// chia bill (ngay sau khi Pay) LAN man xem lai lich su (wealth_split_bill_
/// history_screen.dart) - chi khac o cach [people] duoc gan callback hay
/// khong.
class SplitBillReceiptCard extends StatelessWidget {
  const SplitBillReceiptCard({
    super.key,
    required this.totalAmount,
    required this.paymentLabel,
    required this.occurredAt,
    required this.people,
    this.qr,
  });

  final double totalAmount;
  final String paymentLabel;
  final DateTime occurredAt;
  final List<ReceiptPersonView> people;
  final WealthPaymentQr? qr;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header gon 1 dong (ten bill + gio) thay vi 2 dong rieng - nhuong
            // cho TIEN TONG len ngay ben duoi, dung dau tien nguoi xem thay
            // (yeu cau: "phai co tien tong tren cung").
            Center(
              child: Text(
                '${ref.tr('wealth_split_bill_title').toUpperCase()} · '
                '${formatDateMdy(occurredAt)} '
                '${occurredAt.hour.toString().padLeft(2, '0')}:'
                '${occurredAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                formatVnd(totalAmount),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _dashedDivider(),
            const SizedBox(height: 10),
            // Chi con QR + thong tin tai khoan nhan tien o day (bo hang
            // "Hinh thuc thanh toan" cu - do la cach TOI da tra, khong phai
            // thong tin can cho NGUOI KHAC nhin vao bill de tra lai, gay
            // roi/thua so voi muc dich cua 1 to bien lai de chia se).
            if (qr != null && qr!.hasImage) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.network(qr!.imageUrl!, width: 80, height: 80),
                ),
              ),
              const SizedBox(height: 8),
              if ((qr!.holderName ?? '').isNotEmpty)
                Center(
                  child: Text(
                    qr!.holderName!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              if ((qr!.bankName ?? '').isNotEmpty ||
                  (qr!.accountNumber ?? '').isNotEmpty)
                Center(
                  child: Text(
                    [
                      qr!.bankName,
                      qr!.accountNumber,
                    ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 10),
            ],
            _dashedDivider(),
            const SizedBox(height: 8),
            for (final p in people) _personRow(ref, p),
          ],
        ),
      ),
    );
  }

  Widget _dashedDivider() {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashSpace = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();
          return Row(
            children: List.generate(
              count,
              (_) => const Padding(
                padding: EdgeInsets.only(right: dashSpace),
                child: SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: ColoredBox(color: Colors.black26),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _personRow(WidgetRef ref, ReceiptPersonView p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.isMe ? ref.tr('wealth_split_bill_me_label') : p.name,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            formatVnd(p.amount),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 78, child: _statusWidget(ref, p)),
        ],
      ),
    );
  }

  Widget _statusWidget(WidgetRef ref, ReceiptPersonView p) {
    if (p.isMe) {
      return const Align(
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.check_circle_rounded,
          color: AppColors.teal,
          size: 20,
        ),
      );
    }
    switch (p.status) {
      case 'debt':
        return Align(
          alignment: Alignment.centerRight,
          child: Text(
            ref.tr('wealth_split_bill_status_debt'),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.pink,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        );
      case 'paid':
        return Align(
          alignment: Alignment.centerRight,
          child: Text(
            ref.tr('wealth_split_bill_status_paid'),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pillButton(
              label: ref.tr('wealth_split_bill_debt_button'),
              color: AppColors.pink,
              onTap: p.onDebt,
            ),
            const SizedBox(width: 4),
            _pillButton(
              label: ref.tr('wealth_split_bill_paid_button'),
              color: AppColors.teal,
              onTap: p.onPaid,
            ),
          ],
        );
    }
  }

  Widget _pillButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.7)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 9.5,
          ),
        ),
      ),
    );
  }
}
