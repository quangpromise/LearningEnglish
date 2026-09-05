import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/okx_service.dart';
import 'crypto_providers.dart';

enum _ChartPeriod { d1, w1, m1, y1 }

extension on _ChartPeriod {
  /// (bar OKX, limit) - chon do phan giai + so luong diem phu hop tung
  /// khung thoi gian, tranh goi qua nhieu diem khong can thiet (max cua OKX
  /// la 300/lan goi).
  (String, int) get params => switch (this) {
    _ChartPeriod.d1 => ('15m', 96),
    _ChartPeriod.w1 => ('1H', 168),
    _ChartPeriod.m1 => ('4H', 180),
    _ChartPeriod.y1 => ('1D', 260),
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

  @override
  void initState() {
    super.initState();
    _sub = _okx.watch([widget.symbol]).listen((ticks) {
      final t = ticks[widget.symbol];
      if (t != null && mounted) setState(() => _live = t);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _okx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (bar, limit) = _period.params;
    final candlesAsync = ref.watch(
      okxCandlesProvider('${widget.symbol}|$bar|$limit'),
    );
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
            Row(
              children: [
                for (final p in _ChartPeriod.values) ...[
                  _PeriodChip(
                    label: switch (p) {
                      _ChartPeriod.d1 => '1D',
                      _ChartPeriod.w1 => '1W',
                      _ChartPeriod.m1 => '1M',
                      _ChartPeriod.y1 => '1Y',
                    },
                    selected: p == _period,
                    onTap: () => setState(() => _period = p),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
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
                data: (candles) {
                  if (candles.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('wealth_load_error'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  final chartUp = candles.last.close >= candles.first.close;
                  final color = chartUp ? AppColors.teal : AppColors.pink;
                  final minY = candles
                      .map((c) => c.low)
                      .reduce((a, b) => a < b ? a : b);
                  final maxY = candles
                      .map((c) => c.high)
                      .reduce((a, b) => a > b ? a : b);
                  final pad = (maxY - minY) * 0.08;
                  return LineChart(
                    LineChartData(
                      minY: minY - pad,
                      maxY: maxY + pad,
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < candles.length; i++)
                              FlSpot(i.toDouble(), candles[i].close),
                          ],
                          isCurved: true,
                          curveSmoothness: 0.15,
                          color: color,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withValues(alpha: 0.15),
                          ),
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
