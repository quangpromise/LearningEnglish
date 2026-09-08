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
import '../../learning_path/presentation/learning_path_accent.dart';
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
    // Chua tung tuong tac voi khao sat (chua chon persona nao LAN chua bam
    // "Tu hoc") - hien goi y ban tay + chu tro vao nut khao sat de nguoi
    // dung moi biet no ton tai; mac dinh true (an) trong luc dang tai de
    // tranh loe hien ra roi tat ngay sau 1 frame.
    final surveyInteracted =
        ref.watch(learningPathInteractedProvider).valueOrNull ?? true;
    final recommended = persona != null
        ? kPersonaRecommendations[persona]!
        : const <HomeFeature>[];
    final topPick = recommended.isNotEmpty ? recommended.first : null;
    // Mau highlight doi theo TUNG persona (thay vi 1 mau teal co dinh cho
    // moi nguoi) - dung chung 1 mau voi chip da chon o man khao sat de 2
    // man "noi" duoc voi nhau (xem learning_path_accent.dart).
    final accent = persona != null ? personaColor(persona) : AppColors.teal;
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Tooltip(
                            message: ref.tr('learning_path_tooltip'),
                            child: const _IconCircle(
                              icon: Icons.explore_rounded,
                            ),
                          ),
                          if (!surveyInteracted)
                            Positioned(
                              top: 46,
                              right: -74,
                              child: IgnorePointer(
                                child: _SuggestHint(color: AppColors.teal),
                              ),
                            ),
                        ],
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
                accentColor: accent,
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
                accentColor: accent,
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
                accentColor: accent,
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
  const _CategorySection({
    required this.title,
    required this.items,
    required this.accentColor,
  });
  final String title;
  final List<_CategoryItemData> items;

  /// Mau highlight cho tile duoc goi y trong nhom nay - theo persona dang
  /// chon (xem HomeScreen.build).
  final Color accentColor;

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
                        (item) => _CategoryItem(
                          data: item,
                          width: itemWidth,
                          accentColor: accentColor,
                        ),
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
  const _CategoryItem({
    required this.data,
    required this.width,
    required this.accentColor,
  });
  final _CategoryItemData data;
  final double width;
  final Color accentColor;

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
                        ? accentColor.withValues(alpha: 0.18)
                        : AppColors.glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: data.isRecommended
                          ? accentColor
                          : AppColors.glassBorder,
                      width: data.isRecommended ? 2 : 1,
                    ),
                    boxShadow: data.isRecommended
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.45),
                              blurRadius: 16,
                              spreadRadius: 1.5,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    data.icon,
                    color: data.isRecommended ? accentColor : AppColors.blue,
                    size: 24,
                  ),
                ),
                if (data.isTopPick)
                  Positioned(
                    right: -10,
                    bottom: -8,
                    child: _PointingHandBadge(color: accentColor),
                  )
                else if (data.isRecommended)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
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
  const _PointingHandBadge({required this.color});
  final Color color;

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
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
        ),
        child: const Icon(
          Icons.touch_app_rounded,
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Ban tay tro + dong chu goi y nguoi dung CHUA TUNG mo khao sat "Goi y lo
/// trinh hoc" bam vao nut do (xem [_PointingHandBadge], tai su dung nguyen
/// con vat nay - cung 1 ngon ngu hinh anh voi tile goi y o luoi Home) - tu
/// an ngay sau khi ho chon 1 gia tri BAT KY trong khao sat, ke ca "Tu hoc"
/// (xem learningPathInteractedProvider).
class _SuggestHint extends ConsumerWidget {
  const _SuggestHint({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PointingHandBadge(color: color),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 128),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
          ),
          child: Text(
            ref.tr('learning_path_hint_text'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
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
