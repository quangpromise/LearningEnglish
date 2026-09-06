import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Danh sach tuy chon trac nghiem (2-8 phuong an, dung cho True/False/Not
/// Given, Yes/No/Not Given, Multiple Choice, Matching Headings) - copy gan
/// nguyen ven ToeicOptionsList (du an quy uoc moi feature tu chua widget
/// rieng, khong extract shared).
class IeltsOptionsList extends StatelessWidget {
  const IeltsOptionsList({
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
    required this.correct,
    required this.wrong,
    required this.neutralPicked,
    required this.onTap,
  });

  final String label;
  final String text;
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

/// O nhap cau tra loi TU DO (Sentence/Summary Completion) - KHONG co trong
/// TOEIC, day la thu genuinely moi vi IELTS Reading/Listening co dang dien
/// tu khong chon tu danh sach. Dung chung ngon ngu thi giac voi _OptionTile
/// (cung mau glassFill/glassBorder/bo goc 16) de dong bo voi man thi.
class IeltsShortAnswerField extends StatefulWidget {
  const IeltsShortAnswerField({
    super.key,
    required this.initialValue,
    required this.isCorrect,
    required this.showFeedback,
    required this.locked,
    required this.onChanged,
  });

  final String? initialValue;

  /// null khi chua kiem tra (showFeedback=false hoac chua nhap).
  final bool? isCorrect;
  final bool showFeedback;
  final bool locked;
  final ValueChanged<String> onChanged;

  @override
  State<IeltsShortAnswerField> createState() => _IeltsShortAnswerFieldState();
}

class _IeltsShortAnswerFieldState extends State<IeltsShortAnswerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revealed = widget.showFeedback && widget.isCorrect != null;
    Color border = AppColors.glassBorder;
    if (revealed) {
      border = (widget.isCorrect!
          ? AppColors.teal.withValues(alpha: 0.5)
          : AppColors.pink.withValues(alpha: 0.5));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: revealed
            ? (widget.isCorrect!
                  ? AppColors.teal.withValues(alpha: 0.16)
                  : AppColors.pink.withValues(alpha: 0.16))
            : AppColors.glassFill,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.locked,
              onChanged: widget.onChanged,
              style: AppTextStyles.body(weight: FontWeight.w700),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập câu trả lời...',
              ),
            ),
          ),
          if (revealed)
            Icon(
              widget.isCorrect!
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: widget.isCorrect! ? AppColors.teal : AppColors.pink,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// The che giai thich hien ngay sau khi tra loi (chi Luyen tap) - text
/// thuan tieng Viet tu IeltsQuestion.explanationVi, KHONG qua i18n.
class IeltsExplanationCard extends StatelessWidget {
  const IeltsExplanationCard({
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
