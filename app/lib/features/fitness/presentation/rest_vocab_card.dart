import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/gym_vocabulary.dart';

/// The "Hoc khi nghi" hien trong luc dem nguoc nghi giua set: 1 tu tieng Anh
/// trong phong gym, bam loa de nghe (CHI phat khi nguoi dung bam - khong tu
/// doc de khong gianh audio focus voi nhac dang nghe), cham the de xem nghia
/// + vi du, roi tu danh gia "Chua nho"/"Da nho".
///
/// Mau xanh cua khu Hoc tieng Anh (khac mau do Fitness) de nguoi dung nhin
/// la biet day la phan hoc.
class RestVocabCard extends ConsumerStatefulWidget {
  const RestVocabCard({
    super.key,
    required this.word,
    required this.onKnown,
    required this.onStillLearning,
    required this.onTurnOff,
  });

  final GymWord word;
  final VoidCallback onKnown;
  final VoidCallback onStillLearning;
  final VoidCallback onTurnOff;

  @override
  ConsumerState<RestVocabCard> createState() => _RestVocabCardState();
}

class _RestVocabCardState extends ConsumerState<RestVocabCard> {
  bool _revealed = false;

  @override
  void didUpdateWidget(RestVocabCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.key != widget.word.key) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    return GlowBox(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 14),
      borderRadius: 20,
      border: Border.all(color: AppColors.blue.withValues(alpha: 0.45)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ref.tr('fitness_rest_learn_title'),
                  style: AppTextStyles.body(
                    size: 12,
                    weight: FontWeight.w800,
                    color: AppColors.blue,
                  ),
                ),
              ),
              SpeakerButton(
                icon: Icons.close_rounded,
                iconSize: 18,
                tapSize: 44,
                color: AppColors.textMuted,
                onTap: widget.onTurnOff,
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _revealed = !_revealed),
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.en,
                            style: AppTextStyles.heading(size: 26),
                          ),
                        ),
                        SpeakerButton(
                          tapSize: 52,
                          iconSize: 28,
                          color: AppColors.blue,
                          onTap: () => AppTts.instance.speak(word.en),
                        ),
                      ],
                    ),
                    if (word.ipa.isNotEmpty)
                      Text(word.ipa, style: AppTextStyles.muted(size: 14)),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _revealed
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        ref.tr('fitness_rest_learn_tap_reveal'),
                        style: AppTextStyles.muted(size: 13),
                      ),
                      secondChild: _Meaning(word: word),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: ref.tr('fitness_rest_learn_still'),
                    accentColor: AppColors.blue,
                    filled: false,
                    onTap: widget.onStillLearning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PillButton(
                    label: ref.tr('fitness_rest_learn_got_it'),
                    accentColor: AppColors.blue,
                    onTap: widget.onKnown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meaning extends StatelessWidget {
  const _Meaning({required this.word});
  final GymWord word;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word.vi,
          style: AppTextStyles.body(
            size: 16,
            weight: FontWeight.w800,
            color: AppColors.teal,
          ),
        ),
        if (word.exampleEn.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  word.exampleEn,
                  style: AppTextStyles.body(size: 14),
                ),
              ),
              SpeakerButton(
                iconSize: 20,
                tapSize: 44,
                color: AppColors.blue,
                onTap: () => AppTts.instance.speak(word.exampleEn),
              ),
            ],
          ),
        ],
        if (word.exampleVi.isNotEmpty)
          Text(word.exampleVi, style: AppTextStyles.muted(size: 13)),
      ],
    );
  }
}
