import '../../fitness/data/program_model.dart';

/// Muc tieu tap luyen chon o bang "Thiet lap GymTalk".
enum FitnessGoal {
  buildMuscle,
  loseFat,
  getStronger;

  String get labelKey => switch (this) {
    FitnessGoal.buildMuscle => 'setup_goal_muscle',
    FitnessGoal.loseFat => 'setup_goal_fat_loss',
    FitnessGoal.getStronger => 'setup_goal_strength',
  };
}

/// Cau tra loi cua nguoi dung o bang thiet lap.
class GymTalkSetupAnswers {
  const GymTalkSetupAnswers({
    required this.goal,
    required this.difficulty,
    required this.daysPerWeek,
    required this.atHome,
  });

  final FitnessGoal goal;
  final ProgramDifficulty difficulty;
  final int daysPerWeek;

  /// Tap tai nha (khong co phong gym).
  final bool atHome;
}

/// Diem phu hop cua 1 giao an voi cau tra loi - cao hon la hop hon. Tach
/// rieng de test; bo giao an hien chi co vai bai nen luat don gian, ro rang.
int scoreProgram(Program program, GymTalkSetupAnswers answers) {
  var score = 0;
  final tags = program.tags.map((t) => t.toLowerCase()).toList();
  final title = '${program.titleVi} ${program.titleEn}'.toLowerCase();
  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  switch (answers.goal) {
    case FitnessGoal.buildMuscle:
      if (hasTag('Tăng cơ')) score += 3;
    case FitnessGoal.loseFat:
      if (hasTag('Giảm mỡ')) score += 3;
    case FitnessGoal.getStronger:
      if (hasTag('Tăng cơ')) score += 1;
      if (title.contains('strength') || title.contains('sức mạnh')) {
        score += 3;
      }
  }

  final atHomeProgram = hasTag('Tại nhà') || program.equipment == 'Tại nhà';
  if (answers.atHome) {
    // Khong co dung cu phong gym -> giao an phong gym gan nhu khong tap duoc.
    score += atHomeProgram ? 4 : -4;
  } else if (!atHomeProgram) {
    score += 1;
  }

  final difficulty = program.difficulty;
  if (difficulty == null) {
    score += 1; // "Moi trinh do".
  } else if (difficulty == answers.difficulty) {
    score += 2;
  } else {
    score -= (difficulty.steps - answers.difficulty.steps).abs();
  }

  score -= (program.sessionsPerWeek - answers.daysPerWeek).abs();
  return score;
}

/// Giao an hop nhat (null neu danh sach rong). Hoa diem -> giu thu tu goc.
Program? recommendProgram(List<Program> programs, GymTalkSetupAnswers answers) {
  Program? best;
  var bestScore = -1 << 30;
  for (final program in programs) {
    final score = scoreProgram(program, answers);
    if (score > bestScore) {
      best = program;
      bestScore = score;
    }
  }
  return best;
}
