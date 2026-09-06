import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Danh sach tuy chon A/B/C/D (hoac A/B/C cho Part 2) dung chung cho ca 7
/// phan va ca 2 che do Luyen tap/Thi thu - kieu dang dua theo
/// quiz_question_screen.dart's tile (khoanh tron chu cai + highlight mau).
///
/// [showFeedback] = true (Luyen tap): sau khi chon, to XANH dung/HONG sai va
/// khoa lai. [showFeedback] = false (Thi thu): chon chi to mau trung tinh
/// (da chon), KHONG lo dung/sai cho toi khi nop bai.
class ToeicOptionsList extends StatelessWidget {
  const ToeicOptionsList({
    super.key,
    required this.options,
    required this.correctIndex,
    required this.pickedIndex,
    required this.showFeedback,
    required this.onPick,
  });

  final List<String> options;
  final int correctIndex;
  final int? pickedIndex;
  final bool showFeedback;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final locked = pickedIndex != null && showFeedback;
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _OptionTile(
            label: String.fromCharCode(65 + i),
            text: options[i],
            picked: pickedIndex == i,
            correct: showFeedback && pickedIndex != null && i == correctIndex,
            wrong: showFeedback && pickedIndex == i && i != correctIndex,
            neutralPicked: !showFeedback && pickedIndex == i,
            onTap: locked ? null : () => onPick(i),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.picked,
    required this.correct,
    required this.wrong,
    required this.neutralPicked,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool picked;
  final bool correct;
  final bool wrong;
  final bool neutralPicked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.glassFill;
    Color border = AppColors.glassBorder;
    if (correct) {
      bg = AppColors.teal.withValues(alpha: 0.16);
      border = AppColors.teal.withValues(alpha: 0.5);
    } else if (wrong) {
      bg = AppColors.pink.withValues(alpha: 0.16);
      border = AppColors.pink.withValues(alpha: 0.5);
    } else if (neutralPicked) {
      bg = AppColors.blue.withValues(alpha: 0.16);
      border = AppColors.blue.withValues(alpha: 0.5);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.body(size: 12, weight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body(weight: FontWeight.w700),
              ),
            ),
            if (correct)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
            if (wrong)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.cancel_rounded,
                  color: AppColors.pink,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The che giai thich hien ngay sau khi chon dap an (chi Luyen tap) - text
/// thuan tieng Viet tu ToeicQuestion.explanationVi, KHONG qua i18n.
class ToeicExplanationCard extends StatelessWidget {
  const ToeicExplanationCard({
    super.key,
    required this.explanationVi,
    required this.isCorrect,
  });

  final String explanationVi;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.teal : AppColors.pink;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Chính xác!' : 'Chưa đúng',
                style: AppTextStyles.body(
                  weight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanationVi,
            style: AppTextStyles.body(size: 12.5).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
