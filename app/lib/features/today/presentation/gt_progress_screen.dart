import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/gt_mini_player.dart';
import '../../../core/navigation/gt_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../english_path/data/cefr_level.dart';
import '../../english_path/data/english_path_providers.dart';
import '../../fitness/data/body_level.dart';
import '../../music_player/presentation/home_screen.dart'
    show greetingKeyProvider;
import '../data/gymtalk_rank.dart';
import '../data/progress_presentation.dart';
import 'progress_social_cards.dart';

/// Giay hoat dong 7 ngay theo nguon ('english' | 'fitness') - RPC
/// `my_weekly_activity` san co.
final weeklyActivitySecondsProvider = FutureProvider.autoDispose
    .family<Map<DateTime, int>, String>((ref, source) async {
      final user = ref.watch(supabaseClientProvider).auth.currentUser;
      if (user == null) return const {};
      final rows = await ref
          .watch(statsRepositoryProvider)
          .fetchWeeklyActivity(source: source);
      return {for (final r in rows) r.date: r.seconds};
    });

/// Tab "Tien do" cua ban redesign (spec #70, #77; README §8, ADR-0005):
/// the GymTalk Rank, 2 o Body/English Level, bieu do tuan, ban be tuan nay,
/// cai dat (mini player + nhac nho). Thay `ProgressScreen` khi bat
/// `kUseRedesign`.
class GtProgressScreen extends ConsumerWidget {
  const GtProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final padding = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: t.bg,
      child: RefreshIndicator(
        color: t.gold,
        onRefresh: () async {
          ref
            ..invalidate(bodyStatsProvider)
            ..invalidate(myLearningXpProvider)
            ..invalidate(weeklyActivitySecondsProvider)
            ..invalidate(friendsChallengeProvider);
          await ref.read(gymTalkSyncProvider).syncNow();
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            padding.top + 4,
            16,
            padding.bottom + 16,
          ),
          children: [
            GtTopBar(greetingKey: ref.watch(greetingKeyProvider)),
            const SizedBox(height: 14),
            const GtRankCard(),
            const SizedBox(height: 12),
            const _LevelTiles(),
            const SizedBox(height: 14),
            const GtWeekChartCard(),
            const SizedBox(height: 14),
            const FriendsChallengeCard(),
            const SizedBox(height: 20),
            Text(ref.tr('gt_progress_settings'), style: GtText.cardTitle(t.tx)),
            const SizedBox(height: 8),
            const _MiniPlayerSwitch(),
            const SizedBox(height: 10),
            const ReminderSettingsCard(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The hang (ADR-0005: GymTalk Rank, khong co "Kim cuong")

class GtRankCard extends ConsumerWidget {
  const GtRankCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final stats = ref.watch(bodyStatsProvider).valueOrNull;
    final english = ref.watch(englishLevelProvider);
    final xp = ref.watch(myLearningXpProvider).valueOrNull;
    final rank = stats == null
        ? null
        : gymTalkRank(bodyLevelFor(stats), english);
    final tiers = CefrLevel.values.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.goldB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: t.goldT,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  color: t.gold,
                  size: 44,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('gt_progress_rank_overline'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.overline(t.gold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rank == null
                          ? '…'
                          : '${ref.tr('body_level_${BodyLevel.values[rank.tier].name}')}'
                                ' · ${CefrLevel.values[rank.tier].code}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.cardTitle(t.tx).copyWith(fontSize: 24),
                    ),
                    Text(
                      [
                        if (rank != null)
                          ref
                              .tr('progress_rank')
                              .replaceFirst('{n}', '${rank.tier + 1}')
                              .replaceFirst('{max}', '$tiers'),
                        if (xp != null)
                          ref
                              .tr('progress_xp_points')
                              .replaceFirst('{xp}', '${xp.xp}'),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(t.tx2, size: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rank != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (rank.tier + 1) / tiers,
                minHeight: 10,
                color: t.gold,
                backgroundColor: t.s2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr('progress_rank_${rank.limitedBy.name}'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GtText.body(t.tx2, size: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2 o Body Level / English Level (ADR-0002: 2 thang doc lap)

class _LevelTiles extends ConsumerWidget {
  const _LevelTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final stats = ref.watch(bodyStatsProvider).valueOrNull;
    final body = stats == null ? null : bodyLevelFor(stats);
    final next = stats == null ? null : nextBodyTarget(stats);
    final english = ref.watch(englishLevelProvider);
    final bodySub = next == null
        ? (body == null ? '' : ref.tr('progress_body_max'))
        : ref
              .tr(switch ((next.workoutsNeeded, next.weeksNeeded)) {
                (0, _) => 'progress_body_next_weeks',
                (_, 0) => 'progress_body_next_workouts',
                _ => 'progress_body_next',
              })
              .replaceFirst('{w}', '${next.workoutsNeeded}')
              .replaceFirst('{k}', '${next.weeksNeeded}')
              .replaceFirst('{level}', ref.tr('body_level_${next.level.name}'));
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _LevelTile(
              color: t.red,
              overline: ref.tr('gt_progress_body_overline'),
              title: body == null ? '…' : ref.tr('body_level_${body.name}'),
              sub: bodySub,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LevelTile(
              color: t.blue,
              overline: ref.tr('gt_progress_english_overline'),
              title: english.code,
              sub: ref.tr(english.labelKey),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.color,
    required this.overline,
    required this.title,
    required this.sub,
  });

  final Color color;
  final String overline;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GtText.overline(color),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GtText.ringStat(t.tx),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GtText.body(t.tx2, size: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bieu do tuan: cot chong (xanh = phut hoc o tren, do = phut tap o duoi)

class GtWeekChartCard extends ConsumerWidget {
  const GtWeekChartCard({super.key});

  static const plotHeight = 110.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final learn = ref.watch(weeklyActivitySecondsProvider('english'));
    final train = ref.watch(weeklyActivitySecondsProvider('fitness'));
    final ready = learn.hasValue && train.hasValue;
    final cols = ready
        ? weeklyChart(
            learnSeconds: learn.value!,
            trainSeconds: train.value!,
            today: DateTime.now(),
          )
        : const <WeekColumn>[];
    final total = splitHoursMinutes(weeklyTotalMinutes(cols));
    final maxDay = cols.fold<int>(0, (m, c) {
      final v = c.learnMin + c.trainMin;
      return v > m ? v : m;
    });
    final scale = chartScale(maxDayMinutes: maxDay, plotHeight: plotHeight);
    final labels = ref.tr('gt_weekday_short').split(',');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.tr('gt_progress_week_title'),
                  style: GtText.cardTitle(t.tx),
                ),
              ),
              if (ready)
                Text(
                  ref
                      .tr('gt_progress_week_total')
                      .replaceFirst('{h}', '${total.hours}')
                      .replaceFirst('{m}', '${total.minutes}'),
                  style: GtText.body(t.tx2, size: 13, weight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!ready)
            SizedBox(
              height: plotHeight + 24,
              child: Center(
                child: Text(
                  learn.hasError || train.hasError
                      ? ref.tr('gt_progress_week_error')
                      : '…',
                  style: GtText.body(t.tx2, size: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: plotHeight + 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (i, c) in cols.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (c.learnMin > 0)
                            _Bar(height: c.learnMin * scale, color: t.blue),
                          if (c.learnMin > 0 && c.trainMin > 0)
                            const SizedBox(height: 3),
                          if (c.trainMin > 0)
                            _Bar(height: c.trainMin * scale, color: t.red),
                          const SizedBox(height: 6),
                          Text(
                            labels[c.day.weekday - 1],
                            maxLines: 1,
                            style: GtText.body(t.tx3, size: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: t.blue, label: ref.tr('gt_progress_legend_learn')),
              const SizedBox(width: 16),
              _Legend(color: t.red, label: ref.tr('gt_progress_legend_train')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    // Toi thieu 3px de ngay co 1-2 phut van thay.
    height: height < 3 ? 3 : height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: GtText.body(t.tx2, size: 12)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cai dat: bat/tat mini player (review #72 -> tieu chi cua ticket nay)

class _MiniPlayerSwitch extends ConsumerWidget {
  const _MiniPlayerSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final visible = ref.watch(miniPlayerVisibleProvider);
    return Material(
      color: t.s1,
      borderRadius: BorderRadius.circular(20),
      child: SwitchListTile(
        value: visible,
        onChanged: (v) => ref.read(miniPlayerVisibleProvider.notifier).set(v),
        activeThumbColor: t.gold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        secondary: Icon(Icons.music_note_rounded, color: t.tx2),
        title: Text(
          ref.tr('gt_progress_mini_player'),
          style: GtText.rowTitle(t.tx),
        ),
        subtitle: Text(
          ref.tr('gt_progress_mini_player_sub'),
          style: GtText.body(t.tx2, size: 12),
        ),
      ),
    );
  }
}
