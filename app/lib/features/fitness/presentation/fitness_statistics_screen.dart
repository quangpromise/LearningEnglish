import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/workout_repository.dart';
import 'home/fitness_home_theme.dart';

/// Man Thong ke cua khu vuc Fitness: so buoi tap, thoi luong, tong khoi
/// luong va duong khoi luong theo thoi gian, loc theo 7 ngay / 30 ngay /
/// 3 thang / 1 nam.
///
/// Moi con so deu tinh tu cac buoi DA HOAN THANH trong Supabase (xem
/// [WorkoutRepository.getHistorySeries]) - khong co so lieu mau nao.
/// Bieu do dung fl_chart voi bang mau cua man Fitness: nen den, luoi xam
/// rat mo, duong do, KHONG dung them mau nao khac.
class FitnessStatisticsScreen extends ConsumerWidget {
  const FitnessStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(fitnessStatsRangeProvider);
    final seriesAsync = ref.watch(fitnessHistorySeriesProvider);

    return FitnessScreenScaffold(
      title: ref.tr('fitness_stats_title'),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const _StreakCard(),
          const SizedBox(height: 14),
          _RangeFilter(
            selected: range,
            onChanged: (value) =>
                ref.read(fitnessStatsRangeProvider.notifier).state = value,
          ),
          const SizedBox(height: 14),
          seriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: FitnessHome.red),
              ),
            ),
            error: (_, _) => FitnessCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                ref.tr('fitness_stats_error'),
                style: FitnessHome.bodySecondary(size: 12.5),
              ),
            ),
            data: (series) => _Body(series: series, range: range),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.series, required this.range});

  final FitnessHistorySeries series;
  final FitnessStatsRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumeTons = series.totalVolumeKg / 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.event_available_rounded,
                label: ref.tr('fitness_stats_sessions'),
                value: '${series.totalSessions}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                icon: Icons.timer_outlined,
                label: ref.tr('fitness_stats_duration'),
                value: _formatMinutes(series.totalMinutes),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                icon: Icons.scale_rounded,
                label: ref.tr('fitness_stats_volume'),
                value: volumeTons >= 10
                    ? '${volumeTons.toStringAsFixed(0)}t'
                    : '${volumeTons.toStringAsFixed(1)}t',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (series.isEmpty)
          FitnessCard(
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
            child: Center(
              child: Text(
                ref.tr('fitness_stats_empty'),
                textAlign: TextAlign.center,
                style: FitnessHome.bodySecondary(size: 12.5),
              ),
            ),
          )
        else ...[
          _ChartCard(
            title: ref.tr('fitness_stats_volume_chart'),
            child: _VolumeLineChart(
              buckets: _bucketize(series.dailyVolumeKg, range),
            ),
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: ref.tr('fitness_stats_sessions_chart'),
            child: _SessionsBarChart(
              buckets: _bucketize(
                series.dailySessions.map((v) => v.toDouble()).toList(),
                range,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}p';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h$rest';
  }
}

/// Gop du lieu NGAY thanh cac cot vua man hinh: 7/30 ngay ve theo ngay,
/// 3 thang gop theo tuan, 1 nam gop theo thang - neu khong, bieu do 365 cot
/// se thanh 1 mang mau dac khong doc duoc.
List<double> _bucketize(List<double> daily, FitnessStatsRange range) {
  final groupSize = switch (range) {
    FitnessStatsRange.week => 1,
    FitnessStatsRange.month => 1,
    FitnessStatsRange.quarter => 7,
    FitnessStatsRange.year => 30,
  };
  if (groupSize == 1) return daily;
  final out = <double>[];
  for (var i = 0; i < daily.length; i += groupSize) {
    final end = (i + groupSize).clamp(0, daily.length);
    out.add(daily.sublist(i, end).fold<double>(0, (sum, v) => sum + v));
  }
  return out;
}

class _RangeFilter extends ConsumerWidget {
  const _RangeFilter({required this.selected, required this.onChanged});

  final FitnessStatsRange selected;
  final ValueChanged<FitnessStatsRange> onChanged;

  static const _labelKeys = {
    FitnessStatsRange.week: 'fitness_stats_range_week',
    FitnessStatsRange.month: 'fitness_stats_range_month',
    FitnessStatsRange.quarter: 'fitness_stats_range_quarter',
    FitnessStatsRange.year: 'fitness_stats_range_year',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (final range in FitnessStatsRange.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(range),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: range == selected ? FitnessHome.red : FitnessHome.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: range == selected
                        ? FitnessHome.red
                        : FitnessHome.cardBorder,
                  ),
                ),
                child: Text(
                  ref.tr(_labelKeys[range]!),
                  style: AppTextStyles.body(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: range == selected
                        ? Colors.white
                        : FitnessHome.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          if (range != FitnessStatsRange.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: FitnessHome.red),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FitnessHome.statLabel(),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading(size: 19),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FitnessHome.bodySecondary(size: 12)),
          const SizedBox(height: 14),
          SizedBox(height: 150, child: child),
        ],
      ),
    );
  }
}

class _VolumeLineChart extends StatelessWidget {
  const _VolumeLineChart({required this.buckets});

  final List<double> buckets;

  @override
  Widget build(BuildContext context) {
    final maxY = buckets.fold<double>(0, (m, v) => v > m ? v : m);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 1 : maxY * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (maxY <= 0 ? 1 : maxY * 1.2) / 3,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: FitnessHome.divider, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          // Nhan truc bi bo han: cac cot ke sat nhau o moc 30 ngay/1 nam se
          // chong chu len nhau. Con so cu the doc o 3 the tong o tren.
          show: false,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < buckets.length; i++)
                FlSpot(i.toDouble(), buckets[i]),
            ],
            isCurved: true,
            curveSmoothness: 0.25,
            color: FitnessHome.red,
            barWidth: 2.4,
            dotData: FlDotData(show: buckets.length <= 10),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FitnessHome.red.withValues(alpha: 0.28),
                  FitnessHome.red.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 350),
    );
  }
}

class _SessionsBarChart extends StatelessWidget {
  const _SessionsBarChart({required this.buckets});

  final List<double> buckets;

  @override
  Widget build(BuildContext context) {
    final maxY = buckets.fold<double>(0, (m, v) => v > m ? v : m);
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY <= 0 ? 1 : maxY * 1.25,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i],
                  width: buckets.length > 30 ? 3 : 7,
                  borderRadius: BorderRadius.circular(3),
                  color: buckets[i] > 0 ? FitnessHome.red : FitnessHome.divider,
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 350),
    );
  }
}

/// Chuoi ngay tap lien tiep + goi y theo LUAT CO DINH (khong phai AI): lau
/// khong tap -> nhac quay lai, dang co chuoi >= 3 ngay -> khen, con lai ->
/// 1 loi khuyen chung doi theo ngay. Port tu khoi Dashboard cu cua man
/// Fitness Home truoc khi thiet ke lai.
class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  static const _tipKeys = [
    'fitness_dashboard_tip_generic_1',
    'fitness_dashboard_tip_generic_2',
    'fitness_dashboard_tip_generic_3',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(fitnessDashboardStatsProvider).valueOrNull;
    if (stats == null) return const SizedBox.shrink();

    final String tip;
    if (stats.dailyVolumeLast7.every((v) => v <= 0)) {
      tip = ref.tr('fitness_dashboard_tip_come_back');
    } else if (stats.streakDays >= 3) {
      tip = ref
          .tr('fitness_dashboard_tip_streak_praise')
          .replaceFirst('{n}', '\${stats.streakDays}');
    } else {
      final dayOfYear = DateTime.now()
          .difference(DateTime(DateTime.now().year))
          .inDays;
      tip = ref.tr(_tipKeys[dayOfYear % _tipKeys.length]);
    }

    return FitnessCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FitnessHome.red.withValues(alpha: 0.14),
              border: Border.all(
                color: FitnessHome.red.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '\${stats.streakDays}',
              style: AppTextStyles.heading(size: 20),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('fitness_dashboard_streak'),
                  style: FitnessHome.bodySecondary(size: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
