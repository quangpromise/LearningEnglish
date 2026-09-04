import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exercise_model.dart';
import '../data/workout_model.dart';
import 'workout_finished_screen.dart';

/// Man log truc tiep 1 buoi tap - port tu WorkoutViewModel/may trang thai
/// cua FitViet (Gate 4): log 1 set -> nghi (dem nguoc) -> set tiep theo ->
/// het bai tap cuoi -> hoan thanh. Toan bo state chi song trong man hinh nay
/// qua [WorkoutController] (khong phai Riverpod provider toan cuc), dung y
/// cach AiVoiceChatScreen tu quan state phuc tap cua no.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.blocks, this.programId});
  final List<WorkoutExerciseBlock> blocks;
  final int? programId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late final WorkoutController _controller;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
    _controller = WorkoutController(
      blocks: widget.blocks,
      repository: ref.read(workoutRepositoryProvider),
      userId: userId,
      programId: widget.programId,
    )..addListener(_onControllerChanged);
    _controller.start();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.phase == WorkoutPhase.finished) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutFinishedScreen(controller: _controller),
        ),
      );
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = _controller.currentBlock;
    final exercise = block.exercise;

    return ScreenBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const _IconCircle(icon: Icons.close_rounded),
                  ),
                  const Spacer(),
                  if (_controller.isPairedGroup)
                    Consumer(
                      builder: (context, ref, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.fitnessAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'A${_controller.pairSubIndex + 1} · '
                          '${_controller.currentSetNumber}/${_controller.currentTotalSets}',
                          style: AppTextStyles.body(
                            size: 12,
                            weight: FontWeight.w800,
                          ).copyWith(color: AppColors.fitnessAccent),
                        ),
                      ),
                    )
                  else
                    Consumer(
                      builder: (context, ref, _) => Text(
                        ref
                            .tr('fitness_workout_set_label')
                            .replaceFirst(
                              '{current}',
                              '${_controller.currentSetNumber}',
                            )
                            .replaceFirst(
                              '{total}',
                              '${_controller.currentTotalSets}',
                            ),
                        style: AppTextStyles.muted(),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (_controller.phase == WorkoutPhase.resting)
                _RestingView(controller: _controller)
              else
                _LoggingView(controller: _controller, exercise: exercise),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggingView extends StatelessWidget {
  const _LoggingView({required this.controller, required this.exercise});
  final WorkoutController controller;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          exercise.nameVi,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 20),
        ),
        Text(
          exercise.nameEn,
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(),
        ),
        const SizedBox(height: 28),
        Consumer(
          builder: (context, ref, _) => _StepperRow(
            label: ref.tr('fitness_workout_weight_kg'),
            value: controller.currentWeightKg.toStringAsFixed(1),
            onMinus: () => controller.adjustWeight(-2.5),
            onPlus: () => controller.adjustWeight(2.5),
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, _) => _StepperRow(
            label: ref.tr('fitness_workout_reps'),
            value: '${controller.currentReps}',
            onMinus: () => controller.adjustReps(-1),
            onPlus: () => controller.adjustReps(1),
          ),
        ),
        const SizedBox(height: 32),
        Consumer(
          builder: (context, ref, _) => PillButton(
            label: ref.tr('fitness_workout_complete_set'),
            accentColor: AppColors.fitnessAccent,
            onTap: controller.completeSet,
          ),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      borderRadius: 18,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(weight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 64,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 18),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.fitnessAccent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.fitnessAccent),
      ),
    );
  }
}

class _RestingView extends StatelessWidget {
  const _RestingView({required this.controller});
  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(
          builder: (context, ref, _) => Text(
            ref.tr('fitness_workout_resting'),
            style: AppTextStyles.muted(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${controller.restSecondsRemaining}s',
          style: AppTextStyles.heading(size: 48),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, _) => PillButton(
                label: ref.tr('fitness_workout_add_rest'),
                accentColor: AppColors.fitnessAccent,
                filled: false,
                onTap: () => controller.addRestSeconds(15),
              ),
            ),
            const SizedBox(width: 12),
            Consumer(
              builder: (context, ref, _) => PillButton(
                label: ref.tr('fitness_workout_skip_rest'),
                accentColor: AppColors.fitnessAccent,
                onTap: controller.skipRest,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: AppColors.glassBorder)),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}
