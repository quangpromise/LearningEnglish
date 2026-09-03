import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../attribution/presentation/attribution_screen.dart';
import '../../crypto/presentation/crypto_screen.dart';
import '../../fitness/presentation/fitness_shell.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../story/data/story_data.dart';
import '../../story/presentation/story_screen.dart';
import '../../translation/presentation/dictionary_popup.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import 'music_home_screen.dart';

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
    final profileAsync = ref.watch(myProfileProvider);
    // Loading/loi: khong hien ten rong nhin nhu "mat chu" - giu placeholder
    // ro rang thay vi chuoi rong.
    final displayName = profileAsync.when(
      data: (p) => p.nameLabel,
      loading: () => '...',
      error: (_, _) => ref.tr('home_greeting'),
    );
    final avatarUrl = profileAsync.valueOrNull?.avatarUrl;
    final statsAsync = ref.watch(myStatsProvider);
    final stats = statsAsync.valueOrNull;

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.blue, width: 1.4),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl != null
                        ? Image.network(avatarUrl, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person_rounded,
                            color: AppColors.blue,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('home_greeting'),
                          style: AppTextStyles.muted(),
                        ),
                        Text(
                          displayName,
                          style: AppTextStyles.heading(size: 18),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
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
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      value: '${stats?.streakDays ?? 0}',
                      label: ref.tr('home_stat_streak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.style_rounded,
                      value: '${stats?.wordsLearned ?? 0}',
                      label: ref.tr('home_stat_words'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.record_voice_over_rounded,
                      value: '${stats?.avgPronunciationScore ?? 0}%',
                      label: ref.tr('home_stat_pronunciation'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                ref.tr('home_level_section_title'),
                style: AppTextStyles.heading(size: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LevelPill(
                      label: ref.tr('song_level_basic'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MusicHomeScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LevelPill(
                      label: ref.tr('song_level_intermediate'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MusicHomeScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LevelPill(
                      label: ref.tr('song_level_advanced'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MusicHomeScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _CategorySection(
                title: ref.tr('home_category_listening'),
                items: [
                  _CategoryItemData(
                    icon: Icons.library_music_rounded,
                    label: ref.tr('home_music_quick_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MusicHomeScreen(),
                      ),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.graphic_eq_rounded,
                    label: ref.tr('phonics_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PhonicsLessonsScreen(),
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
                    icon: Icons.auto_stories_rounded,
                    label: ref.tr('home_story_quick_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryScreen(story: kStories.first),
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
              const SizedBox(height: 16),
              _CategorySection(
                title: ref.tr('home_category_other'),
                items: [
                  _CategoryItemData(
                    icon: Icons.fitness_center_rounded,
                    label: ref.tr('fitness_menu_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FitnessShell()),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.currency_bitcoin_rounded,
                    label: ref.tr('crypto_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CryptoScreen()),
                    ),
                  ),
                  _CategoryItemData(
                    icon: Icons.copyright_rounded,
                    label: ref.tr('attribution_menu_title'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AttributionScreen(),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.blue),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading(size: 15)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 10.5),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(size: 12.5, weight: FontWeight.w700),
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
    return GlowBox(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading(size: 14)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items.map((item) => _CategoryItem(data: item)).toList(),
          ),
        ],
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
  const _CategoryItem({required this.data});
  final _CategoryItemData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: SizedBox(
        width: 72,
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
