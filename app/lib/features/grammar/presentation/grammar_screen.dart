import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../music_player/presentation/player_screen.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key, required this.sentence});
  final LyricLine sentence;

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: AppColors.glassFill, shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder)),
                    child: const Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
                Text('Ngữ pháp', style: AppTextStyles.heading(size: 15)),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.blue.withValues(alpha: 0.18), AppColors.purple.withValues(alpha: 0.18)]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                    child: const Text('PRESENT CONTINUOUS', style: TextStyle(color: Color(0xFF5B3CFF), fontWeight: FontWeight.w800, fontSize: 10)),
                  ),
                  const SizedBox(height: 10),
                  Text(sentence.en, style: AppTextStyles.heading(size: 19)),
                  Text(sentence.vi, style: AppTextStyles.muted()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  GlowBox(
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CẤU TRÚC', style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.6)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _WordBlock(label: 'Chủ ngữ', word: 'I', color: AppColors.blue),
                            _WordBlock(label: "To be", word: "am ('m)", color: AppColors.purple),
                            _WordBlock(label: 'V-ing', word: 'standing', color: AppColors.purple),
                            _WordBlock(label: 'Trạng ngữ', word: 'in the rain', color: AppColors.teal),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Diễn tả một hành động đang xảy ra ngay tại thời điểm nói. Công thức: S + am/is/are + V-ing. Ở đây \"standing\" mô tả trạng thái đang diễn ra của người hát.",
                          style: AppTextStyles.body(size: 13, weight: FontWeight.w500, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlowBox(
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BÀI TẬP NHANH', style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.6)),
                        const SizedBox(height: 10),
                        Text('Chọn câu đúng dùng thì hiện tại tiếp diễn:', style: AppTextStyles.body(size: 13)),
                        const SizedBox(height: 10),
                        const _QuizOption(text: 'She stand in the rain now.', correct: false),
                        const _QuizOption(text: 'She is standing in the rain now.', correct: true),
                        const _QuizOption(text: 'She stood in the rain now.', correct: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PillButton(label: 'Tiếp tục', onTap: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }
}

class _WordBlock extends StatelessWidget {
  const _WordBlock({required this.label, required this.word, required this.color});
  final String label;
  final String word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
          Text(word, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({required this.text, required this.correct});
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: correct ? AppColors.teal.withValues(alpha: 0.16) : AppColors.glassFill,
        border: Border.all(color: correct ? AppColors.teal.withValues(alpha: 0.5) : AppColors.glassBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: correct ? AppColors.teal : Colors.transparent, border: Border.all(color: correct ? AppColors.teal : AppColors.textMuted, width: 2)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body(size: 13, weight: FontWeight.w700, color: correct ? AppColors.teal : AppColors.textPrimary))),
        ],
      ),
    );
  }
}
