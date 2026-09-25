import 'package:flutter/foundation.dart';

import '../../../core/i18n/app_language.dart';
import 'exercise_i18n.dart';
import 'exercise_model.dart';
import 'gym_vocabulary.dart';

/// Loai chuong trong "video" huong dan bai tap.
enum TutorialChapterKind { overview, step, keywords }

/// 1 chuong cua trinh phat huong dan (xem exercise_tutorial_player.dart).
@immutable
class TutorialChapter {
  const TutorialChapter({
    required this.kind,
    required this.narration,
    this.phrases = const [],
    this.vi = '',
    this.stepIndex = -1,
    this.practiceText = '',
  });

  final TutorialChapterKind kind;

  /// Cau may doc (tieng Anh).
  final String narration;

  /// Cau hien tren man hinh, chia thanh cum de sang dan theo giong doc.
  final List<String> phrases;

  /// Ban dich tieng Viet.
  final String vi;

  /// Chi so buoc (0-based) - chi co y nghia voi [TutorialChapterKind.step].
  final int stepIndex;

  /// Cau nguoi dung "Noi theo" (rong = chuong nay khong co luyen noi).
  final String practiceText;

  String get displayText => phrases.join();
}

/// Toan bo huong dan 1 bai: tong quan -> cac buoc -> tu khoa.
@immutable
class ExerciseTutorial {
  const ExerciseTutorial({
    required this.exercise,
    required this.chapters,
    required this.keywords,
  });

  final Exercise exercise;
  final List<TutorialChapter> chapters;
  final List<GymWord> keywords;
}

const _stepWords = ['one', 'two', 'three', 'four', 'five', 'six', 'seven'];

/// Chia cau thanh cum tai dau phay/cham/cham phay (giu dau + khoang trang
/// o cuoi moi cum de ghep lai dung nguyen van).
List<String> splitPhrases(String text) {
  final result = <String>[];
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    buffer.write(ch);
    final atBreak = ch == ',' || ch == '.' || ch == ';' || ch == '!';
    final nextIsSpace = i + 1 < text.length && text[i + 1] == ' ';
    if (atBreak && (nextIsSpace || i + 1 == text.length)) {
      if (nextIsSpace) {
        buffer.write(' ');
        i++;
      }
      result.add(buffer.toString());
      buffer.clear();
    }
  }
  if (buffer.isNotEmpty) result.add(buffer.toString());
  return result.where((p) => p.trim().isNotEmpty).toList();
}

/// Thoi diem (giay, tinh tu luc bat dau doc [narration]) moi cum trong
/// [phrases] bat dau duoc doc - uoc luong theo so ky tu vi TTS khong bao
/// tien do tung tu. [lead] = phan doc truoc cac cum (vd "Step one. ").
List<double> phraseStartTimes({
  required String lead,
  required List<String> phrases,
  required double totalSeconds,
}) {
  final total = lead.length + phrases.fold<int>(0, (n, p) => n + p.length);
  if (total == 0) return List.filled(phrases.length, 0);
  var chars = lead.length;
  final times = <double>[];
  for (final p in phrases) {
    times.add(totalSeconds * chars / total);
    chars += p.length;
  }
  return times;
}

/// Thoi gian doc uoc luong (giay) cho [text] o toc do [speed] (1 = binh
/// thuong ~14 ky tu/giay).
double estimateSpeechSeconds(String text, {double speed = 1}) =>
    text.length / (14.0 * speed) + 0.4;

/// Dung huong dan tu du lieu bai tap co san: tong quan (ten + nhom co), tung
/// buoc (tieng Anh + tieng Viet, co "Noi theo"), va 3 tu khoa - uu tien tu
/// XUAT HIEN trong cau huong dan, roi tu cung nhom co, tu chua thuoc truoc.
ExerciseTutorial buildExerciseTutorial(
  Exercise exercise, {
  Map<String, int> boxes = const {},
  int keywordCount = 3,
}) {
  final muscles = [exercise.primaryMuscle, ...exercise.secondaryMuscles]
      .take(3)
      .map(
        // "Dui truoc · chinh" -> bo hau to vai tro, chi lay ten nhom co.
        (m) => exerciseMuscleLabel(
          m.split(' · ').first.trim(),
          AppLanguage.en,
        ).toLowerCase(),
      );
  final muscleList = _joinEnglish(muscles.toList());
  final overview =
      "Today's exercise: the ${exercise.nameEn}."
      '${muscleList.isEmpty ? '' : ' It works your $muscleList.'}';

  final stepsEn = exercise.instructionsEn.isNotEmpty
      ? exercise.instructionsEn
      : exercise.instructions;
  final chapters = <TutorialChapter>[
    TutorialChapter(
      kind: TutorialChapterKind.overview,
      narration: overview,
      phrases: splitPhrases(overview),
    ),
    for (var i = 0; i < stepsEn.length; i++)
      TutorialChapter(
        kind: TutorialChapterKind.step,
        stepIndex: i,
        narration:
            'Step ${i < _stepWords.length ? _stepWords[i] : '${i + 1}'}. '
            '${stepsEn[i]}',
        phrases: splitPhrases(stepsEn[i]),
        vi: i < exercise.instructions.length ? exercise.instructions[i] : '',
        practiceText: stepsEn[i],
      ),
  ];

  final text = stepsEn.join(' ').toLowerCase();
  final candidates = pickGymWords(
    exercises: [exercise],
    boxes: boxes,
    count: 30,
  ).where((w) => w.key != exercise.nameEn.toLowerCase()).toList();
  final indexed = candidates.indexed.toList()
    ..sort((a, b) {
      final inA = text.contains(a.$2.key) ? 0 : 1;
      final inB = text.contains(b.$2.key) ? 0 : 1;
      return inA != inB ? inA - inB : a.$1 - b.$1;
    });
  final keywords = indexed.take(keywordCount).map((e) => e.$2).toList();
  if (keywords.isNotEmpty) {
    chapters.add(
      TutorialChapter(
        kind: TutorialChapterKind.keywords,
        narration: keywords.map((w) => w.en).join('. '),
      ),
    );
  }
  return ExerciseTutorial(
    exercise: exercise,
    chapters: chapters,
    keywords: keywords,
  );
}

String _joinEnglish(List<String> items) {
  final unique = <String>[];
  for (final item in items) {
    if (item.isNotEmpty && !unique.contains(item)) unique.add(item);
  }
  if (unique.length <= 1) return unique.join();
  return '${unique.sublist(0, unique.length - 1).join(', ')} '
      'and ${unique.last}';
}
