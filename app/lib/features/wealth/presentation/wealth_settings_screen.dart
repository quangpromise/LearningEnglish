import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_category.dart';
import '../data/wealth_custom_category_model.dart';

/// Man Cai dat Quan ly tai san - gom 2 muc:
/// 1) Danh muc chi tieu - xem cac danh muc co san + them/sua/xoa danh muc
///    TUY CHINH (dung khi chon danh muc luc them Chi tieu, xem
///    add_transaction_sheet.dart).
/// 2) Chon cac ngan hang "dang su dung" (trong tong hang chuc ngan hang
///    VietQR) de bank_picker_sheet chi hien nhung ngan hang nguoi dung THAT
///    SU dung, khong phai cuon qua ca danh sach ~50 ngan hang moi lan.
///
/// Toan bo noi dung nam trong 1 ListView DUY NHAT (thay vi Expanded(ListView)
/// rieng cho ngan hang nhu truoc) de muc Danh muc chi tieu (dai ngan tuy so
/// danh muc tuy chinh nguoi dung da them) khong lam Column bi tran/am khi
/// dat truoc no.
class WealthSettingsScreen extends ConsumerStatefulWidget {
  const WealthSettingsScreen({super.key});

  @override
  ConsumerState<WealthSettingsScreen> createState() =>
      _WealthSettingsScreenState();
}

class _WealthSettingsScreenState extends ConsumerState<WealthSettingsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(vnBanksProvider);
    final usedCodes = ref.watch(usedBankCodesProvider);
    final customCategories =
        ref.watch(wealthCustomCategoriesProvider).valueOrNull ??
        const <WealthCustomCategory>[];

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
                    ref.tr('wealth_settings_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  _categoriesSection(customCategories),
                  const SizedBox(height: 20),
                  Text(
                    ref.tr('wealth_settings_banks_title'),
                    style: AppTextStyles.body(
                      size: 15,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ref.tr('wealth_settings_banks_desc'),
                    style: AppTextStyles.muted(size: 12.5),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: ref.tr('wallet_pick_bank_search_hint'),
                      hintStyle: AppTextStyles.muted(),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  banksAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.wealthAccent,
                        ),
                      ),
                    ),
                    error: (_, _) =>
                        Center(child: Text(ref.tr('wealth_load_error'))),
                    data: (banks) {
                      final real = banks.where((b) => !b.isOther).toList();
                      final filtered = _query.isEmpty
                          ? real
                          : real
                                .where(
                                  (b) =>
                                      b.shortName.toLowerCase().contains(
                                        _query,
                                      ) ||
                                      b.name.toLowerCase().contains(_query),
                                )
                                .toList();
                      return Column(
                        children: [
                          for (final b in filtered)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _bankTile(b, usedCodes.contains(b.code)),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriesSection(List<WealthCustomCategory> customCategories) {
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.tr('wealth_settings_categories_title'),
                  style: AppTextStyles.body(size: 15, weight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                onTap: () => _showCategoryDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.wealthAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.wealthAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ref.tr('wealth_settings_add_category'),
                        style: AppTextStyles.body(
                          size: 12,
                          weight: FontWeight.w700,
                        ).copyWith(color: AppColors.wealthAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('wealth_settings_categories_desc'),
            style: AppTextStyles.muted(size: 12.5),
          ),
          const SizedBox(height: 14),
          Text(
            ref.tr('wealth_settings_categories_builtin'),
            style: AppTextStyles.muted(size: 11, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in WealthExpenseCategory.values) _builtinChip(c),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr('wealth_settings_categories_custom'),
            style: AppTextStyles.muted(size: 11, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (customCategories.isEmpty)
            Text(
              ref.tr('wealth_settings_categories_empty'),
              style: AppTextStyles.muted(size: 12.5),
            )
          else
            Column(
              children: [
                for (final c in customCategories) _customCategoryTile(c),
              ],
            ),
        ],
      ),
    );
  }

  Widget _builtinChip(WealthExpenseCategory c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(c.icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(ref.tr(c.labelKey), style: AppTextStyles.body(size: 12)),
      ],
    ),
  );

  Widget _customCategoryTile(WealthCustomCategory c) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.glassFill,
            shape: BoxShape.circle,
          ),
          child: Icon(c.icon, size: 16, color: AppColors.wealthAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            c.name,
            style: AppTextStyles.body(size: 13, weight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTap: () => _showCategoryDialog(existing: c),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.edit_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _deleteCategory(c),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: AppColors.pink,
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _showCategoryDialog({WealthCustomCategory? existing}) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final nameController = TextEditingController(text: existing?.name ?? '');
    String iconKey = existing?.iconKey ?? kCustomCategoryIcons.keys.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF12172E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            existing == null
                ? ref.tr('wealth_settings_add_category')
                : ref.tr('wealth_settings_edit_category'),
            style: AppTextStyles.heading(size: 16),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    hintText: ref.tr('wealth_settings_category_name_hint'),
                    hintStyle: AppTextStyles.muted(),
                    filled: true,
                    fillColor: AppColors.glassFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in kCustomCategoryIcons.entries)
                      GestureDetector(
                        onTap: () => setDialogState(() => iconKey = entry.key),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconKey == entry.key
                                ? AppColors.wealthAccent
                                : AppColors.glassFill,
                            border: Border.all(
                              color: iconKey == entry.key
                                  ? AppColors.wealthAccent
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: Icon(
                            entry.value,
                            size: 18,
                            color: iconKey == entry.key
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(ref.tr('common_cancel'), style: AppTextStyles.body()),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final repo = ref.read(wealthCustomCategoryRepositoryProvider);
                if (existing == null) {
                  await repo.create(
                    userId: userId,
                    name: name,
                    iconKey: iconKey,
                  );
                } else {
                  await repo.update(
                    userId: userId,
                    id: existing.id,
                    name: name,
                    iconKey: iconKey,
                  );
                }
                ref.invalidate(wealthCustomCategoriesProvider);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: Text(
                ref.tr('wealth_save'),
                style: AppTextStyles.body(weight: FontWeight.w700)
                    .copyWith(color: AppColors.wealthAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(WealthCustomCategory cat) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ref.tr('wealth_settings_delete_category_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: Text(
          ref.tr('wealth_settings_category_delete_confirm'),
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
        .read(wealthCustomCategoryRepositoryProvider)
        .delete(userId, cat.id);
    ref.invalidate(wealthCustomCategoriesProvider);
  }

  Widget _bankTile(VnBank bank, bool selected) {
    return GestureDetector(
      onTap: () => ref.read(usedBankCodesProvider.notifier).toggle(bank.code),
      child: GlowBox(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: selected
            ? Border.all(
                color: AppColors.wealthAccent.withValues(alpha: 0.6),
                width: 1.4,
              )
            : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: bank.logoUrl != null
                  ? Image.network(
                      bank.logoUrl!,
                      width: 36,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _bankIconFallback(),
                    )
                  : _bankIconFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.shortName,
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                  Text(
                    bank.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.wealthAccent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankIconFallback() => Container(
    width: 36,
    height: 26,
    decoration: BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.account_balance_rounded,
      size: 16,
      color: AppColors.textMuted,
    ),
  );
}
