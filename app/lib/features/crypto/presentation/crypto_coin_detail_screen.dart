import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/okx_service.dart';
import 'crypto_providers.dart';

enum _ChartPeriod { h1, h4, d1, w1, m1, y1 }

extension on _ChartPeriod {
  /// (bar OKX, limit) - chon do phan giai + so luong diem phu hop tung
  /// khung thoi gian, tranh goi qua nhieu diem khong can thiet (max cua OKX
  /// la 300/lan goi).
  (String, int) get params => switch (this) {
    _ChartPeriod.h1 => ('1m', 60),
    _ChartPeriod.h4 => ('5m', 48),
    _ChartPeriod.d1 => ('15m', 96),
    _ChartPeriod.w1 => ('1H', 168),
    _ChartPeriod.m1 => ('4H', 180),
    _ChartPeriod.y1 => ('1D', 260),
  };

  String get label => switch (this) {
    _ChartPeriod.h1 => '1H',
    _ChartPeriod.h4 => '4H',
    _ChartPeriod.d1 => '1D',
    _ChartPeriod.w1 => '1W',
    _ChartPeriod.m1 => '1M',
    _ChartPeriod.y1 => '1Y',
  };
}

/// Man chi tiet 1 coin - gia + %24h REAL-TIME qua OKX WebSocket (dung lai
/// [OkxService], tach ket noi rieng khoi danh sach Market de khong anh
/// huong toi lan nhau), bieu do gia lich su qua OKX candles REST theo tung
/// khung thoi gian (1D/1W/1M/1Y). Luon hien theo USD (gia OKX quy doi tu cap
/// USDT) bat ke nguoi dung dang chon VND o man Market, vi day la gia cua 1
/// san giao dich cu the, khac voi gia trung binh thi truong CoinGecko.
class CryptoCoinDetailScreen extends ConsumerStatefulWidget {
  const CryptoCoinDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    this.imageUrl,
    this.fallbackPrice,
    this.fallbackChangePercent,
  });

  final String symbol;
  final String name;
  final String? imageUrl;
  final double? fallbackPrice;
  final double? fallbackChangePercent;

  @override
  ConsumerState<CryptoCoinDetailScreen> createState() =>
      _CryptoCoinDetailScreenState();
}

class _CryptoCoinDetailScreenState
    extends ConsumerState<CryptoCoinDetailScreen> {
  _ChartPeriod _period = _ChartPeriod.d1;
  final _okx = OkxService();
  StreamSubscription<Map<String, OkxTicker>>? _sub;
  OkxTicker? _live;
  // Ban sao local cua nen tai duoc tu provider - can co ban sao MUTABLE rieng
  // vi moi tick gia live se "ve lai" nen CUOI CUNG (dang hinh thanh) ngay lap
  // tuc thay vi cho toi lan fetch REST tiep theo, giong cach OKX/cac san
  // hien thi 1 nen dang chay theo gia that trong luc no.
  List<OkxCandle>? _liveCandles;
  Timer? _refetchTimer;
  // Zoom truc GIA (truc doc, cot ben phai) giong OKX - keo len/xuong ngay
  // tren cot gia de "keo dai"/"thu gon" chieu cao nen: keo LEN thu hep
  // khoang gia hien thi (nen cao/dai ra), keo XUONG mo rong khoang gia
  // (nen ngan/gon lai). KHONG phai zoom truc ngang (so luong nen hien) -
  // da bo huong do theo yeu cau, chi con zoom doc nay.
  double _yZoomFactor = 1.0;

  // Keo lui xem nen cac nam truoc (toi da 3 nam - xem _kMaxHistory) giong
  // OKX: cuon ngang thu cong (khong dung transform), cham toi gan mep TRAI
  // (nen CU nhat dang co) thi tu dong tai them 1 lo nen cu hon, noi vao dau
  // danh sach hien co.
  final _hScroll = ScrollController();
  static const _candleWidthPx = 6.0;
  static const _kMaxHistory = Duration(days: 365 * 3);
  bool _loadingMoreHistory = false;
  bool _noMoreHistory = false;
  bool _pendingScrollToEnd = true;

  // Bam vao 1 cay nen de xem thong tin (OHLC + ngay gio) giong OKX - KHONG
  // tu tat khi tha tay, chi tat khi bam vao man hinh mot lan nua (xem
  // Listener.onPointerDown boc ngoai cung trong build()). Dung callback
  // rieng (handleBuiltInTouches: false) thay vi tooltip mac dinh cua
  // fl_chart vi tooltip mac dinh chi hien trong luc giu tay, khong dung y
  // muon "hien den khi bam lai".
  int? _selectedCandleIndex;

  @override
  void initState() {
    super.initState();
    _hScroll.addListener(_onHScroll);
    _sub = _okx.watch([widget.symbol]).listen((ticks) {
      final t = ticks[widget.symbol];
      if (t == null || !mounted) return;
      setState(() {
        _live = t;
        final candles = _liveCandles;
        if (candles != null && candles.isNotEmpty) {
          final last = candles.last;
          candles[candles.length - 1] = OkxCandle(
            time: last.time,
            open: last.open,
            high: t.price > last.high ? t.price : last.high,
            low: t.price < last.low ? t.price : last.low,
            close: t.price,
          );
        }
      });
    });
    // Lam moi lai toan bo nen tu REST dinh ky - dam bao khi 1 khung nen ket
    // thuc (vd het 15 phut) se co nen MOI dung gio thay vi nen cu cu bi keo
    // dai vo han chi vi cap nhat gia live o tren.
    _refetchTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final (bar, limit) = _period.params;
      ref.invalidate(okxCandlesProvider('${widget.symbol}|$bar|$limit'));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _refetchTimer?.cancel();
    _hScroll.removeListener(_onHScroll);
    _hScroll.dispose();
    _okx.dispose();
    super.dispose();
  }

  void _onHScroll() {
    if (_loadingMoreHistory || _noMoreHistory) return;
    // Gan mep TRAI (nen cu nhat dang co, ScrollController do tu 0 - KHONG
    // dung reverse) - con cach duoi 300px thi bat dau tai truoc, tranh cho
    // nguoi dung keo toi tan mep roi moi tai (giat/khoang trong tam thoi).
    if (_hScroll.position.pixels <= 300) _loadMoreHistory();
  }

  Future<void> _loadMoreHistory() async {
    final candles = _liveCandles;
    if (candles == null || candles.isEmpty) return;
    final oldest = candles.first.time;
    if (DateTime.now().difference(oldest) >= _kMaxHistory) {
      _noMoreHistory = true;
      return;
    }
    _loadingMoreHistory = true;
    final (bar, _) = _period.params;
    try {
      final older = await OkxService.fetchHistoryCandles(
        symbol: widget.symbol,
        bar: bar,
        before: oldest,
        limit: 100,
      );
      if (!mounted) return;
      if (older.isEmpty) {
        _noMoreHistory = true;
        return;
      }
      final addedWidth = older.length * _candleWidthPx;
      setState(() {
        _liveCandles = [...older, ...candles];
        // Cac nen CU da noi vao DAU danh sach - chi so cua cay nen dang
        // duoc chon (neu co) phai dich theo dung so luong nen moi them vao
        // de van tro toi DUNG cay nen do (khong phai nen o vi tri cu).
        if (_selectedCandleIndex != null) {
          _selectedCandleIndex = _selectedCandleIndex! + older.length;
        }
      });
      // Vua noi them nen CU vao DAU danh sach - toa do cua moi nen HIEN
      // TAI nguoi dung dang xem bi doi (dich sang phai them addedWidth px)
      // du gia tri khong doi. Bu lai offset cuon NGAY LAP TUC (cung 1
      // frame, truoc khi ve) de man hinh KHONG bi giat/nhay vi tri.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_hScroll.hasClients) return;
        _hScroll.jumpTo(_hScroll.position.pixels + addedWidth);
      });
    } catch (_) {
      // Loi mang tam thoi - khong sao, lan cuon toi gan mep tiep theo se
      // thu lai, khong can bao loi rieng cho 1 lan tai them khong thanh
      // cong.
    } finally {
      _loadingMoreHistory = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bar, limit) = _period.params;
    final candlesAsync = ref.watch(
      okxCandlesProvider('${widget.symbol}|$bar|$limit'),
    );
    // Moi khi provider tra ve 1 danh sach MOI (fetch dau/doi khung/refetch
    // dinh ky), dong bo lai ban sao local de tick gia live tiep theo ve
    // dung tren du lieu moi nhat.
    ref.listen(okxCandlesProvider('${widget.symbol}|$bar|$limit'), (_, next) {
      final data = next.valueOrNull;
      if (data != null) _liveCandles = List.of(data);
    });
    final price = _live?.price ?? widget.fallbackPrice;
    final changePercent =
        _live?.changePercent24h ?? widget.fallbackChangePercent;
    final isUp = (changePercent ?? 0) >= 0;

    return ScreenBackground(
      child: Listener(
        // Bam vao BAT KY DAU tren man hinh se XOA lua chon nen truoc tien
        // (chay truoc khi cu chi bam duoc phan giai xong, vi day la
        // pointer-event tho, khong tham gia "gesture arena"). Neu diem bam
        // do dung la 1 cay nen, candlestickTouchData ben duoi se CHON LAI
        // ngay sau do (cung 1 lan bam) - ket qua: bam nen khac -> doi thong
        // tin; bam ra ngoai chart -> tat han, dung y muon cua nguoi dung.
        onPointerDown: (_) {
          if (_selectedCandleIndex != null) {
            setState(() => _selectedCandleIndex = null);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupHeader(title: widget.name),
              const SizedBox(height: 4),
              Text(widget.symbol, style: AppTextStyles.muted(size: 12.5)),
              const SizedBox(height: 14),
              Text(
                price == null ? '...' : '\$${_formatPrice(price)}',
                style: AppTextStyles.heading(size: 30),
              ),
              const SizedBox(height: 4),
              if (changePercent != null)
                Text(
                  '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}% (24h)',
                  style: TextStyle(
                    color: isUp ? AppColors.teal : AppColors.pink,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final p in _ChartPeriod.values) ...[
                      _PeriodChip(
                        label: p.label,
                        selected: p == _period,
                        onTap: () => setState(() {
                          _period = p;
                          // Doi khung thoi gian = nen khac hoan toan - xoa ban
                          // sao live cu de khong "keo theo" du lieu sai khung,
                          // dong thoi reset zoom truc gia vi khoang gia cu se
                          // khong con hop ly voi bo du lieu moi.
                          _liveCandles = null;
                          _yZoomFactor = 1.0;
                          _noMoreHistory = false;
                          _pendingScrollToEnd = true;
                          _selectedCandleIndex = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: candlesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.blue),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      ref.tr('wealth_load_error'),
                      style: AppTextStyles.muted(),
                    ),
                  ),
                  data: (fetched) {
                    if (fetched.isEmpty) {
                      return Center(
                        child: Text(
                          ref.tr('wealth_load_error'),
                          style: AppTextStyles.muted(),
                        ),
                      );
                    }
                    // Seed ban sao local NEU chua co (lan fetch dau/sau khi
                    // doi khung) - cac lan sau du lieu hien thi la ban sao nay
                    // (da duoc "ve tiep" boi tick gia live), khong phai
                    // `fetched` truc tiep, de khong bi ghi de moi lan REST
                    // refetch dinh ky lam mat hieu ung nen dang chay live.
                    _liveCandles ??= List.of(fetched);
                    final candles = _liveCandles!;
                    final rawMinY = candles
                        .map((c) => c.low)
                        .reduce((a, b) => a < b ? a : b);
                    final rawMaxY = candles
                        .map((c) => c.high)
                        .reduce((a, b) => a > b ? a : b);
                    final pad = (rawMaxY - rawMinY) * 0.08;
                    // Zoom truc gia: co gian khoang [minY, maxY] quanh DIEM
                    // GIUA cua khoang gia goc, theo _yZoomFactor (< 1 = thu
                    // hep khoang gia -> nen cao/dai ra; > 1 = mo rong khoang
                    // gia -> nen ngan/gon lai) - xem GestureDetector keo doc
                    // tren cot truc gia ben duoi.
                    final mid = (rawMinY + rawMaxY) / 2;
                    final halfRange = ((rawMaxY - rawMinY) / 2 + pad).clamp(
                      1e-9,
                      double.infinity,
                    );
                    final zoomedHalf = halfRange * _yZoomFactor;
                    final minY = mid - zoomedHalf;
                    final maxY = mid + zoomedHalf;
                    const axisWidth = 56.0;
                    final selectedIndex = _selectedCandleIndex;
                    final selectedCandle =
                        (selectedIndex != null &&
                            selectedIndex >= 0 &&
                            selectedIndex < candles.length)
                        ? candles[selectedIndex]
                        : null;
                    return Stack(
                      children: [
                        Row(
                          children: [
                            // Vung nen: CUON NGANG duoc (keo lui xem nam truoc,
                            // toi 3 nam - xem _loadMoreHistory), do rong toi
                            // thieu theo so nen * be rong 1 nen de nen luon "gon"
                            // (khong bi keo gian ra het man hinh khi it nen).
                            // Truc gia KHONG nam trong day - dat rieng, CO DINH,
                            // ben phai (xem duoi) de khong bi cuon mat theo.
                            Expanded(
                              child: ClipRect(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final totalWidth =
                                        (candles.length * _candleWidthPx).clamp(
                                          constraints.maxWidth,
                                          double.infinity,
                                        );
                                    if (_pendingScrollToEnd) {
                                      _pendingScrollToEnd = false;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted &&
                                                _hScroll.hasClients) {
                                              _hScroll.jumpTo(
                                                _hScroll
                                                    .position
                                                    .maxScrollExtent,
                                              );
                                            }
                                          });
                                    }
                                    return SingleChildScrollView(
                                      controller: _hScroll,
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: totalWidth,
                                        height: constraints.maxHeight,
                                        child: CandlestickChart(
                                          CandlestickChartData(
                                            minY: minY,
                                            maxY: maxY,
                                            gridData: const FlGridData(
                                              show: false,
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            // Nen xanh khi dong cua >= mo cua, do
                                            // khi thap hon - dung mau teal/pink
                                            // chuan cua app thay vi mau mac dinh
                                            // cua fl_chart, cho dong bo voi cac
                                            // PNL khac.
                                            candlestickPainter:
                                                DefaultCandlestickPainter(
                                                  candlestickStyleProvider:
                                                      (spot, _) {
                                                        final color = spot.isUp
                                                            ? AppColors.teal
                                                            : AppColors.pink;
                                                        return CandlestickStyle(
                                                          lineColor: color,
                                                          lineWidth: 1.2,
                                                          bodyStrokeColor:
                                                              color,
                                                          bodyStrokeWidth: 0,
                                                          bodyFillColor: color,
                                                          bodyWidth: 4,
                                                          bodyRadius: 1,
                                                        );
                                                      },
                                                ),
                                            // Khong hien truc nao ben trong chart
                                            // nay nua - truc gia ve RIENG, co dinh
                                            // ben phai (khong cuon theo), xem
                                            // _PriceAxisLabels duoi. Truc NGAY
                                            // (bottomTitles) VAN hien trong day
                                            // (khong tach rieng nhu truc gia) -
                                            // cuon cung voi nen la dung y muon,
                                            // giong ngay/thang luon nam ngay
                                            // duoi cay nen tuong ung o OKX.
                                            titlesData: FlTitlesData(
                                              show: true,
                                              topTitles: const AxisTitles(),
                                              leftTitles: const AxisTitles(),
                                              rightTitles: const AxisTitles(),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 22,
                                                  interval: (candles.length / 6)
                                                      .clamp(1, double.infinity)
                                                      .ceilToDouble(),
                                                  getTitlesWidget: (value, meta) {
                                                    final i = value.round();
                                                    if (i < 0 ||
                                                        i >= candles.length) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    final t = candles[i].time;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 6,
                                                          ),
                                                      child: Text(
                                                        '${t.day.toString().padLeft(2, '0')}/'
                                                        '${t.month.toString().padLeft(2, '0')}/'
                                                        '${t.year}',
                                                        style:
                                                            AppTextStyles.muted(
                                                              size: 9,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            candlestickTouchData:
                                                CandlestickTouchData(
                                                  handleBuiltInTouches: false,
                                                  touchCallback:
                                                      (
                                                        FlTouchEvent event,
                                                        CandlestickTouchResponse?
                                                        response,
                                                      ) {
                                                        if (event
                                                            is! FlTapUpEvent) {
                                                          return;
                                                        }
                                                        final i = response
                                                            ?.touchedSpot
                                                            ?.spotIndex;
                                                        if (i == null) return;
                                                        setState(
                                                          () =>
                                                              _selectedCandleIndex =
                                                                  i,
                                                        );
                                                      },
                                                ),
                                            candlestickSpots: [
                                              for (
                                                var i = 0;
                                                i < candles.length;
                                                i++
                                              )
                                                CandlestickSpot(
                                                  x: i.toDouble(),
                                                  open: candles[i].open,
                                                  high: candles[i].high,
                                                  low: candles[i].low,
                                                  close: candles[i].close,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Truc gia CO DINH ben phai (khong cuon theo vung nen)
                            // - dong thoi la vung keo doc de zoom gia (giong OKX:
                            // keo LEN thu hep khoang gia/nen dai ra, keo XUONG mo
                            // rong khoang gia/nen gon lai).
                            SizedBox(
                              width: axisWidth,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _PriceAxisLabels(
                                      minY: minY,
                                      maxY: maxY,
                                      formatPrice: _formatPrice,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onVerticalDragUpdate: (details) {
                                        setState(() {
                                          _yZoomFactor =
                                              (_yZoomFactor -
                                                      details.delta.dy * 0.006)
                                                  .clamp(0.15, 6.0);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Hop thong tin cay nen dang chon (OHLC + ngay gio) -
                        // hien den khi bam vao 1 cay nen, KHONG tu tat, chi
                        // mat khi bam vao man hinh lan nua (xem
                        // Listener.onPointerDown boc ngoai cung o build()).
                        if (selectedCandle != null)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: _CandleInfoBox(
                              candle: selectedCandle,
                              formatPrice: _formatPrice,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1) return price.toStringAsFixed(2);
    if (price >= 0.01) return price.toStringAsFixed(4);
    return price.toStringAsFixed(8);
  }
}

/// Hop thong tin 1 cay nen (ngay/gio + O/H/L/C) giong OKX - hien khi nguoi
/// dung bam vao 1 cay nen (xem candlestickTouchData trong build()), o goc
/// tren trai vung chart, KHONG tu tat theo thoi gian/khi tha tay.
class _CandleInfoBox extends StatelessWidget {
  const _CandleInfoBox({required this.candle, required this.formatPrice});
  final OkxCandle candle;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final isUp = candle.close >= candle.open;
    final color = isUp ? AppColors.teal : AppColors.pink;
    final t = candle.time;
    final dateLabel =
        '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}/${t.year} '
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgTop.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateLabel,
            style: AppTextStyles.muted(size: 10, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          _InfoRow(label: 'O', value: formatPrice(candle.open), color: color),
          _InfoRow(label: 'H', value: formatPrice(candle.high), color: color),
          _InfoRow(label: 'L', value: formatPrice(candle.low), color: color),
          _InfoRow(label: 'C', value: formatPrice(candle.close), color: color),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            child: Text(
              label,
              style: AppTextStyles.muted(size: 10, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Truc gia ve THU CONG (thay vi dung `rightTitles` cua fl_chart) - can
/// tach rieng khoi CandlestickChart de dat CO DINH ben ngoai vung cuon
/// ngang, khong bi "troi" mat theo khi nguoi dung keo lui xem lich su (xem
/// crypto_coin_detail_screen build()). Chia deu [_tickCount] moc tu
/// [maxY] (tren cung) xuong [minY] (duoi cung).
class _PriceAxisLabels extends StatelessWidget {
  const _PriceAxisLabels({
    required this.minY,
    required this.maxY,
    required this.formatPrice,
  });
  final double minY;
  final double maxY;
  final String Function(double) formatPrice;

  static const _tickCount = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Stack(
          children: [
            for (var i = 0; i < _tickCount; i++)
              Positioned(
                // i=0 o TREN CUNG (gia cao nhat maxY), i cuoi o DUOI CUNG
                // (gia thap nhat minY) - tru 7px de can giua chu theo chieu
                // doc quanh moc do (uoc luong nua chieu cao 1 dong text).
                top: (height / (_tickCount - 1)) * i - 7,
                left: 4,
                right: 0,
                child: Text(
                  formatPrice(maxY - (maxY - minY) * i / (_tickCount - 1)),
                  style: AppTextStyles.muted(size: 10),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.accentGradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12.5,
            weight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
