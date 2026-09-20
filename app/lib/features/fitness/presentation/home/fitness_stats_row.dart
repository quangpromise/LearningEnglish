import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/meal_model.dart';
import 'fitness_home_theme.dart';

/// Hang 4 chi so o Trang chu Fitness. MOI con so deu lay tu du lieu that
/// cua nguoi dung; o nao chua co du lieu thi hien dau gach ngang chu khong
/// dien so mac dinh:
///  - Calo nap vao hom nay: tong kcal cac bua da log (Dinh duong).
///  - Buoi tap tuan nay: so buoi da hoan thanh / so buoi/tuan cua giao an.
///  - Tong khoi luong tuan nay: doi sang tan, kem mui ten so voi tuan truoc.
///  - Nhip tim: lan do GAN NHAT bang camera (xem heart_rate_service.dart).
class FitnessStatsRow extends ConsumerWidget {
  const FitnessStatsRow({
    super.key,
    required this.onOpenNutrition,
    required this.onOpenStatistics,
    required this.onOpenHeartRate,
  });

  /// Moi o mo dung man hinh CUA CHINH NO thay vi ca 4 o cung dan toi man
  /// Thong ke - truoc day bam o nao cung ra 1 man giong het nhau nen nguoi
  /// dung khong biet 4 o khac nhau cho nao.
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenStatistics;
  final VoidCallback onOpenHeartRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todayMealsProvider).valueOrNull ?? const [];
    final kcalToday = meals.fold<int>(0, (sum, m) => sum + m.kcal);
    final stats = ref.watch(fitnessDashboardStatsProvider).valueOrNull;
    final plan = ref.watch(todayWorkoutPlanProvider).valueOrNull;
    final heartRate = ref.watch(latestHeartRateProvider);
    final heartRateHistory =
        ref.watch(heartRateHistoryProvider).valueOrNull ?? const [];

    final sessionGoal = plan?.program.sessionsPerWeek ?? 7;
    final sessionsDone = stats?.sessionsThisWeek ?? 0;
    final volumeTons = (stats?.totalVolumeThisWeekKg ?? 0) / 1000;
    final volumeUp =
        (stats?.totalVolumeThisWeekKg ?? 0) >
        (stats?.previousWeekVolumeKg ?? 0);

    return FitnessCard(
      radius: FitnessHome.cardRadius,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: SizedBox(
        height: FitnessHome.statsHeight - 22 - 2,
        child: Stack(
          children: [
            // Vach dung ngan cot - ve o tang cha (khong phai border tung o)
            // de vach cao het chieu cao phan noi dung, dung nhu anh thiet ke.
            const Positioned.fill(
              child: CustomPaint(painter: _DividerPainter(4)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatCell(
                  onTap: onOpenNutrition,
                  icon: Icons.local_fire_department_rounded,
                  label: ref.tr('fitness_stat_calories'),
                  value: '$kcalToday',
                  unit: 'kcal',
                  indicator: _ProgressIndicatorBar(
                    fraction: (kcalToday / kNutritionGoalKcal).clamp(0.0, 1.0),
                  ),
                ),
                _StatCell(
                  onTap: onOpenStatistics,
                  icon: Icons.fitness_center_rounded,
                  label: ref.tr('fitness_stat_sessions'),
                  value: '$sessionsDone',
                  unit: '/ $sessionGoal',
                  indicator: _SessionDots(
                    done: sessionsDone,
                    goal: sessionGoal,
                  ),
                ),
                _StatCell(
                  onTap: onOpenStatistics,
                  icon: Icons.scale_rounded,
                  label: ref.tr('fitness_stat_volume'),
                  value: volumeTons >= 10
                      ? volumeTons.toStringAsFixed(0)
                      : volumeTons.toStringAsFixed(1),
                  unit: ref.tr('fitness_stat_volume_unit'),
                  trailingIcon: volumeUp && volumeTons > 0
                      ? Icons.trending_up_rounded
                      : null,
                ),
                _StatCell(
                  onTap: onOpenHeartRate,
                  icon: Icons.favorite_rounded,
                  label: ref.tr('fitness_stat_heart_rate'),
                  // Chua do lan nao -> gach ngang. KHONG dat 1 con so mac dinh
                  // o day (xem quy tac trong heart_rate_service.dart).
                  value: heartRate == null ? '--' : '${heartRate.bpm}',
                  unit: 'bpm',
                  indicator: heartRateHistory.length < 2
                      ? null
                      : _HeartRateSparkline(
                          values: heartRateHistory
                              .take(12)
                              .map((m) => m.bpm.toDouble())
                              .toList()
                              .reversed
                              .toList(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.indicator,
    this.trailingIcon,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  /// Thanh tien do / cham / duong nhip - ve o DAY o cua cot, de 4 cot deu
  /// nhau du noi dung khac loai.
  final Widget? indicator;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // opaque de bam vao khoang trong trong o (khong trung chu/icon) van
        // an - o chi so rat hep, bam trung dung chu la kho.
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: FitnessHome.red),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(label, maxLines: 1, style: FitnessHome.statLabel()),
              ),
              const SizedBox(height: 1),
              // FittedBox chu KHONG phai Flexible+ellipsis: khi cot hep, ban
              // cu cat mat han CON SO (phan quan trong nhat cua the) ma chi
              // con lai don vi - o day ca cum so + don vi cung thu nho lai.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, maxLines: 1, style: FitnessHome.statValue()),
                    const SizedBox(width: 4),
                    Text(unit, maxLines: 1, style: FitnessHome.statUnit()),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 3),
                      Icon(
                        trailingIcon,
                        size: 13,
                        color: FitnessHome.redBright,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              ?indicator,
            ],
          ),
        ),
      ),
    );
  }
}

/// Vach dung ngan giua cac cot cua the chi so.
class _DividerPainter extends CustomPainter {
  const _DividerPainter(this.columns);

  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FitnessHome.divider
      ..strokeWidth = 1;
    for (var i = 1; i < columns; i++) {
      final x = size.width * i / columns;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DividerPainter oldDelegate) =>
      oldDelegate.columns != columns;
}

class _ProgressIndicatorBar extends StatelessWidget {
  const _ProgressIndicatorBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            const ColoredBox(
              color: Color(0xFF2E2E2E),
              child: SizedBox.expand(),
            ),
            FractionallySizedBox(
              widthFactor: fraction,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 350),
                builder: (context, t, child) =>
                    Opacity(opacity: t, child: child),
                child: const ColoredBox(
                  color: FitnessHome.red,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDots extends StatelessWidget {
  const _SessionDots({required this.done, required this.goal});

  final int done;
  final int goal;

  @override
  Widget build(BuildContext context) {
    // Toi da 6 cham cho vua be ngang cot; giao an nhieu buoi hon van hien
    // dung ti le (moi cham = 1 phan cua muc tieu).
    final dots = goal.clamp(1, 6);
    final filled = goal == 0 ? 0 : (done / goal * dots).round().clamp(0, dots);
    // FittedBox: so cham phu thuoc muc tieu cua giao an (toi da 6) trong
    // khi be ngang cot lai doi theo khung thiet ke - de Row tu do thi co
    // truong hop tran ngang vai phan nghin dp.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < dots; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < filled ? FitnessHome.red : const Color(0xFF333333),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeartRateSparkline extends StatelessWidget {
  const _HeartRateSparkline({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 9,
    child: CustomPaint(
      painter: _SparklinePainter(values),
      child: const SizedBox.expand(),
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs() < 1 ? 1.0 : max - min;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - (values[i] - min) / range);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = FitnessHome.redBright
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}
