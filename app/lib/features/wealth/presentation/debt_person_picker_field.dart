import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// O nhap ten chu no/nguoi no, co goi y nhung nguoi da tung nhap truoc do
/// (autocomplete) - chon 1 goi y hoac go ten hoan toan moi deu duoc, viec
/// "tim thay thi gop vao lich su nguoi do, khong thi tao moi" xu ly o
/// [WealthDebtPersonRepository.findOrCreate] khi luu, khong phai o day.
class DebtPersonPickerField extends ConsumerStatefulWidget {
  const DebtPersonPickerField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  ConsumerState<DebtPersonPickerField> createState() =>
      _DebtPersonPickerFieldState();
}

class _DebtPersonPickerFieldState extends ConsumerState<DebtPersonPickerField> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(debtPersonsProvider);
    final suggestions = _query.isEmpty
        ? const <String>[]
        : (personsAsync.valueOrNull ?? [])
              .map((p) => p.name)
              .where((n) => n.toLowerCase().contains(_query.toLowerCase()))
              .take(5)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_debt_person_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        if (suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggestions
                  .map(
                    (name) => GestureDetector(
                      onTap: () {
                        widget.controller.text = name;
                        setState(() => _query = '');
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(name, style: AppTextStyles.muted(size: 11)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
