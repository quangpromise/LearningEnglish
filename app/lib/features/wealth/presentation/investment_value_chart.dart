import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_investment_snapshot_repository.dart';

/// Khoang thoi gian xem cua bieu do gia tri danh muc - dat ten/thu tu giong
/// cac nut o chart coin (crypto_coin_detail_screen) cho quen tay.
enum InvestmentChartRange { d1, w1, m1, m3, y1 }

extension on InvestmentChartRange {
  Duration get window => switch (this) {
    InvestmentChartRange.d1 => const Duration(days: 1),
    InvestmentChartRange.w1 => const Duration(days: 7),
    InvestmentChartRange.m1 => const Duration(days: 30),
    InvestmentChartRange.m3 => const Duration(days: 90),
    InvestmentChartRange.y1 => const Duration(days: 365),
  };

  String get label => switch (this) {
    InvestmentChartRange.d1 => '1D',
    InvestmentChartRange.w1 => '1W',
    InvestmentChartRange.m1 => '1M',
    InvestmentChartRange.m3 => '3M',
    InvestmentChartRange.y1 => '1Y',
  };
}

/// Cac moc gia tri danh muc trong khoang [range]. autoDispose: chi song khi
/// dang mo man co bieu do.
final investmentSnapshotsProvider = FutureProvider.autoDispose
    .family<List<InvestmentSnapshot>, InvestmentChartRange>((ref, range) async {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return const [];
      return WealthInvestmentSnapshotRepository.fetch(
        userId: userId,
        since: DateTime.now().subtract(range.window),
      );
    });

/// Ghi lai gia tri danh muc hien tai (toi da 1 lan/gio) - dat o bat ky man
/// nao co hien tong dau tu. Khong ve gi ca, chi la 1 "moc" de bieu do co du
/// lieu ma ve.
///
/// TACH RIENG khoi bieu do: neu chi ghi khi nguoi dung MO bieu do thi bieu
/// do se mai mai gan nhu trong - phai ghi ngay ca khi ho chi luot qua man
/// Home.
class InvestmentSnapshotRecorder extends ConsumerStatefulWidget {
  const InvestmentSnapshotRecorder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InvestmentSnapshotRecorder> createState() =>
      _InvestmentSnapshotRecorderState();
}

class _InvestmentSnapshotRecorderState
    extends ConsumerState<InvestmentSnapshotRecorder> {
  @override
  Widget build(BuildContext context) {
    final total = ref.watch(totalInvestmentValueVndProvider);
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    if (userId != null && total > 0) {
      // Goi NGOAI pha build (post-frame): ghi du lieu ngay trong build la
      // tac dung phu, va o day build chay lai moi lan gia song nhay.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WealthInvestmentSnapshotRepository.record(
          userId: userId,
          valueVnd: total,
        );
      });
    }
    return widget.child;
  }
}

/// Bieu do gia tri danh muc dau tu theo thoi gian - duong gia tri + vung to
/// mo ben duoi, mau vang theo bang mau khu Tai san.
///
/// [compact] = ban nho nhung tren the o man Home: chi con duong, khong nut
/// chon khoang thoi gian, khong truc.
class InvestmentValueChart extends ConsumerStatefulWidget {
  const InvestmentValueChart({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<InvestmentValueChart> createState() =>
      _InvestmentValueChartState();
}

class _InvestmentValueChartState extends ConsumerState<InvestmentValueChart> {
  InvestmentChartRange _range = InvestmentChartRange.m1;

  @override
  Widget build(BuildContext context) {
    final range = widget.compact ? InvestmentChartRange.m1 : _range;
    final snapsAsync = ref.watch(investmentSnapshotsProvider(range));
    final liveTotal = ref.watch(totalInvestmentValueVndProvider);

    final snaps = snapsAsync.valueOrNull ?? const <InvestmentSnapshot>[];
    // Diem CUOI luon la gia tri SONG hien tai (khong doi toi lan ghi moc
    // tiep theo) - nho vay duong bieu do nhuc nhich theo gia y nhu chart
    // coin, thay vi dung yen ca tieng dong ho.
    final points = <(DateTime, double)>[
      for (final s in snaps) (s.takenAt, s.valueVnd),
      if (liveTotal > 0) (DateTime.now(), liveTotal),
    ];

    if (points.length < 2) {
      return _EmptyState(compact: widget.compact);
    }

    final first = points.first.$2;
    final last = points.last.$2;
    final diff = last - first;
    final percent = first == 0 ? null : diff / first * 100;
    final up = diff >= 0;
    final lineColor = up ? AppColors.wealthUp : AppColors.pink;

    final minX = points.first.$1.millisecondsSinceEpoch.toDouble();
    final maxX = points.last.$1.millisecondsSinceEpoch.toDouble();
    final values = points.map((p) => p.$2);
    final rawMin = values.reduce((a, b) => a < b ? a : b);
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    // Khoang gia tri phang lì (moi do 1-2 moc gan bang nhau) se lam duong
    // dinh sat day/dinh khung - nong them 1 chut cho de nhin.
    final pad = ((rawMax - rawMin) * 0.12).clamp(
      rawMax * 0.002,
      double.infinity,
    );

    final chart = LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX == minX ? minX + 1 : maxX,
        minY: rawMin - pad,
        maxY: rawMax + pad,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final p in points)
                FlSpot(p.$1.millisecondsSinceEpoch.toDouble(), p.$2),
            ],
            isCurved: true,
            curveSmoothness: 0.2,
            color: lineColor,
            barWidth: widget.compact ? 1.6 : 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.28),
                  lineColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.compact) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatVnd(last),
              style: AppTextStyles.heading(size: 22)
                  .copyWith(color: AppColors.wealthAmount),
            ),
            const SizedBox(width: 8),
            if (percent != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${up ? '+' : ''}${formatVnd(diff)} '
                  '(${up ? '+' : ''}${percent.toStringAsFixed(1)}%)',
                  style: AppTextStyles.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: lineColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(height: 150, child: chart),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final r in InvestmentChartRange.values)
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: GestureDetector(
                  onTap: () => setState(() => _range = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _range == r
                          ? AppColors.wealthAccent.withValues(alpha: 0.22)
                          : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _range == r
                            ? AppColors.wealthAccent
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: AppTextStyles.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: _range == r
                            ? AppColors.wealthAccent
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Chua du 2 moc de ve duong - noi ro LY DO thay vi de 1 o trong, vi day la
/// trang thai BINH THUONG voi nguoi dung moi (app chi bat dau ghi moc tu lan
/// cap nhat nay, xem migration 0068).
class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            ref.tr('investment_chart_empty'),
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 12),
          ),
        ),
      ),
    );
  }
}
