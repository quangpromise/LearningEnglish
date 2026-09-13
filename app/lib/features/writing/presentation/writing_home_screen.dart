import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../../vocabulary/data/vocabulary_data.dart';
import '../data/writing_bank.dart';
import '../data/writing_paragraph_data.dart';
import 'writing_mixed_list_screen.dart';
import 'writing_paragraph_list_screen.dart';
import 'writing_paragraph_screen.dart';
import 'writing_topic_paragraphs_screen.dart';
import 'writing_vocab_quiz_screen.dart';
import 'writing_vocab_topic_screen.dart';

enum _WritingMode { select, vocab, paragraph }

/// Man chinh cua tinh nang "Luyen viet" - chon 1 trong 2 phuong an: Tu vung
/// (go lai tu tieng Anh theo nghia) hoac Doan van (dich tung cau tieng Viet
/// sang tieng Anh). Dong thoi la "khung" duy nhat cho CA 2 nhanh (moi
/// nhanh co the sau toi 3 cap - vd Doan van: chon chu de -> chon bai ->
/// dich tung cau), KHONG mo them popup/route nao - xem giai thich chi tiet
/// trong VocabularyTopicsScreen (cung nguyen tac, dung lam mau). 2 nhanh
/// duoc tach thanh 2 widget rieng (_WritingVocabFlow/_WritingParagraphFlow)
/// tu quan ly buoc noi bo cua chinh no, chi bao ra ngoai (onExit) khi can
/// thoat het ve man chon che do nay.
class WritingHomeScreen extends StatefulWidget {
  const WritingHomeScreen({super.key});

  @override
  State<WritingHomeScreen> createState() => _WritingHomeScreenState();
}

class _WritingHomeScreenState extends State<WritingHomeScreen> {
  _WritingMode _mode = _WritingMode.select;

  void _exitToSelect() => setState(() => _mode = _WritingMode.select);

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _WritingMode.vocab:
        return _WritingVocabFlow(onExit: _exitToSelect);
      case _WritingMode.paragraph:
        return _WritingParagraphFlow(onExit: _exitToSelect);
      case _WritingMode.select:
        return _ModeSelect(
          onPickVocab: () => setState(() => _mode = _WritingMode.vocab),
          onPickParagraph: () => setState(() => _mode = _WritingMode.paragraph),
        );
    }
  }
}

class _ModeSelect extends ConsumerWidget {
  const _ModeSelect({required this.onPickVocab, required this.onPickParagraph});

  final VoidCallback onPickVocab;
  final VoidCallback onPickParagraph;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('writing_title'),
                        style: AppTextStyles.heading(size: 20),
                      ),
                      Text(
                        ref.tr('writing_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (persona != null) ...[
              const SizedBox(height: 12),
              const LearnerLevelBanner(),
            ],
            const SizedBox(height: 22),
            _WritingModeCard(
              icon: Icons.style_rounded,
              color: AppColors.purple,
              title: ref.tr('writing_mode_vocab_title'),
              desc: ref.tr('writing_mode_vocab_desc'),
              onTap: onPickVocab,
            ),
            const SizedBox(height: 14),
            _WritingModeCard(
              icon: Icons.short_text_rounded,
              color: AppColors.teal,
              title: ref.tr('writing_mode_paragraph_title'),
              desc: ref.tr('writing_mode_paragraph_desc'),
              onTap: onPickParagraph,
            ),
          ],
        ),
      ),
    );
  }
}

class _WritingModeCard extends StatelessWidget {
  const _WritingModeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: GlowBox(
          borderRadius: 24,
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading(size: 15)),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: AppTextStyles.muted(size: 11.5)
                          .copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _VocabFlowStep { topics, quiz }

/// Nhanh "Tu vung" (go tu tieng Anh) - 2 buoc: luoi chu de -> quiz go tu.
class _WritingVocabFlow extends StatefulWidget {
  const _WritingVocabFlow({required this.onExit});
  final VoidCallback onExit;

  @override
  State<_WritingVocabFlow> createState() => _WritingVocabFlowState();
}

class _WritingVocabFlowState extends State<_WritingVocabFlow> {
  _VocabFlowStep _step = _VocabFlowStep.topics;
  VocabTopic? _activeTopic;

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _VocabFlowStep.quiz:
        return WritingVocabQuizScreen(
          topic: _activeTopic!,
          onClose: () => setState(() => _step = _VocabFlowStep.topics),
          // Giu dung hanh vi cu (pop 2 lan tu quiz) - thoat het ve man chon
          // che do, khong dung o luoi chu de.
          onFinishToTopics: widget.onExit,
        );
      case _VocabFlowStep.topics:
        return WritingVocabTopicScreen(
          onBack: widget.onExit,
          onOpenTopic: (topic) => setState(() {
            _activeTopic = topic;
            _step = _VocabFlowStep.quiz;
          }),
        );
    }
  }
}

enum _ParagraphFlowStep { list, topicDetail, mixed, practice }

enum _PracticeOrigin { topic, mixed }

/// Nhanh "Doan van" - toi 3 buoc: chon chu de (hoac "On tong hop") -> chon
/// bai trong chu de do -> dich tung cau.
class _WritingParagraphFlow extends StatefulWidget {
  const _WritingParagraphFlow({required this.onExit});
  final VoidCallback onExit;

  @override
  State<_WritingParagraphFlow> createState() => _WritingParagraphFlowState();
}

class _WritingParagraphFlowState extends State<_WritingParagraphFlow> {
  _ParagraphFlowStep _step = _ParagraphFlowStep.list;
  WritingTopic? _activeTopic;
  WritingParagraph? _activeParagraph;
  _PracticeOrigin _practiceOrigin = _PracticeOrigin.topic;

  void _startFromTopic(WritingParagraph p) {
    setState(() {
      _activeParagraph = p;
      _practiceOrigin = _PracticeOrigin.topic;
      _step = _ParagraphFlowStep.practice;
    });
  }

  void _startFromMixed(WritingParagraph p) {
    setState(() {
      _activeParagraph = p;
      _practiceOrigin = _PracticeOrigin.mixed;
      _step = _ParagraphFlowStep.practice;
    });
  }

  void _closePractice() {
    setState(() {
      _step = _practiceOrigin == _PracticeOrigin.topic
          ? _ParagraphFlowStep.topicDetail
          : _ParagraphFlowStep.mixed;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _ParagraphFlowStep.practice:
        return WritingParagraphScreen(
          paragraph: _activeParagraph!,
          onClose: _closePractice,
          // Giu dung hanh vi cu (pop 2 lan tu day) - ve thang luoi chu de,
          // bo qua man chi tiet/danh sach vua mo bai.
          onDone: () => setState(() => _step = _ParagraphFlowStep.list),
        );
      case _ParagraphFlowStep.topicDetail:
        return WritingTopicParagraphsScreen(
          topic: _activeTopic!,
          onBack: () => setState(() => _step = _ParagraphFlowStep.list),
          onOpenParagraph: _startFromTopic,
        );
      case _ParagraphFlowStep.mixed:
        return WritingMixedParagraphListScreen(
          onBack: () => setState(() => _step = _ParagraphFlowStep.list),
          onOpenParagraph: _startFromMixed,
        );
      case _ParagraphFlowStep.list:
        return WritingParagraphListScreen(
          onBack: widget.onExit,
          onOpenTopic: (topic) => setState(() {
            _activeTopic = topic;
            _step = _ParagraphFlowStep.topicDetail;
          }),
          onOpenMixed: () => setState(() => _step = _ParagraphFlowStep.mixed),
        );
    }
  }
}
