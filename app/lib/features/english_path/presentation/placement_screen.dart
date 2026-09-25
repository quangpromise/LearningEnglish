import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/content_pack.dart';
import '../data/english_path_progress.dart';
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
  int? _picked;
  Timer? _advance;

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _start() {
    final persona = ref.read(learningPathChoiceProvider).valueOrNull;
    setState(() {
      _session = PlacementSession(
        start: defaultLevelForPersona(persona),
        pool: placementPool(widget.pack),
        packVersion: widget.pack.packVersion,
      );
    });
  }

  void _pick(int option) {
    if (_picked != null) return;
    HapticFeedback.selectionClick();
    setState(() => _picked = option);
    _advance = Timer(const Duration(milliseconds: 350), () {
      final session = _session!;
      session.answer(option);
      final record = session.record;
      if (record != null) EnglishPathStore.instance.completePlacement(record);
      if (mounted) setState(() => _picked = null);
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
                      '${session.asked + 1}/$kPlacementMaxQuestions',
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
              Expanded(
                child: session == null
                    ? _Intro(onStart: _start)
                    : session.isFinished
                    ? _Result(record: session.record!)
                    : _question(session.current!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(PracticeItem item) => Column(
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
            state: _picked == null
                ? PathOptionState.idle
                : (_picked == i
                      ? PathOptionState.selected
                      : PathOptionState.dimmed),
            onTap: () => _pick(i),
          ),
        ),
    ],
  );
}

class _Intro extends ConsumerWidget {
  const _Intro({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
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
      const SizedBox(height: 24),
      PillButton(label: ref.tr('placement_start'), onTap: onStart),
    ],
  );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        const SizedBox(height: 8),
        for (final n in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              n,
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
    );
  }
}
