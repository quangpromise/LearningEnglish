import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/gt_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../../../core/i18n/greeting.dart';
import '../data/body_level.dart';
import '../data/exercise_model.dart';
import '../data/meal_model.dart';
import '../data/program_model.dart';
import '../data/train_presentation.dart';
import 'community_screen.dart';
import 'fitness_statistics_screen.dart';
import 'heart_rate_screen.dart';
import 'muscle_group_categories_screen.dart';
import 'nutrition_screen.dart';
import 'programs_list_screen.dart';
import 'sleep_screen.dart';

/// Tab "Tap" cua ban redesign (spec #70, #75; README §6): hero Body Level,
/// luoi 2x2 so lieu tuan, buoi hom nay, hang giao an, loi tat tien ich.
class GtTrainScreen extends ConsumerWidget {
  const GtTrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final padding = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: t.bg,
      child: RefreshIndicator(
        color: t.red,
        onRefresh: () async {
          ref
            ..invalidate(bodyStatsProvider)
            ..invalidate(fitnessDashboardStatsProvider)
            ..invalidate(todayMealsProvider)
            ..invalidate(heartRateHistoryProvider)
            ..invalidate(activeProgramIdProvider)
            ..invalidate(todayWorkoutPlanProvider);
          // Giu vong xoay den khi so lieu tai xong (loi thi van tat).
          await Future.wait<Object?>([
            ref.read(bodyStatsProvider.future),
            ref.read(fitnessDashboardStatsProvider.future),
            ref.read(todayWorkoutPlanProvider.future),
          ]).catchError((Object _) => const <Object?>[]);
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
            // Nhac han goi tap (tu an khi khong co goi sap het han) - giu
            // tu Trang chu Fitness cu.
            const ServiceExpiryBanner(section: AppSection.fitness),
            const GtBodyHero(),
            const SizedBox(height: 12),
            const _StatGrid(),
            const SizedBox(height: 16),
            const _TodaySession(),
            const SizedBox(height: 20),
            const _ProgramRow(),
            const SizedBox(height: 20),
            const _Shortcuts(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Body Level

class GtBodyHero extends ConsumerWidget {
  const GtBodyHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final stats = ref.watch(bodyStatsProvider).valueOrNull;
    final level = stats == null ? null : bodyLevelFor(stats);
    final next = stats == null ? null : nextBodyTarget(stats);
    final progress = stats == null ? 0.0 : bodyLevelProgress(stats);
    final levelName = level == null
        ? '…'
        : ref.tr('body_level_${level.name}').toUpperCase();
    final footer = next == null
        ? (level == BodyLevel.beast ? ref.tr('gt_train_top_level') : '')
        : ref
              .tr('gt_train_next_level')
              .replaceFirst('{level}', ref.tr('body_level_${next.level.name}'))
              .replaceFirst('{pct}', '${(progress * 100).round()}');
    // ADR-0005: noi ro con thieu bao nhieu buoi / tuan lien tiep.
    final missing = next == null
        ? ''
        : [
            if (next.workoutsNeeded > 0)
              ref
                  .tr('gt_train_need_sessions')
                  .replaceFirst('{n}', '${next.workoutsNeeded}'),
            if (next.weeksNeeded > 0)
              ref
                  .tr('gt_train_need_weeks')
                  .replaceFirst('{n}', '${next.weeksNeeded}'),
          ].join(' · ');
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF0A0A0A)),
            Image.asset(
              'assets/fitness/home/hero.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF000000), Color(0x00000000)],
                  stops: [0.3, 0.8],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref
                        .tr('gt_train_level_overline')
                        .replaceFirst('{level}', levelName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GtText.overline(t.red),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    // Co chu tu thu nho de 3 dong luon vua (ban tieng Anh
                    // dai hon), khong bi cat mat dong cuoi.
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Text(
                          ref.tr('gt_train_hero_title'),
                          style: GtText.heroTitle(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  if (footer.isNotEmpty) ...[
                    Text(
                      missing.isEmpty ? footer : '$footer · $missing',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(const Color(0xFFD4D6DA), size: 13),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          color: t.red,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Luoi 2x2

class _StatGrid extends ConsumerWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final stats = ref.watch(fitnessDashboardStatsProvider).valueOrNull;
    final plan = ref.watch(todayWorkoutPlanProvider).valueOrNull;
    final heartRate = ref.watch(latestHeartRateProvider);
    final meals = ref.watch(todayMealsProvider).valueOrNull ?? const [];
    final kcal = meals.fold<int>(0, (sum, m) => sum + m.kcal);
    // Chua co giao an -> khong co muc tieu tuan, khong bia so.
    final goal = plan?.program.sessionsPerWeek ?? 0;
    final done = stats?.sessionsThisWeek ?? 0;
    final change = volumeChangePercent(
      stats?.totalVolumeThisWeekKg ?? 0,
      stats?.previousWeekVolumeKg ?? 0,
    );

    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 10),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      children: [
        row(
          _StatTile(
            label: ref.tr('gt_train_stat_sessions'),
            value: '$done',
            unit: goal > 0 ? '/$goal' : ref.tr('gt_unit_session'),
            onTap: () => openAppPopup(context, const FitnessStatisticsScreen()),
            footer: Row(
              children: [
                for (final (i, on) in sessionSegments(
                  done: done,
                  goal: goal,
                ).indexed) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: on ? t.red : t.s2,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _StatTile(
            label: ref.tr('gt_train_stat_volume'),
            value: formatTonnes(stats?.totalVolumeThisWeekKg ?? 0),
            unit: ref.tr('fitness_stat_volume_unit'),
            onTap: () => openAppPopup(context, const FitnessStatisticsScreen()),
            footer: change == null
                ? null
                : Text(
                    ref
                        .tr('gt_train_vs_last_week')
                        .replaceFirst(
                          '{pct}',
                          '${change > 0 ? '+' : ''}$change',
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GtText.body(
                      change >= 0 ? t.teal : t.tx2,
                      size: 12,
                      weight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        row(
          _StatTile(
            label: ref.tr('gt_train_stat_heart_rate'),
            // Chua do lan nao -> gach ngang, khong dat so mac dinh.
            value: heartRate == null ? '--' : '${heartRate.bpm}',
            unit: 'bpm',
            onTap: () async {
              await openAppPopup(context, const HeartRateScreen());
              ref.invalidate(heartRateHistoryProvider);
            },
            footer: Text(
              ref.tr('gt_train_heart_rate_sub'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GtText.body(t.tx2, size: 12),
            ),
          ),
          _StatTile(
            label: ref.tr('gt_train_stat_kcal'),
            value: '$kcal',
            unit: 'kcal',
            onTap: () => openAppPopup(context, const NutritionScreen()),
            footer: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (kcal / kNutritionGoalKcal).clamp(0.0, 1.0),
                minHeight: 5,
                color: t.gold,
                backgroundColor: t.s2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.onTap,
    this.footer,
  });

  final String label;
  final String value;
  final String unit;
  final VoidCallback onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Material(
      color: t.s1,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GtText.body(t.tx2, size: 13),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: value, style: GtText.ringStat(t.tx)),
                      TextSpan(
                        text: ' $unit',
                        style: GtText.ringStatUnit(t.tx2),
                      ),
                    ],
                  ),
                ),
              ),
              if (footer != null) ...[const SizedBox(height: 10), footer!],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buoi hom nay

class _TodaySession extends ConsumerWidget {
  const _TodaySession();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final lang = ref.watch(appLanguageProvider);
    final plan = ref.watch(todayWorkoutPlanProvider).valueOrNull;
    final exercises = {
      for (final e
          in ref.watch(exerciseListProvider).valueOrNull ?? const <Exercise>[])
        e.id: e,
    };
    final refs = [...?plan?.day.exercises]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    String? note;
    if (plan == null) {
      note = ref.tr('today_cta_choose_program_sub');
    } else if (plan.isRestDay) {
      note = ref.tr('today_cta_rest_day');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ref.tr('gt_train_today_title'), style: GtText.cardTitle(t.tx)),
          const SizedBox(height: 6),
          if (note != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(note, style: GtText.body(t.tx2)),
            )
          else
            for (final (i, r) in refs.indexed)
              _ExerciseRow(
                index: i + 1,
                name: exercises[r.exerciseId]?.nameFor(lang) ?? '…',
                target:
                    '${r.targetSets} × ${r.targetRepsMin}–${r.targetRepsMax}',
              ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: t.red,
                foregroundColor: t.onRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // Ngay nghi -> on tu (giong the buoi tap o Hom nay).
              onPressed: () => openAppPopup(
                context,
                plan != null && plan.isRestDay
                    ? const SrsReviewScreen()
                    : ProgramsListScreen(initialProgramId: plan?.program.id),
              ),
              icon: Icon(switch (plan) {
                null => Icons.fitness_center_rounded,
                final p when p.isRestDay => Icons.style_rounded,
                _ => Icons.play_arrow_rounded,
              }),
              label: Text(
                ref.tr(switch (plan) {
                  null => 'gt_today_cta_choose',
                  final p when p.isRestDay => 'gt_today_cta_review',
                  _ => 'gt_today_cta_start',
                }),
                style: GtText.rowTitle(t.onRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.index,
    required this.name,
    required this.target,
  });

  final int index;
  final String name;
  final String target;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: GtText.cardTitle(t.tx3).copyWith(fontSize: 18),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.rowTitle(t.tx),
                ),
                Text(target, style: GtText.body(t.tx2, size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hang giao an

const _programImages = <int, String>{
  1: 'assets/fitness/home/program_muscle.jpg',
  2: 'assets/fitness/home/program_beginner.jpg',
  3: 'assets/fitness/home/program_fatloss.jpg',
};

class _ProgramRow extends ConsumerWidget {
  const _ProgramRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final lang = ref.watch(appLanguageProvider);
    final programs = ref.watch(programListProvider).valueOrNull ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ref.tr('gt_train_programs'),
                style: GtText.cardTitle(t.tx),
              ),
            ),
            TextButton(
              onPressed: () =>
                  openAppPopup(context, const ProgramsListScreen()),
              child: Text(
                ref.tr('gt_train_see_all'),
                style: GtText.body(t.tx2, weight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: programs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _ProgramCard(
              program: programs[i],
              title: programs[i].titleFor(lang),
              level: ref.tr(programs[i].levelLabelKey),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.title,
    required this.level,
  });

  final Program program;
  final String title;
  final String level;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openAppPopup(
        context,
        ProgramsListScreen(initialProgramId: program.id),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF15171B)),
              Image.asset(
                _programImages[program.id] ??
                    'assets/fitness/home/program_beginner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xE6000000)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.rowTitle(Colors.white)
                          .copyWith(fontSize: 16),
                    ),
                    Text(
                      level,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(const Color(0xFFD4D6DA), size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loi tat: giu cac tien ich cua Trang chu Fitness cu (khong co trong design
// nhung khong duoc mat loi vao).

class _Shortcuts extends ConsumerWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final items = [
      (
        Icons.menu_book_rounded,
        'gt_train_shortcut_library',
        const MuscleGroupCategoriesScreen(),
      ),
      (
        Icons.restaurant_rounded,
        'gt_train_shortcut_nutrition',
        const NutritionScreen(),
      ),
      (Icons.bedtime_rounded, 'gt_train_shortcut_sleep', const SleepScreen()),
      (
        Icons.groups_rounded,
        'gt_train_shortcut_community',
        const CommunityScreen(),
      ),
    ];
    return Row(
      children: [
        for (final (i, (icon, key, screen)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: t.s1,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => openAppPopup(context, screen),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(icon, color: t.red, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        ref.tr(key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GtText.body(t.tx, size: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
