import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/app_providers.dart';
import '../data/crypto_currency.dart';
import '../data/crypto_portfolio_repository.dart';
import '../data/crypto_repository.dart';
import '../data/crypto_transaction_repository.dart';
import '../data/crypto_watchlist_repository.dart';
import '../data/okx_service.dart';

final cryptoCurrencyProvider = StateProvider<CryptoCurrency>(
  (ref) => CryptoCurrency.usd,
);

final cryptoTop100Provider = FutureProvider.autoDispose
    .family<List<CryptoCoin>, CryptoCurrency>(
      (ref, currency) => CryptoRepository.fetchTop100(currency: currency),
    );

/// Ky hieu (vd "BTC", "PI") dang co cap USDT dang giao dich tren OKX - dung
/// de biet coin nao theo doi duoc gia real-time qua WebSocket, coin nao
/// phai fallback ve gia CoinGecko (fetch dinh ky, khong phai real-time).
final okxSymbolsProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => OkxService.fetchUsdtSymbols(),
);

/// Toan bo gia hien tai tren OKX (khong chi top 100 von hoa) - dung de mo
/// rong tim kiem sang coin ngoai bang xep hang chinh. Khong autoDispose vi
/// danh sach nay lon (~vai nghin cap), giu lai giua cac lan mo/dong tab
/// Market de khong phai tai lai moi lan go tim kiem.
final okxAllTickersProvider = FutureProvider<List<OkxTickerRow>>(
  (ref) => OkxService.fetchAllUsdtTickers(),
);

/// Toan bo "co phieu tokenized" (xStocks) tren OKX, da sap theo thanh khoan
/// 24h giam dan - dung cho Market > Chung khoan > Quoc te. Khong autoDispose
/// giong okxAllTickersProvider (danh sach hang tram dong, giu lai giua cac
/// lan mo/dong tab).
final okxTokenizedStocksProvider = FutureProvider<List<OkxTokenizedStock>>(
  (ref) => OkxService.fetchTokenizedStocks(),
);

/// Lich su nen 1 ky hieu cho man chi tiet coin - family theo (symbol, bar)
/// noi bang dau gach doc de dung String lam key (gion voi cac family khac
/// trong file nay).
final okxCandlesProvider = FutureProvider.autoDispose
    .family<List<OkxCandle>, String>((ref, key) {
      final parts = key.split('|');
      return OkxService.fetchCandles(symbol: parts[0], bar: parts[1]);
    });

/// `symbolsKey` la danh sach ky hieu da sap xep, noi bang dau phay - dung
/// String thay vi List lam key family vi List khong co gia tri == theo noi
/// dung (Dart so sanh List theo identity), se khien family tao provider moi
/// moi lan build dai gia tri.
final okxTickerProvider = StreamProvider.autoDispose
    .family<Map<String, OkxTicker>, String>((ref, symbolsKey) {
      if (symbolsKey.isEmpty) return const Stream.empty();
      final service = OkxService();
      ref.onDispose(service.dispose);
      return service.watch(symbolsKey.split(','));
    });

/// Danh sach coin da "ghep" gia real-time tu OKX (khi co) len tren du lieu
/// nen tu CoinGecko (rank/ten/anh/von hoa/luong luu hanh khong doi nhanh).
/// Chi ap dung khi hien thi bang USD, vi gia OKX quy doi theo USDT (~USD);
/// khi chon VND van dung nguyen gia CoinGecko (da fetch truc tiep theo VND).
final liveCoinsProvider = Provider.autoDispose
    .family<List<CryptoCoin>, CryptoCurrency>((ref, currency) {
      final coins = ref.watch(cryptoTop100Provider(currency)).valueOrNull;
      if (coins == null) return const [];
      if (currency != CryptoCurrency.usd) return coins;

      final symbols = ref.watch(okxSymbolsProvider).valueOrNull;
      if (symbols == null || symbols.isEmpty) return coins;
      final tradable =
          coins.map((c) => c.symbol).where(symbols.contains).toList()..sort();
      if (tradable.isEmpty) return coins;

      final tickers = ref
          .watch(okxTickerProvider(tradable.join(',')))
          .valueOrNull;
      if (tickers == null || tickers.isEmpty) return coins;

      return coins.map((c) {
        final t = tickers[c.symbol];
        if (t == null) return c;
        return CryptoCoin(
          id: c.id,
          rank: c.rank,
          symbol: c.symbol,
          name: c.name,
          imageUrl: c.imageUrl,
          price: t.price,
          change24hPercent: t.changePercent24h,
          marketCap: c.marketCap,
          circulatingSupply: c.circulatingSupply,
        );
      }).toList();
    });

/// Quan ly danh muc Crypto - dong bo qua Supabase (wealth_holdings,
/// asset_type='crypto') thay vi SharedPreferences truoc day, de dong bo da
/// thiet bi giong phan con lai cua Vi. `_userId` null (chua dang nhap) thi
/// moi thao tac ghi la no-op, danh sach luon rong.
class CryptoPortfolioController extends StateNotifier<List<CryptoHolding>> {
  CryptoPortfolioController(this._supabase, this._userId) : super([]) {
    _load();
  }
  final SupabaseClient _supabase;
  final String? _userId;

  CryptoPortfolioRepository get _repo => CryptoPortfolioRepository(_supabase);
  CryptoTransactionRepository get _txRepo =>
      CryptoTransactionRepository(_supabase);

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    state = await _repo.load(userId);
  }

  Future<void> addOrUpdate(CryptoCoin coin, double quantity) async {
    final userId = _userId;
    if (userId == null) return;
    final i = state.indexWhere((h) => h.coinId == coin.id);
    final holding = CryptoHolding(
      coinId: coin.id,
      symbol: coin.symbol,
      name: coin.name,
      imageUrl: coin.imageUrl,
      quantity: quantity,
    );
    if (i == -1) {
      state = [...state, holding];
    } else {
      final updated = [...state];
      updated[i] = updated[i].copyWith(quantity: quantity);
      state = updated;
    }
    await _repo.upsert(userId, holding);
  }

  Future<void> remove(String coinId) async {
    final userId = _userId;
    if (userId == null) return;
    state = state.where((h) => h.coinId != coinId).toList();
    await _repo.remove(userId, coinId);
  }

  /// Mua them (hoac mua lan dau) 1 coin - cong don vao so luong dang giu,
  /// va ghi lai 1 dong lich su "buy".
  Future<void> buy({
    required String coinId,
    required String symbol,
    required String name,
    required String imageUrl,
    required double quantity,
    required double priceAtTime,
  }) async {
    final userId = _userId;
    if (userId == null || quantity <= 0) return;
    final i = state.indexWhere((h) => h.coinId == coinId);
    late final CryptoHolding holding;
    if (i == -1) {
      holding = CryptoHolding(
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        quantity: quantity,
      );
      state = [...state, holding];
    } else {
      final updated = [...state];
      holding = updated[i].copyWith(quantity: updated[i].quantity + quantity);
      updated[i] = holding;
      state = updated;
    }
    await _repo.upsert(userId, holding);
    await _txRepo.record(
      userId,
      CryptoTransaction(
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        type: CryptoTransactionType.buy,
        quantity: quantity,
        priceAtTime: priceAtTime,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Ban bot 1 coin dang giu - khong the ban qua so luong dang co (tu dong
  /// gioi han lai o muc toi da dang giu), xoa het holding neu ban het sach,
  /// va ghi lai 1 dong lich su "sell".
  Future<void> sell({
    required String coinId,
    required double quantity,
    required double priceAtTime,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final i = state.indexWhere((h) => h.coinId == coinId);
    if (i == -1 || quantity <= 0) return;
    final holding = state[i];
    final sellQty = quantity > holding.quantity ? holding.quantity : quantity;
    final remaining = holding.quantity - sellQty;

    final updated = [...state];
    if (remaining <= 0) {
      updated.removeAt(i);
      await _repo.remove(userId, holding.coinId);
    } else {
      updated[i] = holding.copyWith(quantity: remaining);
      await _repo.upsert(userId, updated[i]);
    }
    state = updated;
    await _txRepo.record(
      userId,
      CryptoTransaction(
        coinId: holding.coinId,
        symbol: holding.symbol,
        name: holding.name,
        imageUrl: holding.imageUrl,
        type: CryptoTransactionType.sell,
        quantity: sellQty,
        priceAtTime: priceAtTime,
        timestamp: DateTime.now(),
      ),
    );
  }
}

final cryptoPortfolioProvider =
    StateNotifierProvider<CryptoPortfolioController, List<CryptoHolding>>(
      (ref) => CryptoPortfolioController(
        ref.watch(supabaseClientProvider),
        ref.watch(supabaseClientProvider).auth.currentUser?.id,
      ),
    );

/// Lich su mua/ban - tu tai lai khi cryptoPortfolioProvider thay doi (nghia
/// la vua co 1 lan buy/sell moi duoc ghi lai).
final cryptoTransactionHistoryProvider =
    FutureProvider.autoDispose<List<CryptoTransaction>>((ref) {
      ref.watch(cryptoPortfolioProvider);
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<CryptoTransaction>[]);
      return CryptoTransactionRepository(ref.watch(supabaseClientProvider))
          .load(userId);
    });

/// Danh sach coin id dang "theo doi" (watchlist) - chi de xem gia, khong
/// lien quan gi Portfolio (khong so luong, khong lai/lo).
class CryptoWatchlistController extends StateNotifier<Set<String>> {
  CryptoWatchlistController() : super({}) {
    _load();
  }

  Future<void> _load() async {
    state = await CryptoWatchlistRepository.load();
  }

  Future<void> toggle(String coinId) async {
    final next = Set<String>.from(state);
    if (!next.remove(coinId)) next.add(coinId);
    state = next;
    await CryptoWatchlistRepository.save(state);
  }
}

final cryptoWatchlistProvider =
    StateNotifierProvider<CryptoWatchlistController, Set<String>>(
      (ref) => CryptoWatchlistController(),
    );
