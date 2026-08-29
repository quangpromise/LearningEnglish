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

class OkxService {
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
