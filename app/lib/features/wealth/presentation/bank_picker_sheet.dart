import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vn_bank_model.dart';

/// Bottom sheet chon 1 ngan hang VN (co o Tien ngan hang trong Vi + chon
/// hinh thuc thanh toan o Chi tieu/Tra no) - co o tim kiem, logo tung ngan
/// hang (VietQR), va muc "Khac" cho phep tu go ten khong co trong danh sach.
/// Tra ve `null` neu nguoi dung huy.
Future<VnBank?> showBankPickerSheet(BuildContext context) {
  return showModalBottomSheet<VnBank>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BankPickerSheet(),
  );
}

class _BankPickerSheet extends ConsumerStatefulWidget {
  const _BankPickerSheet();

  @override
  ConsumerState<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends ConsumerState<_BankPickerSheet> {
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

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ScreenBackground(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('wallet_pick_bank_title'),
                  style: AppTextStyles.heading(size: 18),
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
                Expanded(
                  child: banksAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) =>
                        Center(child: Text(ref.tr('wallet_load_error'))),
                    data: (banks) {
                      final filtered = _query.isEmpty
                          ? banks
                          : banks
                                .where(
                                  (b) =>
                                      b.isOther ||
                                      b.shortName.toLowerCase().contains(
                                        _query,
                                      ) ||
                                      b.name.toLowerCase().contains(_query),
                                )
                                .toList();
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _bankTile(context, filtered[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bankTile(BuildContext context, VnBank bank) {
    return GestureDetector(
      onTap: () => _onPick(context, bank),
      child: GlowBox(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  if (!bank.isOther)
                    Text(
                      bank.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.muted(size: 11),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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

  Future<void> _onPick(BuildContext context, VnBank bank) async {
    if (!bank.isOther) {
      Navigator.of(context).pop(bank);
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          ref.tr('wallet_pick_bank_other_title'),
          style: AppTextStyles.heading(size: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: ref.tr('wallet_pick_bank_other_hint'),
            hintStyle: AppTextStyles.muted(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(ref.tr('common_confirm')),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (context.mounted) {
      Navigator.of(context).pop(
        VnBank(
          code: kOtherBankCode,
          shortName: name,
          name: name,
          logoUrl: null,
        ),
      );
    }
  }
}
