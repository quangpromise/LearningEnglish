import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../english_path/data/cefr_level.dart';
import '../../english_path/data/english_path_providers.dart';
import '../../english_path/presentation/level_test_screen.dart';
import '../../fitness/data/body_level.dart';
import '../data/gymtalk_rank.dart';

/// The "Cap do" o man Tien do (spec #45): English Level (+ Estimated Band
/// gan nhat), Body Level (+ muc tieu ke tiep) va GymTalk Rank. XP chi con
/// la diem tich luy - khong con "cap XP" rieng.
class LevelsCard extends ConsumerWidget {
  const LevelsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = ref.watch(englishLevelProvider);
    final pathState = ref.watch(englishPathStateProvider);
    final bodyStats = ref.watch(bodyStatsProvider).valueOrNull;
    final xp = ref.watch(myLearningXpProvider).valueOrNull;
    final body = bodyStats == null ? null : bodyLevelFor(bodyStats);
    final next = bodyStats == null ? null : nextBodyTarget(bodyStats);
    // Band GAN NHAT (spec #45) - Level Test dat moi nhat co band.
    final withBand = [
      for (final r in pathState.levelTests.values)
        if (r.estimatedBand != null) r,
    ]..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    final band = withBand.isEmpty ? null : withBand.first.estimatedBand;
    final rank = body == null ? null : gymTalkRank(body, english);

    return GlowBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ref.tr('progress_levels_title'),
            style: AppTextStyles.muted(size: 13),
          ),
          const SizedBox(height: 10),
          _LevelRow(
            icon: Icons.school_rounded,
            color: AppColors.blue,
            badge: english.code,
            title: ref.tr(english.labelKey),
            subtitle: band == null
                ? ref.tr('progress_english_hint')
                : ref
                      .tr('progress_band')
                      .replaceFirst('{band}', band.toStringAsFixed(1)),
          ),
          if (band != null)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 2),
              child: Text(
                kEstimatedBandDisclaimer,
                style: AppTextStyles.muted(size: 11),
              ),
            ),
          const SizedBox(height: 12),
          _LevelRow(
            icon: Icons.fitness_center_rounded,
            color: AppColors.fitnessAccent,
            badge: body == null ? '…' : '${body.index + 1}',
            title: body == null ? '…' : ref.tr('body_level_${body.name}'),
            subtitle: next == null
                ? (body == null ? '' : ref.tr('progress_body_max'))
                : ref
                      .tr(switch ((next.workoutsNeeded, next.weeksNeeded)) {
                        (0, _) => 'progress_body_next_weeks',
                        (_, 0) => 'progress_body_next_workouts',
                        _ => 'progress_body_next',
                      })
                      .replaceFirst('{w}', '${next.workoutsNeeded}')
                      .replaceFirst('{k}', '${next.weeksNeeded}')
                      .replaceFirst(
                        '{level}',
                        ref.tr('body_level_${next.level.name}'),
                      ),
          ),
          if (rank != null) ...[
            const Divider(height: 24, color: AppColors.glassBorder),
            Row(
              children: [
                const Icon(
                  Icons.military_tech_rounded,
                  color: AppColors.amber,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref
                            .tr('progress_rank')
                            .replaceFirst('{n}', '${rank.tier + 1}')
                            .replaceFirst(
                              '{max}',
                              '${CefrLevel.values.length}',
                            ),
                        style: AppTextStyles.heading(size: 16),
                      ),
                      Text(
                        ref.tr('progress_rank_${rank.limitedBy.name}'),
                        style: AppTextStyles.muted(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (xp != null) ...[
            const SizedBox(height: 10),
            Text(
              ref.tr('progress_xp_points').replaceFirst('{xp}', '${xp.xp}'),
              style: AppTextStyles.muted(size: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.icon,
    required this.color,
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String badge;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.18),
          border: Border.all(color: color, width: 1.6),
        ),
        child: Text(badge, style: AppTextStyles.heading(size: 14)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title, style: AppTextStyles.heading(size: 16)),
                ),
              ],
            ),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: AppTextStyles.muted(size: 12)),
          ],
        ),
      ),
    ],
  );
}
