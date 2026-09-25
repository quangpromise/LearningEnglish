import 'dart:math';

import '../../learning_path/data/learning_path_models.dart';
import 'exercise_model.dart';

/// Kich ban "HLV dan buoi tap bang tieng Anh": sinh cau noi cho tung thoi
/// diem (bat dau bai, bat dau set, giua nghi, ket thuc buoi) theo trinh do
/// nguoi hoc - co ban: cau ngan, tu thong dung; nang cao: cau tu nhien hon.
///
/// Thuan Dart (khong phu thuoc TTS/UI) de test duoc; man tap chi viec doc.
class CoachScript {
  CoachScript({this.level, Random? random}) : _random = random ?? Random();

  /// Trinh do tu "Goi y lo trinh" (null = trung cap).
  final LearnerLevel? level;
  final Random _random;

  bool get _basic => level == LearnerLevel.basic;
  bool get _advanced => level == LearnerLevel.advanced;

  String _pick(List<String> options) =>
      options[_random.nextInt(options.length)];

  /// Luc bat dau 1 bai tap moi (set dau tien).
  String exerciseIntro(Exercise exercise, {required int sets}) {
    final name = exercise.nameEn;
    if (_basic) return 'Next exercise: $name. $sets sets.';
    if (_advanced) {
      return _pick([
        "Alright, let's move on to $name. We've got $sets sets to crush.",
        'Up next is $name, $sets sets. Focus on quality over speed.',
      ]);
    }
    return _pick([
      "Let's do $name. You have $sets sets.",
      'Next up: $name, $sets sets. You can do it!',
    ]);
  }

  /// Nhac ky thuat - lay tu huong dan tieng Anh cua bai (cau ngan nhat de
  /// de nghe), xoay vong theo [setNumber] de moi set nghe 1 cau khac.
  String? formCue(Exercise exercise, {required int setNumber}) {
    final steps = exercise.instructionsEn
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (steps.isEmpty) return null;
    final sorted = [...steps]..sort((a, b) => a.length - b.length);
    // Co ban: chi dung cac cau ngan nhat.
    final pool = _basic ? sorted.take(2).toList() : steps;
    final cue = pool[(setNumber - 1) % pool.length];
    return _basic ? 'Remember: $cue' : 'Coach tip: $cue';
  }

  /// Luc bat dau 1 set.
  String setStart({
    required int setNumber,
    required int totalSets,
    required int repsMin,
    required int repsMax,
  }) {
    final reps = repsMin == repsMax ? '$repsMin' : '$repsMin to $repsMax';
    if (setNumber == totalSets) {
      return _basic
          ? 'Last set. $reps reps.'
          : _pick([
              'Last set! Give me $reps strong reps.',
              'Final set, $reps reps. Finish strong!',
            ]);
    }
    return _basic
        ? 'Set $setNumber. $reps reps.'
        : 'Set $setNumber of $totalSets. Aim for $reps reps.';
  }

  /// Giua luc nghi (con khoang nua thoi gian) - hoi/nhac nhe de nguoi hoc
  /// nghe them tieng Anh.
  String restMiddle() {
    if (_basic) {
      return _pick([
        'Drink some water.',
        'Breathe slowly.',
        'Relax your shoulders.',
      ]);
    }
    if (_advanced) {
      return _pick([
        'How did that last set feel? Keep your breathing steady.',
        'Shake out your arms and stay loose. Almost there.',
        "Take a sip of water. We're halfway through your rest.",
      ]);
    }
    return _pick([
      'Take a sip of water and breathe.',
      'Good job so far. Stay focused.',
      'Relax your muscles. Half of your rest is done.',
    ]);
  }

  /// Ket thuc buoi.
  String workoutDone({required int sets, required int words}) {
    final wordsPart = words > 0 ? ' and reviewed $words words' : '';
    return _basic
        ? 'Great job! You did $sets sets$wordsPart.'
        : 'Amazing work! You finished $sets sets$wordsPart today. '
              'See you next time!';
  }
}
