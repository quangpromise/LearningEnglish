import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/cefr_level.dart';
import '../data/content_pack.dart';
import '../data/english_path_progress.dart';
import '../data/english_path_providers.dart';
import '../data/english_path_state.dart';
import 'unit_session_screen.dart';

/// Man "Lo trinh" (tab Hoc): 5 Stage A1 -> C1, Unit cua Stage hien tai kem
/// tien do, Unit ke tiep duoc lam noi bat. Mo dang popup.
class EnglishPathScreen extends ConsumerWidget {
  const EnglishPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(contentPackProvider);
    final level = ref.watch(englishLevelProvider);
    final state = ref.watch(englishPathStoreProvider).state;
    return ScreenBackground(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr('path_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  _LevelChip(level: level),
                  SpeakerButton(
                    icon: Icons.close_rounded,
                    tapSize: 44,
                    color: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: packAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.blue),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      ref.tr('path_load_error'),
                      style: AppTextStyles.muted(size: 14),
                    ),
                  ),
                  data: (pack) =>
                      _PathList(pack: pack, level: level, state: state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final CefrLevel level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.blue.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.blue),
    ),
    child: Text(level.code, style: AppTextStyles.heading(size: 14)),
  );
}

class _PathList extends ConsumerWidget {
  const _PathList({
    required this.pack,
    required this.level,
    required this.state,
  });

  final ContentPack pack;
  final CefrLevel level;
  final EnglishPathState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = nextUnit(pack, level, state);
    final stages = {for (final s in pack.stages) s.stage: s};
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final cefr in CefrLevel.values) ...[
          _StageHeader(
            cefr: cefr,
            current: cefr == level,
            hasContent: stages[cefr]?.units.isNotEmpty ?? false,
            done:
                cefr.index < level.index || allUnitsComplete(pack, cefr, state),
          ),
          if (cefr == level) ...[
            for (final unit in stages[cefr]?.units ?? const <PathUnit>[])
              _UnitTile(unit: unit, state: state, isNext: unit.id == next?.id),
            if (next == null && (stages[cefr]?.units.isNotEmpty ?? false))
              _Note(text: ref.tr('path_stage_done')),
            if (stages[cefr]?.units.isEmpty ?? true)
              _Note(text: ref.tr('path_coming_soon')),
          ],
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StageHeader extends ConsumerWidget {
  const _StageHeader({
    required this.cefr,
    required this.current,
    required this.hasContent,
    required this.done,
  });

  final CefrLevel cefr;
  final bool current;
  final bool hasContent;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = current
        ? AppColors.blue
        : (done ? AppColors.teal : AppColors.textMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: current ? 0.25 : 0.10),
              border: Border.all(color: color, width: current ? 2 : 1),
            ),
            child: done && !current
                ? const Icon(Icons.check_rounded, color: AppColors.teal)
                : Text(cefr.code, style: AppTextStyles.heading(size: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ref.tr('path_stage_${cefr.code.toLowerCase()}'),
              style: current
                  ? AppTextStyles.heading(size: 16)
                  : AppTextStyles.muted(size: 14),
            ),
          ),
          if (current)
            Text(
              ref.tr('path_you_are_here'),
              style: AppTextStyles.body(size: 12, color: AppColors.blue),
            )
          else if (!hasContent)
            Text(ref.tr('path_soon'), style: AppTextStyles.muted(size: 12)),
        ],
      ),
    );
  }
}

class _UnitTile extends ConsumerWidget {
  const _UnitTile({
    required this.unit,
    required this.state,
    required this.isNext,
  });

  final PathUnit unit;
  final EnglishPathState state;
  final bool isNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final progress = unitProgress(unit, state);
    final complete = isUnitComplete(unit, state);
    final accent = complete ? AppColors.teal : AppColors.blue;
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: GestureDetector(
        onTap: () => openAppPopup(context, UnitSessionScreen(unit: unit)),
        child: GlowBox(
          padding: const EdgeInsets.all(14),
          border: Border.all(
            color: isNext ? AppColors.blue : AppColors.glassBorder,
            width: isNext ? 1.6 : 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ref
                        .tr('path_unit_label')
                        .replaceFirst('{n}', '${unit.index}'),
                    style: AppTextStyles.muted(size: 12),
                  ),
                  const Spacer(),
                  if (isNext)
                    Text(
                      ref.tr('path_next'),
                      style: AppTextStyles.body(
                        size: 12,
                        color: AppColors.blue,
                      ),
                    ),
                  if (complete)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.teal,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                lang == AppLanguage.en ? unit.titleEn : unit.titleVi,
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: accent,
                  backgroundColor: AppColors.glassBorder,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ref
                    .tr('path_unit_progress')
                    .replaceFirst('{p}', '${(progress * 100).round()}'),
                style: AppTextStyles.muted(size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 8),
    child: Text(text, style: AppTextStyles.muted(size: 13)),
  );
}
