import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/content_pack.dart';
import '../data/english_path_progress.dart';
import '../data/english_path_providers.dart';
import '../data/english_path_store.dart';
import 'path_labels.dart';

/// Phien hoc 1 Unit (~5 phut): lan luot cac Practice Item dang chon nghia,
/// item chua dung truoc. Moi cau dung duoc ghi ngay vao tien do Unit.
class UnitSessionScreen extends ConsumerStatefulWidget {
  const UnitSessionScreen({super.key, required this.unit});
  final PathUnit unit;

  @override
  ConsumerState<UnitSessionScreen> createState() => _UnitSessionScreenState();
}

class _UnitSessionScreenState extends ConsumerState<UnitSessionScreen> {
  late final List<PracticeItem> _items = sessionItems(
    widget.unit,
    ref.read(englishPathStateProvider),
  );
  late final Map<String, PathWord> _words = {
    for (final w in widget.unit.words) w.en: w,
  };
  int _index = 0;
  int _correct = 0;
  int? _picked;

  @override
  void dispose() {
    TutorialVoice.shared.stop();
    super.dispose();
  }

  void _pick(PracticeItem item, int option) {
    if (_picked != null) return;
    final right = option == item.answerIndex;
    if (right) {
      HapticFeedback.lightImpact();
      _correct++;
      EnglishPathStore.instance.recordCorrect(item.unitId, item.id);
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() => _picked = option);
  }

  void _next() => setState(() {
    _picked = null;
    _index++;
  });

  @override
  Widget build(BuildContext context) {
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
                      unitLabel(ref, widget.unit),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  if (_index < _items.length)
                    Text(
                      '${_index + 1}/${_items.length}',
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
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _items.isEmpty ? 1 : _index / _items.length,
                minHeight: 4,
                color: AppColors.blue,
                backgroundColor: AppColors.glassBorder,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _index >= _items.length
                    ? _Summary(
                        unit: widget.unit,
                        correct: _correct,
                        total: _items.length,
                      )
                    : _question(_items[_index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(PracticeItem item) {
    final word = _words[item.wordEn];
    final picked = _picked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ref.tr('path_meaning_prompt'),
          style: AppTextStyles.muted(size: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(item.prompt, style: AppTextStyles.heading(size: 32)),
            ),
            SpeakerButton(
              onTap: () => TutorialVoice.shared.speakAndWait(item.prompt),
            ),
          ],
        ),
        if (word != null) Text(word.ipa, style: AppTextStyles.muted(size: 15)),
        const SizedBox(height: 20),
        for (var i = 0; i < item.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionButton(
              label: item.options[i],
              state: _optionState(i, item.answerIndex, picked),
              onTap: () => _pick(item, i),
            ),
          ),
        if (picked != null && word != null) ...[
          const SizedBox(height: 6),
          Text(word.exampleEn, style: AppTextStyles.body(size: 14)),
          Text(word.exampleVi, style: AppTextStyles.muted(size: 13)),
        ],
        const Spacer(),
        if (picked != null)
          PillButton(label: ref.tr('path_continue'), onTap: _next),
      ],
    );
  }
}

enum _OptionState { idle, right, wrong, dimmed }

_OptionState _optionState(int option, int answer, int? picked) {
  if (picked == null) return _OptionState.idle;
  if (option == answer) return _OptionState.right;
  if (option == picked) return _OptionState.wrong;
  return _OptionState.dimmed;
}

/// Nut dap an cao 56dp, bam 1 tay duoc.
class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _OptionState.right => AppColors.teal,
      _OptionState.wrong => AppColors.pink,
      _OptionState.idle || _OptionState.dimmed => AppColors.glassBorder,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state == _OptionState.idle ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: state == _OptionState.idle ? 0.08 : 0.18,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Opacity(
            opacity: state == _OptionState.dimmed ? 0.5 : 1,
            child: Text(label, style: AppTextStyles.body(size: 16)),
          ),
        ),
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({
    required this.unit,
    required this.correct,
    required this.total,
  });

  final PathUnit unit;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(englishPathStateProvider);
    final complete = isUnitComplete(unit, state);
    final progress = unitPercent(unit, state);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          complete ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
          size: 64,
          color: complete ? AppColors.amber : AppColors.teal,
        ),
        const SizedBox(height: 12),
        Text(
          ref.tr(complete ? 'path_unit_complete' : 'path_session_done'),
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          ref
              .tr('path_session_score')
              .replaceFirst('{c}', '$correct')
              .replaceFirst('{t}', '$total')
              .replaceFirst('{p}', '$progress'),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(size: 14),
        ),
        const SizedBox(height: 24),
        PillButton(
          label: ref.tr('path_back_to_path'),
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
