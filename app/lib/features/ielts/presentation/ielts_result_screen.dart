import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/ielts_models.dart';
import '../data/ielts_scoring.dart';
import 'ielts_history_screen.dart';

/// Bang diem + review toan bo cau hoi - mirror toeic_result_screen.dart,
/// hien band diem (0-9, buoc 0.5) thay vi diem scaled int.
class IeltsResultScreen extends ConsumerWidget {
  const IeltsResultScreen({
    super.key,
    required this.test,
    required this.picked,
    required this.listeningCorrect,
    required this.listeningTotal,
    required this.readingCorrect,
    required this.readingTotal,
    required this.bandListening,
    required this.bandReading,
    required this.bandOverall,
  });

  final IeltsTest test;
  final Map<String, dynamic> picked;
  final int listeningCorrect;
  final int listeningTotal;
  final int readingCorrect;
  final int readingTotal;
  final double bandListening;
  final double bandReading;
  final double bandOverall;

  bool _isCorrect(IeltsQuestion q) {
    final value = picked[q.id];
    if (value == null) return false;
    if (q.answerType == IeltsAnswerType.multipleChoice) {
      return value == q.correctIndex;
    }
    return isShortAnswerCorrect(value as String, q.acceptedAnswers);
  }

  String _yourAnswerLabel(IeltsQuestion q) {
    final value = picked[q.id];
    if (value == null) return '';
    if (q.answerType == IeltsAnswerType.multipleChoice) {
      return q.options[value as int];
    }
    return value as String;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCorrect = listeningCorrect + readingCorrect;
    final totalCount = listeningTotal + readingTotal;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            Text(
              ref.tr('toeic_result_title'),
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: AppColors.wealthAccent, letterSpacing: 1),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: totalCount == 0 ? 0 : totalCorrect / totalCount,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: AppColors.wealthAccent,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bandOverall.toStringAsFixed(1),
                        style: AppTextStyles.heading(size: 30)
                            .copyWith(height: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.tr('ielts_score_overall'),
                        style: AppTextStyles.muted(size: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr('ielts_score_disclaimer'),
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(size: 10),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ScoreCard(
                    label: ref.tr('toeic_score_listening'),
                    band: bandListening,
                    correct: listeningCorrect,
                    total: listeningTotal,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoreCard(
                    label: ref.tr('toeic_score_reading'),
                    band: bandReading,
                    correct: readingCorrect,
                    total: readingTotal,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ref.tr('toeic_review_answers'),
                style: AppTextStyles.muted(size: 10.5, weight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: test.questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final q = test.questions[i];
                  final hasAnswer =
                      picked.containsKey(q.id) &&
                      (picked[q.id] is! String ||
                          (picked[q.id] as String).trim().isNotEmpty);
                  final ok = hasAnswer && _isCorrect(q);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: (ok ? AppColors.teal : AppColors.pink)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            ok ? Icons.check_rounded : Icons.close_rounded,
                            size: 13,
                            color: ok ? AppColors.teal : AppColors.pink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.promptEn ?? q.explanationVi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (!hasAnswer)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              ref.tr('toeic_unanswered'),
                              style: AppTextStyles.muted(size: 10),
                            ),
                          )
                        else if (!ok)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              _yourAnswerLabel(q),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.muted(size: 10),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: ref.tr('toeic_retry_test'),
                    filled: false,
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: ref.tr('toeic_view_history'),
                    onTap: () =>
                        openAppPopup(context, const IeltsHistoryScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.band,
    required this.correct,
    required this.total,
    required this.color,
  });

  final String label;
  final double band;
  final int correct;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.muted(size: 10.5, weight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            band.toStringAsFixed(1),
            style: AppTextStyles.heading(
              size: 22,
              weight: FontWeight.w800,
            ).copyWith(color: color),
          ),
          Text('$correct/$total', style: AppTextStyles.muted(size: 10.5)),
        ],
      ),
    );
  }
}
