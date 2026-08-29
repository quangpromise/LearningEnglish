import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CryptoPortfolioController extends StateNotifier<List<CryptoHolding>> {
  CryptoPortfolioController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await CryptoPortfolioRepository.load();
  }

  Future<void> addOrUpdate(CryptoCoin coin, double quantity) async {
    final i = state.indexWhere((h) => h.coinId == coin.id);
    if (i == -1) {
      state = [
        ...state,
        CryptoHolding(
          coinId: coin.id,
          symbol: coin.symbol,
          name: coin.name,
          imageUrl: coin.imageUrl,
          quantity: quantity,
        ),
      ];
    } else {
      final updated = [...state];
      updated[i] = updated[i].copyWith(quantity: quantity);
      state = updated;
    }
    await CryptoPortfolioRepository.save(state);
  }

  Future<void> remove(String coinId) async {
    state = state.where((h) => h.coinId != coinId).toList();
    await CryptoPortfolioRepository.save(state);
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
    if (quantity <= 0) return;
    final i = state.indexWhere((h) => h.coinId == coinId);
    if (i == -1) {
      state = [
        ...state,
        CryptoHolding(
          coinId: coinId,
          symbol: symbol,
          name: name,
          imageUrl: imageUrl,
          quantity: quantity,
        ),
      ];
    } else {
      final updated = [...state];
      updated[i] = updated[i].copyWith(
        quantity: updated[i].quantity + quantity,
      );
      state = updated;
    }
    await CryptoPortfolioRepository.save(state);
    await CryptoTransactionRepository.record(
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
    final i = state.indexWhere((h) => h.coinId == coinId);
    if (i == -1 || quantity <= 0) return;
    final holding = state[i];
    final sellQty = quantity > holding.quantity ? holding.quantity : quantity;
    final remaining = holding.quantity - sellQty;

    final updated = [...state];
    if (remaining <= 0) {
      updated.removeAt(i);
    } else {
      updated[i] = holding.copyWith(quantity: remaining);
    }
    state = updated;
    await CryptoPortfolioRepository.save(state);
    await CryptoTransactionRepository.record(
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
      (ref) => CryptoPortfolioController(),
    );

/// Lich su mua/ban - tu tai lai khi cryptoPortfolioProvider thay doi (nghia
/// la vua co 1 lan buy/sell moi duoc ghi lai).
final cryptoTransactionHistoryProvider =
    FutureProvider.autoDispose<List<CryptoTransaction>>((ref) {
      ref.watch(cryptoPortfolioProvider);
      return CryptoTransactionRepository.load();
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
