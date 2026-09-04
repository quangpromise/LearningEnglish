/// 1 bai tap duoc gan vao 1 ngay cua chuong trinh - chi tham chieu
/// [exerciseId] (khop voi `Exercise.id` trong exercises_seed.json), KHONG
/// nhung lai toan bo thong tin bai tap (ten/anh/huong dan...) de tranh
/// trung lap du lieu - man hinh tu join sang [Exercise] khi hien thi.
class ProgramExerciseRef {
  const ProgramExerciseRef({
    required this.exerciseId,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.orderIndex,
    this.supersetGroup,
  });

  final int exerciseId;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int orderIndex;

  /// Danh dau ghep sieu set (2 bai lien tiep khong nghi giua) - GIU CHO o
  /// model tu Phase 2 nay de khong phai doi schema lan 2, nhung CHUA co UI/
  /// logic ghep cap nao doc field nay (xem CLAUDE.md/ke hoach Fitness Phase
  /// 2: superset la viec cua phase sau). Luon null o phien ban nay.
  final String? supersetGroup;
}

/// 1 ngay trong lich tuan cua 1 chuong trinh - [dayOfWeek] theo chuan ISO
/// (1 = Thu Hai ... 7 = Chu Nhat). [exercises] rong nghia la ngay nghi.
class ProgramDay {
  const ProgramDay({required this.dayOfWeek, required this.exercises});

  final int dayOfWeek;
  final List<ProgramExerciseRef> exercises;

  bool get isRestDay => exercises.isEmpty;
}

/// Do kho hien thi dang 3-vach, dung chung logic cho ca man danh sach va
/// chi tiet chuong trinh - port tu `ProgramDifficulty.levelSteps()` cua
/// FitViet (Gate 42).
enum ProgramDifficulty {
  beginner,
  intermediate,
  advanced;

  /// null nghia la "Moi trinh do" - khong ve vach nao ca (mo/muted).
  static ProgramDifficulty? fromLevel(String level) => switch (level) {
    'Mới bắt đầu' => beginner,
    'Trung cấp' => intermediate,
    'Nâng cao' => advanced,
    _ => null,
  };

  int get steps => switch (this) {
    ProgramDifficulty.beginner => 1,
    ProgramDifficulty.intermediate => 2,
    ProgramDifficulty.advanced => 3,
  };
}

/// 1 chuong trinh tap (giao an) - port tu `ProgramEntity` + lich tuan that
/// (`ProgramDayEntity`/`ProgramExerciseEntity`) cua FitViet (Gate 2/15). Noi
/// dung tinh, dong goi san trong `programs_seed.json` (giong het cach
/// exercises_seed.json dang lam), KHONG luu trong Supabase - chi "chuong
/// trinh dang theo" cua tung user moi can luu rieng (xem workout_repository.dart).
class Program {
  const Program({
    required this.id,
    required this.titleVi,
    required this.level,
    required this.equipment,
    required this.sessionsPerWeek,
    required this.durationWeeks,
    required this.tags,
    required this.days,
  });

  final int id;
  final String titleVi;
  final String level;
  final String equipment;
  final int sessionsPerWeek;
  final int durationWeeks;
  final List<String> tags;
  final List<ProgramDay> days;

  ProgramDifficulty? get difficulty => ProgramDifficulty.fromLevel(level);

  /// Ngay trong tuan hien tai theo lich cua chuong trinh nay -
  /// `DateTime.weekday` da san dung chuan ISO (1-7) nen khong can chuyen doi.
  ProgramDay dayFor(DateTime date) =>
      days.firstWhere((d) => d.dayOfWeek == date.weekday);
}
