import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pointing_hand_badge.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../learning_path/data/learning_path_stages.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../../learning_path/presentation/learning_path_accent.dart';
import 'writing_paragraph_list_screen.dart';
import 'writing_vocab_topic_screen.dart';

/// Man chinh cua tinh nang "Luyen viet" - chon 1 trong 2 phuong an: Tu vung
/// (go lai tu tieng Anh theo nghia) hoac Doan van (dich tung cau tieng Viet
/// sang tieng Anh) - dung chung header + grid 2 cot nhu quiz_category_screen.dart.
class WritingHomeScreen extends ConsumerWidget {
  const WritingHomeScreen({super.key});

  /// Che do Luyen viet duoc goi y cho [persona]: lay buoc Luyen viet DAU TIEN
  /// trong lo trinh cua persona do (kLearningPathStages), persona nao khong co
  /// buoc Luyen viet thi Co ban -> Go tu, con lai -> Doan van.
  static LearningPathTarget _recommendedMode(LearningPersona persona) {
    for (final stage in kLearningPathStages[persona] ?? const []) {
      if (stage.target == LearningPathTarget.writingVocab ||
          stage.target == LearningPathTarget.writingParagraph) {
        return stage.target;
      }
    }
    return persona.level == LearnerLevel.basic
        ? LearningPathTarget.writingVocab
        : LearningPathTarget.writingParagraph;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // null = Tu hoc/chua chon -> khong goi y, khong ban tay.
    final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
    final recommended = persona == null ? null : _recommendedMode(persona);
    final handColor = persona == null ? null : personaColor(persona);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                        ref.tr('writing_title'),
                        style: AppTextStyles.heading(size: 20),
                      ),
                      Text(
                        ref.tr('writing_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (persona != null) ...[
              const SizedBox(height: 12),
              const LearnerLevelBanner(),
            ],
            const SizedBox(height: 22),
            // Truoc day boc Expanded(Column(Expanded, Expanded)) khien 2 the
            // bi keo gian chiem het chieu cao con lai cua man hinh (rong
            // rất nhieu khoang trong ben duoi text) - gio de the tu co kich
            // thuoc theo noi dung, gon gang o dau trang.
            _WritingModeCard(
              icon: Icons.style_rounded,
              color: AppColors.purple,
              title: ref.tr('writing_mode_vocab_title'),
              desc: ref.tr('writing_mode_vocab_desc'),
              handColor: recommended == LearningPathTarget.writingVocab
                  ? handColor
                  : null,
              onTap: () =>
                  openAppPopup(context, const WritingVocabTopicScreen()),
            ),
            const SizedBox(height: 14),
            _WritingModeCard(
              icon: Icons.short_text_rounded,
              color: AppColors.teal,
              title: ref.tr('writing_mode_paragraph_title'),
              desc: ref.tr('writing_mode_paragraph_desc'),
              handColor: recommended == LearningPathTarget.writingParagraph
                  ? handColor
                  : null,
              onTap: () =>
                  openAppPopup(context, const WritingParagraphListScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _WritingModeCard extends StatelessWidget {
  const _WritingModeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.onTap,
    this.handColor,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final VoidCallback onTap;

  /// Khac null = che do duoc goi y theo lo trinh -> gan ban tay (luon hien).
  final Color? handColor;

  @override
  Widget build(BuildContext context) {
    final card = SizedBox(
      width: double.infinity,
      child: GlowBox(
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading(size: 15)),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: AppTextStyles.muted(size: 11.5)
                        .copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: handColor == null
          ? card
          : Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                Positioned(
                  right: 14,
                  bottom: -8,
                  child: PointingHandBadge(color: handColor!),
                ),
              ],
            ),
    );
  }
}
