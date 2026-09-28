import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../fitness/data/program_model.dart';
import '../../today/data/daily_progress_store.dart';
import '../../today/data/gymtalk_reminders.dart';
import '../../today/data/program_recommendation.dart';
import '../data/onboarding_mapping.dart';
import '../data/onboarding_repository.dart';

/// Onboarding 3 buoc cua ban redesign (spec #70, #80; README §1-3): chao
/// mung -> muc tieu (chon nhieu) -> so phut/ngay (+ tom tat ke hoach) ->
/// giao an goi y. Khong co Paywall (ADR-0006). Dung chung co "da xem" voi
/// carousel cu -> nguoi dung cu khong bi hoi lai.
class GtOnboardingScreen extends ConsumerStatefulWidget {
  const GtOnboardingScreen({
    super.key,
    required this.userId,
    required this.onDone,
  });

  final String userId;
  final VoidCallback onDone;

  @override
  ConsumerState<GtOnboardingScreen> createState() => _GtOnboardingScreenState();
}

class _GtOnboardingScreenState extends ConsumerState<GtOnboardingScreen> {
  // Cung khoa voi GymTalkSetupSheet tu mo o Hom nay -> khong mo lai sau
  // khi vua chon giao an o day.
  static const _setupPromptedKey = 'gymtalk_setup_prompted_v1';

  int _step = 0;
  final Set<OnboardingGoal> _goals = {};
  int _minutes = kDefaultOnboardingMinutes;
  bool _saving = false;

  static const _timeout = Duration(seconds: 8);

  /// Doc gia tri hien co tren server (co het gio); loi -> null.
  Future<T?> _existing<T>(Future<T?> future) async {
    try {
      return await future.timeout(_timeout);
    } catch (_) {
      return null;
    }
  }

  /// Luu lua chon roi vao app. KHONG ghi de giao an / persona da co (vd
  /// nguoi dung cu cai lai app thay onboarding lai - co "da xem" chi luu
  /// tren may). Moi buoc ghi rieng, loi thi bao va van vao app.
  Future<void> _finish({Program? follow}) async {
    if (_saving) return;
    setState(() => _saving = true);
    var failed = false;
    var programSet = false;
    try {
      if (follow != null) {
        final current = await _existing(
          ref.read(activeProgramIdProvider.future),
        );
        if (current != null) {
          programSet = true;
        } else {
          try {
            await ref
                .read(workoutRepositoryProvider)
                .setActiveProgramId(widget.userId, follow.id)
                .timeout(_timeout);
            programSet = true;
            ref
              ..invalidate(activeProgramIdProvider)
              ..invalidate(todayWorkoutPlanProvider);
            // Noi dung nhac hang ngay phu thuoc giao an -> dat lai.
            GymTalkReminders.instance.rescheduleFromPrefs(ref);
          } catch (_) {
            failed = true;
          }
        }
      }
      final persona = personaFor(_goals);
      if (persona != null) {
        final current = await _existing(
          ref.read(learningPathChoiceProvider.future),
        );
        if (current == null) {
          try {
            await ref
                .read(learningPathRepositoryProvider)
                .choosePersona(persona)
                .timeout(_timeout);
            ref.invalidate(learningPathChoiceProvider);
          } catch (_) {
            failed = true;
          }
        }
      }
      // Chi tat loi nhac "Thiet lap GymTalk" o Hom nay khi DA co giao an -
      // bo qua / de sau / loi thi Hom nay van nhac chon giao an.
      if (programSet) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_setupPromptedKey, true);
        } catch (_) {}
      }
      if (failed && mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(ref.tr('setup_save_failed'))));
      }
    } finally {
      try {
        await OnboardingRepository.markSeen(widget.userId);
      } catch (_) {}
      if (mounted) {
        setState(() => _saving = false);
        widget.onDone();
      }
    }
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, 3));
  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    // Giao an goi y chi can o buoc 3 (danh sach giao an tai luc do).
    final recommended = _step == 3
        ? recommendProgram(
            ref.watch(programListProvider).valueOrNull ?? const [],
            setupAnswersFor(_goals, _minutes),
          )
        : null;
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: _step == 0 ? Colors.black : t.bg,
        body: switch (_step) {
          0 => _Welcome(onStart: _next, onSkip: () => _finish()),
          1 => _Step(
            index: 1,
            onBack: _back,
            ctaLabel: ref.tr('gt_onb_continue'),
            onCta: _next,
            child: _Goals(
              selected: _goals,
              onToggle: (g) => setState(
                () => _goals.contains(g) ? _goals.remove(g) : _goals.add(g),
              ),
            ),
          ),
          2 => _Step(
            index: 2,
            onBack: _back,
            ctaLabel: ref.tr('gt_onb_make_plan'),
            onCta: _next,
            child: _Minutes(
              minutes: _minutes,
              onPick: (m) => setState(() => _minutes = m),
            ),
          ),
          _ => _Step(
            index: 3,
            onBack: _back,
            ctaLabel: ref.tr('gt_onb_follow'),
            busy: _saving,
            // Chua co goi y (dang tai / loi) -> khong cho bam "Theo giao an".
            onCta: switch (recommended) {
              final Program p => () => _finish(follow: p),
              null => null,
            },
            secondaryLabel: ref.tr('gt_onb_later'),
            onSecondary: () => _finish(),
            child: _Recommendation(goals: _goals, minutes: _minutes),
          ),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buoc 0: chao mung

class _Welcome extends ConsumerWidget {
  const _Welcome({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          right: -120,
          height: 560,
          width: 560,
          child: Image.asset(
            'assets/fitness/home/hero.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topRight,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Colors.black],
              stops: [0.3, 0.7],
            ),
          ),
        ),
        SafeArea(
          // Cuon duoc tren may nho / chu to; Spacer day noi dung xuong day.
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: t.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GYMTALK',
                            style: GtText.overline(Colors.white)
                                .copyWith(letterSpacing: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            style: GtText.onboardingHero(Colors.white),
                            children: [
                              TextSpan(text: ref.tr('gt_onb_hero_1')),
                              const TextSpan(text: '\n'),
                              TextSpan(text: ref.tr('gt_onb_hero_2')),
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: ref.tr('gt_onb_hero_3'),
                                style: TextStyle(color: t.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ref.tr('gt_onb_welcome_body'),
                        style: GtText.body(const Color(0xFFB8BCC4), size: 16),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 58,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onStart,
                          child: Text(
                            '${ref.tr('gt_onb_start')} →',
                            style: GtText.rowTitle(Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: onSkip,
                          child: Text(
                            ref.tr('gt_onb_skip'),
                            style: GtText.body(const Color(0xFFB8BCC4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Khung buoc 1-3: nut lui + 3 vach tien do + tieu de + CTA

class _Step extends ConsumerWidget {
  const _Step({
    required this.index,
    required this.onBack,
    required this.ctaLabel,
    required this.onCta,
    required this.child,
    this.busy = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final int index;
  final VoidCallback onBack;
  final String ctaLabel;
  final VoidCallback? onCta;
  final Widget child;
  final bool busy;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_rounded, color: t.tx),
                  style: IconButton.styleFrom(backgroundColor: t.s1),
                ),
                const SizedBox(width: 12),
                for (var i = 1; i <= 3; i++) ...[
                  if (i > 1) const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= index ? t.tx : t.s2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text(
              ref
                  .tr('gt_onb_step')
                  .replaceFirst('{n}', '$index')
                  .replaceFirst('{total}', '3'),
              style: GtText.overline(t.tx3),
            ),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: t.inv,
                  foregroundColor: t.onInv,
                  shape: const StadiumBorder(),
                ),
                onPressed: busy ? null : onCta,
                child: busy
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: t.onInv,
                        ),
                      )
                    : Text(ctaLabel, style: GtText.rowTitle(t.onInv)),
              ),
            ),
            if (secondaryLabel != null)
              TextButton(
                onPressed: busy ? null : onSecondary,
                child: Text(secondaryLabel!, style: GtText.body(t.tx2)),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buoc 1: muc tieu

class _Goals extends ConsumerWidget {
  const _Goals({required this.selected, required this.onToggle});

  final Set<OnboardingGoal> selected;
  final ValueChanged<OnboardingGoal> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final specs = [
      (
        OnboardingGoal.buildMuscle,
        Icons.fitness_center_rounded,
        t.red,
        'gt_onb_goal_muscle',
      ),
      (
        OnboardingGoal.loseFat,
        Icons.local_fire_department_rounded,
        t.streak,
        'gt_onb_goal_fat',
      ),
      (
        OnboardingGoal.conversation,
        Icons.forum_rounded,
        t.blue,
        'gt_onb_goal_talk',
      ),
      (
        OnboardingGoal.exam,
        Icons.workspace_premium_rounded,
        t.gold,
        'gt_onb_goal_exam',
      ),
    ];
    Widget card(int i) {
      final (goal, icon, color, key) = specs[i];
      final on = selected.contains(goal);
      return Semantics(
        button: true,
        selected: on,
        child: GestureDetector(
          onTap: () => onToggle(goal),
          child: Container(
            constraints: const BoxConstraints(minHeight: 124),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.s1,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: on ? color : t.bd, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 30),
                    const Spacer(),
                    Icon(
                      on
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: on ? color : t.tx3,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  ref.tr(key),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.rowTitle(t.tx).copyWith(fontSize: 16),
                ),
                Text(
                  ref.tr('${key}_sub'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GtText.body(t.tx2, size: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget row(int a, int b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: card(a)),
          const SizedBox(width: 12),
          Expanded(child: card(b)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(ref.tr('gt_onb_goals_title'), style: GtText.stepTitle(t.tx)),
        const SizedBox(height: 6),
        Text(ref.tr('gt_onb_goals_sub'), style: GtText.body(t.tx2)),
        const SizedBox(height: 20),
        row(0, 1),
        const SizedBox(height: 12),
        row(2, 3),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buoc 2: so phut moi ngay

class _Minutes extends ConsumerWidget {
  const _Minutes({required this.minutes, required this.onPick});

  final int minutes;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(ref.tr('gt_onb_minutes_title'), style: GtText.stepTitle(t.tx)),
        const SizedBox(height: 18),
        for (final m in kOnboardingMinutes) ...[
          Semantics(
            button: true,
            selected: m == minutes,
            child: GestureDetector(
              onTap: () => onPick(m),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: t.s1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: m == minutes ? t.tx : t.bd,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text('$m', style: GtText.ringStat(t.tx)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('gt_onb_min_${m}_label'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GtText.rowTitle(t.tx),
                          ),
                          Text(
                            ref.tr('gt_onb_min_${m}_sub'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GtText.body(t.tx2, size: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.s2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.tr('gt_onb_plan_overline'),
                style: GtText.overline(t.tx3),
              ),
              const SizedBox(height: 10),
              _PlanLine(
                icon: Icons.fitness_center_rounded,
                color: t.red,
                text: ref
                    .tr('gt_onb_plan_sessions')
                    .replaceFirst('{n}', '${sessionsPerWeekFor(minutes)}'),
              ),
              const SizedBox(height: 6),
              _PlanLine(
                icon: Icons.school_rounded,
                color: t.blue,
                text:
                    ref
                        .tr('gt_onb_plan_words')
                        .replaceFirst('{n}', '$kDailyLearnGoal') +
                    (includesSpeakingFor(minutes)
                        ? ref.tr('gt_onb_plan_speak')
                        : ''),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanLine extends StatelessWidget {
  const _PlanLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: GtText.body(t.tx, weight: FontWeight.w800)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buoc 3: giao an goi y

class _Recommendation extends ConsumerWidget {
  const _Recommendation({required this.goals, required this.minutes});

  final Set<OnboardingGoal> goals;
  final int minutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final lang = ref.watch(appLanguageProvider);
    final programsAsync = ref.watch(programListProvider);
    final program = recommendProgram(
      programsAsync.valueOrNull ?? const [],
      setupAnswersFor(goals, minutes),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(ref.tr('gt_onb_reco_title'), style: GtText.stepTitle(t.tx)),
        const SizedBox(height: 6),
        Text(ref.tr('gt_onb_reco_sub'), style: GtText.body(t.tx2)),
        const SizedBox(height: 20),
        if (program == null && programsAsync.isLoading)
          Center(child: CircularProgressIndicator(color: t.tx))
        else if (program == null) ...[
          Text(ref.tr('gt_onb_reco_none'), style: GtText.body(t.tx2)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref.invalidate(programListProvider),
              icon: Icon(Icons.refresh_rounded, color: t.tx),
              label: Text(ref.tr('gt_onb_retry'), style: GtText.body(t.tx)),
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: t.s1,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: t.red, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fitness_center_rounded, color: t.red, size: 28),
                const SizedBox(height: 10),
                Text(
                  program.titleFor(lang),
                  style: GtText.cardTitle(t.tx).copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  ref
                      .tr('gt_onb_reco_meta')
                      .replaceFirst('{n}', '${program.sessionsPerWeek}')
                      .replaceFirst('{w}', '${program.durationWeeks}'),
                  style: GtText.body(t.tx2, size: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
