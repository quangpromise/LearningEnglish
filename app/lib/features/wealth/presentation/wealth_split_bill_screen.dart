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
import 'debt_person_picker_field.dart';
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
  String status = 'pending'; // 'pending' | 'debt' | 'paid'
  String? shareId;

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
    }
    super.dispose();
  }

  double get _meAmount {
    final othersTotal = _people
        .skip(1)
        .fold<double>(0, (s, p) => s + p.enteredAmount);
    return _total - othersTotal;
  }

  List<double> _computeShares(double total, int n) {
    final otherCount = n - 1;
    if (otherCount <= 0) return [total];
    final otherShare = (total / n).ceilToDouble();
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
                p.nameController.text.trim().isNotEmpty && p.enteredAmount > 0,
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
      final (billId, shareIds) = await ref
          .read(wealthSplitBillRepositoryProvider)
          .createBill(
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
                ),
            ],
          );
      for (var i = 0; i < _people.length && i < shareIds.length; i++) {
        _people[i].shareId = shareIds[i];
      }

      ref.invalidate(walletBalanceEntriesProvider);
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

  Future<void> _markDebt(_SplitPersonEntry p) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
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
    ref.invalidate(debtsProvider('owed_to_me'));
    if (p.shareId != null) {
      await ref
          .read(wealthSplitBillRepositoryProvider)
          .updateShareStatus(
            userId,
            p.shareId!,
            status: 'debt',
            debtId: debtId,
          );
    }
    setState(() => p.status = 'debt');
  }

  Future<void> _markPaid(_SplitPersonEntry p) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final source = _source!;
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
            amount: p.enteredAmount,
            note:
                '${p.nameController.text.trim()} - ${ref.tr('wealth_split_bill_title')}',
            occurredAt: DateTime.now(),
            source: 'manual',
          ),
        );
    ref.invalidate(walletBalanceEntriesProvider);
    if (p.shareId != null) {
      await ref
          .read(wealthSplitBillRepositoryProvider)
          .updateShareStatus(userId, p.shareId!, status: 'paid');
    }
    setState(() => p.status = 'paid');
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
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(4),
              child: Image.network(qr.imageUrl!, width: 64, height: 64),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((qr.holderName ?? '').isNotEmpty)
                  Text(
                    qr.holderName!,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                if ((qr.bankName ?? '').isNotEmpty)
                  Text(qr.bankName!, style: AppTextStyles.muted(size: 11.5)),
                if ((qr.accountNumber ?? '').isNotEmpty)
                  Text(
                    qr.accountNumber!,
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocate() {
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQrHeader(),
          const SizedBox(height: 16),
          Text(
            ref.tr('wealth_split_bill_payment_method_label'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sourceChip(
                label: ref.tr('wallet_section_cash'),
                selected: _source?.isCash ?? false,
                onTap: () =>
                    setState(() => _source = const _PaymentSource.cash()),
              ),
              for (final b in banks)
                _sourceChip(
                  label: b.shortName,
                  selected:
                      !(_source?.isCash ?? true) &&
                      _source?.bank?.code == b.code,
                  onTap: () => setState(() => _source = _PaymentSource.bank(b)),
                ),
              _sourceChip(
                label: '+ ${ref.tr('wealth_pay_add_bank')}',
                selected: false,
                onTap: () async {
                  final picked = await showBankPickerSheet(context);
                  if (picked != null) {
                    setState(() => _source = _PaymentSource.bank(picked));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final p in _people) ...[
            _personAllocateRow(p),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
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

  Widget _sourceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
            size: 12,
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
      child: p.isMe
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    ref.tr('wealth_split_bill_me_label'),
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                ),
                Text(
                  formatVnd(_meAmount),
                  style: AppTextStyles.body(weight: FontWeight.w800)
                      .copyWith(color: AppColors.wealthAccent),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: DebtPersonPickerField(controller: p.nameController),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 108,
                  child: TextField(
                    controller: p.amountController,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [ThousandsInputFormatter()],
                    style: AppTextStyles.body(weight: FontWeight.w800),
                    cursorColor: AppColors.wealthAccent,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.glassFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettle() {
    final allDone = _people.skip(1).every((p) => p.status != 'pending');
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
                    onDebt: (p.isMe || p.status != 'pending')
                        ? null
                        : () => _markDebt(p),
                    onPaid: (p.isMe || p.status != 'pending')
                        ? null
                        : () => _markPaid(p),
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
            onTap: allDone ? () => Navigator.of(context).maybePop() : null,
          ),
        ),
      ],
    );
  }
}
