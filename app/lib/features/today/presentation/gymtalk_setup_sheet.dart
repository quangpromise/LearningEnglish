import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../fitness/data/program_model.dart';
import '../../learning_path/presentation/learning_path_survey_screen.dart';
import '../data/gymtalk_reminders.dart';
import '../data/program_recommendation.dart';

/// "Thiet lap GymTalk" - mo tu man Hom nay khi chua theo giao an nao: hoi
/// muc tieu, trinh do, so buoi/tuan, noi tap -> goi y 1 giao an va dat lam
/// giao an dang theo. Phan tieng Anh dung lai khao sat "Goi y lo trinh" co
/// san (LearningPathSurveyScreen).
class GymTalkSetupSheet extends ConsumerStatefulWidget {
  const GymTalkSetupSheet({super.key});

  @override
  ConsumerState<GymTalkSetupSheet> createState() => _GymTalkSetupSheetState();
}

class _GymTalkSetupSheetState extends ConsumerState<GymTalkSetupSheet> {
  FitnessGoal _goal = FitnessGoal.buildMuscle;
  ProgramDifficulty _difficulty = ProgramDifficulty.beginner;
  int _days = 3;
  bool _atHome = false;
  bool _saving = false;

  GymTalkSetupAnswers get _answers => GymTalkSetupAnswers(
    goal: _goal,
    difficulty: _difficulty,
    daysPerWeek: _days,
    atHome: _atHome,
  );

  Future<void> _follow(Program program) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(workoutRepositoryProvider)
          .setActiveProgramId(userId, program.id);
      ref
        ..invalidate(activeProgramIdProvider)
        ..invalidate(todayWorkoutPlanProvider);
      // Noi dung nhac hang ngay phu thuoc giao an -> dat lai.
      GymTalkReminders.instance.rescheduleFromPrefs(ref);
      if (mounted) Navigator.of(context).maybePop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(ref.tr('setup_save_failed'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openEnglishSurvey() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LearningPathSurveyScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(programListProvider).valueOrNull ?? const [];
    final recommended = recommendProgram(programs, _answers);
    final lang = ref.watch(appLanguageProvider);
    return ScreenBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ref.tr('setup_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                SpeakerButton(
                  icon: Icons.close_rounded,
                  tapSize: 44,
                  color: AppColors.textPrimary,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            Text(
              ref.tr('setup_subtitle'),
              style: AppTextStyles.muted(size: 13),
            ),
            const SizedBox(height: 18),
            _Question(
              title: ref.tr('setup_q_goal'),
              children: [
                for (final goal in FitnessGoal.values)
                  _Choice(
                    label: ref.tr(goal.labelKey),
                    selected: goal == _goal,
                    onTap: () => setState(() => _goal = goal),
                  ),
              ],
            ),
            _Question(
              title: ref.tr('setup_q_level'),
              children: [
                for (final level in ProgramDifficulty.values)
                  _Choice(
                    label: ref.tr(level.labelKey),
                    selected: level == _difficulty,
                    onTap: () => setState(() => _difficulty = level),
                  ),
              ],
            ),
            _Question(
              title: ref.tr('setup_q_days'),
              children: [
                for (final days in const [2, 3, 4, 5])
                  _Choice(
                    label: ref
                        .tr('setup_days_value')
                        .replaceFirst('{days}', '$days'),
                    selected: days == _days,
                    onTap: () => setState(() => _days = days),
                  ),
              ],
            ),
            _Question(
              title: ref.tr('setup_q_place'),
              children: [
                _Choice(
                  label: ref.tr('setup_place_gym'),
                  selected: !_atHome,
                  onTap: () => setState(() => _atHome = false),
                ),
                _Choice(
                  label: ref.tr('setup_place_home'),
                  selected: _atHome,
                  onTap: () => setState(() => _atHome = true),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (recommended != null)
              GlowBox(
                border: Border.all(
                  color: AppColors.fitnessAccent.withValues(alpha: 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ref.tr('setup_recommended'),
                      style: AppTextStyles.muted(size: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommended.titleFor(lang),
                      style: AppTextStyles.heading(size: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ref
                          .tr('setup_program_meta')
                          .replaceFirst(
                            '{sessions}',
                            '${recommended.sessionsPerWeek}',
                          )
                          .replaceFirst(
                            '{weeks}',
                            '${recommended.durationWeeks}',
                          ),
                      style: AppTextStyles.muted(size: 13),
                    ),
                    const SizedBox(height: 12),
                    PillButton(
                      label: ref.tr(
                        _saving ? 'setup_saving' : 'setup_follow_program',
                      ),
                      accentColor: AppColors.fitnessAccent,
                      accentGradient: AppColors.fitnessAccentGradient,
                      onTap: _saving ? null : () => _follow(recommended),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _openEnglishSurvey,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.school_rounded),
              label: Text(ref.tr('setup_english_survey')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body(weight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.fitnessAccent.withValues(alpha: 0.22)
          : AppColors.glassFill,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.fitnessAccent : AppColors.glassBorder,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label,
            style: AppTextStyles.body(
              weight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
