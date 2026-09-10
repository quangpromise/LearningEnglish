import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../../crypto/data/crypto_currency.dart';
import '../../crypto/data/crypto_repository.dart';
import '../../crypto/presentation/crypto_coin_picker_sheet.dart';
import '../../crypto/presentation/crypto_providers.dart';
import '../data/vn_bank_model.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_holding_model.dart';
import '../data/wealth_transaction_model.dart';
import 'add_balance_entry_sheet.dart';
import 'add_transaction_sheet.dart';
import 'bank_picker_sheet.dart';
import 'stock_picker_sheet.dart';

/// Man "Chi/Thu" - gop 4 hanh dong tien Vi vao 1 noi thay vi 1 nut "Chi
/// tieu" duy nhat truoc day: Chi tieu (giong Them Chi tieu), Nap tien (nap
/// vao Tien mat/Ngan hang), Rut tien mat (tru Ngan hang, tu dong cong Tien
/// mat), va Dau tu (tru tien Vi, cong vao 1 khoan dau tu - Crypto/Chung
/// khoan/Vang/Bat dong san).
class WealthPayScreen extends StatefulWidget {
  const WealthPayScreen({super.key});

  @override
  State<WealthPayScreen> createState() => _WealthPayScreenState();
}

class _WealthPayScreenState extends State<WealthPayScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 4,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
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
                      ref.tr('wealth_pay_screen_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Consumer(
              builder: (context, ref, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    gradient: AppColors.wealthAccentGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: [
                    Tab(text: ref.tr('wealth_pay_tab_pay')),
                    Tab(text: ref.tr('wealth_pay_tab_receive')),
                    Tab(text: ref.tr('wealth_pay_tab_withdraw')),
                    Tab(text: ref.tr('wealth_pay_tab_investment')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _PayTab(),
                  _ReceiveTab(),
                  _WithdrawTab(),
                  _InvestmentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayTab extends ConsumerWidget {
  const _PayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payments_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              ref.tr('wealth_pay_pay_desc'),
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(),
            ),
            const SizedBox(height: 20),
            PillButton(
              label: ref.tr('wealth_pay_pay_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              icon: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
              onTap: () => showAddWealthTransactionSheet(
                context,
                ref,
                WealthTransactionType.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lua chon nguon/dich tien - "Tien mat" (tuy chon, [allowCash]) hoac 1
/// ngan hang tu danh sach da co so du (walletTotalsProvider), them chip "+"
/// mo showBankPickerSheet cho ngan hang chua tung dung truoc do.
class _AccountSelection {
  const _AccountSelection.cash() : isCash = true, bank = null;
  const _AccountSelection.bank(VnBank b) : isCash = false, bank = b;
  final bool isCash;
  final VnBank? bank;
}

class _AccountPicker extends ConsumerWidget {
  const _AccountPicker({
    required this.selection,
    required this.onChanged,
    this.allowCash = true,
  });
  final _AccountSelection? selection;
  final ValueChanged<_AccountSelection> onChanged;
  final bool allowCash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(walletTotalsProvider);
    final seen = <String>{};
    final banks = <VnBank>[];
    for (final t in totals) {
      if (t.accountType != 'bank') continue;
      final key = '${t.bankCode}|${t.bankName}';
      if (!seen.add(key)) continue;
      banks.add(
        VnBank(
          code: t.bankCode ?? t.bankName ?? 'bank',
          shortName: t.bankName ?? t.bankCode ?? '?',
          name: t.bankName ?? t.bankCode ?? '?',
          logoUrl: null,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (allowCash)
          _chip(
            label: ref.tr('wallet_section_cash'),
            selected: selection?.isCash ?? false,
            onTap: () => onChanged(const _AccountSelection.cash()),
          ),
        for (final b in banks)
          _chip(
            label: b.shortName,
            selected:
                !(selection?.isCash ?? true) && selection?.bank?.code == b.code,
            onTap: () => onChanged(_AccountSelection.bank(b)),
          ),
        _chip(
          label: '+ ${ref.tr('wealth_pay_add_bank')}',
          selected: false,
          onTap: () async {
            final picked = await showBankPickerSheet(context);
            if (picked != null) onChanged(_AccountSelection.bank(picked));
          },
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? AppColors.wealthAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ReceiveTab extends ConsumerStatefulWidget {
  const _ReceiveTab();
  @override
  ConsumerState<_ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends ConsumerState<_ReceiveTab> {
  _AccountSelection _selection = const _AccountSelection.cash();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.tr('wealth_pay_receive_desc'), style: AppTextStyles.muted()),
          const SizedBox(height: 14),
          Text(
            ref.tr('wealth_pay_choose_source'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          _AccountPicker(
            selection: _selection,
            onChanged: (s) => setState(() => _selection = s),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_pay_receive_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: () => showAddBalanceEntrySheet(
                context,
                ref,
                initialBank: _selection.isCash ? null : _selection.bank,
                initialIsAdd: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawTab extends ConsumerStatefulWidget {
  const _WithdrawTab();
  @override
  ConsumerState<_WithdrawTab> createState() => _WithdrawTabState();
}

class _WithdrawTabState extends ConsumerState<_WithdrawTab> {
  _AccountSelection? _selection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_pay_withdraw_desc'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 14),
          Text(
            ref.tr('wealth_pay_choose_source'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          _AccountPicker(
            selection: _selection,
            allowCash: false,
            onChanged: (s) => setState(() => _selection = s),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_pay_withdraw_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: _selection?.bank == null
                  ? null
                  : () => showAddBalanceEntrySheet(
                      context,
                      ref,
                      initialBank: _selection!.bank,
                      initialIsAdd: false,
                    ),
            ),
          ),
          if (_selection?.bank == null) ...[
            const SizedBox(height: 8),
            Text(
              ref.tr('wealth_pay_withdraw_need_bank'),
              style: AppTextStyles.muted(size: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}

enum _InvAssetType { crypto, stock, gold, realEstate }

class _SelectedStock {
  const _SelectedStock({
    required this.assetType,
    required this.symbol,
    this.name,
    this.price,
  });
  final String assetType; // 'stock_intl' | 'stock_vn'
  final String symbol;
  final String? name;
  final double? price;
}

class _InvestmentTab extends ConsumerStatefulWidget {
  const _InvestmentTab();
  @override
  ConsumerState<_InvestmentTab> createState() => _InvestmentTabState();
}

class _InvestmentTabState extends ConsumerState<_InvestmentTab> {
  _AccountSelection? _source;
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _realEstateNameController = TextEditingController();
  _InvAssetType _assetType = _InvAssetType.crypto;
  CryptoCoin? _selectedCoin;
  _SelectedStock? _selectedStock;
  String? _selectedGoldType; // 'sjc' | 'pnj'
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    _realEstateNameController.dispose();
    super.dispose();
  }

  void _resetAssetSelection() {
    _selectedCoin = null;
    _selectedStock = null;
    _selectedGoldType = null;
  }

  bool get _hasAssetSelected => switch (_assetType) {
    _InvAssetType.crypto => _selectedCoin != null,
    _InvAssetType.stock => _selectedStock != null,
    _InvAssetType.gold => _selectedGoldType != null,
    _InvAssetType.realEstate =>
      _realEstateNameController.text.trim().isNotEmpty,
  };

  Future<void> _confirm() async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final source = _source;
    if (source == null) return;
    final amount = parseThousandsFormatted(_amountController.text);
    if (amount == null || amount <= 0) return;
    final isRealEstate = _assetType == _InvAssetType.realEstate;
    final quantity = isRealEstate
        ? null
        : double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (!isRealEstate && (quantity == null || quantity <= 0)) return;
    if (!_hasAssetSelected) return;

    final needsUsd =
        _assetType == _InvAssetType.crypto ||
        (_assetType == _InvAssetType.stock &&
            _selectedStock!.assetType == 'stock_intl');
    final usdVnd = ref.read(wealthVnAssetsProvider).valueOrNull?.usdVnd;
    if (needsUsd && usdVnd == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ref.tr('wealth_load_error'))));
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final balanceRepo = ref.read(wealthBalanceEntryRepositoryProvider);
      await balanceRepo.addEntry(
        userId,
        WealthBalanceEntry(
          id: '',
          accountType: source.isCash ? 'cash' : 'bank',
          bankCode: source.isCash
              ? null
              : (source.bank!.isOther ? null : source.bank!.code),
          bankName: source.isCash ? null : source.bank!.shortName,
          currency: 'VND',
          amount: -amount,
          occurredAt: DateTime.now(),
          source: 'investment',
        ),
      );

      switch (_assetType) {
        case _InvAssetType.crypto:
          final coin = _selectedCoin!;
          final amountUsd = amount / usdVnd!;
          await ref
              .read(cryptoPortfolioProvider.notifier)
              .buy(
                coinId: coin.id,
                symbol: coin.symbol,
                name: coin.name,
                imageUrl: coin.imageUrl,
                quantity: quantity!,
                priceAtTime: amountUsd / quantity,
              );
        case _InvAssetType.stock:
          final s = _selectedStock!;
          final isIntl = s.assetType == 'stock_intl';
          final priceInAssetCurrency = isIntl
              ? (amount / usdVnd!) / quantity!
              : amount / quantity!;
          final holdings =
              ref.read(wealthHoldingsProvider(s.assetType)).valueOrNull ?? [];
          final existing = holdings.where((h) => h.symbol == s.symbol);
          final holdingRepo = ref.read(wealthHoldingRepositoryProvider);
          if (existing.isNotEmpty) {
            final h = existing.first;
            final oldQty = h.quantity ?? 0;
            final oldCost = h.avgCost ?? 0;
            final newQty = oldQty + quantity;
            final newAvgCost = newQty == 0
                ? 0.0
                : (oldQty * oldCost + quantity * priceInAssetCurrency) / newQty;
            await holdingRepo.updateQuantityAndCost(
              userId,
              h.id,
              quantity: newQty,
              avgCost: newAvgCost,
            );
          } else {
            await holdingRepo.upsertBySymbol(
              userId,
              WealthHolding(
                id: '',
                assetType: s.assetType,
                symbol: s.symbol,
                name: s.name,
                quantity: quantity,
                avgCost: priceInAssetCurrency,
                currency: isIntl ? 'USD' : 'VND',
              ),
            );
          }
          await ref
              .read(wealthInvestmentTransactionRepositoryProvider)
              .record(
                userId: userId,
                assetType: s.assetType,
                action: 'buy',
                symbol: s.symbol,
                quantity: quantity,
                price: priceInAssetCurrency,
                amount: amount,
                currency: 'VND',
              );
          ref.invalidate(wealthHoldingsProvider(s.assetType));
        case _InvAssetType.gold:
          final type = _selectedGoldType!;
          final price = amount / quantity!;
          await ref
              .read(wealthHoldingRepositoryProvider)
              .insertNew(
                userId,
                WealthHolding(
                  id: '',
                  assetType: 'gold',
                  symbol: type,
                  name: type == 'sjc'
                      ? ref.tr('wealth_metal_gold_sjc')
                      : ref.tr('wealth_metal_gold_pnj'),
                  quantity: quantity,
                  avgCost: price,
                  currency: 'VND',
                ),
              );
          await ref
              .read(wealthInvestmentTransactionRepositoryProvider)
              .record(
                userId: userId,
                assetType: 'gold',
                action: 'buy',
                symbol: type,
                quantity: quantity,
                price: price,
                amount: amount,
                currency: 'VND',
              );
          ref.invalidate(wealthHoldingsProvider('gold'));
        case _InvAssetType.realEstate:
          await ref
              .read(wealthHoldingRepositoryProvider)
              .insertNew(
                userId,
                WealthHolding(
                  id: '',
                  assetType: 'real_estate',
                  name: _realEstateNameController.text.trim(),
                  manualValue: amount,
                  currency: 'VND',
                ),
              );
          await ref
              .read(wealthInvestmentTransactionRepositoryProvider)
              .record(
                userId: userId,
                assetType: 'real_estate',
                action: 'buy',
                amount: amount,
                currency: 'VND',
              );
          ref.invalidate(wealthHoldingsProvider('real_estate'));
      }

      ref.invalidate(walletBalanceEntriesProvider);
      if (mounted) {
        setState(() {
          _amountController.clear();
          _quantityController.clear();
          _realEstateNameController.clear();
          _resetAssetSelection();
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ref.tr('wealth_saved'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.tr('wealth_investment_desc'), style: AppTextStyles.muted()),
          const SizedBox(height: 14),
          Text(
            ref.tr('wealth_pay_choose_source'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          _AccountPicker(
            selection: _source,
            onChanged: (s) => setState(() => _source = s),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 16),
          Text(
            ref.tr('wealth_investment_asset_type_label'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _InvAssetType.values)
                GestureDetector(
                  onTap: () => setState(() {
                    _assetType = t;
                    _resetAssetSelection();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: _assetType == t
                          ? AppColors.wealthAccent.withValues(alpha: 0.22)
                          : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _assetType == t
                            ? AppColors.wealthAccent
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      ref.tr(switch (t) {
                        _InvAssetType.crypto =>
                          'wealth_investment_asset_crypto',
                        _InvAssetType.stock => 'wealth_investment_asset_stock',
                        _InvAssetType.gold => 'wealth_investment_asset_gold',
                        _InvAssetType.realEstate =>
                          'wealth_investment_asset_real_estate',
                      }),
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: _assetType == t
                            ? AppColors.wealthAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr('wealth_investment_pick_asset_label'),
            style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
          ),
          const SizedBox(height: 10),
          _buildAssetPicker(),
          if (_assetType != _InvAssetType.realEstate) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.body(),
              cursorColor: AppColors.wealthAccent,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.glassFill,
                hintText: ref.tr('wealth_investment_quantity_hint'),
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_investment_confirm_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              onTap: _saving ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetPicker() {
    switch (_assetType) {
      case _InvAssetType.crypto:
        final watchlist = ref.watch(cryptoWatchlistProvider);
        final liveCoins = ref.watch(liveCoinsProvider(CryptoCurrency.usd));
        final coinById = {for (final c in liveCoins) c.id: c};
        final watchedCoins = watchlist
            .where((k) => !k.startsWith('okx:'))
            .map((id) => coinById[id])
            .whereType<CryptoCoin>()
            .toList();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in watchedCoins)
              _assetChip(
                label:
                    '${c.symbol.toUpperCase()} · \$${c.price.toStringAsFixed(2)}',
                selected: _selectedCoin?.id == c.id,
                onTap: () => setState(() => _selectedCoin = c),
              ),
            if (watchedCoins.isEmpty)
              Text(
                ref.tr('wealth_investment_no_watchlist_crypto'),
                style: AppTextStyles.muted(size: 12.5),
              ),
            _assetChip(
              label: '+ ${ref.tr('wealth_investment_search_add')}',
              selected: false,
              onTap: () async {
                final picked = await showCryptoSearchSheet(context);
                if (picked != null) setState(() => _selectedCoin = picked);
              },
            ),
          ],
        );
      case _InvAssetType.stock:
        final watchlist = ref.watch(assetWatchlistProvider);
        final intlSymbols = watchlist
            .where((k) => k.startsWith('stock:'))
            .map((k) => k.substring('stock:'.length))
            .toList();
        final vnSymbols = watchlist
            .where((k) => k.startsWith('stock_vn:'))
            .map((k) => k.substring('stock_vn:'.length))
            .toList();
        final intlQuotes =
            ref
                .watch(stocksIntlQuotesProvider(intlSymbols.join(',')))
                .valueOrNull ??
            [];
        final vnQuotes =
            ref
                .watch(stocksVnQuotesProvider(vnSymbols.join(',')))
                .valueOrNull ??
            [];
        final intlPriceBySymbol = {
          for (final q in intlQuotes) q.symbol: q.price,
        };
        final vnPriceBySymbol = {for (final q in vnQuotes) q.symbol: q.price};
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in vnSymbols)
              _assetChip(
                label: vnPriceBySymbol[s] == null
                    ? s
                    : '$s · ${vnPriceBySymbol[s]!.toStringAsFixed(0)}đ',
                selected:
                    _selectedStock?.assetType == 'stock_vn' &&
                    _selectedStock?.symbol == s,
                onTap: () => setState(
                  () => _selectedStock = _SelectedStock(
                    assetType: 'stock_vn',
                    symbol: s,
                    price: vnPriceBySymbol[s],
                  ),
                ),
              ),
            for (final s in intlSymbols)
              _assetChip(
                label: intlPriceBySymbol[s] == null
                    ? s
                    : '$s · \$${intlPriceBySymbol[s]!.toStringAsFixed(2)}',
                selected:
                    _selectedStock?.assetType == 'stock_intl' &&
                    _selectedStock?.symbol == s,
                onTap: () => setState(
                  () => _selectedStock = _SelectedStock(
                    assetType: 'stock_intl',
                    symbol: s,
                    price: intlPriceBySymbol[s],
                  ),
                ),
              ),
            if (intlSymbols.isEmpty && vnSymbols.isEmpty)
              Text(
                ref.tr('wealth_investment_no_watchlist_stock'),
                style: AppTextStyles.muted(size: 12.5),
              ),
            _assetChip(
              label: '+ ${ref.tr('wealth_investment_search_add')}',
              selected: false,
              onTap: () async {
                final picked = await showStockPickerSheet(context);
                if (picked != null) {
                  setState(
                    () => _selectedStock = _SelectedStock(
                      assetType: picked.assetType,
                      symbol: picked.symbol,
                      name: picked.name,
                      price: picked.manualPrice,
                    ),
                  );
                }
              },
            ),
          ],
        );
      case _InvAssetType.gold:
        final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _assetChip(
              label: snap?.goldSjcSell == null
                  ? ref.tr('wealth_metal_gold_sjc')
                  : '${ref.tr('wealth_metal_gold_sjc')} · ${snap!.goldSjcSell!.toStringAsFixed(0)}đ',
              selected: _selectedGoldType == 'sjc',
              onTap: () => setState(() => _selectedGoldType = 'sjc'),
            ),
            _assetChip(
              label: snap?.goldPnjSell == null
                  ? ref.tr('wealth_metal_gold_pnj')
                  : '${ref.tr('wealth_metal_gold_pnj')} · ${snap!.goldPnjSell!.toStringAsFixed(0)}đ',
              selected: _selectedGoldType == 'pnj',
              onTap: () => setState(() => _selectedGoldType = 'pnj'),
            ),
          ],
        );
      case _InvAssetType.realEstate:
        return TextField(
          controller: _realEstateNameController,
          style: AppTextStyles.body(),
          cursorColor: AppColors.wealthAccent,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: ref.tr('wealth_investment_realestate_name_hint'),
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        );
    }
  }

  Widget _assetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
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
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? AppColors.wealthAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
