import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_providers.dart';
import 'football_standings_view.dart';
import 'football_widgets.dart';

enum _FootballStep { home, leagues, standings }

/// Man goc cua Football Center.
///
/// Giong [VocabularyTopicsScreen]: CA luong nam trong DUNG 1 popup
/// (openAppPopup tu menu AssistiveTouch), chuyen "man hinh" bang doi state
/// chu KHONG mo them route/sheet nao chong len. Ly do da ghi ky o
/// vocabulary_topics_screen.dart: mo sheet chong sheet se lam mat gesture
/// vuot-xuong-de-dong cua chinh popup goc.
class FootballCenterScreen extends ConsumerStatefulWidget {
  const FootballCenterScreen({super.key});

  @override
  ConsumerState<FootballCenterScreen> createState() =>
      _FootballCenterScreenState();
}

class _FootballCenterScreenState extends ConsumerState<FootballCenterScreen> {
  _FootballStep _step = _FootballStep.home;

  void _openStandings(int competitionId) {
    ref.read(footballSelectedCompetitionProvider.notifier).state =
        competitionId;
    setState(() => _step = _FootballStep.standings);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: switch (_step) {
            _FootballStep.home => _HomeView(
              onOpenLeagues: () =>
                  setState(() => _step = _FootballStep.leagues),
              onOpenStandings: _openStandings,
            ),
            _FootballStep.leagues => _LeaguesView(
              onBack: () => setState(() => _step = _FootballStep.home),
              onOpenStandings: _openStandings,
            ),
            _FootballStep.standings => FootballStandingsView(
              onBack: () => setState(() => _step = _FootballStep.home),
            ),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Man Home
// ---------------------------------------------------------------------------
class _HomeView extends ConsumerWidget {
  const _HomeView({required this.onOpenLeagues, required this.onOpenStandings});

  final VoidCallback onOpenLeagues;
  final void Function(int competitionId) onOpenStandings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitions = ref.watch(footballCompetitionsProvider);
    final live = ref.watch(footballLiveFixturesProvider);
    final today = ref.watch(footballFixturesOfDayProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupHeader(title: ref.tr('football_title')),
        const SizedBox(height: 14),
        Expanded(
          child: RefreshIndicator(
            color: FootballColors.electric,
            backgroundColor: AppColors.bgMid,
            onRefresh: () async {
              ref.invalidate(footballLiveFixturesProvider);
              ref.invalidate(footballFixturesOfDayProvider);
              ref.invalidate(footballCompetitionsProvider);
              await ref.read(footballLiveFixturesProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _SectionLabel(
                  label: ref.tr('football_live_now'),
                  trailing: live.valueOrNull?.isNotEmpty == true
                      ? const LivePill()
                      : null,
                ),
                const SizedBox(height: 8),
                live.when(
                  loading: () => const _LoadingBlock(),
                  error: (_, _) =>
                      _ErrorBlock(message: ref.tr('football_load_error')),
                  data: (fixtures) => fixtures.isEmpty
                      ? FootballEmptyState(message: ref.tr('football_no_live'))
                      : Column(
                          children: [
                            for (final f in fixtures.take(4))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: FixtureCard(fixture: f),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 18),

                _SectionLabel(
                  label: ref.tr('football_competitions'),
                  action: ref.tr('football_see_all'),
                  onAction: onOpenLeagues,
                ),
                const SizedBox(height: 8),
                competitions.when(
                  loading: () => const _LoadingBlock(),
                  error: (_, _) =>
                      _ErrorBlock(message: ref.tr('football_load_error')),
                  data: (list) => list.isEmpty
                      ? FootballEmptyState(
                          message: ref.tr('football_no_data_yet'),
                        )
                      : GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                          childAspectRatio: 0.86,
                          children: [
                            for (final c in list)
                              _CompetitionTile(
                                competition: c,
                                onTap: () => onOpenStandings(c.id),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 18),

                _SectionLabel(label: ref.tr('football_today_matches')),
                const SizedBox(height: 8),
                today.when(
                  loading: () => const _LoadingBlock(),
                  error: (_, _) =>
                      _ErrorBlock(message: ref.tr('football_load_error')),
                  data: (fixtures) => fixtures.isEmpty
                      ? FootballEmptyState(
                          message: ref.tr('football_no_match_today'),
                        )
                      : Column(
                          children: [
                            for (final f in fixtures)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: FixtureCard(fixture: f),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                const _LastSyncedLine(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Man danh sach giai dau
// ---------------------------------------------------------------------------
class _LeaguesView extends ConsumerWidget {
  const _LeaguesView({required this.onBack, required this.onOpenStandings});

  final VoidCallback onBack;
  final void Function(int competitionId) onOpenStandings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitions = ref.watch(footballCompetitionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(title: ref.tr('football_competitions'), onBack: onBack),
        const SizedBox(height: 14),
        Expanded(
          child: competitions.when(
            loading: () => const _LoadingBlock(),
            error: (_, _) =>
                _ErrorBlock(message: ref.tr('football_load_error')),
            data: (list) => list.isEmpty
                ? FootballEmptyState(message: ref.tr('football_no_data_yet'))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return GestureDetector(
                        onTap: () => onOpenStandings(c.id),
                        child: GlowBox(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          borderRadius: 18,
                          child: Row(
                            children: [
                              _CompetitionLogo(competition: c, size: 38),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: AppTextStyles.body(
                                        size: 14,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                    if (c.countryName != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        c.countryName!,
                                        style: AppTextStyles.muted(size: 11),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Thanh phan dung chung trong man Football
// ---------------------------------------------------------------------------

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

class _CompetitionTile extends StatelessWidget {
  const _CompetitionTile({required this.competition, required this.onTap});

  final FootballCompetition competition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        borderRadius: 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CompetitionLogo(competition: competition, size: 28),
            const SizedBox(height: 7),
            Text(
              competition.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 9, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo giai - cung nguyen tac voi [TeamBadge]: co anh thi hotlink, khong thi
/// ve o chu viet tat, khong bao gio de o trong.
class _CompetitionLogo extends StatelessWidget {
  const _CompetitionLogo({required this.competition, this.size = 32});

  final FootballCompetition competition;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = competition.logoUrl;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FootballColors.electric.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        competition.slug
            .split('-')
            .map((w) => w.isEmpty ? '' : w[0])
            .join()
            .toUpperCase(),
        style: AppTextStyles.heading(size: size * 0.32).copyWith(
          color: FootballColors.electric,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
    if (logo == null || logo.isEmpty) return fallback;
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        logo,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    this.action,
    this.onAction,
    this.trailing,
  });

  final String label;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.7),
        ),
        const SizedBox(width: 8),
        ?trailing,
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: AppTextStyles.body(
                size: 11,
                weight: FontWeight.w700,
              ).copyWith(color: FootballColors.electric),
            ),
          ),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FootballColors.electric,
          ),
        ),
      ),
    );
  }
}

/// Loi mang/timeout - bao ro rang, KHONG hien so lieu gia (yeu cau muc 18).
class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FootballEmptyState(message: message, icon: Icons.wifi_off_rounded);
  }
}

/// "Cap nhat luc HH:mm" - cho biet du lieu cu toi dau khi worker het quota
/// trong ngay, thay vi de nguoi dung tuong app hong.
class _LastSyncedLine extends ConsumerWidget {
  const _LastSyncedLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final at = ref.watch(footballLastSyncedProvider).valueOrNull;
    if (at == null) return const SizedBox.shrink();
    final label =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return Center(
      child: Text(
        ref.tr('football_last_updated').replaceFirst('{time}', label),
        style: AppTextStyles.muted(size: 10.5),
      ),
    );
  }
}
