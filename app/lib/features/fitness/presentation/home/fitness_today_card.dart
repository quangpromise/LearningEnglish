import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'fitness_home_theme.dart';

/// The "Ke hoach hom nay" - buoi tap cua hom nay theo lich tuan cua giao an
/// DANG THEO, kem 1 cau dong luc o day the.
///
/// 3 trang thai deu la du lieu that, khong co truong hop bia:
///  - Chua chon giao an -> moi nguoi dung chon (bam mo danh sach giao an).
///  - Hom nay la ngay nghi cua giao an -> noi ro la ngay nghi.
///  - Co buoi tap -> ten giao an + so bai + so hiep cua chinh ngay do.
class FitnessTodayCard extends ConsumerWidget {
  const FitnessTodayCard({
    super.key,
    required this.onOpenPlan,
    required this.quote,
  });

  final VoidCallback onOpenPlan;

  /// Cau dong luc o day the - chi de DOC, khong bam duoc: truoc day bam vao
  /// no mo dung man Thong ke ma the chi so ngay ben tren da mo.
  final String quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(todayWorkoutPlanProvider).valueOrNull;

    final String title;
    final List<(IconData, String)> meta;
    if (plan == null) {
      title = ref.tr('fitness_today_no_program');
      meta = const [];
    } else if (plan.isRestDay) {
      title = ref.tr('fitness_today_rest_day');
      meta = [(Icons.self_improvement_rounded, plan.program.titleVi)];
    } else {
      title = plan.program.titleVi;
      meta = [
        (
          Icons.fitness_center_rounded,
          ref
              .tr('fitness_today_exercise_count')
              .replaceFirst('{n}', '${plan.day.exercises.length}'),
        ),
        (
          Icons.repeat_rounded,
          ref
              .tr('fitness_today_set_count')
              .replaceFirst('{n}', '${plan.totalSets}'),
        ),
      ];
    }

    return FitnessCard(
      clip: true,
      child: Stack(
        children: [
          // Anh nen TRAN VIEN, cat ra tu file thiet ke cua chu du an (xem
          // docs/design/fitness-redesign/README.md) - nua trai cua anh da
          // duoc lam den san de chu doc duoc, nen khong can lop phu nang
          // nhu ban dung anh bai tap truoc day.
          Positioned.fill(
            child: Image.asset(
              'assets/fitness/home/today_plan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0, 0.55, 1],
                  colors: [
                    Color(0x8C111111),
                    Color(0x33111111),
                    Color(0x00111111),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FitnessPressable(
                onTap: onOpenPlan,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 10),
                  child: Row(
                    children: [
                      const _TargetRing(),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr('fitness_today_caption'),
                              style: FitnessHome.bodySecondary(),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.heading(size: 16)
                                  .copyWith(letterSpacing: -0.3),
                            ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (final (icon, label) in meta) ...[
                                    Icon(
                                      icon,
                                      size: 15,
                                      color: FitnessHome.textSecondary,
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FitnessHome.bodySecondary()
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: Color(0xFF9A9A9A),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: FitnessHome.divider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 11),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 34,
                      decoration: BoxDecoration(
                        color: FitnessHome.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        quote,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          size: 11.5,
                          weight: FontWeight.w500,
                          color: const Color(0xFFC9C9C9),
                        ).copyWith(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetRing extends StatelessWidget {
  const _TargetRing();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Icon(
        Icons.track_changes_rounded,
        size: 26,
        color: FitnessHome.red,
      ),
    );
  }
}
