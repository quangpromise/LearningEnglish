import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/gt_top_bar.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/navigation/root_tabs.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../../core/theme/gt_haptics.dart';
import '../../../core/theme/gt_motion.dart';
import '../../../core/widgets/gt_celebration.dart';
import '../../../core/widgets/gt_launch_intro.dart';
import '../../../core/widgets/gt_when_on_screen.dart';
import '../../../core/widgets/gt_count_up.dart';
import '../../english_path/data/english_path_providers.dart';
import '../../fitness/data/body_level.dart';
import '../../fitness/presentation/programs_list_screen.dart';
import '../../../core/i18n/greeting.dart';
import '../../srs/data/srs_store.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../data/daily_progress_store.dart';
import '../data/daily_quests.dart';
import '../data/ring_geometry.dart';
import '../data/today_presentation.dart';
import 'gt_quests_card.dart';
import 'milestone_watcher.dart';
import 'gymtalk_setup_sheet.dart';

/// Tab "Hom nay" cua ban redesign (spec #70, #73): top bar -> the Daily
/// Rings -> the buoi tap hom nay -> the nhiem vu.
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
    // Nhiem vu vua xong (o bat ky man nao) -> cong XP 1 lan + toast.
    DailyProgressStore.instance.addListener(_claimQuestXp);
    WidgetsBinding.instance.addPostFrameCallback((_) => _claimQuestXp());
    // Lan dau chua co giao an -> tu mo "Thiet lap GymTalk" 1 lan (giu hanh
    // vi cu cho toi khi co onboarding moi - UI-10).
    ref.listenManual<AsyncValue<TodayWorkoutPlan?>>(todayWorkoutPlanProvider, (
      _,
      next,
    ) {
      if (next.hasValue && next.value == null) _maybePromptSetup();
    }, fireImmediately: true);
  }

  Future<void> _claimQuestXp() async {
    if (!mounted) return;
    if (pendingQuestRewards(DailyProgressStore.instance.today).isEmpty) return;
    // Dich vu tu chong goi chong (khoa dang tra) va lap den khi het.
    final xp = await ref.read(questRewardServiceProvider).claimPendingQuests();
    if (xp > 0) showXpToast(xp);
  }

  @override
  void dispose() {
    DailyProgressStore.instance.removeListener(_claimQuestXp);
    super.dispose();
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
    // Tab Hom nay dang that su hien: dang chon, khong co popup / dialog nao
    // phu len man Home (moi man khac deu mo dang popup tren Navigator goc) va
    // Launch Intro da xong (spec #135 - vong / chuc mung khong chay ngam).
    final onScreen =
        ref.watch(rootTabProvider) == RootTab.today &&
        (ModalRoute.isCurrentOf(context) ?? true) &&
        !ref.watch(launchIntroActiveProvider);
    // Doi popup / trang vua dong lui het (trang 450 ms > sheet 200 ms); giam
    // chuyen dong thi hien ngay.
    final settle = gtReduceMotion(context)
        ? Duration.zero
        : Duration(
            milliseconds: max(
              kGtOnScreenSettle.inMilliseconds,
              topRouteObserver.lastExit.inMilliseconds + 40,
            ),
          );
    return ColoredBox(
      color: t.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RefreshIndicator(
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
                    // Tien do lam o popup / tab khac hien ra khi nguoi dung
                    // quay lai Hom nay -> vong cham 100%, nhiem vu xong chay
                    // truoc mat ho. Doc xong du lieu da luu / nhan so lieu
                    // dong bo thi dung lai the: tien do khong do chinh nguoi
                    // dung vua lam tren may nay thi khong chuc mung.
                    GtWhenOnScreen<DayProgress>(
                      key: ValueKey((store.isLoaded, store.revision)),
                      value: store.today,
                      onScreen: onScreen,
                      settle: settle,
                      builder: (context, day, visit) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Moi the 1 lop ve rieng: hoat anh the nay khong ve
                          // lai 2 the kia.
                          RepaintBoundary(
                            child: GtRingsCard(
                              day: day,
                              strip: weekStreakStrip(
                                (d) => DateUtils.isSameDay(d, now)
                                    ? day
                                    : store.dayOf(d),
                                now,
                              ),
                              date: now,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RepaintBoundary(
                            child: _TodayWorkout(
                              today: day,
                              dueCount: SrsStore.instance.dueCount(now),
                            ),
                          ),
                          const SizedBox(height: 16),
                          RepaintBoundary(
                            child: GtQuestsCard(day: day, visit: visit),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Ngoai ListView: ListView chi dung con dang (sap) hien - con cuoi
          // danh sach tren man thap se khong bao gio duoc dung.
          Positioned(
            left: 0,
            top: 0,
            child: _TodayMilestones(onScreen: onScreen, settle: settle),
          ),
        ],
      ),
    );
  }
}

/// Milestone moi (chuoi 7/30/100/365, len Body Level, len Rank) chuc mung
/// khi nguoi dung quay lai Hom nay (MO-06). Moi nguon chi duoc tinh khi da
/// on dinh - khong lay moc goc / chuc mung tu so lieu tam:
/// - chuoi: store da doc xong VA da dong bo xong 1 luot cho chinh tai khoan
///   nay (truoc do co the con so lieu may cu / tai khoan truoc); chi ha moc
///   khi da dong bo thanh cong hom nay;
/// - English Level: nhu tren (lo trinh dong bo cung luot) VA da tai xong
///   lua chon Persona (chua tai -> tam roi ve A1);
/// - Body Level: tai thanh cong (loi mang -> null, khong phai Rookie).
class _TodayMilestones extends ConsumerWidget {
  const _TodayMilestones({required this.onScreen, required this.settle});

  final bool onScreen;
  final Duration settle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final settled = ref.watch(gymTalkSettledProvider);
    final synced = userId != null && settled?.user == userId;
    final stats = ref.watch(bodyStatsProvider).valueOrNull;
    final persona = ref.watch(learningPathChoiceProvider);
    final english = ref.watch(englishLevelProvider);
    final daily = DailyProgressStore.instance;
    return ListenableBuilder(
      listenable: daily,
      builder: (context, _) {
        final ready = synced && daily.isLoaded;
        return GtWhenOnScreen<MilestoneInputs>(
          value: (
            streak: ready ? daily.bodyBrainStreak : null,
            syncedOn: synced ? settled?.syncedOn : null,
            body: stats == null ? null : bodyLevelFor(stats),
            english: ready && persona.hasValue && !persona.hasError
                ? english
                : null,
          ),
          onScreen: onScreen,
          settle: settle,
          builder: (context, inputs, visit) => GtMilestoneWatcher(
            userId: userId,
            visit: visit,
            onScreen: onScreen,
            inputs: inputs,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// The Daily Rings

/// The Daily Rings: MOT vong chia 3 cung Tap / Hoc / Noi (ADR-0007), 3 chi
/// so va dai chuoi 7 ngay (README §5). Vong lap day bang lo xo expressive,
/// % va chi so dem len; cung vua cham 100% thi loe sang 1 lan + rung (spec
/// #96, quyet dinh #13).
class GtRingsCard extends ConsumerStatefulWidget {
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
  ConsumerState<GtRingsCard> createState() => _GtRingsCardState();
}

List<double> _ratiosOf(DayProgress d) => [
  d.trainRatio,
  d.learnRatio,
  d.speakRatio,
];

class _GtRingsCardState extends ConsumerState<GtRingsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(vsync: this);
  Set<int> _glowing = const {};

  /// Cung vua day dang cho lo xo cham 100% de rung + loe.
  final Set<int> _reaching = {};
  Timer? _reach;

  @override
  void didUpdateWidget(GtRingsCard old) {
    super.didUpdateWidget(old);
    final day = widget.day;
    final done = arcsToCelebrate(
      _ratiosOf(old.day),
      _ratiosOf(day),
      trainByRestDay: day.restDay && day.workouts < kDailyTrainGoal,
    );
    if (done.isEmpty) return;
    if (gtReduceMotion(context)) {
      // Khong lap / loe: rung ngay.
      GtHaptics.play(GtHapticEvent.ringCompleted);
      return;
    }
    // Rung + loe dung luc cung cham 100% (lo xo toi dich lan dau, truoc khi
    // nay qua roi lang lai), khong phai luc bat dau lap.
    _reaching.addAll(done);
    _reach?.cancel();
    _reach = Timer(
      Duration(
        milliseconds: springReachMs(
          gtSpringToken(GtMotionKind.expressive, GtMotionSpeed.normal),
        ),
      ),
      _celebrate,
    );
  }

  void _celebrate() {
    if (!mounted) return;
    // Vua roi tab Hom nay trong luc cho (tab khuat tam dung hoat anh): khong
    // rung o tab khac, khong loe lai luc quay ve.
    if (!TickerMode.valuesOf(context).enabled) {
      _reaching.clear();
      return;
    }
    GtHaptics.play(GtHapticEvent.ringCompleted);
    setState(() {
      // Cung khac vua day trong luc dang loe: loe cung luc, khong cat ngang.
      _glowing = {if (_glow.isAnimating) ..._glowing, ..._reaching};
      _reaching.clear();
    });
    _glow
      ..duration = Duration(
        milliseconds: motionDurationMs(
          GtMotionKind.expressive,
          GtMotionSpeed.slow,
          reduce: false,
        ),
      )
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _reach?.cancel();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final day = widget.day;
    final fill = gtMotion(context, GtMotionKind.expressive);
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
                '${widget.date.day}/${widget.date.month}',
                style: GtText.body(t.tx3, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                // Dich bay cua vong Launch Intro (#137).
                key: gtLaunchRingTarget,
                width: 164,
                height: 164,
                // Tween toi ti le moi: lan dau chay tu 0, sau do chay tu ti
                // le dang hien toi ti le moi.
                // Record (so sanh theo gia tri): rebuild voi cung ti le thi
                // KHONG chay lai hoat anh.
                child: TweenAnimationBuilder<_Ratios>(
                  tween: _RatiosTween(
                    begin: (0, 0, 0),
                    end: (day.trainRatio, day.learnRatio, day.speakRatio),
                  ),
                  duration: fill.duration,
                  curve: fill.curve,
                  builder: (context, ratios, child) => AnimatedBuilder(
                    animation: _glow,
                    builder: (context, _) => CustomPaint(
                      painter: GtRingsPainter(
                        ratios: [ratios.$1, ratios.$2, ratios.$3],
                        glowing: _glowing,
                        // 0 -> 1 -> 0 trong 1 lan loe; tat han khi xong.
                        glow: _glow.isAnimating ? sin(_glow.value * pi) : 0,
                        tokens: t,
                      ),
                      child: child,
                    ),
                  ),
                  child: Center(
                    child: GtCountUp(
                      value: ringsPercent(day),
                      format: (v) => '$v%',
                      style: GtText.ringStat(t.tx).copyWith(
                        // Chu so deu rong: so dang dem khong lam chu nhay.
                        fontFeatures: const [FontFeature.tabularFigures()],
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
                      count: day.restDay
                          ? null
                          : min(day.workouts, kDailyTrainGoal),
                      goal: kDailyTrainGoal,
                      text: day.restDay ? ref.tr('ring_rest_day') : null,
                      unit: day.restDay ? null : ref.tr('gt_unit_session'),
                    ),
                    const SizedBox(height: 12),
                    _RingStat(
                      label: ref.tr('ring_learn'),
                      color: t.blue,
                      count: day.wordsReviewed,
                      goal: kDailyLearnGoal,
                      unit: ref.tr('gt_unit_words'),
                    ),
                    const SizedBox(height: 12),
                    _RingStat(
                      label: ref.tr('ring_speak'),
                      color: t.teal,
                      count: day.speakAttempts,
                      goal: kDailySpeakGoal,
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
                cells: widget.strip,
                labels: ref.tr('gt_weekday_short').split(','),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ti le 3 cung Tap / Hoc / Noi.
typedef _Ratios = (double, double, double);

/// Noi suy tung ti le cua 3 cung.
class _RatiosTween extends Tween<_Ratios> {
  _RatiosTween({required super.begin, required super.end});

  @override
  _Ratios lerp(double t) {
    double at(double a, double b) => a + (b - a) * t;
    final (a, b) = (begin!, end!);
    return (at(a.$1, b.$1), at(a.$2, b.$2), at(a.$3, b.$3));
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({
    required this.label,
    required this.color,
    required this.goal,
    this.count,
    this.text,
    this.unit,
  });

  final String label;
  final Color color;

  /// So dem duoc (dem len); null -> hien [text] (vd "Ngay nghi").
  final int? count;
  final int goal;
  final String? text;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final value = count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GtText.body(color, size: 13, weight: FontWeight.w800),
        ),
        // 1 diem doc cho trinh doc man hinh ("5/10 tu"), khong tach 2.
        MergeSemantics(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (value == null)
                  Text(text ?? '', style: GtText.ringStat(t.tx))
                else
                  GtCountUp(
                    value: value,
                    format: (v) => '$v/$goal',
                    // Chu so deu rong: FittedBox khong co gian theo so dem.
                    style: GtText.ringStat(t.tx).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                if (unit != null)
                  Text(' $unit', style: GtText.ringStatUnit(t.tx2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// MOT vong chia 3 cung (ADR-0007): Tap (do) -> Hoc (xanh) -> Noi (ngoc), tu
/// 12 gio theo chieu kim dong ho; net 14, dau tron, ranh = mau nhat cua
/// chinh cung. Cung trong [glowing] loe sang theo [glow] (0..1) bang quang
/// nhieu lop net rong dan, KHONG blur (spec #96 quyet dinh #10).
class GtRingsPainter extends CustomPainter {
  GtRingsPainter({
    required this.ratios,
    required this.tokens,
    this.glowing = const {},
    this.glow = 0,
  });

  final List<double> ratios;
  final GtTokens tokens;
  final Set<int> glowing;
  final double glow;

  static const _radius = 64.0;
  static const _stroke = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final scale = size.shortestSide / 164;
    final radius = _radius * scale;
    final stroke = _stroke * scale;
    final rect = Rect.fromCircle(center: c, radius: radius);
    final arcs = segmentedRing(ratios, capRadians: (stroke / 2) / radius);
    final colors = [
      (tokens.red, tokens.redT),
      (tokens.blue, tokens.blueT),
      (tokens.teal, tokens.tealT),
    ];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    // Thu tu: moi ranh -> moi quang -> moi phan day, de quang cua cung nay
    // khong de len phan day cua cung ben canh.
    for (final (i, arc) in arcs.indexed) {
      final (_, track) = colors[i % colors.length];
      canvas.drawArc(rect, arc.start, arc.span, false, paint..color = track);
    }
    if (glow > 0) {
      for (final (i, arc) in arcs.indexed) {
        if (!glowing.contains(i) || arc.fill <= 0) continue;
        final (color, _) = colors[i % colors.length];
        // Quang: 3 net rong dan, mo dan ra ngoai.
        for (final (widen, alpha) in const [
          (1.9, 0.12),
          (1.55, 0.2),
          (1.25, 0.3),
        ]) {
          canvas.drawArc(
            rect,
            arc.start,
            arc.fill,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = stroke * (1 + (widen - 1) * glow)
              ..color = color.withValues(alpha: alpha * glow),
          );
        }
      }
    }
    for (final (i, arc) in arcs.indexed) {
      if (arc.fill <= 0) continue;
      final (color, _) = colors[i % colors.length];
      canvas.drawArc(rect, arc.start, arc.fill, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(GtRingsPainter old) =>
      !listEquals(old.ratios, ratios) ||
      old.glow != glow ||
      !setEquals(old.glowing, glowing) ||
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
