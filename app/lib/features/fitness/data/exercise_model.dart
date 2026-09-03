/// Nhom co chinh cua 1 bai tap - dung ma on dinh (khong doi theo ngon ngu)
/// de loc/nhom, khac voi [Exercise.primaryMuscle] la chuoi hien thi tu do.
/// Danh sach nay khop voi `MuscleGroup` enum cua FitViet (nguon port).
enum MuscleGroup {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
  fullBody,
  functional,
  cardio;

  static MuscleGroup fromCode(String code) => switch (code) {
    'CHEST' => chest,
    'BACK' => back,
    'SHOULDERS' || 'DELTOIDS' => shoulders,
    'ARMS' || 'BICEPS' || 'TRICEPS' => arms,
    'LEGS' || 'QUADRICEPS' || 'HAMSTRINGS' || 'GLUTES' || 'CALVES' => legs,
    'CORE' || 'ABS' => core,
    'FULL_BODY' => fullBody,
    'FUNCTIONAL' => functional,
    'CARDIO' => cardio,
    _ => functional,
  };

  String labelVi() => switch (this) {
    MuscleGroup.chest => 'Ngực',
    MuscleGroup.back => 'Lưng',
    MuscleGroup.shoulders => 'Vai',
    MuscleGroup.arms => 'Tay',
    MuscleGroup.legs => 'Chân',
    MuscleGroup.core => 'Bụng',
    MuscleGroup.fullBody => 'Toàn thân',
    MuscleGroup.functional => 'Chức năng',
    MuscleGroup.cardio => 'Tim mạch',
  };

  /// Key AppStrings tuong ung - dung o tang presentation (`ref.tr(...)`) de
  /// nhan Chuong co dich theo App language, khac voi noi dung bai tap tho
  /// (nameVi/instructions...) van giu nguyen tieng Viet vi la du lieu tinh
  /// dong goi san, dich het 155 bai la qua muc cho Phase 1.
  String get labelKey => switch (this) {
    MuscleGroup.chest => 'fitness_muscle_chest',
    MuscleGroup.back => 'fitness_muscle_back',
    MuscleGroup.shoulders => 'fitness_muscle_shoulders',
    MuscleGroup.arms => 'fitness_muscle_arms',
    MuscleGroup.legs => 'fitness_muscle_legs',
    MuscleGroup.core => 'fitness_muscle_core',
    MuscleGroup.fullBody => 'fitness_muscle_full_body',
    MuscleGroup.functional => 'fitness_muscle_functional',
    MuscleGroup.cardio => 'fitness_muscle_cardio',
  };

  /// Anh minh hoa giai phau (nguoi mau 3D highlight vung co, cat tu app
  /// tham khao - da xac nhan co ban quyen su dung) cho man danh sach nhom co.
  String get imageAsset {
    final fileName = switch (this) {
      MuscleGroup.fullBody => 'full_body',
      _ => name,
    };
    return 'assets/fitness/muscle_groups/$fileName.png';
  }
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  static ExerciseDifficulty fromCode(String code) => switch (code) {
    'BEGINNER' => beginner,
    'INTERMEDIATE' => intermediate,
    'ADVANCED' => advanced,
    _ => intermediate,
  };

  String labelVi() => switch (this) {
    ExerciseDifficulty.beginner => 'Cơ bản',
    ExerciseDifficulty.intermediate => 'Trung cấp',
    ExerciseDifficulty.advanced => 'Nâng cao',
  };

  /// Xem ghi chu [MuscleGroup.labelKey].
  String get labelKey => switch (this) {
    ExerciseDifficulty.beginner => 'fitness_difficulty_beginner',
    ExerciseDifficulty.intermediate => 'fitness_difficulty_intermediate',
    ExerciseDifficulty.advanced => 'fitness_difficulty_advanced',
  };
}

/// 1 bai tap trong thu vien - port tu `ExerciseEntity` cua FitViet, chi giu
/// lai cac truong Phase 1 (thu vien bai tap) can dung; cac truong lien quan
/// toi luong tap luyen thuc te (suggestedSets/Reps/Rest) van giu lai vi da
/// co san trong du lieu seed va se can ngay o Phase 3, khong ton them cong
/// suc trich xuat lai.
class Exercise {
  const Exercise({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.involvementPercents,
    required this.equipment,
    required this.instructions,
    required this.suggestedSetsMin,
    required this.suggestedSetsMax,
    required this.suggestedRepsMin,
    required this.suggestedRepsMax,
    required this.suggestedRestSeconds,
    required this.muscleGroupCode,
    required this.movementType,
    required this.difficultyCode,
    required this.photoSlug,
  });

  final int id;
  final String nameVi;
  final String nameEn;
  final String primaryMuscle;
  final List<String> secondaryMuscles;

  /// Ty le % dong gop cua tung nhom co hien thi, ung vien dau tien la co
  /// chinh roi den [secondaryMuscles] theo thu tu. **Danh sach RONG la tin
  /// hieu chu dong "an the nay" (bai cardio/gian co...), KHONG PHAI loi/
  /// thieu du lieu** - dung tu backfill gia tri mac dinh khi danh sach rong,
  /// giu nguyen dung ngu nghia goc tu FitViet.
  final List<int> involvementPercents;

  final String equipment;
  final List<String> instructions;
  final int suggestedSetsMin;
  final int suggestedSetsMax;
  final int suggestedRepsMin;
  final int suggestedRepsMax;
  final int suggestedRestSeconds;
  final String muscleGroupCode;
  final String movementType;
  final String difficultyCode;

  /// Ten file goc (khong duoi/hau to `_0`/`_1`) cua 2 anh minh hoa dong tac
  /// (tu the bat dau/ket thuc) - anh that lay tu chinh app FitViet
  /// (`res/drawable-nodpi/`, nguoi dung xac nhan co ban quyen su dung, xem
  /// docs/research-exercise-gifs.md), ghep tu dong bang [photoAssets].
  final String photoSlug;

  MuscleGroup get muscleGroup => MuscleGroup.fromCode(muscleGroupCode);
  ExerciseDifficulty get difficulty =>
      ExerciseDifficulty.fromCode(difficultyCode);

  /// 2 duong dan anh (tu the bat dau/ket thuc) de tao hieu ung dong don
  /// gian (doi qua lai) trong man chi tiet, thay vi phai co GIF that.
  List<String> get photoAssets => [
    'assets/fitness/exercise_photos/${photoSlug}_0.jpg',
    'assets/fitness/exercise_photos/${photoSlug}_1.jpg',
  ];

  /// Danh sach ten nhom co theo dung thu tu voi [involvementPercents] (co
  /// chinh truoc, [secondaryMuscles] sau) - dung de ghep cap ten+% khi ve
  /// thanh tien do trong man chi tiet.
  List<String> get displayedMuscles => [primaryMuscle, ...secondaryMuscles];
}
