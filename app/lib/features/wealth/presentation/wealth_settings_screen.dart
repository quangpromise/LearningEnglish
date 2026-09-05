import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/vn_bank_model.dart';

/// Man Cai dat Quan ly tai san - hien tai chi co 1 muc: chon cac ngan hang
/// "dang su dung" (trong tong hang chuc ngan hang VietQR) de bank_picker_sheet
/// (dung khi Chi tieu/them so du Vi/Tra no) chi hien nhung ngan hang nguoi
/// dung THAT SU dung, khong phai cuon qua ca danh sach ~50 ngan hang moi lan.
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
            Text(
              ref.tr('wealth_settings_banks_title'),
              style: AppTextStyles.body(size: 15, weight: FontWeight.w800),
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
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: banksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
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
                                  b.shortName.toLowerCase().contains(_query) ||
                                  b.name.toLowerCase().contains(_query),
                            )
                            .toList();
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _bankTile(
                      filtered[i],
                      usedCodes.contains(filtered[i].code),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
