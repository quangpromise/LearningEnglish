import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../learning_path/presentation/learning_path_survey_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../ielts/presentation/ielts_home_screen.dart';
import '../../story/presentation/story_list_screen.dart';
import '../../toeic/presentation/toeic_home_screen.dart';
import '../../translation/presentation/dictionary_popup.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../../writing/presentation/writing_home_screen.dart';

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
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    // Persona nguoi dung da chon o khao sat "Goi y lo trinh hoc" (null = chua
    // chon/chua dang nhap) - dung de highlight tile lien quan ben duoi, VAN
    // HIEN DU MOI TILE NHU CU (khong an/khoa tile nao) theo dung yeu cau.
    final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
    final recommended = persona != null
        ? kPersonaRecommendations[persona]!
        : const <HomeFeature>[];
    final topPick = recommended.isNotEmpty ? recommended.first : null;
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
                unreadCount: unread,
                onMessagesTap: () =>
                    openAppPopup(context, const ConversationsScreen()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const LearningPathSurveyScreen(),
                      ),
                      child: Tooltip(
                        message: ref.tr('learning_path_tooltip'),
                        child: const _IconCircle(icon: Icons.explore_rounded),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const DictionaryPopup(),
                      ),
                      child: Tooltip(
                        message: ref.tr('home_dictionary_tooltip'),
                        // Doi tu menu_book_rounded (trung voi icon Ngu phap
                        // trong nhom "Doc viet" ben duoi, de nham lan) sang
                        // translate_rounded - dac trung hon cho "tra tu dien".
                        child: const _IconCircle(icon: Icons.translate_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const ServiceExpiryBanner(section: AppSection.learnEnglish),
              _CategorySection(
                title: ref.tr('home_category_reading'),
                items: [
                  _CategoryItemData(
                    icon: Icons.style_rounded,
                    label: ref.tr('home_vocabulary_quick_title'),
                    onTap: () =>
                        openAppPopup(context, const VocabularyTopicsScreen()),
                    isRecommended: recommended.contains(HomeFeature.vocabulary),
                    isTopPick: topPick == HomeFeature.vocabulary,
                  ),
                  _CategoryItemData(
                    icon: Icons.menu_book_rounded,
                    label: ref.tr('grammar_topics_title'),
                    onTap: () =>
                        openAppPopup(context, const GrammarTopicsScreen()),
                    isRecommended: recommended.contains(HomeFeature.grammar),
                    isTopPick: topPick == HomeFeature.grammar,
                  ),
                  _CategoryItemData(
                    icon: Icons.local_library_rounded,
                    label: ref.tr('reading_title'),
                    onTap: () =>
                        openAppPopup(context, const ReadingLibraryScreen()),
                    isRecommended: recommended.contains(HomeFeature.reading),
                    isTopPick: topPick == HomeFeature.reading,
                  ),
                  _CategoryItemData(
                    icon: Icons.edit_note_rounded,
                    label: ref.tr('writing_title'),
                    onTap: () =>
                        openAppPopup(context, const WritingHomeScreen()),
                    isRecommended: recommended.contains(HomeFeature.writing),
                    isTopPick: topPick == HomeFeature.writing,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CategorySection(
                title: ref.tr('home_category_listening'),
                items: [
                  _CategoryItemData(
                    icon: Icons.graphic_eq_rounded,
                    label: ref.tr('phonics_title'),
                    onTap: () =>
                        openAppPopup(context, const PhonicsLessonsScreen()),
                    isRecommended: recommended.contains(HomeFeature.phonics),
                    isTopPick: topPick == HomeFeature.phonics,
                  ),
                  _CategoryItemData(
                    // "Luyen phat am" - truoc day 1 tab rieng o thanh Menu,
                    // gio la 1 the trong nhom Nghe noi (giai phong cho thanh
                    // nhac dai chiem giua thanh Menu, xem root_shell.dart).
                    icon: Icons.mic_rounded,
                    label: ref.tr('pron_title'),
                    onTap: () =>
                        openAppPopup(context, const PronunciationScreen()),
                    isRecommended: recommended.contains(
                      HomeFeature.pronunciation,
                    ),
                    isTopPick: topPick == HomeFeature.pronunciation,
                  ),
                  _CategoryItemData(
                    icon: Icons.auto_stories_rounded,
                    label: ref.tr('home_story_quick_title'),
                    onTap: () => openAppPopup(context, const StoryListScreen()),
                    isRecommended: recommended.contains(HomeFeature.story),
                    isTopPick: topPick == HomeFeature.story,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CategorySection(
                title: ref.tr('home_category_test_prep'),
                items: [
                  _CategoryItemData(
                    icon: Icons.assignment_rounded,
                    label: ref.tr('toeic_title'),
                    onTap: () => openAppPopup(context, const ToeicHomeScreen()),
                    isRecommended: recommended.contains(HomeFeature.toeic),
                    isTopPick: topPick == HomeFeature.toeic,
                  ),
                  _CategoryItemData(
                    icon: Icons.public_rounded,
                    label: ref.tr('ielts_title'),
                    onTap: () => openAppPopup(context, const IeltsHomeScreen()),
                    isRecommended: recommended.contains(HomeFeature.ielts),
                    isTopPick: topPick == HomeFeature.ielts,
                  ),
                  _CategoryItemData(
                    // "Do vui" chuyen tu nhom "Doc viet" sang chung box voi
                    // Luyen thi TOEIC/IELTS theo yeu cau - cung la dang bai
                    // tap trac nghiem tu cham diem, hop nhom hon la o nhom
                    // tu vung/ngu phap/doc sach thuan tuy.
                    icon: Icons.extension_rounded,
                    label: ref.tr('quiz_title'),
                    onTap: () =>
                        openAppPopup(context, const QuizCategoryScreen()),
                    isRecommended: recommended.contains(HomeFeature.quiz),
                    isTopPick: topPick == HomeFeature.quiz,
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
    this.isRecommended = false,
    this.isTopPick = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Tile nam trong danh sach goi y cua persona dang chon - vien/glow doi
  /// mau accent, KHONG an/khoa tile (van bam duoc binh thuong nhu moi tile
  /// khac) - xem docs/research-learning-path.md.
  final bool isRecommended;

  /// Tile GOI Y CHINH (phan tu dau tien trong danh sach goi y cua persona)
  /// - duoc gan them 1 hinh ban tay dong o goc de de nhan biet ngay.
  final bool isTopPick;
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: data.isRecommended
                        ? AppColors.teal.withValues(alpha: 0.16)
                        : AppColors.glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: data.isRecommended
                          ? AppColors.teal
                          : AppColors.glassBorder,
                      width: data.isRecommended ? 1.6 : 1,
                    ),
                    boxShadow: data.isRecommended
                        ? [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.4),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    data.icon,
                    color: data.isRecommended ? AppColors.teal : AppColors.blue,
                    size: 24,
                  ),
                ),
                if (data.isTopPick)
                  const Positioned(
                    right: -10,
                    bottom: -8,
                    child: _PointingHandBadge(),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: TileLabelText(label: data.label, maxWidth: width),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hinh ban tay CHAM VAO man hinh, tu chay animation nay len-xuong lien tuc
/// de gay chu y vao tile goi y chinh - StatefulWidget rieng (khong bien
/// _CategoryItem thanh Stateful) vi chi widget nho nay can AnimationController.
class _PointingHandBadge extends StatefulWidget {
  const _PointingHandBadge();

  @override
  State<_PointingHandBadge> createState() => _PointingHandBadgeState();
}

class _PointingHandBadgeState extends State<_PointingHandBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _bounce = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _bounce.value), child: child),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.amber,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
        ),
        child: const Icon(
          Icons.touch_app_rounded,
          size: 14,
          color: Colors.white,
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
