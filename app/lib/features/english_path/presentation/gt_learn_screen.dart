import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/gt_mini_player.dart';
import '../../../core/navigation/gt_top_bar.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gt_tokens.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../ielts/presentation/ielts_home_screen.dart';
import '../../learning_path/presentation/learning_path_survey_screen.dart';
import '../../../core/i18n/greeting.dart';
import '../../profile/presentation/profile_screen.dart'
    show openDailyWordsPopup;
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../speaking/presentation/hands_free_drill_screen.dart';
import '../../srs/data/srs_store.dart';
import '../../story/presentation/story_list_screen.dart';
import '../../toeic/presentation/toeic_home_screen.dart';
import '../../vocabulary/presentation/daily_words_controller.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../../writing/presentation/writing_home_screen.dart';
import '../data/english_path_providers.dart';
import '../data/learn_presentation.dart';
import 'english_path_screen.dart';

/// Tom tat tu vung hang ngay cho hero - tach khoi [DailyWordsController]
/// (controller dat thong bao/Timer) de test override duoc.
final dailyWordsSummaryProvider =
    Provider<({int learned, int total, bool loaded})>((ref) {
      final d = ref.watch(dailyWordsControllerProvider);
      return (
        learned: d.learnedTodayEnLower.length,
        total: d.words.length,
        loaded: d.loaded,
      );
    });

/// Tab "Hoc" cua ban redesign (spec #70, #76; README §7): the English Level
/// + tien do toi Level Test, hero tu vung hang ngay, 4 ky nang, luyen noi,
/// luyen thi.
class GtLearnScreen extends ConsumerStatefulWidget {
  const GtLearnScreen({super.key});

  @override
  ConsumerState<GtLearnScreen> createState() => _GtLearnScreenState();
}

class _GtLearnScreenState extends ConsumerState<GtLearnScreen> {
  @override
  void initState() {
    super.initState();
    SrsStore.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final padding = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: t.bg,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          padding.top + 4,
          16,
          padding.bottom + 16,
        ),
        children: [
          GtTopBar(greetingKey: ref.watch(greetingKeyProvider)),
          const SizedBox(height: 14),
          const ServiceExpiryBanner(section: AppSection.learnEnglish),
          const GtLevelCard(),
          const SizedBox(height: 14),
          const _DailyWordsHero(),
          const SizedBox(height: 14),
          const _MusicCard(),
          const SizedBox(height: 14),
          const _SkillGrid(),
          const SizedBox(height: 14),
          const _SpeakingCard(),
          const SizedBox(height: 14),
          const _ExamRow(),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              // Khao sat goi y lo trinh (truoc o nut la ban tren top bar cu).
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const LearningPathSurveyScreen(),
              ),
              icon: Icon(Icons.explore_outlined, color: t.tx2, size: 18),
              label: Text(
                ref.tr('gt_learn_survey_link'),
                style: GtText.body(t.tx2, size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The English Level

class GtLevelCard extends ConsumerWidget {
  const GtLevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final level = ref.watch(englishLevelProvider);
    final state = ref.watch(englishPathStateProvider);
    final pack = ref.watch(contentPackProvider).valueOrNull;
    final progress = pack == null
        ? null
        : levelTestProgress(pack, level, state);
    final sub = switch (levelCardState(pack, level, state, DateTime.now())) {
      LevelCardState.allDone => ref.tr('path_all_done'),
      LevelCardState.noContent => ref.tr('path_entry_subtitle_idle'),
      LevelCardState.testReady => ref.tr('gt_learn_level_test_ready'),
      LevelCardState.coolingDown => ref.tr('gt_learn_level_test_cooldown'),
      LevelCardState.learning =>
        ref
            .tr('gt_learn_units_to_test')
            .replaceFirst('{done}', '${progress?.done ?? 0}')
            .replaceFirst('{total}', '${progress?.total ?? 0}'),
    };
    return Material(
      color: t.s1,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => openAppPopup(context, const EnglishPathScreen()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.blueT,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(level.code, style: GtText.ringStat(t.blue)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('path_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.cardTitle(t.tx).copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(t.tx2, size: 13),
                    ),
                    // Khong co noi dung cho Stage -> khong ve thanh.
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.fraction,
                          minHeight: 8,
                          color: t.blue,
                          backgroundColor: t.s2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: t.tx3),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero tu vung hang ngay

class _DailyWordsHero extends ConsumerWidget {
  const _DailyWordsHero();

  static const _bg = Color(0xFF050B16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyWordsSummaryProvider);
    // Chua tai xong / chua co tu -> khong hien so (khong "Hoc 0 tu").
    final hasCount = daily.loaded && daily.total > 0;
    final total = daily.total;
    final learned = daily.learned.clamp(0, total);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: _bg,
        constraints: const BoxConstraints(minHeight: 200),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/home/hero_daily_words.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bg, _bg, Color(0x00050B16)],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('gt_learn_daily_overline'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GtText.overline(const Color(0xFF8FB0FF)),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Text(
                      hasCount
                          ? ref
                                .tr('gt_learn_daily_title')
                                .replaceFirst('{n}', '$total')
                          : ref.tr('gt_learn_daily_title_plain'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.cardTitle(Colors.white)
                          .copyWith(fontSize: 24, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasCount)
                    Text(
                      ref
                          .tr('gt_learn_daily_sub')
                          .replaceFirst('{done}', '$learned')
                          .replaceFirst('{total}', '$total'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(const Color(0xFFAFC0DA), size: 13),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B0C0E),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => openDailyWordsPopup(context),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      ref.tr('home_continue'),
                      style: GtText.rowTitle(const Color(0xFF0B0C0E)),
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

// ---------------------------------------------------------------------------
// 4 ky nang (khong co % gia: chi so lieu that hoac mo ta)

class _SkillGrid extends ConsumerWidget {
  const _SkillGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srs = SrsStore.instance;
    return ListenableBuilder(
      listenable: srs,
      builder: (context, _) {
        final cards = srs.totalCards;
        final tiles = [
          _Tile(
            icon: Icons.menu_book_outlined,
            title: ref.tr('home_skill_vocabulary'),
            sub: cards > 0
                ? ref.tr('gt_learn_vocab_cards').replaceFirst('{n}', '$cards')
                : ref.tr('home_sub_vocabulary'),
            onTap: () => openAppPopup(context, const VocabularyTopicsScreen()),
          ),
          _Tile(
            icon: Icons.article_outlined,
            title: ref.tr('grammar_topics_title'),
            sub: ref.tr('home_sub_grammar'),
            onTap: () => openAppPopup(context, const GrammarTopicsScreen()),
          ),
          _Tile(
            icon: Icons.chrome_reader_mode_outlined,
            title: ref.tr('reading_title'),
            sub: ref.tr('home_sub_reading'),
            onTap: () => openAppPopup(context, const ReadingLibraryScreen()),
          ),
          _Tile(
            icon: Icons.edit_outlined,
            title: ref.tr('writing_title'),
            sub: ref.tr('home_sub_writing'),
            onTap: () => openAppPopup(context, const WritingHomeScreen()),
          ),
        ];
        return _Grid(children: tiles);
      },
    );
  }
}

/// Luoi 2 cot, cac o trong 1 hang cao bang nhau.
class _Grid extends StatelessWidget {
  const _Grid({required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < children.length; i += 2) ...[
        if (i > 0) SizedBox(height: gap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: gap),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.accent,
    this.background,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final Color? accent;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Material(
      color: background ?? t.s1,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent ?? t.blue, size: 26),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GtText.rowTitle(t.tx).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GtText.body(t.tx2, size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Luyen noi

class _SpeakingCard extends ConsumerWidget {
  const _SpeakingCard();

  void _openPronunciation(BuildContext context) => openAppPopup(
    context,
    const PronunciationScreen(),
    routeName: kPronunciationRouteName,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final modes = [
      _Tile(
        icon: Icons.record_voice_over_rounded,
        title: ref.tr('pron_title'),
        sub: ref.tr('home_sub_pronunciation'),
        accent: t.teal,
        background: t.s2,
        onTap: () => _openPronunciation(context),
      ),
      _Tile(
        icon: Icons.headphones_rounded,
        title: ref.tr('hands_free_title'),
        sub: ref.tr('today_hands_free_sub'),
        accent: t.teal,
        background: t.s2,
        onTap: () => openAppPopup(
          context,
          const HandsFreeDrillScreen(),
          routeName: kPronunciationRouteName,
        ),
      ),
      _Tile(
        icon: Icons.auto_stories_rounded,
        title: ref.tr('home_story_quick_title'),
        sub: ref.tr('home_sub_story'),
        accent: t.teal,
        background: t.s2,
        onTap: () => openAppPopup(context, const StoryListScreen()),
      ),
      _Tile(
        icon: Icons.forum_rounded,
        title: ref.tr('voice_chat_title'),
        sub: ref.tr('home_sub_ai_chat'),
        accent: t.teal,
        background: t.s2,
        onTap: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          routeSettings: const RouteSettings(name: kAiVoiceChatRouteName),
          builder: (_) => const FractionallySizedBox(
            heightFactor: 0.94,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              child: AiVoiceChatScreen(),
            ),
          ),
        ),
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('gt_learn_speaking_overline'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.overline(t.teal),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.tr('gt_learn_speaking_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.cardTitle(t.tx),
                    ),
                    Text(
                      ref.tr('gt_learn_speaking_sub'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(t.tx2, size: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                label: ref.tr('pron_title'),
                child: Material(
                  color: t.teal,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _openPronunciation(context),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Icon(Icons.mic_rounded, color: t.onTeal, size: 30),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Grid(gap: 8, children: modes),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              // Phonics: loi vao cu o khung Luyen tap, giu lai.
              onPressed: () =>
                  openAppPopup(context, const PhonicsLessonsScreen()),
              child: Text(
                '${ref.tr('phonics_title')} ›',
                style: GtText.body(t.teal, size: 13, weight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Luyen thi

class _ExamRow extends ConsumerWidget {
  const _ExamRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final items = [
      (
        Icons.workspace_premium_rounded,
        'home_skill_toeic',
        const ToeicHomeScreen(),
      ),
      (Icons.school_rounded, 'home_skill_ielts', const IeltsHomeScreen()),
      (Icons.quiz_rounded, 'home_skill_quiz', const QuizCategoryScreen()),
    ];
    return Row(
      children: [
        for (final (i, (icon, key, screen)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: t.s1,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => openAppPopup(context, screen),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(icon, color: t.gold, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        ref.tr(key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GtText.rowTitle(t.tx).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hoc qua bai hat - loi vao trinh phat (lyric song ngu, cham tu tra nghia)

class _MusicCard extends ConsumerWidget {
  const _MusicCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return Material(
      color: t.s1,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => openMusicPlayer(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: t.blueT,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.library_music_rounded, color: t.blue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('gt_learn_music_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.rowTitle(t.tx).copyWith(fontSize: 16),
                    ),
                    Text(
                      ref.tr('gt_learn_music_sub'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GtText.body(t.tx2, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, color: t.blue, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
