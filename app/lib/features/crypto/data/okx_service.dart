import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Gia + % thay doi 24h REAL-TIME qua OKX WebSocket - mien phi, khong can
/// API key, day du lieu ngay khi co thay doi (khac voi CoinGecko REST phai
/// tu polling dinh ky). OKX co niem yet nhieu coin ma Binance khong co (vd
/// Pi Network - PI-USDT) nen dung OKX lam nguon real-time chinh; coin nao
/// van khong co tren OKX se fallback ve CoinGecko - xem
/// docs/research-crypto-api.md.
class OkxTicker {
  const OkxTicker({required this.price, required this.changePercent24h});
  final double price;
  final double changePercent24h;
}

/// 1 diem nen (candlestick) - dung ve chart gia theo thoi gian.
class OkxCandle {
  const OkxCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
}

/// 1 dong gia trong bang xep hang TOAN BO cap USDT tren OKX - dung cho tim
/// kiem coin NGOAI top 100 von hoa (CoinGecko chi tra top 100), khong co
/// ten day du/logo (OKX chi tra ma) nen chi dung lam ket qua tim kiem phu,
/// khong thay the danh sach chinh sap theo von hoa.
class OkxTickerRow {
  const OkxTickerRow({
    required this.symbol,
    required this.price,
    required this.changePercent24h,
  });
  final String symbol;
  final double price;
  final double changePercent24h;
}

/// Ma chinh cua vai coin THAT (khong phai co phieu tokenized) tren OKX vo
/// tinh cung bat dau bang "X" - phai loai truoc khi loc theo pattern
/// "X{TICKER}-USDT" cua xStocks/Backed Finance, neu khong se hien Stellar/
/// XRP/Tezos... nham lan thanh "co phieu".
const _kOkxRealCryptoXPrefixed = {'XLM', 'XRP', 'XTZ', 'XCH', 'XPL', 'XAUT'};

/// 1 "co phieu tokenized" tren OKX (xStocks/Backed Finance, ma dang
/// "X{TICKER}-USDT" vd XAAPL-USDT) - LA TOKEN ON-CHAIN mo phong gia, KHONG
/// PHAI gia co phieu that tu NASDAQ/NYSE, co the lech gia thuc te do cung-
/// cau rieng cua token. `symbol` la ma da bo tien to "X" (vd "AAPL") de
/// hien thi giong ma co phieu that; `okxSymbol` giu nguyen "X{TICKER}" de
/// goi candles/ticker WebSocket dung dinh dang OKX.
class OkxTokenizedStock {
  const OkxTokenizedStock({
    required this.symbol,
    required this.okxSymbol,
    required this.price,
    required this.changePercent24h,
    required this.volume24hUsd,
  });
  final String symbol;
  final String okxSymbol;
  final double price;
  final double changePercent24h;
  final double volume24hUsd;
}

class OkxService {
  /// Toan bo "co phieu tokenized" (xStocks) dang giao dich tren OKX - sap
  /// theo volume24hUsd GIAM DAN lam proxy cho "quy mo" (KHONG PHAI von hoa
  /// thi truong that - token nay khong co khai niem von hoa chinh thuc, chi
  /// dung thanh khoan 24h de uoc luong tuong doi ma nao "lon" hon).
  static Future<List<OkxTokenizedStock>> fetchTokenizedStocks() async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(
        Uri.parse('https://www.okx.com/api/v5/market/tickers?instType=SPOT'),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final list = data['data'] as List;
      final pattern = RegExp(r'^X([A-Z0-9]+)-USDT$');
      final result = list
          .cast<Map<String, dynamic>>()
          .map((r) {
            final instId = r['instId'] as String? ?? '';
            final match = pattern.firstMatch(instId);
            if (match == null) return null;
            final ticker = match.group(1)!;
            // LUU Y: `ticker` la phan SAU chu X (regex da bo X di), nen phai
            // noi lai 'X$ticker' truoc khi so voi danh sach loai tru - truoc
            // day so truc tiep voi `ticker` (vd "RP") trong khi danh sach
            // loai tru luu ca chu X (vd "XRP") nen KHONG BAO GIO khop, khien
            // XRP/XAUT/XLM/XPL... lot vao danh sach "co phieu" duoi ten gia
            // "RP"/"AUT"/"LM"/"PL".
            if (_kOkxRealCryptoXPrefixed.contains('X$ticker')) return null;
            if (ticker.contains('TEST')) return null;
            final last = double.tryParse(r['last']?.toString() ?? '') ?? 0;
            final open24h =
                double.tryParse(r['open24h']?.toString() ?? '') ?? 0;
            final volCcy24h =
                double.tryParse(r['volCcy24h']?.toString() ?? '') ?? 0;
            if (last <= 0) return null;
            final changePercent = open24h == 0
                ? 0.0
                : (last - open24h) / open24h * 100;
            return OkxTokenizedStock(
              symbol: ticker,
              okxSymbol: 'X$ticker',
              price: last,
              changePercent24h: changePercent,
              volume24hUsd: volCcy24h,
            );
          })
          .whereType<OkxTokenizedStock>()
          .toList();
      result.sort((a, b) => b.volume24hUsd.compareTo(a.volume24hUsd));
      return result;
    } finally {
      client.close();
    }
  }

  /// Toan bo gia hien tai cho MOI cap giao dich USDT dang "live" tren OKX -
  /// 1 lan goi REST duy nhat (khong phan trang), dung de tim kiem coin ngoai
  /// pham vi top 100 von hoa cua CoinGecko.
  static Future<List<OkxTickerRow>> fetchAllUsdtTickers() async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(
        Uri.parse('https://www.okx.com/api/v5/market/tickers?instType=SPOT'),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final list = data['data'] as List;
      return list
          .cast<Map<String, dynamic>>()
          .where((r) => (r['instId'] as String? ?? '').endsWith('-USDT'))
          .map((r) {
            final instId = r['instId'] as String;
            final symbol = instId.substring(0, instId.length - 5);
            final last = double.tryParse(r['last']?.toString() ?? '') ?? 0;
            final open24h =
                double.tryParse(r['open24h']?.toString() ?? '') ?? 0;
            final changePercent = open24h == 0
                ? 0.0
                : (last - open24h) / open24h * 100;
            return OkxTickerRow(
              symbol: symbol,
              price: last,
              changePercent24h: changePercent,
            );
          })
          .where((r) => r.price > 0)
          .toList();
    } finally {
      client.close();
    }
  }

  /// Lich su nen (candlestick) cho 1 ky hieu - dung ve chart. `bar` la don vi
  /// nen OKX ho tro (vd '1m','15m','1H','4H','1D','1W'), `limit` toi da 300
  /// theo gioi han cua endpoint nay.
  static Future<List<OkxCandle>> fetchCandles({
    required String symbol,
    required String bar,
    int limit = 100,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(
        Uri.parse(
          'https://www.okx.com/api/v5/market/candles'
          '?instId=$symbol-USDT&bar=$bar&limit=$limit',
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final rows = (data['data'] as List?) ?? [];
      // OKX tra ve moi nen [ts, o, h, l, c, ...] theo thu tu MOI NHAT truoc -
      // dao lai de ve chart theo thoi gian tang dan (trai -> phai).
      return rows
          .cast<List<dynamic>>()
          .map(
            (r) => OkxCandle(
              time: DateTime.fromMillisecondsSinceEpoch(
                int.parse(r[0] as String),
              ),
              open: double.parse(r[1] as String),
              high: double.parse(r[2] as String),
              low: double.parse(r[3] as String),
              close: double.parse(r[4] as String),
            ),
          )
          .toList()
          .reversed
          .toList();
    } finally {
      client.close();
    }
  }

  WebSocket? _socket;
  Timer? _pingTimer;
  StreamController<Map<String, OkxTicker>>? _controller;
  final Map<String, OkxTicker> _latest = {};

  /// Danh sach ky hieu (vd "BTC", "PI") dang co cap giao dich USDT dang
  /// hoat dong (state "live") tren OKX.
  static Future<Set<String>> fetchUsdtSymbols() async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(
        Uri.parse(
          'https://www.okx.com/api/v5/public/instruments?instType=SPOT',
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final list = data['data'] as List;
      return list
          .cast<Map<String, dynamic>>()
          .where((s) => s['quoteCcy'] == 'USDT' && s['state'] == 'live')
          .map((s) => (s['baseCcy'] as String).toUpperCase())
          .toSet();
    } finally {
      client.close();
    }
  }

  /// Mo 1 WebSocket cong khai cua OKX, dang ky kenh "tickers" cho tung ky
  /// hieu, tra ve stream snapshot Map (ky hieu -> gia+%24h) moi khi co cap
  /// nhat moi. OKX tu dong dong ket noi neu khong nhan duoc gi trong 30s nen
  /// phai gui "ping" dinh ky de giu ket noi song.
  Stream<Map<String, OkxTicker>> watch(List<String> symbols) {
    final controller = StreamController<Map<String, OkxTicker>>.broadcast();
    _controller = controller;
    WebSocket.connect('wss://ws.okx.com:8443/ws/v5/public')
        .then((socket) {
          _socket = socket;
          final args = symbols
              .map((s) => {'channel': 'tickers', 'instId': '$s-USDT'})
              .toList();
          socket.add(jsonEncode({'op': 'subscribe', 'args': args}));
          _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
            try {
              socket.add('ping');
            } catch (_) {}
          });
          socket.listen(
            (event) {
              try {
                if (event == 'pong') return;
                final msg = jsonDecode(event as String) as Map<String, dynamic>;
                final arg = msg['arg'] as Map<String, dynamic>?;
                if (arg == null || arg['channel'] != 'tickers') return;
                final rows = msg['data'] as List?;
                if (rows == null || rows.isEmpty) return;
                for (final row in rows.cast<Map<String, dynamic>>()) {
                  final instId = (row['instId'] as String?) ?? '';
                  if (!instId.endsWith('-USDT')) continue;
                  final base = instId.substring(0, instId.length - 5);
                  final last = double.tryParse(row['last']?.toString() ?? '');
                  final open24h = double.tryParse(
                    row['open24h']?.toString() ?? '',
                  );
                  if (last == null || open24h == null || open24h == 0) {
                    continue;
                  }
                  final changePercent = (last - open24h) / open24h * 100;
                  _latest[base] = OkxTicker(
                    price: last,
                    changePercent24h: changePercent,
                  );
                }
                controller.add(Map.of(_latest));
              } catch (_) {
                // Bo qua 1 message loi dinh dang - khong lam sap ca stream.
              }
            },
            onError: (_) {},
            cancelOnError: false,
          );
        })
        .catchError((_) {});
    return controller.stream;
  }

  void dispose() {
    _pingTimer?.cancel();
    _socket?.close();
    _controller?.close();
  }
}
