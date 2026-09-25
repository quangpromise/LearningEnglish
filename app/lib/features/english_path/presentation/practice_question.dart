import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/content_pack.dart';
import 'path_option_button.dart';

/// Hien 1 Practice Item theo dang cua no (Meaning / Listening / Gap-fill /
/// Word Scramble) va bao dap an qua [onAnswered] (so sanh voi
/// `item.answerIndex`; Scramble dung -> answerIndex, sai -> -1).
///
/// [reveal] = true: to dung/sai ngay (phien hoc, Rest Game); false: chi to
/// dap an da chon (Placement, Level Test).
class PracticeQuestion extends ConsumerStatefulWidget {
  const PracticeQuestion({
    super.key,
    required this.item,
    required this.onAnswered,
    this.reveal = true,
    this.compact = false,
    this.word,
  });

  final PracticeItem item;
  final ValueChanged<int> onAnswered;
  final bool reveal;

  /// Ban gon cho the Rest Game (chu nho hon, it khoang trang).
  final bool compact;

  /// Tu vung cua item (IPA, cau vi du) neu co.
  final PathWord? word;

  @override
  ConsumerState<PracticeQuestion> createState() => _PracticeQuestionState();
}

class _PracticeQuestionState extends ConsumerState<PracticeQuestion> {
  int? _picked;

  /// Chu cai da bam cho Word Scramble (vi tri trong [_letters]).
  final List<int> _tapped = [];
  late List<String> _letters = _shuffledLetters();

  @override
  void initState() {
    super.initState();
    if (widget.item.type == PracticeItemType.listening) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    }
  }

  @override
  void didUpdateWidget(PracticeQuestion old) {
    super.didUpdateWidget(old);
    if (old.item.id != widget.item.id) {
      _picked = null;
      _tapped.clear();
      _letters = _shuffledLetters();
      if (widget.item.type == PracticeItemType.listening) _speak();
    }
  }

  void _speak() => TutorialVoice.shared.speakAndWait(widget.item.prompt);

  /// Xao chu cai co dinh theo id (khong trung thu tu dung khi co the).
  List<String> _shuffledLetters() {
    final word = widget.item.options.first;
    final letters = word.split('');
    if (widget.item.type != PracticeItemType.wordScramble) return letters;
    final rng = Random(widget.item.id.hashCode);
    for (var i = 0; i < 5; i++) {
      letters.shuffle(rng);
      if (letters.join() != word) break;
    }
    return letters;
  }

  void _pick(int option) {
    if (_picked != null) return;
    final right = option == widget.item.answerIndex;
    if (widget.reveal) {
      right ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    setState(() => _picked = option);
    widget.onAnswered(option);
  }

  void _tapLetter(int i) {
    if (_picked != null || _tapped.contains(i)) return;
    HapticFeedback.selectionClick();
    setState(() => _tapped.add(i));
    if (_tapped.length == _letters.length) {
      final built = _tapped.map((j) => _letters[j]).join();
      final right =
          built.toLowerCase() == widget.item.options.first.toLowerCase();
      _pick(right ? widget.item.answerIndex : -1);
    }
  }

  void _undoLetter() {
    if (_picked != null || _tapped.isEmpty) return;
    setState(() {
      _tapped.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final big = widget.compact ? 24.0 : 32.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ref.tr(_promptKey(item.type)),
          style: AppTextStyles.muted(size: 13),
        ),
        SizedBox(height: widget.compact ? 6 : 8),
        ..._stem(item, big),
        SizedBox(height: widget.compact ? 10 : 20),
        if (item.type == PracticeItemType.wordScramble)
          _scramble()
        else
          for (var i = 0; i < item.options.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: widget.compact ? 8 : 10),
              child: PathOptionButton(
                label: item.options[i],
                state: _optionState(i),
                onTap: () => _pick(i),
              ),
            ),
        if (_picked != null && widget.reveal && widget.word != null) ...[
          const SizedBox(height: 6),
          Text(widget.word!.exampleEn, style: AppTextStyles.body(size: 14)),
          Text(widget.word!.exampleVi, style: AppTextStyles.muted(size: 13)),
        ],
      ],
    );
  }

  PathOptionState _optionState(int i) {
    final picked = _picked;
    if (picked == null) return PathOptionState.idle;
    if (!widget.reveal) {
      return i == picked ? PathOptionState.selected : PathOptionState.dimmed;
    }
    return pathOptionState(i, widget.item.answerIndex, picked);
  }

  List<Widget> _stem(PracticeItem item, double big) => switch (item.type) {
    PracticeItemType.meaning => [
      Row(
        children: [
          Expanded(
            child: Text(item.prompt, style: AppTextStyles.heading(size: big)),
          ),
          SpeakerButton(onTap: _speak),
        ],
      ),
      if (widget.word != null)
        Text(widget.word!.ipa, style: AppTextStyles.muted(size: 15)),
    ],
    PracticeItemType.listening => [
      Center(
        child: SpeakerButton(
          icon: Icons.volume_up_rounded,
          iconSize: 40,
          tapSize: 72,
          color: AppColors.blue,
          onTap: _speak,
        ),
      ),
    ],
    PracticeItemType.gapFill => [
      Text(item.prompt, style: AppTextStyles.heading(size: big * 0.7)),
      if (item.hintVi != null)
        Text(item.hintVi!, style: AppTextStyles.muted(size: 14)),
    ],
    PracticeItemType.wordScramble => [
      Text(item.hintVi ?? '', style: AppTextStyles.heading(size: big * 0.8)),
    ],
  };

  Widget _scramble() {
    final built = _tapped.map((j) => _letters[j]).join();
    final picked = _picked;
    final color = picked == null || !widget.reveal
        ? AppColors.blue
        : (picked == widget.item.answerIndex ? AppColors.teal : AppColors.pink);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _undoLetter,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 1.4),
            ),
            child: Text(
              built.isEmpty ? ref.tr('rest_game_scramble_hint') : built,
              style: built.isEmpty
                  ? AppTextStyles.muted(size: 14)
                  : AppTextStyles.heading(size: 24),
            ),
          ),
        ),
        if (picked != null &&
            widget.reveal &&
            picked != widget.item.answerIndex)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.item.options.first,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 16, color: AppColors.teal),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _letters.length; i++)
              _LetterTile(
                letter: _letters[i],
                used: _tapped.contains(i),
                onTap: () => _tapLetter(i),
              ),
          ],
        ),
      ],
    );
  }
}

String _promptKey(PracticeItemType type) => switch (type) {
  PracticeItemType.meaning => 'path_meaning_prompt',
  PracticeItemType.listening => 'rest_game_listening_prompt',
  PracticeItemType.gapFill => 'rest_game_gap_prompt',
  PracticeItemType.wordScramble => 'rest_game_scramble_prompt',
};

/// O chu cai 48dp cho Word Scramble.
class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.used,
    required this.onTap,
  });

  final String letter;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: used ? 0.25 : 1,
    child: Material(
      color: AppColors.blue.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: used ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(letter, style: AppTextStyles.heading(size: 22)),
          ),
        ),
      ),
    ),
  );
}
