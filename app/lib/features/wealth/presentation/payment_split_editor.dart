import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import 'bank_picker_sheet.dart';

/// 1 phan trong thanh toan tach nhieu hinh thuc (vi du: 200k tien mat +
/// 300k Vietcombank cho cung 1 giao dich) - dung chung cho Chi tieu va Gia
/// han dich vu dinh ky.
class PaymentSplit {
  const PaymentSplit({
    required this.accountType,
    required this.amount,
    this.bankCode,
    this.bankName,
  });

  final String accountType; // 'cash' | 'bank'
  final String? bankCode;
  final String? bankName;
  final double amount;

  PaymentSplit copyWith({double? amount}) => PaymentSplit(
    accountType: accountType,
    bankCode: bankCode,
    bankName: bankName,
    amount: amount ?? this.amount,
  );
}

/// Widget quan ly danh sach [PaymentSplit] - mac dinh 1 dong duy nhat (Tien
/// mat, toan bo so tien) de khong lam phuc tap truong hop pho bien (thanh
/// toan bang 1 hinh thuc); nguoi dung bam "+ them hinh thuc" moi hien UI
/// tach nhieu dong. Bao loi neu tong cac dong khac [totalAmount].
class PaymentSplitEditor extends ConsumerStatefulWidget {
  const PaymentSplitEditor({
    super.key,
    required this.totalAmount,
    required this.onChanged,
  });
  final double totalAmount;
  final ValueChanged<List<PaymentSplit>> onChanged;

  @override
  ConsumerState<PaymentSplitEditor> createState() => _PaymentSplitEditorState();
}

class _PaymentSplitEditorState extends ConsumerState<PaymentSplitEditor> {
  final List<PaymentSplit> _splits = [
    const PaymentSplit(accountType: 'cash', amount: 0),
  ];
  final List<TextEditingController> _controllers = [TextEditingController()];

  @override
  void didUpdateWidget(covariant PaymentSplitEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_splits.length == 1 && oldWidget.totalAmount != widget.totalAmount) {
      _controllers[0].text = widget.totalAmount == 0
          ? ''
          : groupThousands(widget.totalAmount);
      _splits[0] = _splits[0].copyWith(amount: widget.totalAmount);
      _emit();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() => widget.onChanged(List.unmodifiable(_splits));

  double get _allocated => _splits.fold(0, (s, p) => s + p.amount);

  void _addSplit() {
    setState(() {
      _splits.add(const PaymentSplit(accountType: 'cash', amount: 0));
      _controllers.add(TextEditingController());
    });
    _emit();
  }

  void _removeSplit(int i) {
    setState(() {
      _splits.removeAt(i);
      _controllers.removeAt(i).dispose();
    });
    _emit();
  }

  Future<void> _pickMethod(int i) async {
    final choice = await _showMethodChoiceSheet(context);
    if (choice == 'cash') {
      setState(() {
        _splits[i] = PaymentSplit(
          accountType: 'cash',
          amount: _splits[i].amount,
        );
      });
      _emit();
    } else if (choice == 'bank') {
      if (!mounted) return;
      final bank = await showBankPickerSheet(context);
      if (bank == null) return;
      setState(() {
        _splits[i] = PaymentSplit(
          accountType: 'bank',
          bankCode: bank.isOther ? null : bank.code,
          bankName: bank.shortName,
          amount: _splits[i].amount,
        );
      });
      _emit();
    }
  }

  Future<String?> _showMethodChoiceSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF12172E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.money_rounded,
                color: AppColors.wealthAccent,
              ),
              title: Text(
                ref.tr('wallet_section_cash'),
                style: AppTextStyles.body(),
              ),
              onTap: () => Navigator.of(context).pop('cash'),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.wealthAccent,
              ),
              title: Text(
                ref.tr('wealth_pay_by_bank'),
                style: AppTextStyles.body(),
              ),
              onTap: () => Navigator.of(context).pop('bank'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.totalAmount - _allocated;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _splits.length; i++) ...[
          _SplitRow(
            split: _splits[i],
            controller: _controllers[i],
            showRemove: _splits.length > 1,
            onPickMethod: () => _pickMethod(i),
            onAmountChanged: (v) {
              final amount = parseThousandsFormatted(v) ?? 0;
              _splits[i] = _splits[i].copyWith(amount: amount);
              _emit();
            },
            onRemove: () => _removeSplit(i),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            GestureDetector(
              onTap: _addSplit,
              child: Text(
                '+ ${ref.tr('wealth_add_payment_method')}',
                style: AppTextStyles.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.wealthAccent,
                ),
              ),
            ),
            const Spacer(),
            if (remaining.abs() > 0.5)
              Text(
                '${ref.tr('wealth_split_remaining')}: ${remaining.toStringAsFixed(0)}',
                style: AppTextStyles.muted(size: 11)
                    .copyWith(color: AppColors.pink),
              ),
          ],
        ),
      ],
    );
  }
}

class _SplitRow extends ConsumerWidget {
  const _SplitRow({
    required this.split,
    required this.controller,
    required this.showRemove,
    required this.onPickMethod,
    required this.onAmountChanged,
    required this.onRemove,
  });
  final PaymentSplit split;
  final TextEditingController controller;
  final bool showRemove;
  final VoidCallback onPickMethod;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: onPickMethod,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                split.accountType == 'cash'
                    ? ref.tr('wallet_section_cash')
                    : (split.bankName ?? ''),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 12, weight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ThousandsInputFormatter()],
            style: AppTextStyles.body(size: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.glassFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onAmountChanged,
          ),
        ),
        if (showRemove)
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            onPressed: onRemove,
          ),
      ],
    );
  }
}
