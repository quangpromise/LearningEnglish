import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../../crypto/presentation/crypto_providers.dart';

/// Ket qua chon 1 co phieu tu [showStockPickerSheet] - `assetType` la
/// 'stock_vn' hoac 'stock_intl' (dung lam gia tri cot asset_type cua
/// wealth_holdings). `manualPrice` CHI khac null khi nguoi dung tu them thu
/// cong (khong tim thay trong danh sach) - luu vao manualValue cua holding
/// de dung lam gia hien tai du phong khi khong co nguon gia song (Twelve
/// Data/HOSE) cho ma nay.
class StockPickResult {
  const StockPickResult({
    required this.assetType,
    required this.symbol,
    this.name,
    this.manualPrice,
  });
  final String assetType;
  final String symbol;
  final String? name;
  final double? manualPrice;
}

Future<StockPickResult?> showStockPickerSheet(BuildContext context) {
  return showModalBottomSheet<StockPickResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _StockPickerSheet(),
  );
}

enum _Market { vn, intl }

class _StockPickerSheet extends ConsumerStatefulWidget {
  const _StockPickerSheet();

  @override
  ConsumerState<_StockPickerSheet> createState() => _StockPickerSheetState();
}

class _StockPickerSheetState extends ConsumerState<_StockPickerSheet> {
  _Market _market = _Market.vn;
  final _searchController = TextEditingController();
  String _query = '';
  bool _manualMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  ref.tr('wealth_stock_pick_title'),
                  style: AppTextStyles.heading(size: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MarketChip(
                        label: ref.tr('wealth_watchlist_stocks_vn'),
                        selected: _market == _Market.vn,
                        onTap: () => setState(() {
                          _market = _Market.vn;
                          _manualMode = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MarketChip(
                        label: ref.tr('wealth_watchlist_stocks_intl'),
                        selected: _market == _Market.intl,
                        onTap: () => setState(() {
                          _market = _Market.intl;
                          _manualMode = false;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_manualMode)
                  _ManualEntryForm(
                    assetType: _market == _Market.vn
                        ? 'stock_vn'
                        : 'stock_intl',
                    onCancel: () => setState(() => _manualMode = false),
                  )
                else ...[
                  TextField(
                    controller: _searchController,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: ref.tr('wealth_stock_pick_search_hint'),
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
                        setState(() => _query = v.trim().toUpperCase()),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _market == _Market.vn
                        ? _VnResults(query: _query)
                        : _IntlResults(query: _query),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _manualMode = true),
                    child: Text(
                      '+ ${ref.tr('wealth_stock_pick_manual_add')}',
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.wealthAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VnResults extends ConsumerWidget {
  const _VnResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(stocksVnAllProvider);
    return allAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_load_error'), style: AppTextStyles.muted()),
      ),
      data: (all) {
        final filtered = query.isEmpty
            ? all
            : all
                  .where(
                    (q) =>
                        q.symbol.contains(query) ||
                        (q.name?.toUpperCase().contains(query) ?? false),
                  )
                  .toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              ref.tr('crypto_no_results'),
              style: AppTextStyles.muted(),
            ),
          );
        }
        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final q = filtered[i];
            return _ResultTile(
              symbol: q.symbol,
              name: q.name,
              onTap: () => Navigator.of(context).pop(
                StockPickResult(
                  assetType: 'stock_vn',
                  symbol: q.symbol,
                  name: q.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Danh sach ma quoc te tieu bieu de tim kiem - MUON tu OkxTokenizedStock
/// (danh sach ~80 ma xStocks) chi de lay MA (khong dung gia token cua no) -
/// gia thuc su van luon lay qua Twelve Data (stocksIntlQuotesProvider) sau
/// khi luu, dam bao Portfolio (tien that) khong bao gio hien gia token.
class _IntlResults extends ConsumerWidget {
  const _IntlResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(okxTokenizedStocksProvider);
    return allAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.wealthAccent),
      ),
      error: (_, _) => Center(
        child: Text(ref.tr('wealth_load_error'), style: AppTextStyles.muted()),
      ),
      data: (all) {
        final filtered = query.isEmpty
            ? all
            : all.where((s) => s.symbol.contains(query)).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              ref.tr('crypto_no_results'),
              style: AppTextStyles.muted(),
            ),
          );
        }
        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final s = filtered[i];
            return _ResultTile(
              symbol: s.symbol,
              name: null,
              onTap: () => Navigator.of(
                context,
              ).pop(StockPickResult(assetType: 'stock_intl', symbol: s.symbol)),
            );
          },
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.symbol, this.name, required this.onTap});
  final String symbol;
  final String? name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                  if (name != null)
                    Text(
                      name!,
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
}

/// Nhap thu cong khi khong tim thay trong danh sach - bat buoc go ca gia
/// hien tai vi khong co nguon gia song cho ma tu do, dung lam manualValue.
class _ManualEntryForm extends ConsumerStatefulWidget {
  const _ManualEntryForm({required this.assetType, required this.onCancel});
  final String assetType;
  final VoidCallback onCancel;

  @override
  ConsumerState<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends ConsumerState<_ManualEntryForm> {
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVn = widget.assetType == 'stock_vn';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.tr('wealth_stock_pick_manual_note'),
          style: AppTextStyles.muted(size: 11.5),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _symbolController,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_symbol_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_stock_pick_name_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsInputFormatter()],
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: isVn
                ? ref.tr('wealth_stock_pick_price_hint_vn')
                : ref.tr('wealth_stock_pick_price_hint_intl'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PillButton(
                label: ref.tr('common_cancel'),
                filled: false,
                onTap: widget.onCancel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: ref.tr('wallet_save'),
                accentGradient: AppColors.wealthAccentGradient,
                accentColor: AppColors.wealthAccent,
                onTap: () {
                  final symbol = _symbolController.text.trim().toUpperCase();
                  final price = parseThousandsFormatted(_priceController.text);
                  if (symbol.isEmpty || price == null || price <= 0) return;
                  Navigator.of(context).pop(
                    StockPickResult(
                      assetType: widget.assetType,
                      symbol: symbol,
                      name: _nameController.text.trim().isEmpty
                          ? null
                          : _nameController.text.trim(),
                      manualPrice: price,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MarketChip extends StatelessWidget {
  const _MarketChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.wealthAccentGradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 12.5,
              weight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
