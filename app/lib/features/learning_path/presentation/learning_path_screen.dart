import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../ai_voice_chat/presentation/ai_voice_chat_screen.dart';
import '../../grammar/presentation/grammar_topics_screen.dart';
import '../../ielts/presentation/ielts_home_screen.dart';
import '../../pronunciation/presentation/phonics_lessons_screen.dart';
import '../../pronunciation/presentation/pronunciation_screen.dart';
import '../../quiz/presentation/quiz_category_screen.dart';
import '../../reading/presentation/reading_library_screen.dart';
import '../../story/presentation/story_list_screen.dart';
import '../../toeic/presentation/toeic_home_screen.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import '../../writing/presentation/writing_paragraph_list_screen.dart';
import '../../writing/presentation/writing_vocab_topic_screen.dart';
import '../data/learning_path_models.dart';
import '../data/learning_path_stages.dart';
import 'learning_path_accent.dart';
import 'learning_path_survey_screen.dart';

/// Man "Lo trinh hoc" day du - danh sach stage TUAN TU cua persona dang
/// chon, moi stage co nut mo dung tinh nang + nut danh dau hoan thanh + 1
/// thanh tien do tong o dau trang - xem docs/research-learning-path.md muc
/// 7. KHONG khoa stage nao (bam duoc bat ky luc nao, dung yeu cau muc 6).
class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key, required this.persona});

  final LearningPersona persona;

  /// Anh xa [LearningPathTarget] -> widget man hinh that su can mo. Dat o
  /// day (presentation) thay vi trong data/learning_path_stages.dart de giu
  /// dung quy uoc feature-first (data khong phu thuoc widget).
  void _openTarget(BuildContext context, LearningPathTarget target) {
    switch (target) {
      case LearningPathTarget.vocabulary:
        openAppPopup(context, const VocabularyTopicsScreen());
      case LearningPathTarget.grammar:
        openAppPopup(context, const GrammarTopicsScreen());
      case LearningPathTarget.phonics:
        openAppPopup(context, const PhonicsLessonsScreen());
      case LearningPathTarget.pronunciation:
        openAppPopup(context, const PronunciationScreen());
      case LearningPathTarget.story:
        openAppPopup(context, const StoryListScreen());
      case LearningPathTarget.reading:
        openAppPopup(context, const ReadingLibraryScreen());
      case LearningPathTarget.writingVocab:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WritingVocabTopicScreen()),
        );
      case LearningPathTarget.writingParagraph:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WritingParagraphListScreen()),
        );
      case LearningPathTarget.quiz:
        openAppPopup(context, const QuizCategoryScreen());
      case LearningPathTarget.toeic:
        openAppPopup(context, const ToeicHomeScreen());
      case LearningPathTarget.ielts:
        openAppPopup(context, const IeltsHomeScreen());
      case LearningPathTarget.aiVoiceChat:
        openAppPopup(context, const AiVoiceChatScreen());
    }
  }

  IconData _targetIcon(LearningPathTarget target) => switch (target) {
    LearningPathTarget.vocabulary => Icons.style_rounded,
    LearningPathTarget.grammar => Icons.menu_book_rounded,
    LearningPathTarget.phonics => Icons.graphic_eq_rounded,
    LearningPathTarget.pronunciation => Icons.mic_rounded,
    LearningPathTarget.story => Icons.auto_stories_rounded,
    LearningPathTarget.reading => Icons.local_library_rounded,
    LearningPathTarget.writingVocab => Icons.style_rounded,
    LearningPathTarget.writingParagraph => Icons.short_text_rounded,
    LearningPathTarget.quiz => Icons.extension_rounded,
    LearningPathTarget.toeic => Icons.assignment_rounded,
    LearningPathTarget.ielts => Icons.public_rounded,
    LearningPathTarget.aiVoiceChat => Icons.forum_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = personaColor(persona);
    final stages = kLearningPathStages[persona] ?? const [];
    final progress =
        ref.watch(learningPathProgressProvider(persona)).valueOrNull ??
        const <int>{};
    final done = progress.length;
    final total = stages.length;

    return ScreenBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupHeader(title: ref.tr('lp_screen_title')),
              const SizedBox(height: 4),
              Text(
                ref.tr(personaNameKey(persona)),
                style: AppTextStyles.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 14),
              _ProgressBar(done: done, total: total, accent: accent),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: stages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final isDone = progress.contains(index);
                    return _StageCard(
                      index: index,
                      stage: stage,
                      accent: accent,
                      isDone: isDone,
                      icon: _targetIcon(stage.target),
                      onOpen: () => _openTarget(context, stage.target),
                      onToggleDone: () async {
                        final repo = ref.read(learningPathRepositoryProvider);
                        if (isDone) {
                          await repo.unmarkStepCompleted(persona, index);
                        } else {
                          await repo.markStepCompleted(persona, index);
                        }
                        ref.invalidate(learningPathProgressProvider(persona));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: ref.tr('lp_change_path_button'),
                      filled: false,
                      accentColor: accent,
                      onTap: () {
                        Navigator.of(context).maybePop();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const LearningPathSurveyScreen(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton(
                      label: ref.tr('lp_turn_off_button'),
                      filled: false,
                      accentColor: AppColors.textMuted,
                      onTap: () async {
                        await ref
                            .read(learningPathRepositoryProvider)
                            .turnOff();
                        ref.invalidate(learningPathChoiceProvider);
                        ref.invalidate(learningPathInteractedProvider);
                        if (context.mounted) Navigator.of(context).maybePop();
                      },
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

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({
    required this.done,
    required this.total,
    required this.accent,
  });

  final int done;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref
              .tr('lp_screen_progress')
              .replaceAll('{done}', '$done')
              .replaceAll('{total}', '$total'),
          style: AppTextStyles.muted(size: 12.5, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.glassFill,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

class _StageCard extends ConsumerWidget {
  const _StageCard({
    required this.index,
    required this.stage,
    required this.accent,
    required this.isDone,
    required this.icon,
    required this.onOpen,
    required this.onToggleDone,
  });

  final int index;
  final LearningPathStage stage;
  final Color accent;
  final bool isDone;
  final IconData icon;
  final VoidCallback onOpen;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      borderRadius: 22,
      border: isDone ? Border.all(color: accent.withValues(alpha: 0.55)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${ref.tr(stage.titleKey)}',
                      style: AppTextStyles.heading(size: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.tr(stage.descKey),
                      style: AppTextStyles.muted(size: 12)
                          .copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ref.tr('lp_stage_open_button'),
                  accentColor: accent,
                  accentGradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.65)],
                  ),
                  onTap: onOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: ref.tr(
                    isDone ? 'lp_stage_unmark' : 'lp_stage_mark_done',
                  ),
                  filled: false,
                  accentColor: isDone ? accent : AppColors.textMuted,
                  onTap: onToggleDone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
