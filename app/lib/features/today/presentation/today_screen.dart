import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/navigation/root_tabs.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../ai_voice_chat/data/voice_chat_scenario.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../fitness/presentation/programs_list_screen.dart';
import '../../music_player/presentation/home_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../speaking/presentation/hands_free_drill_screen.dart';
import '../../srs/data/srs_store.dart';
import '../../srs/presentation/srs_review_screen.dart';
import '../data/daily_progress_store.dart';
import 'daily_rings.dart';
import 'gymtalk_setup_sheet.dart';

/// Tab "Hom nay" - man dau tien cua GymTalk: 3 vong muc tieu trong ngay
/// (Tap - Hoc - Noi), chuoi "Body + Brain", 1 nut hanh dong CHINH thay doi
/// theo lich tap hom nay, va loi tat on tu den han / luyen noi.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  static const _setupPromptedKey = 'gymtalk_setup_prompted_v1';
  bool _setupChecked = false;

  @override
  void initState() {
    super.initState();
    DailyProgressStore.instance.ensureLoaded();
    SrsStore.instance.ensureLoaded();
    // Lan dau: chua theo giao an nao -> tu mo "Thiet lap GymTalk" 1 lan
    // (60 giay: 4 cau hoi -> co giao an + buoi tap hom nay).
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
                greeting: '${ref.tr(greetingKeyForNow())},',
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
                    ..invalidate(todayWorkoutPlanProvider)
                    ..invalidate(myLearningXpProvider);
                },
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    DailyProgressStore.instance,
                    SrsStore.instance,
                  ]),
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: const [
                      _RingsCard(),
                      SizedBox(height: 14),
                      _PrimaryAction(),
                      SizedBox(height: 14),
                      _ReviewCard(),
                      SizedBox(height: 12),
                      _SpeakCard(),
                      SizedBox(height: 12),
                      _HandsFreeCard(),
                      SizedBox(height: 12),
                      _TrainerChatCard(),
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

class _RingsCard extends ConsumerWidget {
  const _RingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = DailyProgressStore.instance;
    final today = store.today;
    final streak = store.bodyBrainStreak;
    final xp = ref.watch(myLearningXpProvider).valueOrNull;
    return GlowBox(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.tr('today_goals_title'),
                  style: AppTextStyles.heading(size: 18),
                ),
              ),
              _Chip(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.amber,
                label: ref.tr('today_streak').replaceFirst('{days}', '$streak'),
              ),
            ],
          ),
          if (xp != null) ...[
            const SizedBox(height: 4),
            Text(
              ref
                  .tr('today_level')
                  .replaceFirst('{level}', '${xp.level}')
                  .replaceFirst('{xp}', '${xp.xpInLevel}')
                  .replaceFirst('{next}', '${xp.xpInLevel + xp.xpToNext}'),
              style: AppTextStyles.muted(size: 13),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GoalRing(
                ratio: today.trainRatio,
                color: AppColors.fitnessAccent,
                icon: Icons.fitness_center_rounded,
                label: ref.tr('ring_train'),
                caption: today.restDay
                    ? ref.tr('ring_rest_day')
                    : '${today.workouts}/$kDailyTrainGoal',
              ),
              GoalRing(
                ratio: today.learnRatio,
                color: AppColors.blue,
                icon: Icons.school_rounded,
                label: ref.tr('ring_learn'),
                caption: '${today.wordsReviewed}/$kDailyLearnGoal',
              ),
              GoalRing(
                ratio: today.speakRatio,
                color: AppColors.teal,
                icon: Icons.record_voice_over_rounded,
                label: ref.tr('ring_speak'),
                caption: '${today.speakAttempts}/$kDailySpeakGoal',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Nut hanh dong chinh cua ngay, theo lich tap hom nay:
/// - co buoi tap -> "Bat dau buoi tap" (mo giao an dang theo);
/// - da tap xong -> chuc mung + goi y on tu;
/// - ngay nghi -> on tu den han;
/// - chua chon giao an -> chon giao an.
class _PrimaryAction extends ConsumerWidget {
  const _PrimaryAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todayWorkoutPlanProvider);
    final today = DailyProgressStore.instance.today;
    final due = SrsStore.instance.dueCount(DateTime.now());

    void openPrograms({int? programId}) {
      openAppPopup(context, ProgramsListScreen(initialProgramId: programId));
    }

    void openReview() => openAppPopup(context, const SrsReviewScreen());

    void openSetup() => openAppPopup(context, const GymTalkSetupSheet());

    return planAsync.when(
      loading: () => const _ActionSkeleton(),
      error: (_, _) => _ActionCard(
        icon: Icons.fitness_center_rounded,
        color: AppColors.fitnessAccent,
        title: ref.tr('today_cta_choose_program'),
        subtitle: ref.tr('today_cta_error_sub'),
        onTap: () => openPrograms(),
      ),
      data: (plan) {
        if (plan == null) {
          return _ActionCard(
            icon: Icons.fitness_center_rounded,
            color: AppColors.fitnessAccent,
            title: ref.tr('today_cta_choose_program'),
            subtitle: ref.tr('today_cta_choose_program_sub'),
            onTap: openSetup,
          );
        }
        if (plan.isRestDay) {
          // Ghi nhan ngay nghi -> vong Tap tinh la xong (sau frame, khong
          // ghi state trong luc build).
          if (!today.restDay) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => DailyProgressStore.instance.markRestDay(true),
            );
          }
          return _ActionCard(
            icon: Icons.self_improvement_rounded,
            color: AppColors.blue,
            title: ref.tr('today_cta_rest_day'),
            subtitle: ref
                .tr('today_cta_rest_day_sub')
                .replaceFirst('{count}', '$due'),
            onTap: openReview,
          );
        }
        if (today.workouts > 0) {
          return _ActionCard(
            icon: Icons.emoji_events_rounded,
            color: AppColors.wealthUp,
            title: ref.tr('today_cta_done'),
            subtitle: ref.tr('today_cta_done_sub'),
            onTap: () =>
                ref.read(rootTabProvider.notifier).state = RootTab.progress,
          );
        }
        final exercises = plan.day.exercises.length;
        return _ActionCard(
          icon: Icons.play_arrow_rounded,
          color: AppColors.fitnessAccent,
          filled: true,
          title: ref.tr('today_cta_start_workout'),
          subtitle: ref
              .tr('today_cta_start_workout_sub')
              .replaceFirst('{exercises}', '$exercises')
              .replaceFirst('{sets}', '${plan.totalSets}'),
          onTap: () => openPrograms(programId: plan.program.id),
        );
      },
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = SrsStore.instance;
    final due = store.dueCount(DateTime.now());
    final subtitle = due > 0
        ? ref.tr('today_review_due').replaceFirst('{count}', '$due')
        : store.totalCards == 0
        ? ref.tr('today_review_empty')
        : ref.tr('today_review_none_due');
    return _ActionCard(
      icon: Icons.style_rounded,
      color: AppColors.blue,
      title: ref.tr('today_review_title'),
      subtitle: subtitle,
      badge: due > 0 ? '$due' : null,
      onTap: () => openAppPopup(context, const SrsReviewScreen()),
    );
  }
}

class _SpeakCard extends ConsumerWidget {
  const _SpeakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActionCard(
      icon: Icons.record_voice_over_rounded,
      color: AppColors.teal,
      title: ref.tr('today_speak_title'),
      subtitle: ref
          .tr('today_speak_sub')
          .replaceFirst('{goal}', '$kDailySpeakGoal'),
      onTap: () => openAppPopup(
        context,
        const PronunciationScreen(),
        routeName: kPronunciationRouteName,
      ),
    );
  }
}

/// Luyen noi ranh tay (nghe va nhac lai) - dung khi chay bo/dap xe.
class _HandsFreeCard extends ConsumerWidget {
  const _HandsFreeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActionCard(
      icon: Icons.headphones_rounded,
      color: AppColors.teal,
      title: ref.tr('hands_free_title'),
      subtitle: ref.tr('today_hands_free_sub'),
      onTap: () => openAppPopup(
        context,
        const HandsFreeDrillScreen(),
        // Chiem mic - nut AI Voice Chat biet de khong mo chong len.
        routeName: kPronunciationRouteName,
      ),
    );
  }
}

/// Tro chuyen voi "PT AI" - AI Voice Chat nhap vai huan luyen vien.
class _TrainerChatCard extends ConsumerWidget {
  const _TrainerChatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActionCard(
      icon: Icons.sports_gymnastics_rounded,
      color: AppColors.purple,
      title: ref.tr('voice_chat_pt_title'),
      subtitle: ref.tr('today_pt_sub'),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        routeSettings: const RouteSettings(name: kAiVoiceChatRouteName),
        builder: (_) => const FractionallySizedBox(
          heightFactor: 0.94,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            child: AiVoiceChatScreen(
              scenario: VoiceChatScenario.personalTrainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
    this.badge,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool filled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final badge = this.badge;
    return Material(
      color: filled ? color : AppColors.glassFill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: filled ? color : color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: filled ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading(size: 17)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.body(
                        size: 13,
                        color: filled
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: filled ? Colors.white : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSkeleton extends StatelessWidget {
  const _ActionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body(
              size: 12,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
