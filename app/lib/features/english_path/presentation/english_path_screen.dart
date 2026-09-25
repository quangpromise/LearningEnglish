import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../data/english_path_store.dart';
import '../data/level_test.dart';
import 'level_test_screen.dart';
import 'path_labels.dart';
import 'placement_screen.dart';
import 'unit_session_screen.dart';

/// Man "Lo trinh" (tab Hoc): 5 Stage A1 -> C1, Unit cua Stage hien tai kem
/// tien do, Unit ke tiep duoc lam noi bat. Mo dang popup.
class EnglishPathScreen extends ConsumerWidget {
  const EnglishPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(contentPackProvider);
    final level = ref.watch(englishLevelProvider);
    final state = ref.watch(englishPathStateProvider);
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
                  if (packAsync.valueOrNull != null &&
                      (state.placement != null || state.placementSkipped))
                    Tooltip(
                      message: ref.tr('placement_retake'),
                      child: SpeakerButton(
                        icon: Icons.restart_alt_rounded,
                        tapSize: 44,
                        color: AppColors.textPrimary,
                        onTap: () => openAppPopup(
                          context,
                          PlacementScreen(pack: packAsync.requireValue),
                        ),
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
        if (state.level == null && !state.placementSkipped)
          _PlacementBanner(pack: pack),
        for (final cefr in CefrLevel.values) ...[
          ..._stage(ref, cefr, stages[cefr]?.units ?? const [], next),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  /// Header + cac Unit cua 1 Stage. Moi Stage co noi dung deu hien Unit (xem
  /// lai/on duoc, khong khoa); chi Stage hien tai co nhan "Tiep theo".
  List<Widget> _stage(
    WidgetRef ref,
    CefrLevel cefr,
    List<PathUnit> units,
    PathUnit? next,
  ) {
    final current = cefr == level;
    return [
      _StageHeader(
        cefr: cefr,
        current: current,
        hasContent: units.isNotEmpty,
        // Stage duoi English Level coi nhu da qua (ADR-0001: English Level
        // la nguon goc duy nhat, ke ca khi den tu Placement).
        done: cefr.index < level.index || allUnitsComplete(pack, cefr, state),
      ),
      for (final unit in units)
        _UnitTile(
          unit: unit,
          state: state,
          isNext: current && unit.id == next?.id,
        ),
      if (current && units.isNotEmpty && next == null)
        if (cefr == CefrLevel.values.last && passedFinalStage(state))
          _Note(text: ref.tr('path_all_done'))
        else
          _LevelTestCard(pack: pack, stage: cefr, state: state),
      if (current && units.isEmpty) _Note(text: ref.tr('path_coming_soon')),
    ];
  }
}

/// Moi lam bai xep lop khi chua co English Level va chua bo qua.
class _PlacementBanner extends ConsumerWidget {
  const _PlacementBanner({required this.pack});
  final ContentPack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: GlowBox(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: AppColors.blue, width: 1.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('placement_banner_title'),
            style: AppTextStyles.heading(size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('placement_banner_body'),
            style: AppTextStyles.muted(size: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ref.tr('placement_start'),
                  onTap: () =>
                      openAppPopup(context, PlacementScreen(pack: pack)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: ref.tr('placement_skip'),
                  filled: false,
                  accentColor: AppColors.blue,
                  onTap: EnglishPathStore.instance.skipPlacement,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
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
              ref.tr(cefr.labelKey),
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
                    unitLabel(ref, unit),
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
              Text(unit.titleFor(lang), style: AppTextStyles.heading(size: 16)),
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
                    .replaceFirst('{p}', '${unitPercent(unit, state)}'),
                style: AppTextStyles.muted(size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Level Test khi moi Unit cua Stage hien tai da xong: lam bai, hoac
/// dem nguoc cooldown 24h kem nut on cau sai. Tu cap nhat khi het cooldown.
class _LevelTestCard extends ConsumerStatefulWidget {
  const _LevelTestCard({
    required this.pack,
    required this.stage,
    required this.state,
  });

  final ContentPack pack;
  final CefrLevel stage;
  final EnglishPathState state;

  @override
  ConsumerState<_LevelTestCard> createState() => _LevelTestCardState();
}

class _LevelTestCardState extends ConsumerState<_LevelTestCard> {
  Timer? _unlock;

  @override
  void dispose() {
    _unlock?.cancel();
    super.dispose();
  }

  /// "10:00 ngay 26/09" - cooldown 24h nen gio lam lai luon la ngay khac.
  String _retryLabel(DateTime retry) {
    final l10n = MaterialLocalizations.of(context);
    return '${l10n.formatTimeOfDay(TimeOfDay.fromDateTime(retry))}'
        ' · ${l10n.formatShortMonthDay(retry)}';
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    final stage = widget.stage;
    final state = widget.state;
    final now = DateTime.now();
    final status = levelTestStatus(pack, state, now, stage: stage);
    final last = state.levelTests[stage];
    final retry = retryAt(state, stage);
    _unlock?.cancel();
    if (status == LevelTestStatus.coolingDown && retry != null) {
      _unlock = Timer(retry.difference(now), () {
        if (mounted) setState(() {});
      });
    }
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: GlowBox(
        padding: const EdgeInsets.all(14),
        border: Border.all(color: AppColors.amber, width: 1.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('level_test_title').replaceFirst('{stage}', stage.code),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              status == LevelTestStatus.coolingDown && retry != null
                  ? ref
                        .tr('level_test_retry_at')
                        .replaceFirst('{time}', _retryLabel(retry))
                  : ref.tr('level_test_ready_body'),
              style: AppTextStyles.muted(size: 13),
            ),
            const SizedBox(height: 10),
            if (status == LevelTestStatus.ready)
              PillButton(
                label: ref.tr('level_test_start'),
                onTap: () => openAppPopup(
                  context,
                  LevelTestScreen(pack: pack, stage: stage),
                  dismissible: false,
                ),
              )
            else if (last != null && last.wrongItemIds.isNotEmpty)
              PillButton(
                label: ref.tr('level_test_review_wrong'),
                filled: false,
                accentColor: AppColors.blue,
                onTap: () =>
                    openAppPopup(context, reviewWrongSession(ref, pack, last)),
              ),
          ],
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
