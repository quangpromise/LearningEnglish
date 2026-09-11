import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
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
class SplitBillReceiptCard extends ConsumerStatefulWidget {
  const SplitBillReceiptCard({
    super.key,
    required this.totalAmount,
    required this.paymentLabel,
    required this.occurredAt,
    required this.people,
    this.qr,
    this.note,
  });

  final double totalAmount;
  final String paymentLabel;
  final DateTime occurredAt;
  final List<ReceiptPersonView> people;
  final WealthPaymentQr? qr;
  final String? note;

  @override
  ConsumerState<SplitBillReceiptCard> createState() =>
      _SplitBillReceiptCardState();
}

class _SplitBillReceiptCardState extends ConsumerState<SplitBillReceiptCard> {
  // Ngon ngu RIENG cua to bien lai nay, doc lap voi ngon ngu giao dien chung
  // cua app (appLanguageProvider) - nguoi dung co the dang dung app tieng
  // Viet nhung muon gui bien lai tieng Anh cho ban be nuoc ngoai (hoac
  // nguoc lai) ma khong can doi ngon ngu ca app. null = chua tu chon, mac
  // dinh theo ngon ngu app hien tai.
  AppLanguage? _lang;

  @override
  Widget build(BuildContext context) {
    final AppLanguage lang = _lang ?? ref.watch(appLanguageProvider);
    String tr(String key) => AppStrings.t(key, lang);
    return Container(
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
          // Nut chon ngon ngu VI/EN cho to bien lai - dat goc tren-phai, tren
          // ca dong tieu de, de khong lan vao noi dung chinh.
          Align(alignment: Alignment.topRight, child: _langToggle(lang)),
          const SizedBox(height: 4),
          // Header gon 1 dong (ten bill + gio) thay vi 2 dong rieng - nhuong
          // cho TIEN TONG len ngay ben duoi, dung dau tien nguoi xem thay
          // (yeu cau: "phai co tien tong tren cung").
          Center(
            child: Text(
              '${tr('wealth_split_bill_title').toUpperCase()} · '
              '${formatDateMdy(widget.occurredAt)} '
              '${widget.occurredAt.hour.toString().padLeft(2, '0')}:'
              '${widget.occurredAt.minute.toString().padLeft(2, '0')}',
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
              formatVnd(widget.totalAmount),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
          ),
          if ((widget.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                widget.note!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _dashedDivider(),
          const SizedBox(height: 10),
          // Chi con QR + thong tin tai khoan nhan tien o day (bo hang
          // "Hinh thuc thanh toan" cu - do la cach TOI da tra, khong phai
          // thong tin can cho NGUOI KHAC nhin vao bill de tra lai, gay
          // roi/thua so voi muc dich cua 1 to bien lai de chia se).
          if (widget.qr != null && widget.qr!.hasImage) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(14),
                ),
                // QR to hon (140 thay vi 80) de de quet truc tiep tu bien
                // lai khi gui/chup lai cho nguoi khac, khong can zoom.
                child: Image.network(
                  widget.qr!.imageUrl!,
                  width: 140,
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if ((widget.qr!.holderName ?? '').isNotEmpty)
              Center(
                child: Text(
                  widget.qr!.holderName!,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            if ((widget.qr!.bankName ?? '').isNotEmpty ||
                (widget.qr!.accountNumber ?? '').isNotEmpty)
              Center(
                child: Text(
                  [
                    widget.qr!.bankName,
                    widget.qr!.accountNumber,
                  ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ),
            const SizedBox(height: 10),
          ],
          _dashedDivider(),
          const SizedBox(height: 8),
          for (final p in widget.people) _personRow(tr, p),
        ],
      ),
    );
  }

  Widget _langToggle(AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langChip('VI', AppLanguage.vi, lang),
          _langChip('EN', AppLanguage.en, lang),
        ],
      ),
    );
  }

  Widget _langChip(String label, AppLanguage value, AppLanguage current) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => setState(() => _lang = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black45,
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
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

  Widget _personRow(String Function(String) tr, ReceiptPersonView p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.name.isNotEmpty ? p.name : tr('wealth_split_bill_me_label'),
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
          SizedBox(width: 78, child: _statusWidget(tr, p)),
        ],
      ),
    );
  }

  Widget _statusWidget(String Function(String) tr, ReceiptPersonView p) {
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
            tr('wealth_split_bill_status_debt'),
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
            tr('wealth_split_bill_status_paid'),
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
              label: tr('wealth_split_bill_debt_button'),
              color: AppColors.pink,
              onTap: p.onDebt,
            ),
            const SizedBox(width: 4),
            _pillButton(
              label: tr('wealth_split_bill_paid_button'),
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
