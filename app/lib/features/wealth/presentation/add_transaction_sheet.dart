import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/recurring_service_model.dart';
import '../data/recurring_service_repository.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_category.dart';
import '../data/wealth_custom_category_model.dart';
import '../data/wealth_transaction_model.dart';
import 'payment_split_editor.dart';

/// Bottom sheet them/sua 1 giao dich chi tieu/thu nhap - [type] co dinh theo
/// tab dang mo (Chi tieu hoac Thu nhap), khong cho doi loai trong sheet de
/// UI don gian (giong cach Fitness khong cho doi nhom co khi da vao 1 nhom).
/// Truyen [existing] de mo o CHE DO SUA (cap nhat lai giao dich do thay vi
/// tao moi).
void showAddWealthTransactionSheet(
  BuildContext context,
  WidgetRef ref,
  WealthTransactionType type, {
  WealthTransaction? existing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(sheetContext).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Color(0xFF12172E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: WealthTransactionForm(type: type, existing: existing),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Noi dung form them/sua 1 giao dich - dung lai (embed) o ca bottom sheet
/// ([showAddWealthTransactionSheet], khi sua 1 giao dich cu hoac them Thu
/// nhap) LAN o thang tab "Pay" cua WealthPayScreen (hien inline, khong qua
/// sheet - xem wealth_pay_screen.dart). Khi [onSaved] duoc truyen (truong
/// hop nhung inline), luu xong se CLEAR form de nhap tiep thay vi
/// Navigator.pop() (khong co gi de pop trong ngu canh inline).
class WealthTransactionForm extends ConsumerStatefulWidget {
  const WealthTransactionForm({
    super.key,
    required this.type,
    this.existing,
    this.onSaved,
  });
  final WealthTransactionType type;
  final WealthTransaction? existing;
  final VoidCallback? onSaved;

  @override
  ConsumerState<WealthTransactionForm> createState() =>
      _WealthTransactionFormState();
}

class _WealthTransactionFormState extends ConsumerState<WealthTransactionForm> {
  late final _amountController = TextEditingController(
    text: widget.existing == null
        ? ''
        : groupThousands(widget.existing!.amount),
  );
  late final _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late String _categoryCode =
      widget.existing?.categoryCode ??
      (widget.type == WealthTransactionType.expense
          ? WealthExpenseCategory.other.code
          : WealthIncomeCategory.salary.code);
  bool _saving = false;
  // Chi dung khi type=expense - cho phep tach nhieu hinh thuc thanh toan
  // (vd 1 phan tien mat + 1 phan ngan hang) cho cung 1 giao dich (Phase G).
  // Khi sua 1 giao dich cu, KHONG khoi phuc lai dung cau truc tach nhieu
  // hinh thuc truoc do (wealth_transactions chi luu 1 hinh thuc dai dien) -
  // mac dinh ve 1 dong Tien mat bang dung tong tien cu, nguoi dung tu chinh
  // lai neu can tach.
  late List<PaymentSplit> _splits = _initialSplits;
  late double _amount = widget.existing?.amount ?? 0;

  // Khoi phuc dung hinh thuc thanh toan (cash/bank + ngan hang) da luu tren
  // giao dich cu khi mo sua - truoc day luon mac dinh ve Tien mat, khien man
  // hinh sua hien sai hinh thuc va Save khong hoat dong (so tien khoi tao
  // cua split la 0, khac tong tien that su cua giao dich).
  List<PaymentSplit> get _initialSplits {
    final existing = widget.existing;
    if (existing == null) {
      // Mac dinh NGAN HANG (khong phai Tien mat) neu nguoi dung da co san
      // it nhat 1 tai khoan ngan hang - theo yeu cau nguoi dung, da so thanh
      // toan qua ngan hang/the hon la tien mat. Chua co ngan hang nao thi
      // fallback ve Tien mat nhu truoc.
      final totals = ref.read(walletTotalsProvider);
      for (final t in totals) {
        if (t.accountType == 'bank') {
          return [
            PaymentSplit(
              accountType: 'bank',
              bankCode: t.bankCode,
              bankName: t.bankName,
              amount: 0,
            ),
          ];
        }
      }
      return const [PaymentSplit(accountType: 'cash', amount: 0)];
    }
    return [
      PaymentSplit(
        accountType: existing.paymentAccountType ?? 'cash',
        bankCode: existing.paymentBankCode,
        bankName: existing.paymentBankName,
        amount: existing.amount,
      ),
    ];
  }

  late DateTime _occurredAt = widget.existing?.occurredAt ?? DateTime.now();

  // Chi ap dung khi THEM MOI 1 khoan Chi tieu (khong ap dung luc Sua, va
  // khong ap dung cho Thu nhap) - chon 1 Dich vu dinh ky de khoan chi nay
  // duoc ghi nhan y het nhu bam "Gia han" o man Dich vu dinh ky (co lich su
  // renew + tu cap nhat ngay het han), thay vi tao 1 khoan Chi tieu roi rac
  // khong lien quan gi den dich vu do (nguyen nhan gay lech du lieu da gap
  // truoc day voi Cloud Code/4G Viettel - xem migration 0043 backfill).
  String? _selectedServiceId;

  bool get _isEditing => widget.existing != null;

  // "Pay" (thay vi "Save") CHI khi dang THEM MOI 1 khoan Chi tieu - dung ngu
  // canh hanh dong ("dang thanh toan", khop voi tab "Pay") hon la khi SUA 1
  // giao dich cu (chi cap nhat lai ban ghi, khong "tra tien" lan nua) hoac
  // khi dang o luong Thu nhap (khong phai hanh dong tra tien).
  String get _saveButtonLabel => (!_isEditing && _isExpense)
      ? ref.tr('wealth_pay_action_button')
      : ref.tr('wealth_save');

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(
        () => _amount = parseThousandsFormatted(_amountController.text) ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isExpense => widget.type == WealthTransactionType.expense;

  bool get _splitsValid {
    final sum = _splits.fold<double>(0, (s, p) => s + p.amount);
    return _amount > 0 && (sum - _amount).abs() < 0.5;
  }

  RecurringService? _findService(String id) {
    for (final s
        in ref.read(recurringServicesProvider).valueOrNull ?? const []) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<RenewalPaymentInput> get _renewalPayments => _splits
      .where((s) => s.amount > 0)
      .map(
        (s) => RenewalPaymentInput(
          accountType: s.accountType,
          bankCode: s.bankCode,
          bankName: s.bankName,
          amount: s.amount,
        ),
      )
      .toList();

  /// Da chon 1 Dich vu dinh ky o Wrap chip - ghi khoan chi nay y het nut
  /// "Gia han" (lich su renew + tu cap nhat expiry_date), KHONG di theo
  /// duong Chi tieu thong thuong ben duoi (xem [_save]).
  Future<void> _saveAsServiceRenewal(
    String userId,
    RecurringService service,
  ) async {
    final newExpiry = RecurringService.computeNextExpiry(
      cycleType: service.cycleType,
      from: service.expiryDate,
      cycleYears: service.cycleYears,
    );
    if (newExpiry == null) {
      // 'manual' - khong tu tinh duoc ngay het han moi, khong xay ra tren
      // thuc te vi Wrap chip da loc bo cac dich vu 'manual' (xem build()).
      setState(() => _saving = false);
      return;
    }
    try {
      await ref
          .read(recurringServiceRepositoryProvider)
          .renew(
            userId: userId,
            service: service,
            totalAmount: _amount,
            newExpiryDate: newExpiry,
            occurredAt: _occurredAt,
            payments: _renewalPayments,
          );
      ref.invalidate(recurringServicesProvider);
      ref.invalidate(serviceRenewalsProvider);
      ref.invalidate(walletBalanceEntriesProvider);
      ref.invalidate(wealthTransactionsProvider);
      _onSaveComplete();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Sau khi luu thanh cong: co [widget.onSaved] (dung inline, vd tab Pay)
  /// thi CLEAR form de nhap giao dich tiep theo va goi callback (vd hien
  /// snackbar) thay vi pop - khong co route nao de pop trong ngu canh do.
  /// Khong co onSaved (dung trong bottom sheet) thi giu nguyen hanh vi cu:
  /// dong sheet lai.
  void _onSaveComplete() {
    if (!mounted) return;
    final onSaved = widget.onSaved;
    if (onSaved == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _amountController.clear();
      _noteController.clear();
      _amount = 0;
      _splits = const [PaymentSplit(accountType: 'cash', amount: 0)];
      _selectedServiceId = null;
    });
    onSaved();
  }

  Future<void> _save() async {
    if (_amount <= 0) return;
    if (!_splitsValid) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    if (_isExpense && !_isEditing && _selectedServiceId != null) {
      final service = _findService(_selectedServiceId!);
      if (service != null) {
        await _saveAsServiceRenewal(userId, service);
        return;
      }
    }
    final incomeKind = widget.type == WealthTransactionType.income
        ? (WealthIncomeCategory.fromCode(_categoryCode).isPassive
              ? 'passive'
              : 'active')
        : null;
    // Ghi lai payment_account_type/bank chi khi thanh toan bang DUNG 1 hinh
    // thuc (thong tin tham khao tren wealth_transactions) - khi tach nhieu
    // hinh thuc, thong tin that nam o cac dong wealth_balance_entries rieng.
    final singleSplit = _splits.length == 1 ? _splits.first : null;
    final tx = WealthTransaction(
      id: widget.existing?.id ?? '',
      type: widget.type,
      categoryCode: _categoryCode,
      amount: _amount,
      currency: 'VND',
      occurredAt: _occurredAt,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      incomeKind: incomeKind,
      paymentAccountType: singleSplit?.accountType,
      paymentBankCode: singleSplit?.bankCode,
      paymentBankName: singleSplit?.bankName,
    );
    try {
      final txRepo = ref.read(wealthTransactionRepositoryProvider);
      final String txId;
      if (_isEditing) {
        txId = tx.id;
        await txRepo.updateTransaction(userId, tx);
      } else {
        txId = await txRepo.addTransaction(userId, tx);
      }
      // Thu nhap cung phai cong vao Vi giong het Chi tieu tru vao Vi - truoc
      // day CHI Chi tieu moi tao dong wealth_balance_entries, khien tong Thu
      // nhap tren man Bao cao khong khop voi tien thuc te tang trong Vi (xem
      // migration 0045).
      final repo = ref.read(wealthBalanceEntryRepositoryProvider);
      if (_isEditing) {
        // Sua lai giao dich cu - xoa het bo dong balance_entries CU sinh
        // ra tu no roi chen lai bo MOI theo split vua sua (don gian hon
        // nhieu so voi doi chieu tung dong cu/moi, vi split truoc do
        // khong khoi phuc duoc dung cau truc - xem ghi chu o _splits).
        await repo.deleteBySourceTransaction(userId, txId);
      }
      for (final split in _splits) {
        if (split.amount <= 0) continue;
        await repo.addEntry(
          userId,
          WealthBalanceEntry(
            id: '',
            accountType: split.accountType,
            bankCode: split.bankCode,
            bankName: split.bankName,
            currency: 'VND',
            amount: _isExpense ? -split.amount : split.amount,
            note: tx.note,
            occurredAt: tx.occurredAt,
            source: _isExpense ? 'expense' : 'income',
            sourceTransactionId: txId,
          ),
        );
      }
      ref.invalidate(walletBalanceEntriesProvider);
      ref.invalidate(wealthTransactionsProvider);
      _onSaveComplete();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == WealthTransactionType.expense;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditing
              ? ref.tr('wealth_edit_transaction')
              : ref.tr('wealth_add_transaction'),
          style: AppTextStyles.heading(size: 16),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: isExpense
              ? [
                  for (final c in WealthExpenseCategory.values)
                    _CategoryChip(
                      icon: c.icon,
                      label: ref.tr(c.labelKey),
                      selected: _categoryCode == c.code,
                      onTap: () => setState(() => _categoryCode = c.code),
                    ),
                  for (final c
                      in ref
                              .watch(wealthCustomCategoriesProvider)
                              .valueOrNull ??
                          const <WealthCustomCategory>[])
                    _CategoryChip(
                      icon: c.icon,
                      label: c.name,
                      selected: _categoryCode == c.code,
                      onTap: () => setState(() => _categoryCode = c.code),
                    ),
                ]
              : [
                  for (final c in WealthIncomeCategory.values)
                    _CategoryChip(
                      icon: c.icon,
                      label: ref.tr(c.labelKey),
                      selected: _categoryCode == c.code,
                      onTap: () => setState(() => _categoryCode = c.code),
                    ),
                ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsInputFormatter()],
          style: AppTextStyles.body(),
          cursorColor: AppColors.wealthAccent,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_amount_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _noteController,
          style: AppTextStyles.body(),
          cursorColor: AppColors.wealthAccent,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_note_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          ref.tr(isExpense ? 'wealth_pay_by' : 'wealth_receive_by'),
          style: AppTextStyles.muted(size: 11),
        ),
        const SizedBox(height: 6),
        PaymentSplitEditor(
          totalAmount: _amount,
          initialSplits: _initialSplits,
          onChanged: (splits) => setState(() => _splits = splits),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  '${formatDateMdy(_occurredAt)} '
                  '${_occurredAt.hour.toString().padLeft(2, '0')}:'
                  '${_occurredAt.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.body(size: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: _saveButtonLabel,
            accentGradient: AppColors.wealthAccentGradient,
            accentColor: AppColors.wealthAccent,
            onTap: _saving || !_splitsValid ? null : _save,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? AppColors.wealthAccent : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: selected
                    ? AppColors.wealthAccent
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
