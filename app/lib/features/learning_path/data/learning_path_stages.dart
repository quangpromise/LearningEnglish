import 'learning_path_models.dart';

/// Tinh nang dich cua 1 stage trong lo trinh - man hinh
/// `learning_path_screen.dart` (presentation) se anh xa gia tri nay sang
/// widget/screen that su can mo (dung lai `openAppPopup`/`Navigator.push`
/// nhu cac noi khac trong app) - file data nay KHONG import widget de giu
/// dung quy uoc feature-first (data khong phu thuoc presentation).
enum LearningPathTarget {
  vocabulary,
  grammar,
  phonics,
  pronunciation,
  story,
  reading,
  writingVocab,
  writingParagraph,
  quiz,
  toeic,
  ielts,
  aiVoiceChat,
}

/// 1 buoc (stage) trong lo trinh cua 1 persona - xem
/// docs/research-learning-path.md muc 4. [titleKey]/[descKey] la key dang ky
/// trong app_strings.dart (khong hardcode chuoi o day). [target] quyet dinh
/// nut "Mo tinh nang" mo man nao.
class LearningPathStage {
  const LearningPathStage({
    required this.titleKey,
    required this.descKey,
    required this.target,
  });

  final String titleKey;
  final String descKey;
  final LearningPathTarget target;
}

/// Lo trinh 5-6 buoc TUAN TU cho tung persona - CHI tro toi tinh nang da co
/// san, KHONG khoa buoc sau du buoc truoc chua hoan thanh (nguoi dung bam
/// duoc bat ky buoc nao). Ten chu de Ngu phap/Tu vung nhac toi trong mo ta
/// (descKey) lay DUNG tu grammar_data.dart/vocabulary_data.dart that dang co
/// trong code (doc lai 2 file do truoc khi sua danh sach nay).
const kLearningPathStages = <LearningPersona, List<LearningPathStage>>{
  // A - Mat goc: xem docs/research-learning-path.md muc 4 "A - Mat goc".
  LearningPersona.beginner: [
    LearningPathStage(
      titleKey: 'lp_stage_beginner_1_title',
      descKey: 'lp_stage_beginner_1_desc',
      target: LearningPathTarget.phonics,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_beginner_2_title',
      descKey: 'lp_stage_beginner_2_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_beginner_3_title',
      descKey: 'lp_stage_beginner_3_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_beginner_4_title',
      descKey: 'lp_stage_beginner_4_desc',
      target: LearningPathTarget.story,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_beginner_5_title',
      descKey: 'lp_stage_beginner_5_desc',
      target: LearningPathTarget.writingVocab,
    ),
  ],

  // B - Giao tiep hang ngay.
  LearningPersona.dailyConversation: [
    LearningPathStage(
      titleKey: 'lp_stage_daily_1_title',
      descKey: 'lp_stage_daily_1_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_daily_2_title',
      descKey: 'lp_stage_daily_2_desc',
      target: LearningPathTarget.pronunciation,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_daily_3_title',
      descKey: 'lp_stage_daily_3_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_daily_4_title',
      descKey: 'lp_stage_daily_4_desc',
      target: LearningPathTarget.aiVoiceChat,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_daily_5_title',
      descKey: 'lp_stage_daily_5_desc',
      target: LearningPathTarget.story,
    ),
  ],

  // C - Tieng Anh cong so.
  LearningPersona.officeEnglish: [
    LearningPathStage(
      titleKey: 'lp_stage_office_1_title',
      descKey: 'lp_stage_office_1_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_office_2_title',
      descKey: 'lp_stage_office_2_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_office_3_title',
      descKey: 'lp_stage_office_3_desc',
      target: LearningPathTarget.writingVocab,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_office_4_title',
      descKey: 'lp_stage_office_4_desc',
      target: LearningPathTarget.writingParagraph,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_office_5_title',
      descKey: 'lp_stage_office_5_desc',
      target: LearningPathTarget.aiVoiceChat,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_office_6_title',
      descKey: 'lp_stage_office_6_desc',
      target: LearningPathTarget.reading,
    ),
  ],

  // D - On tap toan dien (ngu phap).
  LearningPersona.grammarOverhaul: [
    LearningPathStage(
      titleKey: 'lp_stage_grammar_1_title',
      descKey: 'lp_stage_grammar_1_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_grammar_2_title',
      descKey: 'lp_stage_grammar_2_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_grammar_3_title',
      descKey: 'lp_stage_grammar_3_desc',
      target: LearningPathTarget.quiz,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_grammar_4_title',
      descKey: 'lp_stage_grammar_4_desc',
      target: LearningPathTarget.writingParagraph,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_grammar_5_title',
      descKey: 'lp_stage_grammar_5_desc',
      target: LearningPathTarget.reading,
    ),
  ],

  // E - Luyen thi TOEIC.
  LearningPersona.toeicPrep: [
    LearningPathStage(
      titleKey: 'lp_stage_toeic_1_title',
      descKey: 'lp_stage_toeic_1_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_toeic_2_title',
      descKey: 'lp_stage_toeic_2_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_toeic_3_title',
      descKey: 'lp_stage_toeic_3_desc',
      target: LearningPathTarget.phonics,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_toeic_4_title',
      descKey: 'lp_stage_toeic_4_desc',
      target: LearningPathTarget.toeic,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_toeic_5_title',
      descKey: 'lp_stage_toeic_5_desc',
      target: LearningPathTarget.toeic,
    ),
  ],

  // F - Luyen thi IELTS.
  LearningPersona.ieltsPrep: [
    LearningPathStage(
      titleKey: 'lp_stage_ielts_1_title',
      descKey: 'lp_stage_ielts_1_desc',
      target: LearningPathTarget.vocabulary,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_ielts_2_title',
      descKey: 'lp_stage_ielts_2_desc',
      target: LearningPathTarget.grammar,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_ielts_3_title',
      descKey: 'lp_stage_ielts_3_desc',
      target: LearningPathTarget.writingParagraph,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_ielts_4_title',
      descKey: 'lp_stage_ielts_4_desc',
      target: LearningPathTarget.ielts,
    ),
    LearningPathStage(
      titleKey: 'lp_stage_ielts_5_title',
      descKey: 'lp_stage_ielts_5_desc',
      target: LearningPathTarget.story,
    ),
  ],
};
