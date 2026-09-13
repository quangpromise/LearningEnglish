import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/story_data.dart';
import 'story_screen.dart';

/// Danh sach Luyen nghe, nhom theo [StoryCategory] (Truyen ngan/Hoi thoai/
/// TOEIC/IELTS/...) - thay the cach cu mo thang `kStories.first` tu Home,
/// vi gio co nhieu hon 1 story chia theo nhieu chu de. Dong thoi la khung
/// duy nhat cho ca luong (danh sach -> doc 1 truyen), KHONG mo them popup -
/// xem giai thich chi tiet trong VocabularyTopicsScreen (cung nguyen tac).
class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  Story? _activeStory;

  @override
  Widget build(BuildContext context) {
    final story = _activeStory;
    if (story != null) {
      return StoryScreen(
        story: story,
        onBack: () => setState(() => _activeStory = null),
      );
    }
    return Consumer(builder: (context, ref, _) => _buildList(context, ref));
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
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
                        _StoryTile(
                          story: story,
                          onTap: () => setState(() => _activeStory = story),
                        ),
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
  const _StoryTile({required this.story, required this.onTap});
  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
