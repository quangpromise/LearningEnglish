import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'writing_paragraph_list_screen.dart';
import 'writing_vocab_topic_screen.dart';

/// Man chinh cua tinh nang "Luyen viet" - chon 1 trong 2 phuong an: Tu vung
/// (go lai tu tieng Anh theo nghia) hoac Doan van (dich tung cau tieng Viet
/// sang tieng Anh) - dung chung header + grid 2 cot nhu quiz_category_screen.dart.
class WritingHomeScreen extends ConsumerWidget {
  const WritingHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const SizedBox(height: 22),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _WritingModeCard(
                      icon: Icons.style_rounded,
                      color: AppColors.purple,
                      title: ref.tr('writing_mode_vocab_title'),
                      desc: ref.tr('writing_mode_vocab_desc'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WritingVocabTopicScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _WritingModeCard(
                      icon: Icons.short_text_rounded,
                      color: AppColors.teal,
                      title: ref.tr('writing_mode_paragraph_title'),
                      desc: ref.tr('writing_mode_paragraph_desc'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WritingParagraphListScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
      ),
    );
  }
}
