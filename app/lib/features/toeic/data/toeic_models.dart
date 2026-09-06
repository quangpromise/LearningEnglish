import 'package:flutter/material.dart';

/// 7 phan cua 1 de thi TOEIC that - Part 1-4 la Listening, Part 5-7 la
/// Reading (xem extension `skill` ben duoi).
enum ToeicPartNumber { p1, p2, p3, p4, p5, p6, p7 }

extension ToeicPartNumberX on ToeicPartNumber {
  ToeicSkill get skill =>
      index <= 3 ? ToeicSkill.listening : ToeicSkill.reading;

  /// So thu tu hien thi ("Part 1", "Part 2"...) - trung voi index+1.
  int get displayNumber => index + 1;

  /// Key i18n cho mo ta ngan gon dang lam cua tung Part (xem cac key
  /// `toeic_part_N_desc` trong app_strings.dart) - hien ngay duoi tieu de
  /// Part trong man thi (toeic_exam_screen.dart), tu doi theo ngon ngu app
  /// dang chon (KHONG hardcode 1 ngon ngu) de nguoi lam de biet minh dang
  /// lam dang bai nao ma khong can nho thu tu 7 Part.
  String get descriptionKey => 'toeic_part_${index + 1}_desc';
}

enum ToeicSkill { listening, reading }

/// 1 icon duoc dat trong "anh" minh hoa Part 1 - vi tri tinh theo ty le
/// (0.0-1.0) trong khung AspectRatio(16/9) cua
/// toeic_part_scene_illustration.dart, giong cach lam cua
/// story_illustration.dart. KHONG dung anh chup that de tranh rui ro ban
/// quyen (xem CLAUDE.md).
class ToeicSceneIcon {
  const ToeicSceneIcon({
    required this.icon,
    required this.dx,
    required this.dy,
    this.size = 48,
  });

  final IconData icon;
  final double dx;
  final double dy;
  final double size;
}

class ToeicIllustrationSpec {
  const ToeicIllustrationSpec({
    required this.backgroundColor,
    required this.icons,
    this.imageAssetPath,
  });

  final Color backgroundColor;
  final List<ToeicSceneIcon> icons;

  /// Neu co (vd 'assets/toeic/p1-q1.jpg') - anh THAT do nguoi dung tu tao
  /// bang Gemini AI (goc hoan toan, khong phai stock photo) se duoc uu
  /// tien hien thi thay cho phan ve bang Icon (xem
  /// toeic_part_scene_illustration.dart).
  final String? imageAssetPath;
}

/// 1 cau/luot noi trong doan hoi thoai/bai noi Part 1-4 - `speakerIndex`
/// (0/1/2) duoc anh xa sang 1 trong 3 muc pitch cua AppTts
/// (pitchSpeakerA/B/pitchNarrator) de mo phong nhieu nguoi noi khac nhau.
class ToeicAudioLine {
  const ToeicAudioLine({required this.speakerIndex, required this.textEn});

  final int speakerIndex;
  final String textEn;
}

/// 1 doan am thanh (hoi thoai Part 3, bai noi Part 4, hoac 4 phuong an doc
/// lien tuc cua Part 1/cau hoi+3 phuong an cua Part 2) - nhieu ToeicQuestion
/// co the cung tro toi 1 script qua `audioScriptId` (Part 3/4: 1 hoi
/// thoai/bai noi dung chung cho 2-3 cau hoi).
class ToeicAudioScript {
  const ToeicAudioScript({
    required this.id,
    required this.lines,
    this.speakerLabels = const [],
  });

  final String id;
  final List<ToeicAudioLine> lines;

  /// Nhan hien thi tren UI (vd ['Man', 'Woman']) - CHI de hien chu, khong
  /// anh huong toi cach doc TTS.
  final List<String> speakerLabels;
}

/// 1 doan van doc hieu Part 6/7 - co the la 1 doan (single passage), 2 doan
/// (double passage) hoac 3 doan (triple passage) trong `textsEn`. Nhieu
/// ToeicQuestion co the cung tro toi 1 passage qua `passageId`.
class ToeicPassage {
  const ToeicPassage({
    required this.id,
    required this.titleEn,
    required this.textsEn,
  });

  final String id;
  final String titleEn;
  final List<String> textsEn;
}

/// Don vi lap DUY NHAT cho man thi (toeic_exam_screen.dart) - flat list
/// xuyen suot ca 7 phan theo dung thu tu, KHONG phan cay theo nhom. Cau
/// hoi Part 3/4 tro chung 1 `audioScriptId`, cau hoi Part 6/7 tro chung 1
/// `passageId` - man thi chi can so sanh voi cau truoc do de biet co can
/// phat lai audio/hien lai doan van hay khong.
class ToeicQuestion {
  const ToeicQuestion({
    required this.id,
    required this.part,
    required this.options,
    required this.correctIndex,
    required this.explanationVi,
    this.promptEn,
    this.illustration,
    this.audioScriptId,
    this.passageId,
  });

  /// Slug on dinh, khong tai su dung giua cac cau/de (vd 'p1-q1').
  final String id;
  final ToeicPartNumber part;

  /// Part 2 chi co 3 phuong an (A-C), cac phan con lai co 4 (A-D).
  final List<String> options;
  final int correctIndex;

  /// Text thuan tieng Viet (KHONG qua i18n) - dang
  /// "· Câu hỏi: ... · Đáp án: ... · Giải thích: ... · Dịch: ...", cung
  /// dinh dang voi phan giai thich Part 5 trong file PDF tham khao.
  final String explanationVi;

  /// Part 5: cau co cho trong; Part 2: cau hoi duoc doc len (hien text de
  /// nguoi lam quen dan, that ra TOEIC that Part 2 khong hien text nay).
  final String? promptEn;

  /// Chi Part 1 - "anh" minh hoa ve bang Icon.
  final ToeicIllustrationSpec? illustration;

  /// Part 1-4 - id tro vao ToeicTest.audioScripts.
  final String? audioScriptId;

  /// Part 6-7 - id tro vao ToeicTest.passages.
  final String? passageId;
}

class ToeicTest {
  const ToeicTest({
    required this.id,
    required this.titleVi,
    required this.questions,
    required this.audioScripts,
    required this.passages,
  });

  final String id;
  final String titleVi;

  /// FLAT list, thu tu Part1..Part7.
  final List<ToeicQuestion> questions;
  final Map<String, ToeicAudioScript> audioScripts;
  final Map<String, ToeicPassage> passages;

  List<ToeicQuestion> questionsForPart(ToeicPartNumber p) =>
      questions.where((q) => q.part == p).toList(growable: false);

  List<ToeicQuestion> get listeningQuestions => questions
      .where((q) => q.part.skill == ToeicSkill.listening)
      .toList(growable: false);

  List<ToeicQuestion> get readingQuestions => questions
      .where((q) => q.part.skill == ToeicSkill.reading)
      .toList(growable: false);
}
