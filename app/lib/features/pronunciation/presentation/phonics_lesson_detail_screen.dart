import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/phonics_data.dart';
import 'phonics_lessons_screen.dart';

/// Noi dung chi tiet 1 bai hoc phat am - tung "am/quy tac" (PhonicsItem)
/// hien nhu 1 the rieng, kem vi du co the bam loa nghe TTS.
class PhonicsLessonDetailScreen extends ConsumerWidget {
  const PhonicsLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.index,
  });

  final PhonicsLesson lesson;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phonicsLessonLabel(ref, lesson),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 17),
                      ),
                      Text(
                        '${ref.tr('phonics_lesson_label')} ${index + 1}/${kPhonicsLessons.length}',
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  GlowBox(
                    borderRadius: 20,
                    child: Text(
                      lesson.intro,
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w500,
                      ).copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...lesson.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PhonicsItemCard(item: item, color: lesson.color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: index > 0 ? () => _goTo(context, index - 1) : null,
                ),
                Text(
                  '${index + 1} / ${kPhonicsLessons.length}',
                  style: AppTextStyles.muted(size: 12),
                ),
                _NavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: index < kPhonicsLessons.length - 1
                      ? () => _goTo(context, index + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goTo(BuildContext context, int newIndex) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PhonicsLessonDetailScreen(
          lesson: kPhonicsLessons[newIndex],
          index: newIndex,
        ),
      ),
    );
  }
}

class _PhonicsItemCard extends StatelessWidget {
  const _PhonicsItemCard({required this.item, required this.color});

  final PhonicsItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: AppTextStyles.heading(size: 16).copyWith(color: color),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.description,
              style: AppTextStyles.body(
                size: 12.5,
                weight: FontWeight.w500,
                color: AppColors.textMuted,
              ).copyWith(height: 1.45),
            ),
          ],
          if (item.examples.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...item.examples.map(
              (ex) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => AppTts.instance.speak(ex.en),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: 15,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.en,
                            style: AppTextStyles.body(
                              size: 13.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(ex.vi, style: AppTextStyles.muted(size: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
