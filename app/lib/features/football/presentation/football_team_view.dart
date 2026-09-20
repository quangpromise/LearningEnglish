import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_fixture_card.dart';
import 'football_providers.dart';
import 'football_widgets.dart';

/// Trang 1 doi bong: lich thi dau sap toi + ket qua gan day, tren MOI giai
/// dau (yeu cau muc 4 cua de bai: "khong chi Premier League").
///
/// Bo loc giai duoc dung tu chinh du lieu tra ve - chi hien nhung giai doi
/// nay THUC SU co tran, thay vi liet ke cung 6 giai roi de nguoi dung bam
/// vao cai rong.
class FootballTeamView extends ConsumerWidget {
  const FootballTeamView({
    super.key,
    required this.team,
    required this.onBack,
    required this.onOpenMatch,
  });

  final FootballTeam team;
  final VoidCallback onBack;
  final void Function(int fixtureId) onOpenMatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.watch(footballTeamFixturesProvider(team.id));
    final filter = ref.watch(footballTeamLeagueFilterProvider);
    final competitions =
        ref.watch(footballCompetitionsProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(title: team.name, onBack: onBack),
        const SizedBox(height: 12),

        GlowBox(
          padding: const EdgeInsets.all(14),
          borderRadius: 18,
          child: Row(
            children: [
              TeamBadge(team: team, size: 46),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  team.name,
                  style: AppTextStyles.heading(size: 16)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: fixtures.when(
            loading: () => const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: FootballColors.electric,
                ),
              ),
            ),
            error: (_, _) => FootballEmptyState(
              message: ref.tr('football_load_error'),
              icon: Icons.wifi_off_rounded,
            ),
            data: (all) {
              if (all.isEmpty) {
                return FootballEmptyState(
                  message: ref.tr('football_no_team_fixtures'),
                );
              }

              // Chi cac giai doi nay co tran - giu dung thu tu uu tien cua
              // bang football_competitions.
              final usedIds = all.map((f) => f.competitionId).toSet();
              final chips = competitions
                  .where((c) => usedIds.contains(c.id))
                  .toList();

              final shown = filter == null
                  ? all
                  : all.where((f) => f.competitionId == filter).toList();
              final now = DateTime.now();
              final upcoming = shown
                  .where((f) => f.kickoffLocal.isAfter(now))
                  .toList();
              final past =
                  shown.where((f) => !f.kickoffLocal.isAfter(now)).toList()
                    ..sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: ref.tr('football_filter_all'),
                          selected: filter == null,
                          onTap: () =>
                              ref
                                      .read(
                                        footballTeamLeagueFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  null,
                        ),
                        for (final c in chips)
                          _FilterChip(
                            label: c.name,
                            selected: filter == c.id,
                            onTap: () =>
                                ref
                                    .read(
                                      footballTeamLeagueFilterProvider.notifier,
                                    )
                                    .state = c
                                    .id,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        if (upcoming.isNotEmpty) ...[
                          _Label(text: ref.tr('football_upcoming')),
                          for (final f in upcoming)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: FixtureCard(
                                fixture: f,
                                onTap: () => onOpenMatch(f.id),
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                        if (past.isNotEmpty) ...[
                          _Label(text: ref.tr('football_results')),
                          for (final f in past)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: FixtureCard(
                                fixture: f,
                                onTap: () => onOpenMatch(f.id),
                              ),
                            ),
                        ],
                        if (upcoming.isEmpty && past.isEmpty)
                          FootballEmptyState(
                            message: ref.tr('football_no_team_fixtures'),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.muted(size: 10.5).copyWith(letterSpacing: 0.7),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? FootballColors.electric : AppColors.glassFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 11,
              weight: FontWeight.w700,
            ).copyWith(color: selected ? Colors.white : AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
