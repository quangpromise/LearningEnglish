import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/content_pack.dart';
import '../data/rest_game.dart';
import 'practice_question.dart';

/// The Rest Game trong gio nghi: tung cau cua [session], tu sang cau sau
/// ~1 giay sau khi tra loi. Man tap tu dong phien khi het gio nghi (widget
/// bi go khoi cay) - moi cau da tra loi da duoc bao qua [onAnswered].
class RestGameCard extends ConsumerStatefulWidget {
  const RestGameCard({
    super.key,
    required this.session,
    required this.words,
    required this.onAnswered,
    required this.onUseCards,
  });

  final RestGameSession session;

  /// Tu vung theo `wordEn` (IPA, cau vi du) cho cac item.
  final Map<String, PathWord> words;
  final void Function(PracticeItem item, bool correct) onAnswered;

  /// Doi sang che do the tu kieu cu.
  final VoidCallback onUseCards;

  @override
  ConsumerState<RestGameCard> createState() => _RestGameCardState();
}

class _RestGameCardState extends ConsumerState<RestGameCard> {
  Timer? _advance;
  bool _waiting = false;

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _answer(PracticeItem item, int option) {
    if (_waiting || widget.session.current == null) return;
    final correct = widget.session.answer(option);
    widget.onAnswered(item, correct);
    setState(() => _waiting = true);
    _advance = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _waiting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final answers = session.answers;
    // Dang cho sang cau sau: van hien cau vua tra loi (co to dung/sai).
    final shown = _waiting && answers.isNotEmpty
        ? answers.last.item
        : session.current;
    final correct = answers.where((a) => a.correct).length;
    return GlowBox(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
      borderRadius: 18,
      border: Border.all(color: AppColors.blue.withValues(alpha: 0.6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                color: AppColors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ref.tr('rest_game_title'),
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ),
              Text(
                '${answers.length}/${session.plan.length}',
                style: AppTextStyles.muted(size: 13),
              ),
              IconButton(
                tooltip: ref.tr('rest_game_use_cards'),
                onPressed: widget.onUseCards,
                icon: const Icon(
                  Icons.style_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (shown != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: PracticeQuestion(
                key: ValueKey(shown.id),
                item: shown,
                compact: true,
                word: widget.words[shown.wordEn],
                onAnswered: (option) => _answer(shown, option),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                ref
                    .tr('rest_game_done')
                    .replaceFirst('{c}', '$correct')
                    .replaceFirst('{t}', '${answers.length}'),
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 15),
              ),
            ),
        ],
      ),
    );
  }
}
