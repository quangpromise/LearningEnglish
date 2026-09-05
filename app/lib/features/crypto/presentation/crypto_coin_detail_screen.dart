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

  @override
  void initState() {
    super.initState();
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
    _okx.dispose();
    super.dispose();
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
                        // sao live cu de khong "keo theo" du lieu sai khung.
                        _liveCandles = null;
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
                  final minY = candles
                      .map((c) => c.low)
                      .reduce((a, b) => a < b ? a : b);
                  final maxY = candles
                      .map((c) => c.high)
                      .reduce((a, b) => a > b ? a : b);
                  final pad = (maxY - minY) * 0.08;
                  return CandlestickChart(
                    CandlestickChartData(
                      minY: minY - pad,
                      maxY: maxY + pad,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      // Nen xanh khi dong cua >= mo cua, do khi thap hon -
                      // dung mau teal/pink chuan cua app thay vi mau mac
                      // dinh cua fl_chart, cho dong bo voi cac PNL khac.
                      candlestickPainter: DefaultCandlestickPainter(
                        candlestickStyleProvider: (spot, _) {
                          final color = spot.isUp
                              ? AppColors.teal
                              : AppColors.pink;
                          return CandlestickStyle(
                            lineColor: color,
                            lineWidth: 1.2,
                            bodyStrokeColor: color,
                            bodyStrokeWidth: 0,
                            bodyFillColor: color,
                            bodyWidth: 4,
                            bodyRadius: 1,
                          );
                        },
                      ),
                      // Truc gia ben PHAI giong OKX (khong hien truc trai/
                      // tren/duoi de chart gon, chi can 1 truc tham chieu).
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(),
                        leftTitles: const AxisTitles(),
                        bottomTitles: const AxisTitles(),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                _formatPrice(value),
                                style: AppTextStyles.muted(size: 10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      candlestickSpots: [
                        for (var i = 0; i < candles.length; i++)
                          CandlestickSpot(
                            x: i.toDouble(),
                            open: candles[i].open,
                            high: candles[i].high,
                            low: candles[i].low,
                            close: candles[i].close,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
