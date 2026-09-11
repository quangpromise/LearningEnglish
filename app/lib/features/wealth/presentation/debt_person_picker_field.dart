import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/wealth_debt_person_model.dart';

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

  /// Bam "x" tren 1 goi y - hoi xac nhan roi AN nguoi do khoi danh sach goi y
  /// (khong xoa lich su no that, xem WealthDebtPersonRepository.hideFromSuggestions).
  Future<void> _confirmRemove(WealthDebtPerson person) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(person.name, style: AppTextStyles.heading(size: 16)),
        content: Text(
          ref.tr('wealth_debt_person_remove_confirm'),
          style: AppTextStyles.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(ref.tr('common_cancel'), style: AppTextStyles.body()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              ref.tr('common_delete'),
              style: AppTextStyles.body().copyWith(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(wealthDebtPersonRepositoryProvider)
        .hideFromSuggestions(userId, person.id);
    ref.invalidate(debtPersonsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(debtPersonsProvider);
    final allPersons = personsAsync.valueOrNull ?? [];
    // Chua go gi thi hien LUON tat ca ten da luu truoc do (chon nhanh, khong
    // bat phai go it nhat 1 chu moi thay goi y) - go roi thi loc theo query.
    final suggestions = _query.isEmpty
        ? allPersons.take(8).toList()
        : allPersons
              .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
              .take(8)
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
                    (person) => GestureDetector(
                      onTap: () {
                        widget.controller.text = person.name;
                        setState(() => _query = '');
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 4,
                          top: 6,
                          bottom: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              person.name,
                              style: AppTextStyles.muted(size: 11),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _confirmRemove(person),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
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
