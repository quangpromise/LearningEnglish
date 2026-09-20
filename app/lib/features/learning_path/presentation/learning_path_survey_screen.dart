import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/learning_path_models.dart';
import 'learning_path_accent.dart';

/// Khao sat ngan de tao ke hoach 7 ngay ca nhan. Cac lua chon duoc luu co cau
/// truc de co the gui den AI planner o giai doan sau, thay vi chi luu persona.
class LearningPathSurveyScreen extends ConsumerStatefulWidget {
  const LearningPathSurveyScreen({super.key});

  @override
  ConsumerState<LearningPathSurveyScreen> createState() =>
      _LearningPathSurveyScreenState();
}

class _LearningPathSurveyScreenState
    extends ConsumerState<LearningPathSurveyScreen> {
  int _step = 0;
  int? _levelChoice;
  LearningPersona? _goal;
  int? _dailyMinutes;
  final Set<String> _skills = {};
  final Set<String> _topics = {};
  List<LearningPlanItem>? _plan;

  LearningPersona get _persona {
    // Nguoi mat goc can xay nen truoc, ke ca khi muc tieu cuoi la thi cu.
    if (_levelChoice == 0) return LearningPersona.beginner;
    if (_levelChoice == 1) {
      return LearningPersona.grammarOverhaul;
    }
    return _goal ?? LearningPersona.grammarOverhaul;
  }

  void _next() {
    if (_step == 0 && _levelChoice == null) return;
    if (_step == 1 && _goal == null) return;
    if (_step == 2 && _dailyMinutes == null) return;
    if (_step == 3 && _skills.isEmpty) return;
    setState(() => _step++);
  }

  Future<void> _finish() async {
    final profile = LearnerProfile(
      persona: _persona,
      goal: _goal!,
      dailyMinutes: _dailyMinutes!,
      prioritySkills: _skills.toList(),
      interestTopics: _topics.toList(),
    );
    await ref.read(learningPathRepositoryProvider).saveProfile(profile);
    if (!mounted) return;
    ref.invalidate(learningPathChoiceProvider);
    ref.invalidate(learningPathInteractedProvider);
    setState(() => _plan = buildFirstWeekPlan(profile));
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F1326),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: plan != null ? _PlanResult(plan: plan) : _survey(),
      ),
    );
  }

  Widget _survey() {
    final questions =
        <({String titleKey, List<({String id, String labelKey})> options})>[
          (
            titleKey: 'learning_survey_level_title',
            options: [
              (id: 'beginner', labelKey: 'learning_survey_level_beginner'),
              (
                id: 'grammar_weak',
                labelKey: 'learning_survey_level_grammar_weak',
              ),
              (id: 'goal_ready', labelKey: 'learning_survey_level_goal_ready'),
            ],
          ),
          (
            titleKey: 'learning_survey_goal_title',
            options: [
              (id: 'daily', labelKey: 'learning_survey_goal_daily'),
              (id: 'office', labelKey: 'learning_survey_goal_office'),
              (id: 'toeic', labelKey: 'learning_survey_goal_toeic'),
              (id: 'ielts', labelKey: 'learning_survey_goal_ielts'),
              (id: 'foundation', labelKey: 'learning_survey_goal_foundation'),
            ],
          ),
          (
            titleKey: 'learning_survey_time_title',
            options: [
              (id: '10', labelKey: 'learning_survey_time_10'),
              (id: '20', labelKey: 'learning_survey_time_20'),
              (id: '30', labelKey: 'learning_survey_time_30'),
              (id: '45', labelKey: 'learning_survey_time_45'),
            ],
          ),
          (
            titleKey: 'learning_survey_skills_title',
            options: [
              (id: 'vocabulary', labelKey: 'learning_survey_skill_vocabulary'),
              (id: 'grammar', labelKey: 'learning_survey_skill_grammar'),
              (id: 'listening', labelKey: 'learning_survey_skill_listening'),
              (id: 'speaking', labelKey: 'learning_survey_skill_speaking'),
              (id: 'reading', labelKey: 'learning_survey_skill_reading'),
              (id: 'writing', labelKey: 'learning_survey_skill_writing'),
            ],
          ),
          (
            titleKey: 'learning_survey_topics_title',
            options: [
              (id: 'daily_life', labelKey: 'learning_survey_topic_daily_life'),
              (id: 'work', labelKey: 'learning_survey_topic_work'),
              (id: 'travel', labelKey: 'learning_survey_topic_travel'),
              (id: 'technology', labelKey: 'learning_survey_topic_technology'),
              (id: 'music', labelKey: 'learning_survey_topic_music'),
            ],
          ),
        ];
    final (titleKey: title, options: options) = questions[_step];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          ref.tr('learning_survey_title'),
          style: AppTextStyles.heading(size: 19),
        ),
        const SizedBox(height: 4),
        Text(
          ref.tr('learning_survey_progress_${_step + 1}'),
          style: AppTextStyles.muted(size: 12.5),
        ),
        const SizedBox(height: 18),
        Text(
          ref.tr(title),
          style: AppTextStyles.body(size: 15, weight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < options.length; i++)
                  _option(options[i].id, ref.tr(options[i].labelKey), i),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: Text(ref.tr('learning_survey_back')),
              ),
            const Spacer(),
            FilledButton(
              onPressed: _step == 4 ? _finish : _next,
              child: Text(
                ref.tr(
                  _step == 4
                      ? 'learning_survey_create_plan'
                      : 'learning_survey_continue',
                ),
              ),
            ),
          ],
        ),
        Center(
          child: TextButton(
            onPressed: _turnOff,
            child: Text(
              ref.tr('learning_survey_turn_off'),
              style: AppTextStyles.muted(size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(String id, String label, int index) {
    bool selected;
    VoidCallback onTap;
    if (_step == 0) {
      selected = _levelChoice == index;
      onTap = () => setState(() => _levelChoice = index);
    } else if (_step == 1) {
      final values = [
        LearningPersona.dailyConversation,
        LearningPersona.officeEnglish,
        LearningPersona.toeicPrep,
        LearningPersona.ieltsPrep,
        LearningPersona.grammarOverhaul,
      ];
      selected = _goal == values[index];
      onTap = () => setState(() => _goal = values[index]);
    } else if (_step == 2) {
      const values = [10, 20, 30, 45];
      selected = _dailyMinutes == values[index];
      onTap = () => setState(() => _dailyMinutes = values[index]);
    } else {
      final target = _step == 3 ? _skills : _topics;
      selected = target.contains(id);
      onTap = () => setState(() {
        if (selected) {
          target.remove(id);
        } else if (_step != 3 || target.length < 2) {
          target.add(id);
        }
      });
    }
    final color = _goal != null ? personaColor(_persona) : AppColors.teal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: .16)
                : Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(
                    size: 13.5,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? color : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _turnOff() async {
    await ref.read(learningPathRepositoryProvider).turnOff();
    if (!mounted) return;
    ref.invalidate(learningPathChoiceProvider);
    ref.invalidate(learningPathInteractedProvider);
    Navigator.of(context).maybePop();
  }
}

class _PlanResult extends ConsumerWidget {
  const _PlanResult({required this.plan});
  final List<LearningPlanItem> plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        ref.tr('learning_plan_title'),
        style: AppTextStyles.heading(size: 19),
      ),
      const SizedBox(height: 4),
      Text(
        ref.tr('learning_plan_subtitle'),
        style: AppTextStyles.muted(size: 12.5),
      ),
      const SizedBox(height: 14),
      Expanded(
        child: ListView.separated(
          itemCount: plan.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final item = plan[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.teal.withValues(alpha: .22),
                    child: Text(
                      '${item.day}',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr(item.titleKey),
                          style: AppTextStyles.body(
                            size: 13.5,
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ref.tr(item.reasonKey),
                          style: AppTextStyles.muted(size: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(ref.tr('learning_plan_start')),
        ),
      ),
    ],
  );
}
