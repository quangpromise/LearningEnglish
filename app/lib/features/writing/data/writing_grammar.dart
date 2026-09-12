import '../../learning_path/data/learning_path_models.dart';

/// Nhan thi/cau truc ngu phap dung trong ngan hang bai Doan van theo cap -
/// gia tri chuoi TRUNG voi kAllTenseLabels (writing_paragraph_data.dart) cho
/// 12 thi, them vai cau truc khac. Thu tu cap hoc bam theo trinh tu ngu phap
/// CEFR (British Council/EAQUALS Core Inventory, Cambridge English Grammar
/// Profile) - xem docs/research-level-based-content.md muc 4b.
abstract final class G {
  static const presentSimple = 'Hiện tại đơn';
  static const presentContinuous = 'Hiện tại tiếp diễn';
  static const pastSimple = 'Quá khứ đơn';
  static const futureSimple = 'Tương lai đơn';
  static const goingTo = 'Tương lai gần (going to)';
  static const modal = 'Động từ khuyết thiếu (can/should/must)';

  static const presentPerfect = 'Hiện tại hoàn thành';
  static const pastContinuous = 'Quá khứ tiếp diễn';
  static const comparison = 'So sánh hơn / so sánh nhất';
  static const conditional1 = 'Câu điều kiện loại 1';
  static const passive = 'Câu bị động';

  static const presentPerfectContinuous = 'Hiện tại hoàn thành tiếp diễn';
  static const pastPerfect = 'Quá khứ hoàn thành';
  static const pastPerfectContinuous = 'Quá khứ hoàn thành tiếp diễn';
  static const futureContinuous = 'Tương lai tiếp diễn';
  static const futurePerfect = 'Tương lai hoàn thành';
  static const conditional2 = 'Câu điều kiện loại 2';
  static const conditional3 = 'Câu điều kiện loại 3';
  static const relativeClause = 'Mệnh đề quan hệ';
  static const reportedSpeech = 'Câu tường thuật';
}

const _basicLabels = {
  G.presentSimple,
  G.presentContinuous,
  G.pastSimple,
  G.futureSimple,
  G.goingTo,
  G.modal,
};

const _intermediateLabels = {
  ..._basicLabels,
  G.presentPerfect,
  G.pastContinuous,
  G.comparison,
  G.conditional1,
  G.passive,
};

const _advancedLabels = {
  ..._intermediateLabels,
  G.presentPerfectContinuous,
  G.pastPerfect,
  G.pastPerfectContinuous,
  G.futureContinuous,
  G.futurePerfect,
  G.conditional2,
  G.conditional3,
  G.relativeClause,
  G.reportedSpeech,
};

/// Cau truc DUOC PHEP dung o moi cap (cap cao gom ca cau truc cap thap) -
/// test kiem tra khong soan nham cau qua kho vao cap duoi.
const kGrammarLabelsByLevel = <LearnerLevel, Set<String>>{
  LearnerLevel.basic: _basicLabels,
  LearnerLevel.intermediate: _intermediateLabels,
  LearnerLevel.advanced: _advancedLabels,
};

/// Gioi han do dai cau (so tu) va so cau/bai theo cap - muc 4b cua tai lieu
/// nghien cuu, noi rong 1-2 tu de khong ep cau tieng Anh thanh guong gao.
const kWordsPerSentenceByLevel = <LearnerLevel, (int, int)>{
  LearnerLevel.basic: (3, 10),
  LearnerLevel.intermediate: (5, 15),
  LearnerLevel.advanced: (8, 24),
};

const kSentencesPerParagraphByLevel = <LearnerLevel, (int, int)>{
  LearnerLevel.basic: (4, 5),
  LearnerLevel.intermediate: (5, 6),
  LearnerLevel.advanced: (6, 7),
};
