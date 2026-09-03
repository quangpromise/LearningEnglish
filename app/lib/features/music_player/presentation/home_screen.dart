import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../story/data/story_data.dart';
import '../../story/presentation/story_screen.dart';
import '../../translation/presentation/dictionary_popup.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import 'music_home_screen.dart';

/// Man Home - gio chi con loi vao nhanh toi cac tinh nang chinh (Tu vung,
/// Ngu phap, Bai hoc phat am IPA, Nghe nhac) - phan tim kiem/danh sach bai
/// hat da tach rieng sang MusicHomeScreen de Home gon hon, khong con bi 1
/// danh sach nhac dai chiem het man hinh. LUU Y: day la Phonics (bai hoc IPA
/// tinh, chuyen sang tu Menu) - KHAC voi "Luyen phat am" (ghi am + cham
/// diem) van con la 1 tab rieng o thanh dieu huong duoi (xem root_shell.dart).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final displayName = profileAsync.valueOrNull?.nameLabel ?? '';
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        // SingleChildScrollView: them the "Chuyen ngan" lam 5 the truy cap
        // nhanh (truoc la 4) - boc cuon phong khi may man hinh thap/chu to
        // (accessibility) khien noi dung tran, thay vi gia dinh luon vua 1
        // man hinh nhu truoc.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('home_greeting'),
                        style: AppTextStyles.muted(),
                      ),
                      Text(
                        displayName,
                        style: AppTextStyles.heading(size: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const _MessagesButton(),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const DictionaryPopup(),
                        ),
                        child: Tooltip(
                          message: ref.tr('home_dictionary_tooltip'),
                          child: const _IconCircle(
                            icon: Icons.menu_book_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _QuickAccessTile(
                icon: Icons.style_rounded,
                title: ref.tr('home_vocabulary_quick_title'),
                subtitle: ref.tr('home_vocabulary_quick_subtitle'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VocabularyTopicsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _QuickAccessTile(
                icon: Icons.menu_book_rounded,
                title: ref.tr('grammar_topics_title'),
                subtitle: ref.tr('grammar_topics_quick_subtitle'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GrammarTopicsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _QuickAccessTile(
                icon: Icons.record_voice_over_rounded,
                title: ref.tr('phonics_title'),
                subtitle: ref.tr('phonics_quick_subtitle'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PhonicsLessonsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _QuickAccessTile(
                icon: Icons.library_music_rounded,
                title: ref.tr('home_music_quick_title'),
                subtitle: ref.tr('home_music_quick_subtitle'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MusicHomeScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _QuickAccessTile(
                icon: Icons.auto_stories_rounded,
                title: ref.tr('home_story_quick_title'),
                subtitle: ref.tr('home_story_quick_subtitle'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryScreen(story: kStories.first),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        light: true,
        borderRadius: 26,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.87),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

/// Nút tin nhắn kiểu Facebook: chấm đỏ (kèm số nếu <10) nổi ở góc khi có
/// tin nhắn chưa đọc, tự cập nhật realtime qua [unreadMessageCountProvider].
class _MessagesButton extends ConsumerWidget {
  const _MessagesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ConversationsScreen())),
      child: Tooltip(
        message: ref.tr('home_messages_tooltip'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const _IconCircle(icon: Icons.chat_bubble_rounded),
            if (unread > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgTop, width: 2),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}
