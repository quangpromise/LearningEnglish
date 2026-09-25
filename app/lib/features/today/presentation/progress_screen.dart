import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../fitness/presentation/fitness_statistics_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../srs/data/srs_store.dart';
import '../data/daily_progress_store.dart';
import 'daily_rings.dart';
import 'progress_social_cards.dart';

/// Tab "Tien do": 1 cap do GymTalk XP chung (tap + hoc), chuoi Body + Brain
/// voi lich su 7 ngay, so lieu tap tuan nay va so lieu hoc tieng Anh.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    DailyProgressStore.instance.ensureLoaded();
    SrsStore.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return ColoredBox(
      color: AppColors.bgTop,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
              child: AppTopBar(
                greeting: ref.tr('tab_progress'),
                unreadCount: unread,
                onMessagesTap: () =>
                    openAppPopup(context, const ConversationsScreen()),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blue,
                onRefresh: () async {
                  ref
                    ..invalidate(myLearningXpProvider)
                    ..invalidate(myStatsProvider)
                    ..invalidate(fitnessDashboardStatsProvider)
                    ..invalidate(friendsChallengeProvider);
                  await ref.read(gymTalkSyncProvider).syncNow();
                },
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    DailyProgressStore.instance,
                    SrsStore.instance,
                  ]),
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: const [
                      _XpCard(),
                      SizedBox(height: 14),
                      _StreakCard(),
                      SizedBox(height: 14),
                      _TrainCard(),
                      SizedBox(height: 14),
                      _LearnCard(),
                      SizedBox(height: 14),
                      FriendsChallengeCard(),
                      SizedBox(height: 14),
                      ReminderSettingsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpCard extends ConsumerWidget {
  const _XpCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsync = ref.watch(myLearningXpProvider);
    final xp = xpAsync.valueOrNull;
    return GlowBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ref.tr('progress_xp_title'),
            style: AppTextStyles.muted(size: 13),
          ),
          const SizedBox(height: 4),
          if (xp == null)
            Text(
              xpAsync.hasError ? ref.tr('progress_load_error') : '…',
              style: AppTextStyles.body(color: AppColors.textMuted),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ref
                      .tr('progress_level')
                      .replaceFirst('{level}', '${xp.level}'),
                  style: AppTextStyles.heading(size: 26),
                ),
                const Spacer(),
                Text(
                  '${xp.xpInLevel}/${xp.xpInLevel + xp.xpToNext} XP',
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: xp.xpInLevel / (xp.xpInLevel + xp.xpToNext),
                minHeight: 10,
                color: AppColors.blue,
                backgroundColor: AppColors.glassBorder,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr('progress_xp_hint'),
              style: AppTextStyles.muted(size: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = DailyProgressStore.instance;
    final days = store.lastDays(7);
    return GlowBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.amber,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ref
                      .tr('progress_streak')
                      .replaceFirst('{days}', '${store.bodyBrainStreak}'),
                  style: AppTextStyles.heading(size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('progress_streak_hint'),
            style: AppTextStyles.muted(size: 12),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (date, day) in days)
                MiniDayRings(
                  label: '${date.day}',
                  train: day.trainDone,
                  learn: day.learnDone,
                  speak: day.speakDone,
                  highlight: date == days.last.$1,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Legend(
                color: AppColors.fitnessAccent,
                label: ref.tr('ring_train'),
              ),
              _Legend(color: AppColors.blue, label: ref.tr('ring_learn')),
              _Legend(color: AppColors.teal, label: ref.tr('ring_speak')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.muted(size: 12)),
      ],
    );
  }
}

class _TrainCard extends ConsumerWidget {
  const _TrainCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(fitnessDashboardStatsProvider).valueOrNull;
    return _StatsCard(
      title: ref.tr('progress_train_title'),
      color: AppColors.fitnessAccent,
      stats: [
        (
          ref.tr('progress_train_sessions'),
          stats == null ? '–' : '${stats.sessionsThisWeek}',
        ),
        (
          ref.tr('progress_train_volume'),
          stats == null
              ? '–'
              : '${stats.totalVolumeThisWeekKg.toStringAsFixed(0)} kg',
        ),
        (
          ref.tr('progress_train_streak'),
          stats == null ? '–' : '${stats.streakDays}',
        ),
      ],
      actionLabel: ref.tr('progress_train_more'),
      onAction: () => openAppPopup(context, const FitnessStatisticsScreen()),
    );
  }
}

class _LearnCard extends ConsumerWidget {
  const _LearnCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(myStatsProvider).valueOrNull;
    final srs = SrsStore.instance;
    final mastered = srs.boxes.values
        .where((box) => box >= kSrsMasteredBox)
        .length;
    return _StatsCard(
      title: ref.tr('progress_learn_title'),
      color: AppColors.blue,
      stats: [
        (
          ref.tr('progress_learn_words'),
          stats == null ? '–' : '${stats.wordsLearned}',
        ),
        (ref.tr('progress_learn_deck'), '$mastered/${srs.totalCards}'),
        (
          ref.tr('progress_learn_pron'),
          stats == null ? '–' : '${stats.avgPronunciationScore}',
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.color,
    required this.stats,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final Color color;
  final List<(String, String)> stats;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    return GlowBox(
      border: Border.all(color: color.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.body(
              size: 15,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (label, value) in stats)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: AppTextStyles.heading(size: 22)),
                      const SizedBox(height: 2),
                      Text(label, style: AppTextStyles.muted(size: 12)),
                    ],
                  ),
                ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: color),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
