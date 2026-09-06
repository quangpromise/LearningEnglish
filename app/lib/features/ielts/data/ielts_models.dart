/// Phan/section cua 1 de IELTS - Reading co 3 bai doc (r1-r3), Listening co
/// 4 phan (l1-l4). Khac TOEIC (7 "Part" danh so lien tuc), IELTS chia theo
/// tung ky nang ro rang nen dung enum rieng + extension `skill` de biet
/// thuoc Reading hay Listening.
enum IeltsSectionNumber { r1, r2, r3, l1, l2, l3, l4 }

enum IeltsSkill { reading, listening }

extension IeltsSectionNumberX on IeltsSectionNumber {
  IeltsSkill get skill =>
      index <= 2 ? IeltsSkill.reading : IeltsSkill.listening;

  /// "Bài đọc 1"/"Phần 1" - so thu tu hien thi trong pham vi ky nang cua no
  /// (Reading: 1-3, Listening: 1-4), KHONG phai index toan cuc.
  int get displayNumber => skill == IeltsSkill.reading ? index + 1 : index - 2;
}

/// Cach 1 IeltsQuestion duoc tra loi/cham diem - khac TOEIC (luon la trac
/// nghiem), IELTS Reading/Listening co dang dien tu tu do (Sentence/Summary
/// Completion) khong chon tu danh sach co san.
enum IeltsAnswerType { multipleChoice, shortAnswer }

/// 1 cau/luot noi Listening - giong het ToeicAudioLine, dung chung
/// AppTts.pitchSpeakerA/B/pitchNarrator de mo phong nhieu nguoi noi.
class IeltsAudioLine {
  const IeltsAudioLine({required this.speakerIndex, required this.textEn});

  final int speakerIndex;
  final String textEn;
}

/// 1 doan audio Listening (1 phan/section) - nhieu IeltsQuestion cung tro
/// toi 1 script qua `audioScriptId`.
class IeltsAudioScript {
  const IeltsAudioScript({
    required this.id,
    required this.lines,
    this.speakerLabels = const [],
  });

  final String id;
  final List<IeltsAudioLine> lines;
  final List<String> speakerLabels;
}

/// 1 bai doc Reading - giu dang `List<String>` cac doan (khong phai 1 String
/// dai) de ho tro dang cau hoi "Matching Information" (chon dung doan A/B/
/// C... chua thong tin nao do).
class IeltsPassage {
  const IeltsPassage({
    required this.id,
    required this.titleEn,
    required this.paragraphsEn,
  });

  final String id;
  final String titleEn;
  final List<String> paragraphsEn;
}

/// Don vi lap DUY NHAT cho man thi (ielts_exam_screen.dart) - flat list,
/// giong het cach ToeicQuestion duoc thiet ke. `groupInstructionEn` lap lai
/// tren MOI cau trong cung 1 nhom (giong cach audioScriptId/passageId lap
/// lai) - man thi chi can so voi cau truoc do de biet co hien lai dong
/// huong dan/doan van/audio hay khong.
class IeltsQuestion {
  const IeltsQuestion({
    required this.id,
    required this.section,
    required this.answerType,
    required this.explanationVi,
    this.options = const [],
    this.correctIndex,
    this.acceptedAnswers = const [],
    this.promptEn,
    this.groupInstructionEn,
    this.audioScriptId,
    this.passageId,
  });

  final String id;
  final IeltsSectionNumber section;
  final IeltsAnswerType answerType;

  /// Text thuan tieng Viet (KHONG qua i18n).
  final String explanationVi;

  /// Dung khi answerType == multipleChoice - bao gom ca True/False/Not
  /// Given, Yes/No/Not Given (3 lua chon co dinh) va Matching Headings
  /// (nhieu cau dung CHUNG 1 danh sach dai hon so cau, co decoy).
  final List<String> options;
  final int? correctIndex;

  /// Dung khi answerType == shortAnswer - 1 hoac nhieu dap an duoc chap
  /// nhan (vd ['12', 'twelve']), so sanh khong phan biet hoa/thuong qua
  /// isShortAnswerCorrect() trong ielts_scoring.dart.
  final List<String> acceptedAnswers;

  final String? promptEn;
  final String? groupInstructionEn;
  final String? audioScriptId;
  final String? passageId;
}

class IeltsTest {
  const IeltsTest({
    required this.id,
    required this.titleVi,
    required this.questions,
    required this.audioScripts,
    required this.passages,
  });

  final String id;
  final String titleVi;

  /// FLAT list, thu tu Reading (r1-r3) roi Listening (l1-l4).
  final List<IeltsQuestion> questions;
  final Map<String, IeltsAudioScript> audioScripts;
  final Map<String, IeltsPassage> passages;

  List<IeltsQuestion> questionsForSection(IeltsSectionNumber s) =>
      questions.where((q) => q.section == s).toList(growable: false);

  List<IeltsQuestion> get readingQuestions => questions
      .where((q) => q.section.skill == IeltsSkill.reading)
      .toList(growable: false);

  List<IeltsQuestion> get listeningQuestions => questions
      .where((q) => q.section.skill == IeltsSkill.listening)
      .toList(growable: false);
}
