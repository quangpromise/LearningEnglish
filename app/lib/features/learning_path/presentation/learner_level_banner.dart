import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'learning_path_accent.dart';
import 'learning_path_survey_screen.dart';

/// Nhan nho "Dang hien thi cap: Co ban · Doi" dat o dau cac man da loc noi
/// dung theo cap hoc (Tu vung, Luyen viet...) - de nguoi dung biet vi sao
/// chi thay 1 phan noi dung va doi cap ngay tai cho (mo lai khao sat), khong
/// phai quay ve Home. Tu an khi "Tu hoc"/chua chon (khong loc gi ca) - xem
/// docs/research-level-based-content.md muc 7.
class LearnerLevelBanner extends ConsumerWidget {
  const LearnerLevelBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
    final level = ref.watch(learnerLevelProvider);
    if (persona == null || level == null) return const SizedBox.shrink();
    final color = personaColor(persona);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const LearningPathSurveyScreen(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${ref.tr('learner_level_showing')}: '
                '${ref.tr(level.labelKey)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // The nen dam hon + icon chevron thay cho gach chan - bao hieu
            // "co the bam" ro hon ma khong can gach chan (yeu cau nguoi
            // dung: bo gach chan o tat ca man dung banner nay, thiet ke lai
            // sao van biet duoc la nut bam duoc).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ref.tr('learner_level_change'),
                    style: AppTextStyles.body(
                      size: 11.5,
                      weight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 13, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
