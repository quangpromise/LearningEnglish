import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pointing_hand_badge.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../learning_path/presentation/learning_path_accent.dart';
import '../../learning_path/presentation/learning_path_survey_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../ielts/presentation/ielts_home_screen.dart';
import '../../story/presentation/story_list_screen.dart';
import '../../toeic/presentation/toeic_home_screen.dart';
import '../../vocabulary/presentation/daily_words_controller.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../../writing/presentation/writing_home_screen.dart';

/// Khoa loi chao theo GIO TREN MAY - sang/chieu/toi/khuya.
String greetingKeyForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h >= 5 && h < 12) return 'home_greeting_morning';
  if (h >= 12 && h < 18) return 'home_greeting_afternoon';
  if (h >= 18 && h < 22) return 'home_greeting_evening';
  return 'home_greeting_night';
}

/// Man Home cua khu vuc "Hoc Tieng Anh".
///
/// Bo cuc theo ban thiet ke da duyet (xem docs/design/english-redesign/):
///   1. Thanh dau man - loi chao theo gio + ten + nut La ban/Tin nhan
///   2. The tien do  - vong tron Level/XP + chuoi ngay lien tiep
///   3. The "Ky nang chinh" - "Hoc {n} tu hom nay", bam mo danh sach tu
///   4. 4 the Doc viet - Tu vung / Ngu phap / Doc sach / Luyen viet
///   5. Khung Nghe noi - 4 muc Phat am / Luyen phat am / Chuyen ngan / AI
///   6. Khung Luyen thi - TOEIC / IELTS / Do vui
///
/// MOI tinh nang van mo len dang popup tu day y nhu truoc (khong doi luong),
/// chi doi cach trinh bay. Goi y lo trinh theo persona van giu: the duoc goi
/// y doi mau vien + the goi y CHINH co them hinh ban tay.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    // Persona nguoi dung da chon o khao sat "Goi y lo trinh hoc" (null = chua
    // chon/chua dang nhap) - dung de highlight the lien quan ben duoi, VAN
    // HIEN DU MOI THE NHU CU (khong an/khoa the nao) theo dung yeu cau.
    final personaAsync = ref.watch(learningPathChoiceProvider);
    final persona = personaAsync.valueOrNull;
    final showSurveyHint =
        personaAsync.hasValue &&
        persona == null &&
        !ref.watch(_surveyHintDismissedProvider);
    final recommended = persona != null
        ? kPersonaRecommendations[persona]!
        : const <HomeFeature>[];
    final topPick = recommended.isNotEmpty ? recommended.first : null;
    final accent = persona != null ? personaColor(persona) : AppColors.teal;
    final compassLink = LayerLink();

    return HomeDesignBackground(
      glow: const Color(0xFF68A6FF),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 2),
        // Noi dung duoc thu gon vua DUNG chieu cao than man (do bang bo chup:
        // ~670pt) nen binh thuong KHONG phai cuon. Van giu
        // SingleChildScrollView de tren nhung may co vung hien thi thap hon
        // (browser co nhieu thanh cong cu) thi cuon duoc thay vi bao loi tran.
        //
        // KHONG dung Transform.scale de "co cho vua": Transform chi doi luc VE
        // chu khong doi kich thuoc luc DO, nen scroll view van danh du cho cho
        // chieu cao goc - sinh ra 1 khoang trong du o duoi va van cuon duoc,
        // dong thoi noi dung bi thu hep lech vao giua. Da thu va phai bo.
        //
        // Noi dung CHIEM TRON chieu cao con lai (khong con SingleChildScrollView
        // khoa cuon): bo cuc duoc do theo 1 man mau ~670pt, tren may cao hon
        // (ty le 20:9) thua ra ca tram pt bi don het xuong day thanh 1 mang
        // trong. Nay phan thua do duoc chia cho ca 4 khoi theo ti le thiet ke
        // (xem cac Expanded trong _buildBody), nen man nao cung day kin.
        child: ClipRect(
          child: _buildBody(
            context,
            ref,
            unread: unread,
            accent: accent,
            recommended: recommended,
            topPick: topPick,
            compassLink: compassLink,
            showSurveyHint: showSurveyHint,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref, {
    required int unread,
    required Color accent,
    required List<HomeFeature> recommended,
    required HomeFeature? topPick,
    required LayerLink compassLink,
    required bool showSurveyHint,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              greeting: '${ref.tr(greetingKeyForNow())},',
              unreadCount: unread,
              onMessagesTap: () =>
                  openAppPopup(context, const ConversationsScreen()),
              trailing: GestureDetector(
                // Bam icon la ban luon mo lai khao sat (chon/doi/tat
                // goi y lo trinh) - da bo man "Lo trinh hoc" day du
                // rieng theo yeu cau.
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const LearningPathSurveyScreen(),
                ),
                child: CompositedTransformTarget(
                  link: compassLink,
                  child: Tooltip(
                    message: ref.tr('learning_path_tooltip'),
                    child: const TopBarIconChip(icon: Icons.explore_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const ServiceExpiryBanner(section: AppSection.learnEnglish),
            // The tien do (Lv/XP/chuoi ngay) da BO theo yeu cau.
            //
            // CA 4 khoi deu Expanded, flex = chieu cao THIET KE cua tung khoi
            // (do tren ban mau ~670pt: 29/19/30/25) - nho vay chieu cao thua
            // cua may cao duoc chia cho ca 4 theo DUNG TI LE ban thiet ke,
            // khoi nao cung cao len mot chut va van giu dung tuong quan to
            // nho voi nhau.
            //
            // Ban truoc don HET phan thua cho rieng the MAIN SKILL: the do
            // phinh gan gap doi, day khung Luyen thi tut han xuong day man.
            const Expanded(flex: 29, child: _DailyWordsHeroCard()),
            const SizedBox(height: 5),
            Expanded(
              flex: 19,
              child: _SkillGrid(
                accent: accent,
                recommended: recommended,
                topPick: topPick,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 30,
              child: _PracticePanel(
                accent: accent,
                recommended: recommended,
                topPick: topPick,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 25,
              child: _TestPrepPanel(
                accent: accent,
                recommended: recommended,
                topPick: topPick,
              ),
            ),
          ],
        ),
        if (showSurveyHint)
          Positioned(
            top: 0,
            right: 0,
            child: CompositedTransformFollower(
              link: compassLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: const _SuggestHint(color: AppColors.teal),
            ),
          ),
      ],
    );
  }
}

// ===========================================================================
// Khung nen chung cho moi the o man Home
// ===========================================================================

/// The kinh o man Home - nen PHANG + vien mong deu 4 canh, theo dung so do
/// duoc tu ban thiet ke. Khac [GlowBox] (dung o cac man con) o cho nen nhat
/// hon va vien sang hon.
class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Vien doi mau khi the nay nam trong danh sach goi y cua persona.
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = borderColor != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: highlighted
              ? borderColor!.withValues(alpha: 0.10)
              : AppColors.homeCardFill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? AppColors.homeCardBorder,
            width: highlighted ? 1.4 : 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: borderColor!.withValues(alpha: 0.28),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Dem sang tron sau moi icon tinh nang. Do tu ban thiet ke: sang deu toi
/// ~78% ban kinh roi tat gon o bien (khong tan dan tu tam) - nho vay no doc
/// ra la "1 lop dem" chu khong phai vet sang mo.
class _IconPad extends StatelessWidget {
  const _IconPad({required this.icon, this.size = 32, this.color});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0, -0.06),
          colors: [
            (color ?? const Color(0xFFC2DEFF)).withValues(alpha: 0.185),
            (color ?? const Color(0xFFB8D4FC)).withValues(alpha: 0.165),
            (color ?? const Color(0xFFA8CAF8)).withValues(alpha: 0.125),
            (color ?? const Color(0xFF96BCF0)).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.56, 0.76, 1.0],
        ),
        border: Border.all(color: const Color(0x1AC8E0FF)),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}

/// Nhan nho in hoa dau moi khung ("KY NANG CHINH", "LUYEN TAP").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.body(
      size: 9,
      weight: FontWeight.w700,
      color: AppColors.textLabel,
    ).copyWith(letterSpacing: 1.5),
  );
}

// ===========================================================================
// 2. The tien do - Level/XP + chuoi ngay
class _DailyWordsHeroCard extends ConsumerWidget {
  const _DailyWordsHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(dailyWordsControllerProvider).words.length;

    return GestureDetector(
      onTap: () => openDailyWordsPopup(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.homeCardBorder),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16202F), Color(0xFF0B1522), Color(0xFF040A13)],
              stops: [0, 0.46, 1],
            ),
          ),
          child: Stack(
            children: [
              // Hinh hanh tinh + doi cat - cat tu chinh anh thiet ke cua chu
              // du an nen khop 100%, khong the ve lai bang gradient cho giong.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0, 0.26],
                  ).createShader(rect),
                  child: Image.asset(
                    'assets/home/hero_daily_words.jpg',
                    fit: BoxFit.cover,
                    // Anh hong/thieu khong duoc lam vo ca man Home.
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // Positioned.fill + spaceBetween: the nay duoc [Expanded] o man
              // Home keo cao them bao nhieu thi nhan chu bam TREN cung con nut
              // "Tiep tuc" tut xuong DAY the, khong de mot mang trong duoi
              // nut nhu khi de Column co chieu cao tu nhien.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 7, 13, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cum chu gom lai lam 1 KHOI: spaceBetween chi tach
                      // khoi chu (tren) voi hang nut (duoi), neu de cac dong
                      // chu la con truc tiep thi moi dong se bi keo roi xa
                      // nhau khi the cao len.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SectionLabel(ref.tr('home_main_skill')),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              ref
                                  .tr('profile_daily_words_title')
                                  .replaceFirst('{n}', '$total'),
                              style: AppTextStyles.heading(size: 15.5)
                                  .copyWith(height: 1.12),
                            ),
                          ),
                          const SizedBox(height: 3),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              ref.tr('home_vocabulary_quick_subtitle'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                size: 10.5,
                                weight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ).copyWith(height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      // Khong con SizedBox ngan cach o day: spaceBetween chia
                      // khoang trong cho TUNG khe giua cac con, them 1 con
                      // SizedBox o giua se bi tha troi lung lo giua the.
                      Row(
                        children: [
                          Container(
                            height: 30,
                            padding: const EdgeInsets.fromLTRB(14, 0, 17, 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFCFF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 16,
                                  color: Color(0xFF07090F),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ref.tr('home_continue'),
                                  style: AppTextStyles.heading(size: 12.5)
                                      .copyWith(color: const Color(0xFF07090F)),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 29,
                            height: 29,
                            decoration: BoxDecoration(
                              color: const Color(0xEE1C2A3E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0x29C8DEFF),
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ===========================================================================
// 4. 4 the Doc viet
// ===========================================================================

class _SkillGrid extends ConsumerWidget {
  const _SkillGrid({
    required this.accent,
    required this.recommended,
    required this.topPick,
  });

  final Color accent;
  final List<HomeFeature> recommended;
  final HomeFeature? topPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_FeatureEntry>[
      _FeatureEntry(
        feature: HomeFeature.vocabulary,
        icon: Icons.menu_book_outlined,
        title: ref.tr('home_skill_vocabulary'),
        subtitle: ref.tr('home_sub_vocabulary'),
        open: () => openAppPopup(context, const VocabularyTopicsScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.grammar,
        icon: Icons.article_outlined,
        title: ref.tr('grammar_topics_title'),
        subtitle: ref.tr('home_sub_grammar'),
        open: () => openAppPopup(context, const GrammarTopicsScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.reading,
        icon: Icons.chrome_reader_mode_outlined,
        title: ref.tr('reading_title'),
        subtitle: ref.tr('home_sub_reading'),
        open: () => openAppPopup(context, const ReadingLibraryScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.writing,
        icon: Icons.edit_outlined,
        title: ref.tr('writing_title'),
        subtitle: ref.tr('home_sub_writing'),
        open: () => openAppPopup(context, const WritingHomeScreen()),
      ),
    ];

    return Row(
      // stretch: hang nay nam trong 1 Expanded o man Home nen co chieu cao co
      // dinh - de mac dinh (center) thi 4 the giu chieu cao tu nhien va noi
      // lung lung giua o trong.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _SkillCard(
              entry: items[i],
              accent: accent,
              isRecommended: recommended.contains(items[i].feature),
              isTopPick: topPick == items[i].feature,
            ),
          ),
        ],
      ],
    );
  }
}

/// Khoi chu chiem DUNG [lines] dong, du chu ngan hay dai.
///
/// Ly do co widget nay: cac the o Home nam trong Row + Expanded nen be ngang
/// bang nhau nhung chu thi khong - "Vocabulary" xuong 2 dong con "Grammar"
/// chi 1 dong, lam the do CAO HON han cac the ben canh va dong phu bi lech
/// hang. Dat truoc chieu cao theo so dong toi da thi moi the cao bang nhau
/// bat ke ngon ngu hay do dai chu.
class _FixedLines extends StatelessWidget {
  const _FixedLines(
    this.text, {
    required this.lines,
    required this.style,
    this.shrinkToFit = false,
  });

  final String text;
  final int lines;
  final TextStyle style;

  /// true = thu nho chu vua khung thay vi cat bang dau "..." - dung cho ten
  /// 1 dong (vd "Vocabulary" dai hon han "Grammar") de khong bi ngat giua tu.
  final bool shrinkToFit;

  @override
  Widget build(BuildContext context) {
    final height = (style.fontSize ?? 12) * (style.height ?? 1.2) * lines;
    final text_ = Text(
      text,
      maxLines: lines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: shrinkToFit
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: text_,
            )
          : text_,
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry({
    required this.feature,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.open,
  });
  final HomeFeature feature;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback open;
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.entry,
    required this.accent,
    required this.isRecommended,
    required this.isTopPick,
  });

  final _FeatureEntry entry;
  final Color accent;
  final bool isRecommended;
  final bool isTopPick;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Positioned.fill: Stack truyen rang buoc LONG xuong con khong duoc
        // Positioned, nen neu de _HomeCard la con thuong thi the van cao tu
        // nhien du o trong da duoc cap du cho - phai ep no lap day.
        Positioned.fill(
          child: _HomeCard(
            onTap: entry.open,
            radius: 15,
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
            borderColor: isRecommended ? accent : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // spaceBetween: the cao len thi mui ten tut xuong day the thay
              // vi de 1 mang trong duoi cung.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon + 2 dong chu gom lam 1 KHOI de spaceBetween chi tach
                // khoi nay voi mui ten - de roi tung dong thi chu bi keo gian
                // ra khap the khi the cao len.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconPad(
                      icon: entry.icon,
                      size: 24,
                      color: isRecommended ? accent : null,
                    ),
                    const SizedBox(height: 5),
                    _FixedLines(
                      entry.title,
                      lines: 1,
                      shrinkToFit: true,
                      style: AppTextStyles.body(
                        size: 10.5,
                        weight: FontWeight.w700,
                      ).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 1),
                    _FixedLines(
                      entry.subtitle,
                      lines: 2,
                      style: AppTextStyles.body(
                        size: 8.5,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.2),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (isTopPick)
          Positioned(
            right: -8,
            bottom: -8,
            child: PointingHandBadge(color: accent),
          ),
      ],
    );
  }
}

// ===========================================================================
// 5. Khung Nghe noi
// ===========================================================================

class _PracticePanel extends ConsumerWidget {
  const _PracticePanel({
    required this.accent,
    required this.recommended,
    required this.topPick,
  });

  final Color accent;
  final List<HomeFeature> recommended;
  final HomeFeature? topPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_FeatureEntry>[
      _FeatureEntry(
        feature: HomeFeature.phonics,
        icon: Icons.graphic_eq_rounded,
        title: ref.tr('phonics_title'),
        subtitle: ref.tr('home_sub_phonics'),
        open: () => openAppPopup(context, const PhonicsLessonsScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.pronunciation,
        icon: Icons.record_voice_over_outlined,
        title: ref.tr('pron_title'),
        subtitle: ref.tr('home_sub_pronunciation'),
        open: () => openAppPopup(context, const PronunciationScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.story,
        icon: Icons.headphones_outlined,
        title: ref.tr('home_story_quick_title'),
        subtitle: ref.tr('home_sub_story'),
        open: () => openAppPopup(context, const StoryListScreen()),
      ),
    ];

    return _HomeCard(
      padding: const EdgeInsets.fromLTRB(11, 7, 11, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de + duong ke gom lam 1 KHOI: spaceBetween chia khoang trong
          // cho TUNG khe, de roi tung phan thi duong ke se bi tha troi giua
          // khung thay vi nam sat duoi tieu de.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SectionLabel(ref.tr('home_practice_label')),
                        const SizedBox(height: 3),
                        Text(
                          ref.tr('home_listening_speaking'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading(size: 15.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ref.tr('home_listening_speaking_sub'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            size: 10.5,
                            weight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        openAppPopup(context, const PronunciationScreen()),
                    child: Container(
                      width: 54,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x29AAD4FF)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue.withValues(alpha: 0.14),
                          border: Border.all(
                            color: AppColors.blue.withValues(alpha: 0.5),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.22),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic_none_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.09)),
            ],
          ),
          const SizedBox(height: 7),
          // Expanded thay cho IntrinsicHeight: 4 muc luyen tap CAO LEN lap
          // het cho trong con lai cua khung (khung duoc cap them chieu cao o
          // man Home), cac vach ngan doc cung keo het chieu cao hang. Van giu
          // stretch nen 4 muc luon cao bang nhau.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: Colors.white.withValues(alpha: 0.085),
                    ),
                  Expanded(
                    child: _PracticeItem(
                      entry: items[i],
                      accent: accent,
                      isRecommended: recommended.contains(items[i].feature),
                      isTopPick: topPick == items[i].feature,
                    ),
                  ),
                ],
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: Colors.white.withValues(alpha: 0.085),
                ),
                // Tro chuyen AI - truoc day chi mo duoc tu nut noi
                // (AssistiveTouch); ban thiet ke dua no thanh 1 muc o Home cho
                // de thay. Van mo dung man AiVoiceChatScreen do, cung ten route
                // nen nut noi van nhan biet duoc dang o trong man nay.
                Expanded(
                  child: _PracticeItem(
                    entry: _FeatureEntry(
                      feature: HomeFeature.story,
                      icon: Icons.memory_rounded,
                      title: ref.tr('voice_chat_title'),
                      subtitle: ref.tr('home_sub_ai_chat'),
                      open: () => showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        routeSettings: const RouteSettings(
                          name: kAiVoiceChatRouteName,
                        ),
                        builder: (_) => const FractionallySizedBox(
                          heightFactor: 0.94,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            child: AiVoiceChatScreen(),
                          ),
                        ),
                      ),
                    ),
                    accent: accent,
                    isRecommended: false,
                    isTopPick: false,
                    badge: ref.tr('home_badge_new'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeItem extends StatelessWidget {
  const _PracticeItem({
    required this.entry,
    required this.accent,
    required this.isRecommended,
    required this.isTopPick,
    this.badge,
  });

  final _FeatureEntry entry;
  final Color accent;
  final bool isRecommended;
  final bool isTopPick;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: entry.open,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconPad(
                icon: entry.icon,
                size: 23,
                color: isRecommended ? accent : null,
              ),
              const SizedBox(height: 5),
              _FixedLines(
                entry.title,
                lines: 2,
                style: AppTextStyles.body(
                  size: 9,
                  weight: FontWeight.w700,
                ).copyWith(height: 1.22),
              ),
              const SizedBox(height: 1),
              _FixedLines(
                entry.subtitle,
                lines: 1,
                style: AppTextStyles.body(
                  size: 8,
                  weight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.2),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x29C8DEFF)),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.body(
                    size: 7.5,
                    weight: FontWeight.w800,
                  ).copyWith(letterSpacing: 0.4),
                ),
              ),
            ),
          if (isTopPick)
            Positioned(
              left: 14,
              top: 14,
              child: PointingHandBadge(color: accent),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 6. Khung Luyen thi
// ===========================================================================

class _TestPrepPanel extends ConsumerWidget {
  const _TestPrepPanel({
    required this.accent,
    required this.recommended,
    required this.topPick,
  });

  final Color accent;
  final List<HomeFeature> recommended;
  final HomeFeature? topPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_FeatureEntry>[
      _FeatureEntry(
        feature: HomeFeature.toeic,
        // fact_check (bang kiem co dau tick) thay cho assignment - assignment
        // gan giong het article_outlined cua Ngu phap nen 2 muc bi lan.
        icon: Icons.fact_check_outlined,
        title: ref.tr('home_skill_toeic'),
        subtitle: ref.tr('home_sub_toeic'),
        open: () => openAppPopup(context, const ToeicHomeScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.ielts,
        icon: Icons.bar_chart_rounded,
        title: ref.tr('home_skill_ielts'),
        subtitle: ref.tr('home_sub_ielts'),
        open: () => openAppPopup(context, const IeltsHomeScreen()),
      ),
      _FeatureEntry(
        feature: HomeFeature.quiz,
        icon: Icons.extension_outlined,
        title: ref.tr('home_skill_quiz'),
        subtitle: ref.tr('home_sub_quiz'),
        open: () => openAppPopup(context, const QuizCategoryScreen()),
      ),
    ];

    return _HomeCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconPad(icon: Icons.timer_outlined, size: 30),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SectionLabel(ref.tr('home_achieve_label')),
                    const SizedBox(height: 1),
                    Text(
                      ref.tr('home_category_test_prep'),
                      style: AppTextStyles.heading(size: 14.5),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      ref.tr('home_test_prep_sub'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        size: 10,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Expanded + stretch: 3 o TOEIC/IELTS/Quiz CAO LEN lap het cho
          // trong con lai cua khung, thay vi giu chieu cao toi thieu va de
          // 1 mang trong giua tieu de voi chung (bo cuc spaceBetween cu).
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Expanded(
                    child: _TestPrepTile(
                      entry: items[i],
                      accent: accent,
                      isRecommended: recommended.contains(items[i].feature),
                      isTopPick: topPick == items[i].feature,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestPrepTile extends StatelessWidget {
  const _TestPrepTile({
    required this.entry,
    required this.accent,
    required this.isRecommended,
    required this.isTopPick,
  });

  final _FeatureEntry entry;
  final Color accent;
  final bool isRecommended;
  final bool isTopPick;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Positioned.fill: hang cha da cap du chieu cao (stretch), nhung con
        // KHONG Positioned cua Stack chi nhan rang buoc long nen the se van
        // cao tu nhien neu khong ep lap day.
        Positioned.fill(
          child: _HomeCard(
            onTap: entry.open,
            radius: 13,
            padding: const EdgeInsets.all(6),
            borderColor: isRecommended ? accent : null,
            child: Row(
              children: [
                _IconPad(
                  icon: entry.icon,
                  size: 22,
                  color: isRecommended ? accent : null,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FixedLines(
                        entry.title,
                        lines: 1,
                        shrinkToFit: true,
                        style: AppTextStyles.body(
                          size: 9.5,
                          weight: FontWeight.w700,
                        ).copyWith(height: 1.2),
                      ),
                      const SizedBox(height: 1),
                      _FixedLines(
                        entry.subtitle,
                        lines: 1,
                        style: AppTextStyles.body(
                          size: 7.5,
                          weight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isTopPick)
          Positioned(
            right: -8,
            bottom: -8,
            child: PointingHandBadge(color: accent),
          ),
      ],
    );
  }
}

// ===========================================================================
// Goi y "chon lo trinh hoc" - giu nguyen nhu ban cu
// ===========================================================================

/// Ban tay tro + dong chu goi y nguoi dung dang "Tu hoc" bam vao nut khao
/// sat "Goi y lo trinh hoc" (xem [PointingHandBadge], cung 1 ngon ngu hinh
/// anh voi the goi y o luoi Home) - chi an khi da chon 1 lo trinh.
///
/// Nut X tren bong bong = tat HAN goi y nay (luu SharedPreferences, khong
/// hien lai o lan mo app sau).
class _SuggestHint extends ConsumerWidget {
  const _SuggestHint({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PointingHandBadge(color: color),
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Chua cho 10px tren/trai de nut X (goc tren-trai) nam TRONG
            // khung Stack - Flutter khong nhan cham o phan tran ra ngoai.
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    ref.tr('learning_path_hint_text'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              left: -6,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(_surveyHintDismissedProvider.notifier).dismiss(),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2033),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// true = nguoi dung da bam X tat goi y lo trinh hoc. Khoi tao = true (an)
/// cho toi khi doc xong SharedPreferences, tranh goi y loe len roi tat.
final _surveyHintDismissedProvider =
    StateNotifierProvider<_SurveyHintDismissed, bool>(
      (ref) => _SurveyHintDismissed(),
    );

class _SurveyHintDismissed extends StateNotifier<bool> {
  _SurveyHintDismissed() : super(true) {
    _load();
  }

  static const _key = 'learning_path_hint_dismissed_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_key) ?? false;
  }

  Future<void> dismiss() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
