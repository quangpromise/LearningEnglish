import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_providers.dart';
import 'football_widgets.dart';

/// Bang xep hang 1 giai.
///
/// Hien du 10 cot theo yeu cau muc 3 cua de bai (vi tri, logo, ten, ST, T, H,
/// B, BT, BB, HS, D) + phong do 5 tran. Man hinh dien thoai hep nen ST/T/H/B
/// dung co chu nho va bang CUON NGANG duoc thay vi cat bot cot.
///
/// Giai co nhieu bang (group) - vd vong bang cac cup - duoc nhom theo
/// `group_label`; Champions League tu 2024/25 chi con 1 bang 36 doi nen se
/// hien lien mach, khong co tieu de nhom.
class FootballStandingsView extends ConsumerWidget {
  const FootballStandingsView({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionId = ref.watch(footballSelectedCompetitionProvider);
    final competitions =
        ref.watch(footballCompetitionsProvider).valueOrNull ?? const [];
    final competition = competitionId == null
        ? null
        : competitions.where((c) => c.id == competitionId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(
          title: competition?.name ?? ref.tr('football_standings'),
          onBack: onBack,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: competitionId == null
              ? FootballEmptyState(message: ref.tr('football_pick_competition'))
              : ref
                    .watch(footballStandingsProvider(competitionId))
                    .when(
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
                      data: (rows) => rows.isEmpty
                          ? FootballEmptyState(
                              message: ref.tr('football_no_standings'),
                            )
                          : _StandingsTable(rows: rows),
                    ),
        ),
      ],
    );
  }
}

class _StandingsTable extends ConsumerWidget {
  const _StandingsTable({required this.rows});

  final List<FootballStandingRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gom theo bang dau, giu nguyen thu tu server da sap (group_label, position).
    final groups = <String, List<FootballStandingRow>>{};
    for (final r in rows) {
      groups.putIfAbsent(r.groupLabel, () => []).add(r);
    }

    return ListView(
      children: [
        for (final entry in groups.entries) ...[
          if (entry.key.isNotEmpty && groups.length > 1) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                entry.key,
                style: AppTextStyles.body(size: 12, weight: FontWeight.w800),
              ),
            ),
          ],
          GlowBox(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            borderRadius: 18,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // Du rong cho 10 cot; hep hon man hinh thi cuon ngang.
                width: 360,
                child: Column(
                  children: [
                    _HeaderRow(),
                    for (final row in entry.value) _TeamRow(row: row),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        _FormLegend(),
        const SizedBox(height: 10),
      ],
    );
  }
}

const _wPos = 22.0;
const _wTeam = 128.0;
const _wNum = 26.0;
const _wDiff = 32.0;

class _HeaderRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget cell(String key, double width) => SizedBox(
      width: width,
      child: Text(
        ref.tr(key),
        textAlign: TextAlign.center,
        style: AppTextStyles.muted(size: 9.5)
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          const SizedBox(width: _wPos),
          SizedBox(
            width: _wTeam,
            child: Text(
              ref.tr('football_col_team'),
              style: AppTextStyles.muted(size: 9.5)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          cell('football_col_played', _wNum),
          cell('football_col_win', _wNum),
          cell('football_col_draw', _wNum),
          cell('football_col_loss', _wNum),
          cell('football_col_diff', _wDiff),
          cell('football_col_points', _wNum),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.row});

  final FootballStandingRow row;

  @override
  Widget build(BuildContext context) {
    Widget num(int value, double width, {Color? color, FontWeight? weight}) =>
        SizedBox(
          width: width,
          child: Text(
            value > 0 && width == _wDiff ? '+$value' : '$value',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 11.5).copyWith(
              color: color ?? AppColors.textPrimary,
              fontWeight: weight ?? FontWeight.w700,
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _wPos,
            child: Text(
              '${row.position}',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 11)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: _wTeam,
            child: Row(
              children: [
                TeamBadge(team: row.team, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 11.5,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          num(row.played, _wNum, color: AppColors.textMuted),
          num(row.wins, _wNum),
          num(row.draws, _wNum),
          num(row.losses, _wNum),
          num(
            row.goalDifference,
            _wDiff,
            color: row.goalDifference > 0
                ? AppColors.teal
                : row.goalDifference < 0
                ? AppColors.pink
                : AppColors.textMuted,
          ),
          num(row.points, _wNum, weight: FontWeight.w800),
        ],
      ),
    );
  }
}

/// Phong do 5 tran - tach thanh khoi rieng ben duoi thay vi nhet them cot vao
/// bang (bang 10 cot da chat, them 5 cham nua la phai cuon rat xa).
class _FormLegend extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionId = ref.watch(footballSelectedCompetitionProvider);
    if (competitionId == null) return const SizedBox.shrink();
    final rows =
        ref.watch(footballStandingsProvider(competitionId)).valueOrNull ??
        const [];
    final withForm = rows
        .where((r) => (r.form ?? '').isNotEmpty)
        .take(5)
        .toList();
    if (withForm.isEmpty) return const SizedBox.shrink();

    return GlowBox(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('football_recent_form').toUpperCase(),
            style: AppTextStyles.muted(size: 10).copyWith(letterSpacing: 0.7),
          ),
          const SizedBox(height: 10),
          for (final r in withForm)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  TeamBadge(team: r.team, size: 20),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      r.team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FormStrip(form: r.form),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
