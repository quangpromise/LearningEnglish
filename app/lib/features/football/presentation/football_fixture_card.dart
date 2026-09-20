import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_widgets.dart';

/// The 1 tran dau - dung chung cho ca danh sach live lan lich thi dau.
class FixtureCard extends ConsumerWidget {
  const FixtureCard({super.key, required this.fixture, this.onTap});

  final FootballFixture fixture;
  final VoidCallback? onTap;

  /// Gio bong lan theo mui gio MAY NGUOI DUNG (yeu cau muc 18).
  String _timeLabel() {
    final t = fixture.kickoffLocal;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        borderRadius: 16,
        border: fixture.isLive
            ? Border.all(color: FootballColors.live.withValues(alpha: 0.4))
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _TeamLine(team: fixture.homeTeam, goals: fixture.homeGoals),
                  const SizedBox(height: 8),
                  _TeamLine(team: fixture.awayTeam, goals: fixture.awayGoals),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 34, color: AppColors.glassBorder),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              child: Center(
                child: switch (fixture.state) {
                  FixtureState.live => LivePill(minute: fixture.elapsed),
                  FixtureState.finished => Text(
                    ref.tr('football_finished_short'),
                    style: AppTextStyles.muted(size: 10.5),
                  ),
                  FixtureState.postponed => Text(
                    ref.tr('football_postponed_short'),
                    style: AppTextStyles.muted(size: 10.5),
                  ),
                  FixtureState.upcoming => Text(
                    _timeLabel(),
                    style: AppTextStyles.heading(size: 13)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({required this.team, required this.goals});

  final FootballTeam? team;
  final int? goals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamBadge(team: team, size: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            team?.name ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(size: 12.5, weight: FontWeight.w700),
          ),
        ),
        if (goals != null)
          Text(
            '$goals',
            style: AppTextStyles.heading(size: 13)
                .copyWith(fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}
