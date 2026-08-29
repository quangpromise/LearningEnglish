import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/fitness_data.dart';
import 'body_diagram.dart';
import 'exercise_animation.dart';

enum _Phase { work, rest, done }

/// Hen gio tap cho 1 bai tap: neu bai tinh theo thoi gian (workSeconds) se
/// tu dem nguoc; neu tinh theo so lan lap (reps) thi nguoi tap tu bam "Xong
/// hiep" khi lam xong - sau moi hiep la 1 khoang nghi dem nguoc, lap lai
/// du so hiep (sets) roi bao hoan thanh.
class FitnessTimerScreen extends ConsumerStatefulWidget {
  const FitnessTimerScreen({
    super.key,
    required this.exercise,
    required this.color,
    this.region = BodyRegion.fullBody,
  });
  final Exercise exercise;
  final Color color;
  final BodyRegion region;

  @override
  ConsumerState<FitnessTimerScreen> createState() => _FitnessTimerScreenState();
}

class _FitnessTimerScreenState extends ConsumerState<FitnessTimerScreen> {
  int _currentSet = 1;
  _Phase _phase = _Phase.work;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startWorkPhase();
  }

  void _startWorkPhase() {
    _timer?.cancel();
    setState(() => _phase = _Phase.work);
    if (widget.exercise.isTimeBased) {
      setState(() => _secondsLeft = widget.exercise.workSeconds!);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 1) {
          _finishWorkPhase();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  void _finishWorkPhase() {
    _timer?.cancel();
    if (_currentSet >= widget.exercise.sets) {
      setState(() => _phase = _Phase.done);
      return;
    }
    setState(() {
      _phase = _Phase.rest;
      _secondsLeft = widget.exercise.restSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _currentSet++);
        _startWorkPhase();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() => _currentSet++);
    _startWorkPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ex.name, style: AppTextStyles.heading(size: 17)),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: _phase == _Phase.done
                    ? _buildDone(context)
                    : _buildActive(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActive(BuildContext context) {
    final ex = widget.exercise;
    final isRest = _phase == _Phase.rest;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${ref.tr('fitness_set_label')} $_currentSet/${ex.sets}',
          style: AppTextStyles.muted(size: 13),
        ),
        const SizedBox(height: 8),
        ExerciseAnimation(
          color: widget.color,
          region: widget.region,
          movement: ex.movement,
        ),
        const SizedBox(height: 10),
        if (isRest) ...[
          Text(
            ref.tr('fitness_rest_label'),
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text('$_secondsLeft', style: AppTextStyles.heading(size: 64)),
          const SizedBox(height: 20),
          PillButton(
            label: ref.tr('fitness_skip_rest'),
            filled: false,
            onTap: _skipRest,
          ),
        ] else if (ex.isTimeBased) ...[
          Text('$_secondsLeft', style: AppTextStyles.heading(size: 80)),
          const SizedBox(height: 8),
          Text(
            ref.tr('fitness_seconds_left'),
            style: AppTextStyles.muted(size: 12),
          ),
        ] else ...[
          Text('${ex.reps}', style: AppTextStyles.heading(size: 80)),
          Text(ref.tr('fitness_reps'), style: AppTextStyles.muted(size: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: PillButton(
              label: ref.tr('fitness_done_set'),
              onTap: _finishWorkPhase,
            ),
          ),
        ],
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ex.instructionsVi,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 12.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: widget.color, size: 72),
        const SizedBox(height: 16),
        Text(
          ref.tr('fitness_completed'),
          style: AppTextStyles.heading(size: 20),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: PillButton(
            label: ref.tr('vocab_done'),
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
