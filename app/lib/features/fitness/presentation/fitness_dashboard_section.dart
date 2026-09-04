import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/workout_repository.dart';

const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Loi khuyen theo luat co dinh, KHONG phai AI/ML - port dung tinh than
/// Recommendation.kt cua FitViet (Gate 13): uu tien theo thu tu co dinh (1)
/// khong tap trong 7 ngay qua -> nhac quay lai, (2) chuoi >=3 ngay -> khen,
/// (3) con lai -> 1 trong vai loi khuyen chung, chon xoay vong theo NGAY
/// (deterministic, khong random) de moi ngay 1 cau khac nhau ma van on
/// dinh trong cung 1 ngay.
String _recommendation(WidgetRef ref, FitnessDashboardStats stats) {
  final noRecentSession = stats.dailyVolumeLast7.every((v) => v <= 0);
  if (noRecentSession) return ref.tr('fitness_dashboard_tip_come_back');
  if (stats.streakDays >= 3) {
    return ref
        .tr('fitness_dashboard_tip_streak_praise')
        .replaceFirst('{n}', '${stats.streakDays}');
  }
  const tipKeys = [
    'fitness_dashboard_tip_generic_1',
    'fitness_dashboard_tip_generic_2',
    'fitness_dashboard_tip_generic_3',
  ];
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year))
      .inDays;
  return ref.tr(tipKeys[dayOfYear % tipKeys.length]);
}

/// Khoi "Trang chu" thu nho cho khu vuc Fitness (Phase 4) - port rut gon tu
/// Dashboard cua FitViet (Gate 3/13/18/19): 3 the chi so, bieu do cot khoi
/// luong 7 ngay, 1 dong loi khuyen theo luat co dinh. Nhung tinh
/// nang KHONG port o phase nay (ngoai pham vi, xem ke hoach da duyet):
/// widget toggle bat/tat tung the (Gate 19), bieu do can bang nhom co
/// (can du lieu muscleGroupCode tren tung set log, chua thu thap o Phase 2),
/// 3 khoang thoi gian TUAN/THANG/TAT CA (Gate 43, chi giu 7 ngay co dinh).
class FitnessDashboardSection extends ConsumerWidget {
  const FitnessDashboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(fitnessDashboardStatsProvider);
    final stats = statsAsync.valueOrNull;
    if (stats == null) return const SizedBox.shrink();

    return GlowBox(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatTile(
                value: '${stats.streakDays}',
                label: ref.tr('fitness_dashboard_streak'),
              ),
              _StatTile(
                value: '${stats.sessionsThisWeek}',
                label: ref.tr('fitness_dashboard_sessions_week'),
              ),
              _StatTile(
                value: stats.totalVolumeThisWeekKg.toStringAsFixed(0),
                label: ref.tr('fitness_dashboard_volume_week'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            ref.tr('fitness_dashboard_weekly_volume_title'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 8),
          _WeeklyVolumeChart(dailyVolume: stats.dailyVolumeLast7),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fitnessAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 18,
                  color: AppColors.fitnessAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _recommendation(ref, stats),
                    style: AppTextStyles.body(size: 12.5),
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading(size: 20)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted().copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _WeeklyVolumeChart extends StatelessWidget {
  const _WeeklyVolumeChart({required this.dailyVolume});

  /// 7 gia tri, index 0 la 6 ngay truoc, index 6 la hom nay.
  final List<double> dailyVolume;

  @override
  Widget build(BuildContext context) {
    final maxValue = dailyVolume.fold<double>(0, (m, v) => v > m ? v : m);
    final today = DateTime.now();
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final daysAgo = 6 - i;
          final weekday = today
              .subtract(Duration(days: daysAgo))
              .weekday; // 1-7
          final value = dailyVolume[i];
          final heightFraction = maxValue <= 0 ? 0.0 : (value / maxValue);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 6 + 40 * heightFraction,
                    decoration: BoxDecoration(
                      color: daysAgo == 0
                          ? AppColors.fitnessAccent
                          : AppColors.fitnessAccent.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekdayShort[weekday - 1],
                    style: AppTextStyles.muted().copyWith(fontSize: 9.5),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
