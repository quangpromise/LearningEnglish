import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/cefr_level.dart';
import '../data/content_pack.dart';
import '../data/english_path_progress.dart';
import '../data/english_path_providers.dart';
import '../data/english_path_store.dart';
import '../data/placement.dart';
import 'path_option_button.dart';

/// Placement Test (~3 phut, toi da 15 cau). Khong hien dung/sai tung cau -
/// chi ghi nhan va chuyen cau. Ket qua ghi de English Level (spec #45).
class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key, required this.pack});
  final ContentPack pack;

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  PlacementSession? _session;

  /// Cau vua tra loi + dap an da chon - giu to sang 350ms roi moi hien cau
  /// tiep theo (hoac man ket qua).
  ({PracticeItem item, int option})? _justAnswered;
  Timer? _clearHighlight;

  @override
  void dispose() {
    _clearHighlight?.cancel();
    super.dispose();
  }

  void _start() {
    if (_session != null) return;
    final persona = ref.read(learningPathChoiceProvider).valueOrNull;
    setState(() {
      _session = PlacementSession(
        start: defaultLevelForPersona(persona),
        pool: placementPool(widget.pack),
        packVersion: widget.pack.packVersion,
      );
    });
  }

  /// Ghi nhan NGAY (dong man giua chung cung khong mat cau/ket qua); chi
  /// phan to sang la tre 350ms.
  void _pick(PracticeItem item, int option) {
    if (_justAnswered != null) return;
    HapticFeedback.selectionClick();
    final session = _session!;
    session.answer(option);
    final record = session.record;
    if (record != null) EnglishPathStore.instance.completePlacement(record);
    setState(() => _justAnswered = (item: item, option: option));
    _clearHighlight = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _justAnswered = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return ScreenBackground(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr('placement_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  if (session != null && !session.isFinished)
                    Text(
                      ref
                          .tr('placement_progress')
                          .replaceFirst('{n}', '${session.asked + 1}')
                          .replaceFirst('{max}', '$kPlacementMaxQuestions'),
                      style: AppTextStyles.muted(size: 14),
                    ),
                  SpeakerButton(
                    icon: Icons.close_rounded,
                    tapSize: 44,
                    color: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _body(session)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(PlacementSession? session) {
    if (session == null) return _Intro(onStart: _start);
    final answered = _justAnswered;
    if (answered != null) return _question(answered.item, answered.option);
    if (session.isFinished) return _Result(record: session.record!);
    return _question(session.current!, null);
  }

  Widget _question(PracticeItem item, int? chosen) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(ref.tr('path_meaning_prompt'), style: AppTextStyles.muted(size: 13)),
      const SizedBox(height: 8),
      Text(item.prompt, style: AppTextStyles.heading(size: 32)),
      const SizedBox(height: 20),
      for (var i = 0; i < item.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PathOptionButton(
            label: item.options[i],
            state: chosen == null
                ? PathOptionState.idle
                : (chosen == i
                      ? PathOptionState.selected
                      : PathOptionState.dimmed),
            onTap: () => _pick(item, i),
          ),
        ),
    ],
  );
}

class _Intro extends ConsumerWidget {
  const _Intro({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lam lai: ket qua moi se THAY bac hien tai (ke ca khi thap hon).
    final retake = ref.watch(englishPathStateProvider).level != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.explore_rounded, size: 64, color: AppColors.blue),
        const SizedBox(height: 12),
        Text(
          ref.tr('placement_intro_title'),
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          ref.tr('placement_intro_body'),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(size: 14),
        ),
        if (retake) ...[
          const SizedBox(height: 8),
          Text(
            ref.tr('placement_retake_warning'),
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 13, color: AppColors.amber),
          ),
        ],
        const SizedBox(height: 24),
        PillButton(label: ref.tr('placement_start'), onTap: onStart),
      ],
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.record});
  final PlacementRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = [
      ref
          .tr('placement_result_body')
          .replaceFirst('{stage}', ref.tr(record.result.labelKey)),
      if (record.stopReason == PlacementStopReason.noContent)
        ref.tr('placement_note_no_content'),
      if (record.confidence == PlacementConfidence.low)
        ref.tr('placement_note_low_confidence'),
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.blue, width: 2),
            ),
            child: Text(
              record.result.code,
              style: AppTextStyles.heading(size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr('placement_result_title'),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 22),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final e in placementStageScores(record).entries)
                _StageScoreChip(
                  stage: e.key,
                  correct: e.value.correct,
                  asked: e.value.asked,
                  passed: record.stageResults[e.key] ?? false,
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                note,
                textAlign: TextAlign.center,
                style: AppTextStyles.muted(size: 14),
              ),
            ),
          const SizedBox(height: 18),
          PillButton(
            label: ref.tr('placement_go'),
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// "B1 ✓ 3/3" - ket qua tung Stage da danh gia.
class _StageScoreChip extends StatelessWidget {
  const _StageScoreChip({
    required this.stage,
    required this.correct,
    required this.asked,
    required this.passed,
  });

  final CefrLevel stage;
  final int correct;
  final int asked;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppColors.teal : AppColors.pink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        '${stage.code} ${passed ? '✓' : '✗'} $correct/$asked',
        style: AppTextStyles.body(size: 13),
      ),
    );
  }
}
