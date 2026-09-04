import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_category.dart';
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
    builder: (_) => _AddTransactionSheet(type: type, existing: existing),
  );
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet({required this.type, this.existing});
  final WealthTransactionType type;
  final WealthTransaction? existing;

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
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
  List<PaymentSplit> _splits = const [
    PaymentSplit(accountType: 'cash', amount: 0),
  ];
  late double _amount = widget.existing?.amount ?? 0;
  late DateTime _occurredAt = widget.existing?.occurredAt ?? DateTime.now();

  bool get _isEditing => widget.existing != null;

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
    if (!_isExpense) return true;
    final sum = _splits.fold<double>(0, (s, p) => s + p.amount);
    return _amount > 0 && (sum - _amount).abs() < 0.5;
  }

  Future<void> _save() async {
    if (_amount <= 0) return;
    if (_isExpense && !_splitsValid) return;
    setState(() => _saving = true);
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    final incomeKind = widget.type == WealthTransactionType.income
        ? (WealthIncomeCategory.fromCode(_categoryCode).isPassive
              ? 'passive'
              : 'active')
        : null;
    // Ghi lai payment_account_type/bank chi khi thanh toan bang DUNG 1 hinh
    // thuc (thong tin tham khao tren wealth_transactions) - khi tach nhieu
    // hinh thuc, thong tin that nam o cac dong wealth_balance_entries rieng.
    final singleSplit = _isExpense && _splits.length == 1
        ? _splits.first
        : null;
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
      if (_isExpense) {
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
              amount: -split.amount,
              note: tx.note,
              occurredAt: tx.occurredAt,
              source: 'expense',
              sourceTransactionId: txId,
            ),
          );
        }
        ref.invalidate(walletBalanceEntriesProvider);
      }
      ref.invalidate(wealthTransactionsProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == WealthTransactionType.expense;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF12172E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
              if (isExpense) ...[
                const SizedBox(height: 10),
                Text(
                  ref.tr('wealth_pay_by'),
                  style: AppTextStyles.muted(size: 11),
                ),
                const SizedBox(height: 6),
                PaymentSplitEditor(
                  totalAmount: _amount,
                  onChanged: (splits) => _splits = splits,
                ),
              ],
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
                        '${_occurredAt.day.toString().padLeft(2, '0')}/'
                        '${_occurredAt.month.toString().padLeft(2, '0')}/'
                        '${_occurredAt.year} '
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
                  label: ref.tr('wealth_save'),
                  accentGradient: AppColors.wealthAccentGradient,
                  accentColor: AppColors.wealthAccent,
                  onTap: _saving || !_splitsValid ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
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
