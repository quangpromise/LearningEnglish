import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../srs/data/srs_store.dart';
import '../data/exercise_model.dart';
import '../data/gym_vocabulary.dart';

/// "5 tu khoi dong" o man xem truoc buoi tap - tu vung lien quan truc tiep
/// toi cac bai hom nay (ten bai, nhom co, dong tu chuyen dong), uu tien tu
/// chua thuoc. Cung bo tu voi the "Hoc khi nghi" nen gap lai trong buoi tap.
class WarmupWordsCard extends StatefulWidget {
  const WarmupWordsCard({super.key, required this.exercises});
  final List<Exercise> exercises;

  @override
  State<WarmupWordsCard> createState() => _WarmupWordsCardState();
}

class _WarmupWordsCardState extends State<WarmupWordsCard> {
  late final Future<List<GymWord>> _words = _load();

  Future<List<GymWord>> _load() async {
    await SrsStore.instance.ensureLoaded();
    return pickGymWords(
      exercises: widget.exercises,
      boxes: SrsStore.instance.boxes,
    );
  }

  @override
  void dispose() {
    TutorialVoice.shared.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GymWord>>(
      future: _words,
      builder: (context, snapshot) {
        final words = snapshot.data;
        // Dang tai (rat nhanh, chi doc SharedPreferences) hoac khong co tu
        // nao -> an han the, khong chiem cho danh sach bai tap.
        if (words == null || words.isEmpty) return const SizedBox.shrink();
        return GlowBox(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
          borderRadius: 18,
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.45)),
          child: Consumer(
            builder: (context, ref, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 16,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ref.tr('fitness_warmup_words_title'),
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
                Text(
                  ref.tr('fitness_warmup_words_subtitle'),
                  style: AppTextStyles.muted(),
                ),
                const SizedBox(height: 4),
                for (final word in words) _WordRow(word: word),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});
  final GymWord word;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: word.en,
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      if (word.ipa.isNotEmpty)
                        TextSpan(
                          text: '  ${word.ipa}',
                          style: AppTextStyles.muted(),
                        ),
                    ],
                  ),
                ),
                Text(word.vi, style: AppTextStyles.muted(size: 13)),
              ],
            ),
          ),
        ),
        SpeakerButton(
          iconSize: 20,
          tapSize: 44,
          color: AppColors.blue,
          onTap: () => TutorialVoice.shared.speak(word.en),
        ),
      ],
    );
  }
}
