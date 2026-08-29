/// Don vi tien te hien thi cho tinh nang Crypto - gia lay truc tiep tu
/// CoinGecko theo dung don vi nay (CoinGecko ho tro vs_currency=usd/vnd),
/// khong can tu quy doi qua ty gia rieng.
enum CryptoCurrency {
  usd('usd', '\$'),
  vnd('vnd', '₫');

  const CryptoCurrency(this.code, this.symbol);
  final String code;
  final String symbol;
}

String formatCryptoPrice(double price, CryptoCurrency currency) {
  if (currency == CryptoCurrency.vnd) {
    return '${_groupThousands(price.round())} ${currency.symbol}';
  }
  if (price >= 1) return '${currency.symbol}${price.toStringAsFixed(2)}';
  if (price >= 0.01) return '${currency.symbol}${price.toStringAsFixed(4)}';
  return '${currency.symbol}${price.toStringAsFixed(8)}';
}

String formatCryptoCompact(double value, CryptoCurrency currency) {
  final prefix = currency == CryptoCurrency.vnd ? '' : currency.symbol;
  final suffix = currency == CryptoCurrency.vnd ? ' ${currency.symbol}' : '';
  if (value >= 1e12) {
    return '$prefix${(value / 1e12).toStringAsFixed(2)}T$suffix';
  }
  if (value >= 1e9) return '$prefix${(value / 1e9).toStringAsFixed(2)}B$suffix';
  if (value >= 1e6) return '$prefix${(value / 1e6).toStringAsFixed(2)}M$suffix';
  if (value >= 1e3) return '$prefix${(value / 1e3).toStringAsFixed(2)}K$suffix';
  return '$prefix${value.toStringAsFixed(0)}$suffix';
}

String formatSupply(double value, String symbol) {
  String compact;
  if (value >= 1e9) {
    compact = '${(value / 1e9).toStringAsFixed(2)}B';
  } else if (value >= 1e6) {
    compact = '${(value / 1e6).toStringAsFixed(2)}M';
  } else if (value >= 1e3) {
    compact = '${(value / 1e3).toStringAsFixed(2)}K';
  } else {
    compact = value.toStringAsFixed(0);
  }
  return '$compact $symbol';
}

String _groupThousands(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
