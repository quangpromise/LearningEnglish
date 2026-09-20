import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_providers.dart';
import 'football_widgets.dart';

enum _Tab { overview, events, stats, lineup }

/// Match Center - chi tiet 1 tran.
///
/// Ti so va timeline TU CAP NHAT qua Supabase Realtime khi worker
/// `football-live` ghi su kien moi: may nguoi dung khong goi them request nao
/// (dung yeu cau "khong polling lien tuc tu tung dien thoai").
///
/// Doi hinh + thong ke KHONG duoc dong bo san cho moi tran - lay truoc cho
/// tat ca se dot sach han muc 100 request/ngay. Man nay mo ra moi yeu cau
/// backend lay 1 lan (xem [FootballRepository.requestMatchDetail]).
class FootballMatchCenterView extends ConsumerStatefulWidget {
  const FootballMatchCenterView({
    super.key,
    required this.fixtureId,
    required this.onBack,
  });

  final int fixtureId;
  final VoidCallback onBack;

  @override
  ConsumerState<FootballMatchCenterView> createState() =>
      _FootballMatchCenterViewState();
}

class _FootballMatchCenterViewState
    extends ConsumerState<FootballMatchCenterView> {
  _Tab _tab = _Tab.overview;
  bool _requestedDetail = false;

  /// Xin backend lay doi hinh/thong ke - chi 1 lan cho moi lan mo man.
  Future<void> _ensureDetail() async {
    if (_requestedDetail) return;
    _requestedDetail = true;
    final ok = await ref
        .read(footballRepositoryProvider)
        .requestMatchDetail(widget.fixtureId);
    if (!ok || !mounted) return;
    ref.invalidate(footballLineupsProvider(widget.fixtureId));
    ref.invalidate(footballMatchStatsProvider(widget.fixtureId));
  }

  @override
  Widget build(BuildContext context) {
    // Ban tinh: co ten 2 doi (join tu football_teams).
    final base = ref
        .watch(footballFixtureProvider(widget.fixtureId))
        .valueOrNull;
    // Ban realtime: chi co ti so/trang thai (stream khong keo theo join) - ghep
    // 2 nguon lai de vua co ten doi vua co ti so moi nhat.
    final liveRow = ref
        .watch(footballLiveFixtureProvider(widget.fixtureId))
        .valueOrNull;

    final home = base?.homeTeam;
    final away = base?.awayTeam;
    final homeGoals = liveRow?.homeGoals ?? base?.homeGoals;
    final awayGoals = liveRow?.awayGoals ?? base?.awayGoals;
    final state = liveRow?.state ?? base?.state ?? FixtureState.upcoming;
    final elapsed = liveRow?.elapsed ?? base?.elapsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(
          title: ref.tr('football_match_center'),
          onBack: widget.onBack,
        ),
        const SizedBox(height: 12),

        GlowBox(
          padding: const EdgeInsets.all(15),
          borderRadius: 18,
          border: state == FixtureState.live
              ? Border.all(color: FootballColors.live.withValues(alpha: 0.4))
              : null,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _TeamColumn(team: home)),
                  Column(
                    children: [
                      Text(
                        homeGoals == null || awayGoals == null
                            ? 'vs'
                            : '$homeGoals - $awayGoals',
                        style: AppTextStyles.heading(size: 26)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 7),
                      switch (state) {
                        FixtureState.live => LivePill(minute: elapsed),
                        FixtureState.finished => Text(
                          ref.tr('football_finished_short'),
                          style: AppTextStyles.muted(size: 10.5),
                        ),
                        FixtureState.postponed => Text(
                          ref.tr('football_postponed_short'),
                          style: AppTextStyles.muted(size: 10.5),
                        ),
                        FixtureState.upcoming => Text(
                          base == null ? '' : _kickoffLabel(base),
                          style: AppTextStyles.muted(size: 10.5),
                        ),
                      },
                    ],
                  ),
                  Expanded(child: _TeamColumn(team: away)),
                ],
              ),
              if (base?.venue != null) ...[
                const SizedBox(height: 12),
                Text(base!.venue!, style: AppTextStyles.muted(size: 10.5)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TabChip(
                label: ref.tr('football_tab_overview'),
                selected: _tab == _Tab.overview,
                onTap: () => setState(() => _tab = _Tab.overview),
              ),
              _TabChip(
                label: ref.tr('football_tab_events'),
                selected: _tab == _Tab.events,
                onTap: () => setState(() => _tab = _Tab.events),
              ),
              _TabChip(
                label: ref.tr('football_tab_stats'),
                selected: _tab == _Tab.stats,
                onTap: () {
                  setState(() => _tab = _Tab.stats);
                  _ensureDetail();
                },
              ),
              _TabChip(
                label: ref.tr('football_tab_lineup'),
                selected: _tab == _Tab.lineup,
                onTap: () {
                  setState(() => _tab = _Tab.lineup);
                  _ensureDetail();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: switch (_tab) {
            _Tab.overview ||
            _Tab.events => _EventsTab(fixtureId: widget.fixtureId),
            _Tab.stats => _StatsTab(
              fixtureId: widget.fixtureId,
              home: home,
              away: away,
            ),
            _Tab.lineup => _LineupTab(
              fixtureId: widget.fixtureId,
              home: home,
              away: away,
            ),
          },
        ),
      ],
    );
  }

  String _kickoffLabel(FootballFixture f) {
    final t = f.kickoffLocal;
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day}/${t.month} $hh:$mm';
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.team});

  final FootballTeam? team;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamBadge(team: team, size: 44),
        const SizedBox(height: 8),
        Text(
          team?.name ?? '-',
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(size: 11.5, weight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
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
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? FootballColors.live : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 11.5,
              weight: FontWeight.w700,
            ).copyWith(color: selected ? Colors.white : AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

/// Timeline su kien - nghe Realtime nen tu cap nhat khi co ban thang moi.
class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.fixtureId});

  final int fixtureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(footballLiveEventsProvider(fixtureId));
    return events.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
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
      data: (list) => list.isEmpty
          ? FootballEmptyState(message: ref.tr('football_no_events'))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0x0DFFFFFF)),
              itemBuilder: (context, i) => _EventRow(event: list[i]),
            ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final FootballMatchEvent event;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (event) {
      final e when e.isGoal => (Icons.sports_soccer_rounded, AppColors.teal),
      final e when e.isYellowCard => (
        Icons.square_rounded,
        const Color(0xFFFFD66B),
      ),
      final e when e.isRedCard => (Icons.square_rounded, FootballColors.live),
      final e when e.isSubstitution => (
        Icons.swap_horiz_rounded,
        FootballColors.electric,
      ),
      _ => (Icons.circle_outlined, AppColors.textMuted),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              event.minuteLabel,
              textAlign: TextAlign.right,
              style: AppTextStyles.heading(size: 11.5).copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.playerName ?? event.type,
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w700,
                  ),
                ),
                if (event.assistName != null || event.teamName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.assistName ?? event.teamName ?? '',
                    style: AppTextStyles.muted(size: 10.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thong ke 2 cot voi thanh so sanh.
class _StatsTab extends ConsumerWidget {
  const _StatsTab({
    required this.fixtureId,
    required this.home,
    required this.away,
  });

  final int fixtureId;
  final FootballTeam? home;
  final FootballTeam? away;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(footballMatchStatsProvider(fixtureId));
    return stats.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
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
      data: (list) {
        if (list.isEmpty) {
          return FootballEmptyState(message: ref.tr('football_no_stats'));
        }
        final homeStats = list.where((s) => s.teamId == home?.id).firstOrNull;
        final awayStats = list.where((s) => s.teamId == away?.id).firstOrNull;
        if (homeStats == null || awayStats == null) {
          return FootballEmptyState(message: ref.tr('football_no_stats'));
        }

        // Chi hien chi so co o CA HAI doi - so sanh 1 ben khong co nghia gi.
        final awayByName = {for (final e in awayStats.entries) e.name: e};
        final pairs = [
          for (final e in homeStats.entries)
            if (awayByName.containsKey(e.name)) (e, awayByName[e.name]!),
        ];
        if (pairs.isEmpty) {
          return FootballEmptyState(message: ref.tr('football_no_stats'));
        }

        return ListView(
          children: [
            for (final (h, a) in pairs)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _StatBar(name: h.name, home: h, away: a),
              ),
          ],
        );
      },
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.name, required this.home, required this.away});

  final String name;
  final FootballStatEntry home;
  final FootballStatEntry away;

  @override
  Widget build(BuildContext context) {
    final h = home.numeric ?? 0;
    final a = away.numeric ?? 0;
    final total = h + a;
    // Ca 2 deu 0 (hoac khong doc duoc ra so): chia doi de thanh khong bi lech
    // ngau nhien ve 1 ben.
    final hRatio = total <= 0 ? 0.5 : h / total;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 46,
              child: Text(
                home.value,
                style: AppTextStyles.heading(size: 12)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.muted(size: 10.5),
              ),
            ),
            SizedBox(
              width: 46,
              child: Text(
                away.value,
                textAlign: TextAlign.right,
                style: AppTextStyles.heading(size: 12)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 5,
            child: Row(
              children: [
                Expanded(
                  flex: (hRatio * 1000).round().clamp(1, 999),
                  child: Container(color: FootballColors.live),
                ),
                Expanded(
                  flex: ((1 - hRatio) * 1000).round().clamp(1, 999),
                  child: Container(color: FootballColors.electric),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Doi hinh ra san - danh sach chinh thuc + du bi cua tung doi.
class _LineupTab extends ConsumerWidget {
  const _LineupTab({
    required this.fixtureId,
    required this.home,
    required this.away,
  });

  final int fixtureId;
  final FootballTeam? home;
  final FootballTeam? away;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineups = ref.watch(footballLineupsProvider(fixtureId));
    return lineups.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
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
      data: (list) => list.isEmpty
          // Yeu cau muc 9 cua de bai: noi ro "chua duoc cong bo", khong de
          // man hinh trong khong.
          ? FootballEmptyState(message: ref.tr('football_lineup_not_ready'))
          : ListView(
              children: [
                for (final lineup in list)
                  _TeamLineup(
                    lineup: lineup,
                    team: lineup.teamId == home?.id ? home : away,
                  ),
              ],
            ),
    );
  }
}

class _TeamLineup extends ConsumerWidget {
  const _TeamLineup({required this.lineup, required this.team});

  final FootballLineup lineup;
  final FootballTeam? team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlowBox(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TeamBadge(team: team, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    team?.name ?? '-',
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
                if (lineup.formation != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      lineup.formation!,
                      style: AppTextStyles.heading(size: 11).copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final p in lineup.starters) _PlayerRow(player: p),
            if (lineup.substitutes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                ref.tr('football_substitutes').toUpperCase(),
                style: AppTextStyles.muted(size: 10)
                    .copyWith(letterSpacing: 0.7),
              ),
              const SizedBox(height: 6),
              for (final p in lineup.substitutes)
                _PlayerRow(player: p, dim: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, this.dim = false});

  final FootballPlayer player;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              player.number?.toString() ?? '',
              style: AppTextStyles.heading(size: 11.5).copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                size: 12,
                weight: dim ? FontWeight.w600 : FontWeight.w700,
              ),
            ),
          ),
          if (player.position != null)
            Text(
              player.position!,
              style: AppTextStyles.muted(size: 10).copyWith(letterSpacing: 0.5),
            ),
        ],
      ),
    );
  }
}
