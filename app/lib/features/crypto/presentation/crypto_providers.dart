import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/crypto_currency.dart';
import '../data/crypto_portfolio_repository.dart';
import '../data/crypto_repository.dart';
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

  /// Sua so luong dang nam giu cua 1 coin da co san trong danh muc - dung
  /// khi nguoi dung muon tang/giam amount thay vi xoa roi them lai tu dau.
  Future<void> updateQuantity(String coinId, double quantity) async {
    final i = state.indexWhere((h) => h.coinId == coinId);
    if (i == -1) return;
    final updated = [...state];
    updated[i] = updated[i].copyWith(quantity: quantity);
    state = updated;
    await CryptoPortfolioRepository.save(state);
  }

  Future<void> remove(String coinId) async {
    state = state.where((h) => h.coinId != coinId).toList();
    await CryptoPortfolioRepository.save(state);
  }
}

final cryptoPortfolioProvider =
    StateNotifierProvider<CryptoPortfolioController, List<CryptoHolding>>(
      (ref) => CryptoPortfolioController(),
    );
