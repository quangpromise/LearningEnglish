import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_category.dart';
import '../data/wealth_transaction_model.dart';
import 'bank_picker_sheet.dart';
import 'wealth_qr_screen.dart';
import 'wealth_split_bill_history_screen.dart';
import 'wealth_split_bill_receipt.dart';

/// Man Chia tien bill - nhap tong tien + so nguoi, tu dong goi y chia deu
/// (lam tron LEN cho nhung nguoi con lai, "Toi" nhan phan con lai) nhung SO
/// TIEN TUNG NGUOI (tru Toi) co the sua tay tuy y (vd 1 nguoi goi them mon)
/// - "Toi" luon tu dong nhan PHAN CON LAI = tong - tong cac nguoi khac, cap
/// nhat ngay khi sua bat ky o nao. Hien QR + thong tin nhan tien o dau man,
/// Pay TRU THANG tong tien khoi Cash/Bank da chon (giong 1 khoan Chi tieu),
/// LUU lai thanh 1 "hoa don" trong lich su (xem wealth_split_bill_history_
/// screen.dart), roi hien NGAY hoa don do (SplitBillReceiptCard) de moi
/// nguoi (tru Toi) chon "Ghi no" (tao khoan no owed_to_me) hoac "Da tra"
/// (cong thang tien ho vao lai Cash/Bank) - trang thai luu thang vao DB nen
/// co the quay lai xu ly tiep tu man Lich su neu chua xong het.
class WealthSplitBillScreen extends ConsumerStatefulWidget {
  const WealthSplitBillScreen({super.key});

  @override
  ConsumerState<WealthSplitBillScreen> createState() =>
      _WealthSplitBillScreenState();
}

enum _SplitPhase { setup, allocate, settle }

class _SplitPersonEntry {
  _SplitPersonEntry({this.isMe = false, double initialAmount = 0})
    : amountController = TextEditingController(
        text: isMe ? '' : groupThousands(initialAmount),
      );
  final bool isMe;
  final TextEditingController amountController;
  final nameController = TextEditingController();
  // RawAutocomplete BAT BUOC di kem 1 FocusNode ON DINH voi
  // textEditingController da truyen (assert trong Flutter) - phai giu day,
  // KHONG tao moi trong build(), neu khong dropdown goi y se mat focus/loi.
  final nameFocusNode = FocusNode();
  // Chon SAN ngay luc phan bo (truoc khi bam Pay) - khong con trang thai
  // "cho xu ly" rieng nua, xem ghi chu o WealthSplitBillRepository.createBill.
  String status = 'debt'; // 'debt' | 'paid' (khong dung cho "Toi")
  String? shareId;
  // CHI can khi status=='paid' - moi nguoi tu chon rieng tien ho tra vao
  // Cash hay Bank nao (khac nhau giua tung nguoi, KHONG dung chung 1 "Pay
  // with" cho ca man nhu truoc) - hien o ngay duoi nut "Paid" khi duoc chon.
  _PaymentSource? paidSource;

  double get enteredAmount =>
      parseThousandsFormatted(amountController.text) ?? 0;
}

class _PaymentSource {
  const _PaymentSource.cash() : isCash = true, bank = null;
  const _PaymentSource.bank(VnBank b) : isCash = false, bank = b;
  final bool isCash;
  final VnBank? bank;
}

class _WealthSplitBillScreenState extends ConsumerState<WealthSplitBillScreen> {
  _SplitPhase _phase = _SplitPhase.setup;
  final _totalController = TextEditingController();
  final _countController = TextEditingController();
  List<_SplitPersonEntry> _people = [];
  _PaymentSource? _source;
  double _total = 0;
  bool _saving = false;

  @override
  void dispose() {
    _totalController.dispose();
    _countController.dispose();
    for (final p in _people) {
      p.amountController.dispose();
      p.nameController.dispose();
      p.nameFocusNode.dispose();
    }
    super.dispose();
  }

  double get _meAmount {
    final othersTotal = _people
        .skip(1)
        .fold<double>(0, (s, p) => s + p.enteredAmount);
    return _total - othersTotal;
  }

  // Lam tron LEN toi boi so 1,000d (thay vi tron len 1d nhu truoc) cho phan
  // goi y cua tung nguoi khac - de tra/chuyen khoan (vd 329,000d thay vi
  // 328,572d). "Toi" luon nhan PHAN CON LAI (tong - tong nguoi khac * so
  // nguoi) de tong CHUNG khop tuyet doi voi tong bill nhap ban dau.
  static const _roundUnit = 1000.0;

  List<double> _computeShares(double total, int n) {
    final otherCount = n - 1;
    if (otherCount <= 0) return [total];
    var otherShare = (total / n / _roundUnit).ceilToDouble() * _roundUnit;
    // Bill qua nho so voi so nguoi khien tron len 1,000d lam Me con lai <= 0
    // - fallback ve tron toi thieu (1d) nhu truoc de Me luon duong.
    if (otherShare * otherCount >= total) {
      otherShare = (total / n).ceilToDouble();
    }
    final meShare = total - otherShare * otherCount;
    return [meShare, ...List.filled(otherCount, otherShare)];
  }

  void _continue() {
    final total = parseThousandsFormatted(_totalController.text);
    final count = int.tryParse(_countController.text.trim());
    if (total == null || total <= 0 || count == null || count < 2) return;
    final shares = _computeShares(total, count);
    setState(() {
      _total = total;
      _people = [
        _SplitPersonEntry(isMe: true),
        for (var i = 1; i < shares.length; i++)
          _SplitPersonEntry(initialAmount: shares[i]),
      ];
      _phase = _SplitPhase.allocate;
    });
  }

  bool get _canPay =>
      _source != null &&
      _people
          .skip(1)
          .every(
            (p) =>
                p.nameController.text.trim().isNotEmpty &&
                p.enteredAmount > 0 &&
                (p.status != 'paid' || p.paidSource != null),
          );

  Future<void> _confirmPay() async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ref.tr('wealth_split_bill_confirm_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('wealth_split_bill_confirm_desc'),
              style: AppTextStyles.body(size: 13),
            ),
            const SizedBox(height: 10),
            Text(formatVnd(_total), style: AppTextStyles.heading(size: 20)),
            const SizedBox(height: 4),
            Text(
              _source!.isCash
                  ? ref.tr('wallet_section_cash')
                  : _source!.bank!.shortName,
              style: AppTextStyles.muted(size: 12.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(ref.tr('common_cancel'), style: AppTextStyles.body()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              ref.tr('common_confirm'),
              style: AppTextStyles.body(weight: FontWeight.w700)
                  .copyWith(color: AppColors.wealthAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final source = _source!;
      final tx = WealthTransaction(
        id: '',
        type: WealthTransactionType.expense,
        categoryCode: WealthExpenseCategory.other.code,
        amount: _total,
        currency: 'VND',
        occurredAt: DateTime.now(),
        note: ref.tr('wealth_split_bill_title'),
        paymentAccountType: source.isCash ? 'cash' : 'bank',
        paymentBankCode: source.isCash
            ? null
            : (source.bank!.isOther ? null : source.bank!.code),
        paymentBankName: source.isCash ? null : source.bank!.shortName,
      );
      final txId = await ref
          .read(wealthTransactionRepositoryProvider)
          .addTransaction(userId, tx);
      await ref
          .read(wealthBalanceEntryRepositoryProvider)
          .addEntry(
            userId,
            WealthBalanceEntry(
              id: '',
              accountType: source.isCash ? 'cash' : 'bank',
              bankCode: source.isCash
                  ? null
                  : (source.bank!.isOther ? null : source.bank!.code),
              bankName: source.isCash ? null : source.bank!.shortName,
              currency: 'VND',
              amount: -_total,
              note: tx.note,
              occurredAt: tx.occurredAt,
              source: 'expense',
              sourceTransactionId: txId,
            ),
          );

      final meAmount = _meAmount;

      // Tung nguoi (tru "Toi") da CHON SAN Ghi no/Da tra ngay luc phan bo -
      // thuc hien hanh dong tuong ung NGAY tai day (mot lan cung voi Pay,
      // khong con buoc rieng sau do nua): "Da tra" cong thang tien ho vao
      // lai Cash/Bank (coi nhu ho dua tien mat ngay tai cho), "Ghi no" tao 1
      // khoan owed_to_me. debtId thu duoc de lien ket lai voi dong share
      // sau khi tao bill (xem updateShareStatus ben duoi).
      final debtIdByIndex = <int, String>{};
      for (var i = 0; i < _people.length; i++) {
        final p = _people[i];
        if (p.isMe) continue;
        if (p.status == 'paid') {
          final paidSource = p.paidSource!;
          await ref
              .read(wealthBalanceEntryRepositoryProvider)
              .addEntry(
                userId,
                WealthBalanceEntry(
                  id: '',
                  accountType: paidSource.isCash ? 'cash' : 'bank',
                  bankCode: paidSource.isCash
                      ? null
                      : (paidSource.bank!.isOther
                            ? null
                            : paidSource.bank!.code),
                  bankName: paidSource.isCash
                      ? null
                      : paidSource.bank!.shortName,
                  currency: 'VND',
                  amount: p.enteredAmount,
                  note:
                      '${p.nameController.text.trim()} - ${ref.tr('wealth_split_bill_title')}',
                  occurredAt: DateTime.now(),
                  source: 'manual',
                ),
              );
        } else {
          final name = p.nameController.text.trim();
          final person = await ref
              .read(wealthDebtPersonRepositoryProvider)
              .findOrCreate(userId, name);
          final debtId = await ref
              .read(wealthDebtRepositoryProvider)
              .create(
                userId: userId,
                personId: person.id,
                direction: 'owed_to_me',
                amount: p.enteredAmount,
                currency: 'VND',
                occurredAt: DateTime.now(),
                note: ref.tr('wealth_split_bill_title'),
              );
          debtIdByIndex[i] = debtId;
        }
      }
      ref.invalidate(walletBalanceEntriesProvider);
      ref.invalidate(debtsProvider('owed_to_me'));

      final billRepo = ref.read(wealthSplitBillRepositoryProvider);
      final (billId, shareIds) = await billRepo.createBill(
        userId: userId,
        totalAmount: _total,
        currency: 'VND',
        paymentAccountType: source.isCash ? 'cash' : 'bank',
        paymentBankCode: source.isCash
            ? null
            : (source.bank!.isOther ? null : source.bank!.code),
        paymentBankName: source.isCash ? null : source.bank!.shortName,
        transactionId: txId,
        occurredAt: tx.occurredAt,
        shares: [
          for (final p in _people)
            (
              personName: p.isMe
                  ? ref.tr('wealth_split_bill_me_label')
                  : p.nameController.text.trim(),
              isMe: p.isMe,
              amount: p.isMe ? meAmount : p.enteredAmount,
              status: p.status,
            ),
        ],
      );
      for (var i = 0; i < _people.length && i < shareIds.length; i++) {
        _people[i].shareId = shareIds[i];
        final debtId = debtIdByIndex[i];
        if (debtId != null) {
          await billRepo.updateShareStatus(
            userId,
            shareIds[i],
            status: 'debt',
            debtId: debtId,
          );
        }
      }

      ref.invalidate(wealthTransactionsProvider);
      ref.invalidate(wealthSplitBillsProvider);
      if (mounted) {
        setState(() => _phase = _SplitPhase.settle);
      }
      // billId khong can giu lai o day - da luu vao DB, xem lai qua
      // wealth_split_bill_history_screen.dart bang wealthSplitBillsProvider.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('wealth_split_bill_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                GestureDetector(
                  onTap: () => openAppPopup(
                    context,
                    const WealthSplitBillHistoryScreen(),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: switch (_phase) {
                _SplitPhase.setup => _buildSetup(),
                _SplitPhase.allocate => _buildAllocate(),
                _SplitPhase.settle => _buildSettle(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _totalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ThousandsInputFormatter()],
            style: AppTextStyles.body(),
            cursorColor: AppColors.wealthAccent,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.glassFill,
              hintText: ref.tr('wealth_split_bill_total_hint'),
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.body(),
            cursorColor: AppColors.wealthAccent,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.glassFill,
              hintText: ref.tr('wealth_split_bill_people_count_hint'),
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_split_bill_continue'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: _continue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrHeader() {
    final qr = ref.watch(wealthPaymentQrProvider).valueOrNull;
    if (qr == null || !qr.hasImage) {
      return GestureDetector(
        onTap: () => openAppPopup(context, const WealthQrScreen()),
        child: GlowBox(
          borderRadius: 16,
          child: Text(
            ref.tr('wealth_split_bill_no_qr_note'),
            style: AppTextStyles.muted(size: 12),
          ),
        ),
      );
    }
    // QR to, dat giua, NAM TREN thong tin tai khoan (thay vi nho + nam ben
    // canh nhu truoc) - theo yeu cau nguoi dung de de quet hon.
    // QUAN TRONG: Column mac dinh CO RUT LAI vua khop chieu rong con lon
    // nhat (~150px cua QR) neu khong dung crossAxisAlignment.stretch - luc
    // do the QR bi dat sang trai trong Column cha (crossAxisAlignment.start
    // o _buildAllocate) thay vi can giua toan bo chieu rong man hinh nhu
    // yeu cau ("can deu 2 ben"). stretch ep Column rong het co GlowBox, roi
    // Center/textAlign lo can giua tung phan tu ben trong.
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6),
                child: Image.network(qr.imageUrl!, width: 104, height: 104),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if ((qr.holderName ?? '').isNotEmpty)
            Text(
              qr.holderName!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(weight: FontWeight.w800, size: 12.5),
            ),
          if ((qr.bankName ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              qr.bankName!,
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(size: 11),
            ),
          ],
          if ((qr.accountNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              qr.accountNumber!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllocate() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQrHeader(),
          const SizedBox(height: 10),
          for (final p in _people) ...[
            _personAllocateRow(p),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_split_bill_pay_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: (_canPay && !_saving) ? _confirmPay : null,
            ),
          ),
          if (!_canPay) ...[
            const SizedBox(height: 8),
            Text(
              ref.tr('wealth_split_bill_name_missing'),
              style: AppTextStyles.muted(size: 11.5),
            ),
          ],
        ],
      ),
    );
  }

  /// Hang chip Tien mat/Ngan hang/+Ngan hang khac - dung CHUNG cho "Toi"
  /// (nguon tru tong tien bill) VA cho tung nguoi rieng khi ho chon "Da tra"
  /// (nguon nhan lai tien cua NGUOI DO, doc lap voi cac nguoi khac) - thay
  /// the 1 khoi "Pay with" chung duy nhat truoc day.
  Widget _sourceChipsRow(
    _PaymentSource? selected,
    ValueChanged<_PaymentSource> onSelect,
  ) {
    final totals = ref.watch(walletTotalsProvider);
    final seen = <String>{};
    final banks = <VnBank>[];
    for (final t in totals) {
      if (t.accountType != 'bank') continue;
      final key = '${t.bankCode}|${t.bankName}';
      if (!seen.add(key)) continue;
      banks.add(
        VnBank(
          code: t.bankCode ?? t.bankName ?? 'bank',
          shortName: t.bankName ?? t.bankCode ?? '?',
          name: t.bankName ?? t.bankCode ?? '?',
          logoUrl: null,
        ),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _sourceChip(
          label: ref.tr('wallet_section_cash'),
          selected: selected?.isCash ?? false,
          onTap: () => onSelect(const _PaymentSource.cash()),
        ),
        for (final b in banks)
          _sourceChip(
            label: b.shortName,
            selected:
                !(selected?.isCash ?? true) && selected?.bank?.code == b.code,
            onTap: () => onSelect(_PaymentSource.bank(b)),
          ),
        _sourceChip(
          label: '+ ${ref.tr('wealth_pay_add_bank')}',
          selected: false,
          onTap: () async {
            final picked = await showBankPickerSheet(context);
            if (picked != null) onSelect(_PaymentSource.bank(picked));
          },
        ),
      ],
    );
  }

  Widget _sourceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 11,
            weight: FontWeight.w700,
            color: selected ? AppColors.wealthAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _personAllocateRow(_SplitPersonEntry p) {
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: p.isMe
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ref.tr('wealth_split_bill_me_label'),
                        style: AppTextStyles.body(
                          size: 13,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatVnd(_meAmount),
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w800,
                      ).copyWith(color: AppColors.wealthAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ref.tr('wealth_split_bill_payment_method_label'),
                  style: AppTextStyles.muted(size: 10),
                ),
                const SizedBox(height: 4),
                _sourceChipsRow(_source, (s) => setState(() => _source = s)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // O ten dang DROPDOWN (RawAutocomplete) - CHI hien danh sach
                // goi y trong 1 lop noi (overlay) khi dang go/focus, thay vi
                // luon hien san 1 Wrap day het cac ten cu ben duoi nhu
                // DebtPersonPickerField (nguyen nhan khien moi dong nguoi
                // chiem qua nhieu chieu cao, khong the xem QR + tat ca dong
                // trong 1 man hinh nhu nguoi dung yeu cau).
                _PersonNameDropdownField(
                  controller: p.nameController,
                  focusNode: p.nameFocusNode,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: TextField(
                        controller: p.amountController,
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [ThousandsInputFormatter()],
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w800,
                        ),
                        cursorColor: AppColors.wealthAccent,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.glassFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _statusToggleChip(
                        label: ref.tr('wealth_split_bill_debt_button'),
                        color: AppColors.pink,
                        selected: p.status == 'debt',
                        onTap: () => setState(() => p.status = 'debt'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _statusToggleChip(
                        label: ref.tr('wealth_split_bill_paid_button'),
                        color: AppColors.teal,
                        selected: p.status == 'paid',
                        onTap: () => setState(() => p.status = 'paid'),
                      ),
                    ),
                  ],
                ),
                // Chi hien khi bam "Paid" - moi nguoi tu chon rieng tien ho
                // tra vao Cash hay Bank nao cua minh (doc lap voi cac nguoi
                // khac va voi nguon cua "Toi" o tren).
                if (p.status == 'paid') ...[
                  const SizedBox(height: 6),
                  _sourceChipsRow(
                    p.paidSource,
                    (s) => setState(() => p.paidSource = s),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _statusToggleChip({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 11,
            weight: FontWeight.w800,
          ).copyWith(color: selected ? color : AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSettle() {
    // Trang thai Ghi no/Da tra da CHON SAN va thuc hien xong ngay luc bam
    // Pay (xem _confirmPay) - man hinh nay chi con hien lai "hoa don" ket
    // qua, khong con cho phep sua nua nen onDebt/onPaid luon null.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SplitBillReceiptCard(
              totalAmount: _total,
              paymentLabel: _source!.isCash
                  ? ref.tr('wallet_section_cash')
                  : _source!.bank!.shortName,
              occurredAt: DateTime.now(),
              qr: ref.watch(wealthPaymentQrProvider).valueOrNull,
              people: [
                for (final p in _people)
                  ReceiptPersonView(
                    name: p.nameController.text.trim(),
                    amount: p.isMe ? _meAmount : p.enteredAmount,
                    isMe: p.isMe,
                    status: p.status,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: ref.tr('wealth_split_bill_done_button'),
            accentGradient: AppColors.wealthAccentGradient,
            accentColor: AppColors.wealthAccent,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}

/// O nhap ten "Creditor/debtor" dang DROPDOWN - dung RawAutocomplete de danh
/// sach goi y (ten da tung nhap No truoc do, tu debtPersonsProvider) chi
/// hien trong 1 lop noi (overlay) NGAY DUOI o nhap khi dang go/focus, roi tu
/// dong bien mat khi chon xong/bo focus - KHONG chiem cho co dinh trong bo
/// cuc nhu Wrap luon-hien-san cua DebtPersonPickerField (danh cho cac man
/// khac, van giu nguyen o do).
class _PersonNameDropdownField extends ConsumerWidget {
  const _PersonNameDropdownField({
    required this.controller,
    required this.focusNode,
  });
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNames = (ref.watch(debtPersonsProvider).valueOrNull ?? [])
        .map((p) => p.name)
        .toList();
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        final source = query.isEmpty
            ? allNames
            : allNames.where((n) => n.toLowerCase().contains(query));
        return source.take(6);
      },
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          style: AppTextStyles.body(size: 12),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.glassFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            hintText: ref.tr('wealth_debt_person_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        // TextFieldTapRegion: KHONG co no thi tap vao item duoi day bi tinh
        // la "tap ra ngoai" o nhap -> Flutter tu unfocus + xoa overlay nay
        // NGAY LAP TUC (truoc khi InkWell kip nhan onTap), khien danh sach
        // hien ra nhung bam ten nao cung khong chon duoc.
        return TextFieldTapRegion(
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: const Color(0xFF1B2242),
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 176,
                  minWidth: 160,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final name = options.elementAt(i);
                    return InkWell(
                      onTap: () => onSelected(name),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(name, style: AppTextStyles.body(size: 13)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
