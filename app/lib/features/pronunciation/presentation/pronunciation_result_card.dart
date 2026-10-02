import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/gt_haptics.dart';
import '../../../core/theme/gt_motion.dart';
import '../../../core/widgets/gt_count_up.dart';
import '../data/pronunciation_scoring.dart';

/// Diem tu dat thi rung vua (spec #96, quyet dinh #4).
const kPronunciationGoodScore = 80;

/// Ket qua 1 lan phat am (spec #96): vong diem chay toi diem + so dem len,
/// cac tu hien lan luot 40 ms/tu theo mau dung / sai; dat tu
/// [kPronunciationGoodScore] thi rung vua, diem thap khong rung. Giam chuyen
/// dong: hien ngay ca diem lan cac tu.
class PronunciationResultCard extends StatefulWidget {
  const PronunciationResultCard({super.key, required this.result});

  final PronunciationScore result;

  @override
  State<PronunciationResultCard> createState() =>
      _PronunciationResultCardState();
}

/// Moi tu cach nhau, va thoi gian 1 tu hien tron.
const _kWordStepMs = 40;
const _kWordFadeMs = 200;

class _PronunciationResultCardState extends State<PronunciationResultCard> {
  @override
  void initState() {
    super.initState();
    if (widget.result.score >= kPronunciationGoodScore) {
      GtHaptics.play(GtHapticEvent.pronunciationGood);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final ring = gtMotion(context, GtMotionKind.expressive, GtMotionSpeed.slow);
    final words = result.targetWords.length;
    final revealMs = ring.duration == Duration.zero
        ? 0
        : _kWordStepMs * words + _kWordFadeMs;
    return GlowBox(
      light: true,
      borderRadius: 22,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: result.score / 100),
                    duration: ring.duration,
                    curve: ring.curve,
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v.clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: Colors.black12,
                      color: AppColors.blue,
                    ),
                  ),
                ),
                GtCountUp(
                  value: result.score,
                  format: (v) => '$v%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.0,
                    color: Colors.black,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            // 1 dong thoi gian cho ca hang tu: tu thu i hien tu i * 40 ms.
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: revealMs == 0 ? 1 : 0, end: 1),
              duration: Duration(milliseconds: revealMs),
              builder: (context, t, _) {
                final ms = t * revealMs;
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(words, (i) {
                    final ok =
                        i < result.wordResults.length && result.wordResults[i];
                    final shown = revealMs == 0
                        ? 1.0
                        : ((ms - i * _kWordStepMs) / _kWordFadeMs).clamp(
                            0.0,
                            1.0,
                          );
                    return Opacity(
                      opacity: shown,
                      child: Transform.translate(
                        offset: Offset(0, 6 * (1 - shown)),
                        child: _WordChip(word: result.targetWords[i], ok: ok),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.ok});

  final String word;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? AppColors.teal : AppColors.pink).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: ok ? const Color(0xFF1A8F7E) : const Color(0xFFC22A54),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
