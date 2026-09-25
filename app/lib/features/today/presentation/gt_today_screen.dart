import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/gt_top_bar.dart';
import '../../../core/navigation/root_tabs.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../fitness/presentation/programs_list_screen.dart';
import '../../music_player/presentation/home_screen.dart';
import '../../srs/data/srs_store.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../data/daily_progress_store.dart';
import '../data/today_presentation.dart';
import 'gymtalk_setup_sheet.dart';

/// Tab "Hom nay" cua ban redesign (spec #70, #73): top bar -> the Daily
/// Rings -> the buoi tap hom nay (-> the nhiem vu, UI-04). Thay
/// `TodayScreen` khi bat `kUseRedesign`.
class GtTodayScreen extends ConsumerStatefulWidget {
  const GtTodayScreen({super.key});

  @override
  ConsumerState<GtTodayScreen> createState() => _GtTodayScreenState();
}

class _GtTodayScreenState extends ConsumerState<GtTodayScreen> {
  // Cung khoa voi TodayScreen cu -> khong hoi lai nguoi da duoc hoi.
  static const _setupPromptedKey = 'gymtalk_setup_prompted_v1';
  bool _setupChecked = false;

  @override
  void initState() {
    super.initState();
    DailyProgressStore.instance.ensureLoaded();
    SrsStore.instance.ensureLoaded();
    // Lan dau chua co giao an -> tu mo "Thiet lap GymTalk" 1 lan (giu hanh
    // vi cu cho toi khi co onboarding moi - UI-10).
    ref.listenManual<AsyncValue<TodayWorkoutPlan?>>(todayWorkoutPlanProvider, (
      _,
      next,
    ) {
      if (next.hasValue && next.value == null) _maybePromptSetup();
    }, fireImmediately: true);
  }

  Future<void> _maybePromptSetup() async {
    if (_setupChecked) return;
    _setupChecked = true;
    if (ref.read(supabaseClientProvider).auth.currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_setupPromptedKey) ?? false) return;
      await prefs.setBool(_setupPromptedKey, true);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) openAppPopup(context, const GymTalkSetupSheet());
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final padding = MediaQuery.paddingOf(context);
    final store = DailyProgressStore.instance;
    return ColoredBox(
      color: t.bg,
      child: RefreshIndicator(
        color: t.tx,
        onRefresh: () async {
          ref
            ..invalidate(todayWorkoutPlanProvider)
            ..invalidate(myLearningXpProvider);
        },
        child: ListenableBuilder(
          listenable: Listenable.merge([store, SrsStore.instance]),
          builder: (context, _) {
            final now = DateTime.now();
            return ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                padding.top + 4,
                16,
                padding.bottom + 16,
              ),
              children: [
                GtTopBar(greetingKey: ref.watch(greetingKeyProvider)),
                const SizedBox(height: 14),
                GtRingsCard(
                  day: store.today,
                  strip: weekStreakStrip(store.dayOf, now),
                  date: now,
                ),
                const SizedBox(height: 16),
                _TodayWorkout(
                  today: store.today,
                  dueCount: SrsStore.instance.dueCount(now),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The Daily Rings

/// The 3 vong Tap/Hoc/Noi + 3 chi so + dai chuoi 7 ngay (README §5).
class GtRingsCard extends ConsumerWidget {
  const GtRingsCard({
    super.key,
    required this.day,
    required this.strip,
    required this.date,
  });

  final DayProgress day;
  final List<StreakCell> strip;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final trainValue = day.restDay
        ? ref.tr('ring_rest_day')
        : '${min(day.workouts, kDailyTrainGoal)}/$kDailyTrainGoal';
    return Container(
      padding: const EdgeInsets.all(20),
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
                  ref.tr('today_goals_title').toUpperCase(),
                  style: GtText.overline(t.tx2),
                ),
              ),
              Text(
                '${date.day}/${date.month}',
                style: GtText.body(t.tx3, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 164,
                height: 164,
                // Tween toi gia tri moi -> lan dau chay tu 0, sau do moi lan
                // tien do doi cung chay 600ms tu gia tri cu.
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(
                    begin: Offset.zero,
                    end: Offset(day.trainRatio, day.learnRatio),
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, tl, _) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: day.speakRatio),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, speak, child) => CustomPaint(
                      painter: GtRingsPainter(
                        train: tl.dx,
                        learn: tl.dy,
                        speak: speak,
                        tokens: t,
                      ),
                      child: child,
                    ),
                    child: Center(
                      child: Text(
                        '${ringsPercent(day)}%',
                        style: GtText.ringStat(t.tx),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RingStat(
                      label: ref.tr('ring_train'),
                      color: t.red,
                      value: trainValue,
                      unit: day.restDay ? null : ref.tr('gt_unit_session'),
                    ),
                    const SizedBox(height: 12),
                    _RingStat(
                      label: ref.tr('ring_learn'),
                      color: t.blue,
                      value: '${day.wordsReviewed}/$kDailyLearnGoal',
                      unit: ref.tr('gt_unit_words'),
                    ),
                    const SizedBox(height: 12),
                    _RingStat(
                      label: ref.tr('ring_speak'),
                      color: t.teal,
                      value: '${day.speakAttempts}/$kDailySpeakGoal',
                      unit: ref.tr('gt_unit_sentences'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.bd)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _StreakStrip(
                cells: strip,
                labels: ref.tr('gt_weekday_short').split(','),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({
    required this.label,
    required this.color,
    required this.value,
    required this.unit,
  });

  final String label;
  final Color color;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GtText.body(color, size: 13, weight: FontWeight.w800),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: value, style: GtText.ringStat(t.tx)),
                if (unit != null)
                  TextSpan(text: ' $unit', style: GtText.ringStatUnit(t.tx2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 3 vong dong tam: ngoai r72 do (Tap), giua r55 xanh (Hoc), trong r38 ngoc
/// (Noi); net 14, dau tron, ranh = mau nhan nhat (README §5).
class GtRingsPainter extends CustomPainter {
  GtRingsPainter({
    required this.train,
    required this.learn,
    required this.speak,
    required this.tokens,
  });

  final double train;
  final double learn;
  final double speak;
  final GtTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final scale = size.shortestSide / 164;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * scale
      ..strokeCap = StrokeCap.round;
    for (final (r, value, color, track) in [
      (72.0, train, tokens.red, tokens.redT),
      (55.0, learn, tokens.blue, tokens.blueT),
      (38.0, speak, tokens.teal, tokens.tealT),
    ]) {
      final rect = Rect.fromCircle(center: c, radius: r * scale);
      canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
      final v = value.clamp(0.0, 1.0);
      if (v > 0) {
        canvas.drawArc(rect, -pi / 2, 2 * pi * v, false, paint..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(GtRingsPainter old) =>
      old.train != train ||
      old.learn != learn ||
      old.speak != speak ||
      old.tokens != tokens;
}

class _StreakStrip extends StatelessWidget {
  const _StreakStrip({required this.cells, required this.labels});

  final List<StreakCell> cells;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < cells.length; i++)
          Column(
            children: [
              _StreakDot(cell: cells[i]),
              const SizedBox(height: 6),
              Text(
                i < labels.length ? labels[i] : '',
                style: GtText.body(
                  cells[i] == StreakCell.today ||
                          cells[i] == StreakCell.todayDone
                      ? t.tx
                      : t.tx3,
                  size: 12,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StreakDot extends StatelessWidget {
  const _StreakDot({required this.cell});
  final StreakCell cell;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final filled = cell == StreakCell.done || cell == StreakCell.todayDone;
    final ring = switch (cell) {
      StreakCell.today => t.streak,
      StreakCell.missed || StreakCell.future => t.bd,
      _ => null,
    };
    final flame = switch (cell) {
      StreakCell.done || StreakCell.todayDone => Colors.white,
      StreakCell.today => t.streak,
      _ => null,
    };
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? t.streak : null,
        border: ring == null ? null : Border.all(color: ring, width: 2),
      ),
      child: flame == null
          ? null
          : Icon(Icons.local_fire_department_rounded, size: 18, color: flame),
    );
  }
}

// ---------------------------------------------------------------------------
// The buoi tap hom nay

/// Nhan [today]/[dueCount] tu ListenableBuilder cha (khong `const`) de the
/// doi sang "Da tap xong" ngay khi buoi tap ket thuc.
class _TodayWorkout extends ConsumerWidget {
  const _TodayWorkout({required this.today, required this.dueCount});

  final DayProgress today;
  final int dueCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todayWorkoutPlanProvider);
    final plan = planAsync.valueOrNull;
    final state = todayCardState(
      loading: planAsync.isLoading && !planAsync.hasValue,
      error: planAsync.hasError && !planAsync.hasValue,
      hasPlan: plan != null,
      isRestDay: plan?.isRestDay ?? false,
      today: today,
    );
    // Ngay nghi -> vong Tap tinh la xong (sau frame, khong ghi khi build).
    if (state == TodayCardState.restDay && !today.restDay) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => DailyProgressStore.instance.markRestDay(true),
      );
    }
    return GtWorkoutCard(
      state: state,
      plan: plan,
      dueCount: dueCount,
      onTap: () {
        switch (state) {
          case TodayCardState.loading:
            break;
          case TodayCardState.error:
            openAppPopup(context, const ProgramsListScreen());
          case TodayCardState.noPlan:
            openAppPopup(context, const GymTalkSetupSheet());
          case TodayCardState.restDay:
            openAppPopup(context, const SrsReviewScreen());
          case TodayCardState.done:
            ref.read(rootTabProvider.notifier).state = RootTab.progress;
          case TodayCardState.start:
            openAppPopup(
              context,
              ProgramsListScreen(initialProgramId: plan!.program.id),
            );
        }
      },
    );
  }
}

/// The anh buoi tap hom nay (README §5): luon nen toi vi nam tren anh.
class GtWorkoutCard extends ConsumerWidget {
  const GtWorkoutCard({
    super.key,
    required this.state,
    required this.plan,
    required this.dueCount,
    required this.onTap,
  });

  final TodayCardState state;
  final TodayWorkoutPlan? plan;
  final int dueCount;
  final VoidCallback onTap;

  static const _cardBg = Color(0xFF0A0A0A);
  static const _chipText = Color(0xFFFF6B6F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final lang = ref.watch(appLanguageProvider);
    final plan = this.plan;
    String? chip;
    String title;
    String? sub;
    String? cta;
    IconData ctaIcon = Icons.play_arrow_rounded;
    var ctaBg = t.red;
    var ctaFg = t.onRed;
    switch (state) {
      case TodayCardState.loading:
        title = '';
      case TodayCardState.error:
        title = ref.tr('today_cta_choose_program');
        sub = ref.tr('today_cta_error_sub');
        cta = ref.tr('gt_today_cta_choose');
        ctaIcon = Icons.fitness_center_rounded;
      case TodayCardState.noPlan:
        title = ref.tr('today_cta_choose_program');
        sub = ref.tr('today_cta_choose_program_sub');
        cta = ref.tr('gt_today_cta_choose');
        ctaIcon = Icons.fitness_center_rounded;
      case TodayCardState.restDay:
        title = ref.tr('today_cta_rest_day');
        sub = ref
            .tr('today_cta_rest_day_sub')
            .replaceFirst('{count}', '$dueCount');
        cta = ref.tr('gt_today_cta_review');
        ctaIcon = Icons.style_rounded;
        ctaBg = t.blue;
        ctaFg = Colors.white;
      case TodayCardState.done:
      case TodayCardState.start:
        final p = plan!;
        final session = sessionOfWeek(p.program, p.day.dayOfWeek);
        if (session != null) {
          chip = ref
              .tr('gt_today_session_chip')
              .replaceFirst('{n}', '${session.session}')
              .replaceFirst('{total}', '${session.total}');
        }
        title = p.program.titleFor(lang);
        sub = ref
            .tr('gt_today_workout_meta')
            .replaceFirst('{exercises}', '${p.day.exercises.length}')
            .replaceFirst('{sets}', '${p.totalSets}')
            .replaceFirst('{minutes}', '${estimatedMinutes(p.totalSets)}');
        if (state == TodayCardState.done) {
          cta = ref.tr('gt_today_cta_done');
          ctaIcon = Icons.check_rounded;
          ctaBg = t.teal;
          ctaFg = t.onTeal;
        } else {
          cta = ref.tr('gt_today_cta_start');
        }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        color: _cardBg,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/fitness/home/today_plan.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_cardBg, _cardBg, Color(0x000A0A0A)],
                    stops: [0, 0.38, 1],
                  ),
                ),
              ),
            ),
            if (state == TodayCardState.loading)
              const SizedBox(height: 220, width: double.infinity)
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chip != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: t.redT,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          chip,
                          style: GtText.overline(_chipText)
                              .copyWith(fontSize: 12),
                        ),
                      ),
                    if (chip != null) const SizedBox(height: 10),
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GtText.cardTitle(Colors.white)
                                .copyWith(fontSize: 26, height: 1.1),
                          ),
                          if (sub != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              sub,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GtText.body(
                                const Color(0xFFB9BDC4),
                                size: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (cta != null)
                      Semantics(
                        button: true,
                        child: Material(
                          color: ctaBg,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onTap,
                            child: SizedBox(
                              height: 52,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(ctaIcon, color: ctaFg, size: 22),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        cta,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GtText.rowTitle(ctaFg),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
