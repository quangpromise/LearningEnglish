import '../../learning_path/data/learning_path_models.dart';
import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_state.dart';

/// Unit hoan thanh khi so item da dung it nhat 1 lan dat >= 4/5 (80%) -
/// so sanh bang so nguyen, khong qua so thuc.
bool isUnitComplete(PathUnit unit, EnglishPathState state) =>
    unit.items.isNotEmpty &&
    _correctCount(unit, state) * 5 >= unit.items.length * 4;

/// Ti le item cua [unit] da tra loi dung it nhat 1 lan (0..1).
double unitProgress(PathUnit unit, EnglishPathState state) =>
    unit.items.isEmpty ? 0 : _correctCount(unit, state) / unit.items.length;

/// % tien do lam tron de hien thi.
int unitPercent(PathUnit unit, EnglishPathState state) =>
    (unitProgress(unit, state) * 100).round();

int _correctCount(PathUnit unit, EnglishPathState state) {
  final done = state.correctItems[unit.id] ?? const <String>{};
  return unit.items.where((i) => done.contains(i.id)).length;
}

/// Cac Unit cua Stage [level] trong pack (rong neu chua co noi dung).
List<PathUnit> unitsOf(ContentPack pack, CefrLevel level) {
  for (final s in pack.stages) {
    if (s.stage == level) return s.units;
  }
  return const [];
}

/// Unit dau tien chua hoan thanh cua Stage [level]; null khi da xong het
/// (den luc lam Level Test) hoac pack chua co noi dung cho Stage do.
PathUnit? nextUnit(ContentPack pack, CefrLevel level, EnglishPathState state) {
  for (final unit in unitsOf(pack, level)) {
    if (!isUnitComplete(unit, state)) return unit;
  }
  return null;
}

/// Moi Unit cua Stage [level] da hoan thanh (Stage phai co noi dung).
bool allUnitsComplete(
  ContentPack pack,
  CefrLevel level,
  EnglishPathState state,
) {
  final units = unitsOf(pack, level);
  return units.isNotEmpty && units.every((u) => isUnitComplete(u, state));
}

/// Thu tu item cho 1 phien hoc Unit: item chua dung truoc, da dung sau.
List<PracticeItem> sessionItems(PathUnit unit, EnglishPathState state) {
  final done = state.correctItems[unit.id] ?? const <String>{};
  return [
    ...unit.items.where((i) => !done.contains(i.id)),
    ...unit.items.where((i) => done.contains(i.id)),
  ];
}

/// Stage xuat phat theo Persona - chi la diem bat dau, ket qua Placement
/// (neu co) luon thang (spec #45).
CefrLevel defaultLevelForPersona(LearningPersona? persona) => switch (persona) {
  null || LearningPersona.beginner => CefrLevel.a1,
  LearningPersona.dailyConversation ||
  LearningPersona.grammarOverhaul => CefrLevel.a2,
  LearningPersona.officeEnglish ||
  LearningPersona.toeicPrep ||
  LearningPersona.ieltsPrep => CefrLevel.b1,
};

/// Lop tuong thich 3 cap cho cac tinh nang cu (ADR-0001).
LearnerLevel learnerLevelFor(CefrLevel level) => switch (level) {
  CefrLevel.a1 || CefrLevel.a2 => LearnerLevel.basic,
  CefrLevel.b1 => LearnerLevel.intermediate,
  CefrLevel.b2 || CefrLevel.c1 => LearnerLevel.advanced,
};

/// Learner Level cho cac tinh nang cu (spec #48):
/// - "Tu hoc"/chua chon Persona: null = khong loc, ke ca khi co English Level.
/// - Co English Level da luu (Placement/Level Test): suy tu no.
/// - Chua co: GIU mapping cu theo Persona (ADR-0001, muc Consequences) de
///   khong doi hanh vi cua nguoi dung hien tai.
LearnerLevel? projectLearnerLevel({
  required CefrLevel? englishLevel,
  required LearningPersona? persona,
}) {
  if (persona == null) return null;
  return englishLevel != null ? learnerLevelFor(englishLevel) : persona.level;
}

/// English Level dang ap dung: da luu thi dung, chua co thi theo Persona.
CefrLevel effectiveLevel(EnglishPathState state, LearningPersona? persona) =>
    state.level ?? defaultLevelForPersona(persona);
