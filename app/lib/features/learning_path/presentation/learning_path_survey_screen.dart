import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/learning_path_models.dart';

/// Popup khao sat 2 cau hoi de xac dinh persona nguoi hoc - xem
/// docs/research-learning-path.md muc 3. Cau 1 co 2/3 nhanh CHOT NGAY persona
/// (mat goc/on tap ngu phap), nhanh con lai moi sang cau 2 de chon theo muc
/// tieu. Luu xong dong popup, Home se tu highlight lai tile lien quan.
class LearningPathSurveyScreen extends ConsumerStatefulWidget {
  const LearningPathSurveyScreen({super.key});

  @override
  ConsumerState<LearningPathSurveyScreen> createState() =>
      _LearningPathSurveyScreenState();
}

class _LearningPathSurveyScreenState
    extends ConsumerState<LearningPathSurveyScreen> {
  bool _showSecondQuestion = false;

  Future<void> _choose(LearningPersona persona) async {
    await ref.read(learningPathRepositoryProvider).choosePersona(persona);
    ref.invalidate(learningPathChoiceProvider);
    if (mounted) Navigator.of(context).maybePop();
  }

  void _onFirstAnswer(int index) {
    switch (index) {
      case 0:
        _choose(LearningPersona.beginner);
      case 1:
        _choose(LearningPersona.grammarOverhaul);
      default:
        setState(() => _showSecondQuestion = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr('learning_path_survey_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('learning_path_survey_subtitle'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 18),
          if (!_showSecondQuestion) ...[
            Text(
              ref.tr('learning_path_q1_title'),
              style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _AnswerChip(
              label: ref.tr('learning_path_q1_a1'),
              onTap: () => _onFirstAnswer(0),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q1_a2'),
              onTap: () => _onFirstAnswer(1),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q1_a3'),
              onTap: () => _onFirstAnswer(2),
            ),
          ] else ...[
            Text(
              ref.tr('learning_path_q2_title'),
              style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a1'),
              onTap: () => _choose(LearningPersona.dailyConversation),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a2'),
              onTap: () => _choose(LearningPersona.officeEnglish),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a3'),
              onTap: () => _choose(LearningPersona.toeicPrep),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a4'),
              onTap: () => _choose(LearningPersona.ieltsPrep),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(size: 13.5, weight: FontWeight.w700),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
