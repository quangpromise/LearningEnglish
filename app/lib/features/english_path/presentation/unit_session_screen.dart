import 'package:flutter/material.dart';
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
import 'practice_question.dart';

/// Phien hoc 1 Unit (~5 phut): item chua dung truoc.
class UnitSessionScreen extends ConsumerWidget {
  const UnitSessionScreen({super.key, required this.unit});
  final PathUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PracticeSessionScreen(
    title: unitLabel(ref, unit),
    items: sessionItems(unit, ref.read(englishPathStateProvider)),
    words: unit.words,
    unit: unit,
  );
}

/// Phien luyen co phan hoi dung/sai tung cau: dung cho phien hoc Unit va
/// phien on cau sai sau Level Test. Moi cau dung duoc ghi ngay vao tien do
/// Unit cua item do.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({
    super.key,
    required this.title,
    required this.items,
    required this.words,
    this.unit,
  });

  final String title;
  final List<PracticeItem> items;
  final List<PathWord> words;

  /// Co thi man ket thuc hien tien do Unit nay.
  final PathUnit? unit;

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  late final List<PracticeItem> _items = widget.items;
  late final Map<String, PathWord> _words = {
    for (final w in widget.words) w.en: w,
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
    if (option == item.answerIndex) {
      _correct++;
      EnglishPathStore.instance.recordCorrect(item.unitId, item.id);
    } else {
      EnglishPathStore.instance.recordWrong(item.id);
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
                      widget.title,
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

  Widget _question(PracticeItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: PracticeQuestion(
            key: ValueKey(item.id),
            item: item,
            word: _words[item.wordEn],
            onAnswered: (option) => _pick(item, option),
          ),
        ),
      ),
      if (_picked != null)
        PillButton(label: ref.tr('path_continue'), onTap: _next),
    ],
  );
}

class _Summary extends ConsumerWidget {
  const _Summary({
    required this.unit,
    required this.correct,
    required this.total,
  });

  final PathUnit? unit;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(englishPathStateProvider);
    final unit = this.unit;
    final complete = unit != null && isUnitComplete(unit, state);
    final score = ref
        .tr('path_review_score')
        .replaceFirst('{c}', '$correct')
        .replaceFirst('{t}', '$total');
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
          unit == null
              ? score
              : ref
                    .tr('path_session_score')
                    .replaceFirst('{c}', '$correct')
                    .replaceFirst('{t}', '$total')
                    .replaceFirst('{p}', '${unitPercent(unit, state)}'),
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
