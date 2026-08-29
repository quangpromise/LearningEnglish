import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/crypto_currency.dart';
import '../data/crypto_portfolio_repository.dart';
import '../data/crypto_repository.dart';

final cryptoCurrencyProvider = StateProvider<CryptoCurrency>(
  (ref) => CryptoCurrency.usd,
);

final cryptoTop100Provider = FutureProvider.autoDispose
    .family<List<CryptoCoin>, CryptoCurrency>(
      (ref, currency) => CryptoRepository.fetchTop100(currency: currency),
    );

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
}

final cryptoPortfolioProvider =
    StateNotifierProvider<CryptoPortfolioController, List<CryptoHolding>>(
      (ref) => CryptoPortfolioController(),
    );
