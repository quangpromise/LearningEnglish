import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../story/data/story_data.dart';
import '../../story/presentation/story_screen.dart';
import '../../translation/presentation/dictionary_popup.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';

/// Man Home - da bo han tab Menu rieng (xem root_shell.dart): moi tinh nang
/// (ke ca nhung thu truoc gom trong Menu: Doc sach, Do vui, Fitness, Crypto,
/// Ghi cong) gio vao thang tu day, phan nhom theo the loai (Nghe noi/Doc
/// viet/Khac) trong 1 khung vien rieng cho tung nhom - giong cach cac app
/// smart-home nhom "Quick Actions" theo phong/loai thiet bi. Dung thang
/// AppColors/GlowBox chuan (khong con bang mau rieng) vi toan app da doi
/// sang cung 1 bang mau nen-den + cam (xem app_theme.dart).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        // Le ngang giam tu 24 -> 14 de khung the loai sat 2 canh man hinh
        // hon (van deu 2 ben), du khong gian de icon ben trong dan deu ro
        // hon thay vi bi ep vao giua khung qua hep.
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(
                trailing: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const DictionaryPopup(),
                  ),
                  child: Tooltip(
                    message: ref.tr('home_dictionary_tooltip'),
                    child: const _IconCircle(icon: Icons.menu_book_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _CategorySection(
                title: ref.tr('home_category_listening'),
                items: [
                  _CategoryItemData(
                    icon: Icons.graphic_eq_rounded,
                    label: ref.tr('phonics_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PhonicsLessonsScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    // "Luyen phat am" - truoc day 1 tab rieng o thanh Menu,
                    // gio la 1 the trong nhom Nghe noi (giai phong cho thanh
                    // nhac dai chiem giua thanh Menu, xem root_shell.dart).
                    icon: Icons.mic_rounded,
                    label: ref.tr('pron_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PronunciationScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.auto_stories_rounded,
                    label: ref.tr('home_story_quick_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryScreen(story: kStories.first),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CategorySection(
                title: ref.tr('home_category_reading'),
                items: [
                  _CategoryItemData(
                    icon: Icons.style_rounded,
                    label: ref.tr('home_vocabulary_quick_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VocabularyTopicsScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.menu_book_rounded,
                    label: ref.tr('grammar_topics_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GrammarTopicsScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.local_library_rounded,
                    label: ref.tr('reading_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReadingLibraryScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.extension_rounded,
                    label: ref.tr('quiz_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuizCategoryScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 khung vien (border) rieng cho 1 nhom the loai - ben trong la luoi icon,
/// moi icon kem ten nho ben duoi, dung theo yeu cau thiet ke ("nghe noi 1
/// border chung, doc viet 1 border chung, moi tinh nang 1 icon + ten nho").
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.title, required this.items});
  final String title;
  final List<_CategoryItemData> items;

  @override
  Widget build(BuildContext context) {
    // SizedBox(width: double.infinity) BAT BUOC o day: Column cha (Home)
    // dung crossAxisAlignment.start nen GlowBox mac dinh chi rong bang noi
    // dung ben trong (Wrap co the), khien khung the loai bi hep lai va lech
    // sang trai thay vi keo dai het chieu rong man hinh nhu cac khung khac.
    const spacing = 12.0;
    const columns = 4;
    return SizedBox(
      width: double.infinity,
      child: GlowBox(
        padding: const EdgeInsets.all(16),
        borderRadius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading(size: 14)),
            const SizedBox(height: 14),
            // LayoutBuilder tinh RIENG be rong 1 the theo cong thuc "vua du 4
            // the/hang" - Wrap+spaceBetween truoc day dua vao SizedBox(width:
            // 86) CO DINH, chi vua khop khi 1 hang co DUNG so luong the lap
            // day het chieu rong (khien hang le - vd 3 the "English riddles"
            // mot minh - bi dan sat mep thay vi dung cong thuc chia deu, va
            // khong dam bao luon vua dung 4 the/hang tren moi kich thuoc man
            // hinh nhu yeu cau).
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 14,
                  children: items
                      .map(
                        (item) => _CategoryItem(data: item, width: itemWidth),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItemData {
  const _CategoryItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.data, required this.width});
  final _CategoryItemData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(data.icon, color: AppColors.blue, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 10.5, weight: FontWeight.w600),
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
