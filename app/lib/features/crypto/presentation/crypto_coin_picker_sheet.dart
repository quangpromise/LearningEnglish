import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/crypto_repository.dart';
import 'crypto_providers.dart';

/// Bottom sheet: tim + chon 1 coin tu top 100, roi nhap so luong dang nam
/// giu de them vao danh muc ca nhan.
Future<void> showCryptoCoinPicker(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CoinPickerSheet(),
  );
}

class _CoinPickerSheet extends ConsumerStatefulWidget {
  const _CoinPickerSheet();

  @override
  ConsumerState<_CoinPickerSheet> createState() => _CoinPickerSheetState();
}

class _CoinPickerSheetState extends ConsumerState<_CoinPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(cryptoCurrencyProvider);
    final coins = ref.watch(cryptoTop100Provider(currency));

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
                  ref.tr('crypto_add_coin'),
                  style: AppTextStyles.heading(size: 18),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    hintText: ref.tr('crypto_search_hint'),
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
                  child: coins.when(
                    data: (list) {
                      final filtered = _query.isEmpty
                          ? list
                          : list
                                .where(
                                  (c) =>
                                      c.name.toLowerCase().contains(_query) ||
                                      c.symbol.toLowerCase().contains(_query),
                                )
                                .toList();
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _pickTile(context, filtered[i]),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) =>
                        Center(child: Text(ref.tr('crypto_error'))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickTile(BuildContext context, CryptoCoin coin) {
    return GestureDetector(
      onTap: () => _pickQuantity(context, coin),
      child: GlowBox(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                coin.imageUrl,
                width: 26,
                height: 26,
                errorBuilder: (_, _, _) => Container(
                  width: 26,
                  height: 26,
                  color: AppColors.glassFill,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                  Text(coin.symbol, style: AppTextStyles.muted(size: 11)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.blue),
          ],
        ),
      ),
    );
  }

  Future<void> _pickQuantity(BuildContext context, CryptoCoin coin) async {
    final controller = TextEditingController();
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text(
          '${ref.tr('crypto_quantity_of')} ${coin.symbol}',
          style: AppTextStyles.heading(size: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: AppTextStyles.muted(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(ref.tr('crypto_cancel')),
          ),
          TextButton(
            onPressed: () {
              final q = double.tryParse(controller.text.replaceAll(',', '.'));
              Navigator.of(dialogContext).pop(q);
            },
            child: Text(ref.tr('crypto_confirm_add')),
          ),
        ],
      ),
    );
    if (quantity == null || quantity <= 0) return;
    await ref
        .read(cryptoPortfolioProvider.notifier)
        .addOrUpdate(coin, quantity);
    if (context.mounted) Navigator.of(context).pop();
  }
}
