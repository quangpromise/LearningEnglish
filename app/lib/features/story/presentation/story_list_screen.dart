import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/story_data.dart';
import 'story_screen.dart';

/// Danh sach Luyen nghe, nhom theo [StoryCategory] (Truyen ngan/Hoi thoai/
/// TOEIC/IELTS/...) - thay the cach cu mo thang `kStories.first` tu Home,
/// vi gio co nhieu hon 1 story chia theo nhieu chu de.
class StoryListScreen extends ConsumerWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCategory = <StoryCategory, List<Story>>{};
    for (final s in kStories) {
      byCategory.putIfAbsent(s.category, () => []).add(s);
    }
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
                Text(
                  ref.tr('story_list_title'),
                  style: AppTextStyles.heading(size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final category in StoryCategory.values)
                    if (byCategory[category]?.isNotEmpty == true) ...[
                      Text(
                        ref.tr(category.labelKey),
                        style: AppTextStyles.muted(size: 10)
                            .copyWith(letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 8),
                      for (final story in byCategory[category]!) ...[
                        _StoryTile(story: story),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openAppPopup(context, StoryScreen(story: story)),
      child: GlowBox(
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: story.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_stories_rounded, color: story.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  Text(
                    '${story.level} · ${story.segments.length}',
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
