import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/learning_path_models.dart';
import 'learning_path_accent.dart';

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
    // choosePersona() KHONG con nem loi ra ngoai (da bat loi trong
    // repository) - truoc day neu luu that bai (vd bang chua duoc migrate
    // len server) thi await nay khong bao gio ket thuc thanh cong, khien
    // Navigator.pop() ben duoi khong bao gio chay -> nguoi dung tuong nhu
    // "bam khong duoc" du GestureDetector van nhan tap binh thuong.
    await ref.read(learningPathRepositoryProvider).choosePersona(persona);
    if (!mounted) return;
    ref.invalidate(learningPathChoiceProvider);
    Navigator.of(context).maybePop();
  }

  /// Nguoi dung chon "Tu hoc" - tat het highlight/goi y tren Home (khac voi
  /// chi dong popup ma khong chon gi: neu TRUOC DO da co persona duoc luu,
  /// dong popup khong lam mat highlight cu - phai goi turnOff() de xoa han).
  Future<void> _turnOff() async {
    await ref.read(learningPathRepositoryProvider).turnOff();
    if (!mounted) return;
    ref.invalidate(learningPathChoiceProvider);
    Navigator.of(context).maybePop();
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
              color: personaColor(LearningPersona.beginner),
              onTap: () => _onFirstAnswer(0),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q1_a2'),
              color: personaColor(LearningPersona.grammarOverhaul),
              onTap: () => _onFirstAnswer(1),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              // Dap an "de sau moi chon" - chua chot persona nao nen dung
              // mau trung tinh (khong phai mau cua 1 persona cu the).
              label: ref.tr('learning_path_q1_a3'),
              color: AppColors.textMuted,
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
              color: personaColor(LearningPersona.dailyConversation),
              onTap: () => _choose(LearningPersona.dailyConversation),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a2'),
              color: personaColor(LearningPersona.officeEnglish),
              onTap: () => _choose(LearningPersona.officeEnglish),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a3'),
              color: personaColor(LearningPersona.toeicPrep),
              onTap: () => _choose(LearningPersona.toeicPrep),
            ),
            const SizedBox(height: 8),
            _AnswerChip(
              label: ref.tr('learning_path_q2_a4'),
              color: personaColor(LearningPersona.ieltsPrep),
              onTap: () => _choose(LearningPersona.ieltsPrep),
            ),
          ],
          const SizedBox(height: 16),
          // Luon hien o CA 2 buoc (khong chi Cau 1) - nguoi dung co the doi
          // y sang Cau 2 roi van muon tat gui y thay vi chon tiep 1 muc tieu.
          Center(
            child: GestureDetector(
              onTap: _turnOff,
              child: Text(
                ref.tr('learning_path_turn_off'),
                style: AppTextStyles.muted(size: 12.5)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;

  /// Mau rieng cua persona ma dap an nay dan toi - dung to mau CHU (khong
  /// chi vien) de nguoi dung phan biet ro cac lua chon ngay ca khi luot
  /// nhanh, thay vi moi dong deu mau trang giong het nhau nhu truoc.
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
