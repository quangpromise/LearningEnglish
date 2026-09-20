import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_providers.dart';
import 'football_widgets.dart';

/// Chon doi yeu thich.
///
/// Danh sach doi lay tu bang `football_teams` - chi co cac doi DA xuat hien
/// trong lich da dong bo (6 giai, cua so ~38 ngay). Co y nhu vay: nguoi dung
/// chi chon duoc doi ma app thuc su co du lieu, thay vi chon 1 doi roi man
/// hinh trong tron.
class FootballFavoritesView extends ConsumerStatefulWidget {
  const FootballFavoritesView({
    super.key,
    required this.onBack,
    required this.onOpenTeam,
  });

  final VoidCallback onBack;
  final void Function(FootballTeam team) onOpenTeam;

  @override
  ConsumerState<FootballFavoritesView> createState() =>
      _FootballFavoritesViewState();
}

class _FootballFavoritesViewState extends ConsumerState<FootballFavoritesView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle(FootballTeam team, bool isFavorite) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final repo = ref.read(footballRepositoryProvider);
    if (isFavorite) {
      await repo.removeFavorite(userId, team.id);
    } else {
      await repo.addFavorite(userId, team.id);
    }
    ref.invalidate(footballFavoriteTeamIdsProvider);
    ref.invalidate(footballFavoriteTeamsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds =
        ref.watch(footballFavoriteTeamIdsProvider).valueOrNull ?? const [];
    final favorites =
        ref.watch(footballFavoriteTeamsProvider).valueOrNull ?? const [];
    final results = ref.watch(footballTeamSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(
          title: ref.tr('football_favorites'),
          onBack: widget.onBack,
        ),
        const SizedBox(height: 12),

        // O tim doi
        GlowBox(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          borderRadius: 999,
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) =>
                      ref.read(footballTeamQueryProvider.notifier).state = v,
                  style: AppTextStyles.body(size: 13),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: ref.tr('football_search_team'),
                    hintStyle: AppTextStyles.muted(size: 13),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(footballTeamQueryProvider.notifier).state = '';
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Expanded(
          child: ListView(
            children: [
              if (favorites.isNotEmpty) ...[
                Text(
                  ref.tr('football_your_teams').toUpperCase(),
                  style: AppTextStyles.muted(size: 10.5)
                      .copyWith(letterSpacing: 0.7),
                ),
                const SizedBox(height: 8),
                for (final team in favorites)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TeamRow(
                      team: team,
                      isFavorite: true,
                      onToggle: () => _toggle(team, true),
                      onTap: () => widget.onOpenTeam(team),
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              Text(
                (_controller.text.isEmpty
                        ? ref.tr('football_all_teams')
                        : ref.tr('football_search_results'))
                    .toUpperCase(),
                style: AppTextStyles.muted(size: 10.5)
                    .copyWith(letterSpacing: 0.7),
              ),
              const SizedBox(height: 8),
              results.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FootballColors.electric,
                      ),
                    ),
                  ),
                ),
                error: (_, _) => FootballEmptyState(
                  message: ref.tr('football_load_error'),
                  icon: Icons.wifi_off_rounded,
                ),
                data: (teams) {
                  final rest = teams
                      .where((t) => !favoriteIds.contains(t.id))
                      .toList();
                  if (rest.isEmpty) {
                    return FootballEmptyState(
                      message: ref.tr('football_no_team_found'),
                    );
                  }
                  return Column(
                    children: [
                      for (final team in rest)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TeamRow(
                            team: team,
                            isFavorite: false,
                            onToggle: () => _toggle(team, false),
                            onTap: () => widget.onOpenTeam(team),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    required this.isFavorite,
    required this.onToggle,
    required this.onTap,
  });

  final FootballTeam team;
  final bool isFavorite;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        borderRadius: 16,
        border: isFavorite
            ? Border.all(color: AppColors.amber.withValues(alpha: 0.35))
            : null,
        child: Row(
          children: [
            TeamBadge(team: team, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 13, weight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 21,
                  color: isFavorite ? AppColors.amber : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
