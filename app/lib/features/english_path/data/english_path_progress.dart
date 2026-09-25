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

PathStage? _stageOf(ContentPack pack, CefrLevel level) {
  for (final s in pack.stages) {
    if (s.stage == level) return s;
  }
  return null;
}

/// Unit dau tien chua hoan thanh cua Stage [level]; null khi da xong het
/// (den luc lam Level Test) hoac pack chua co noi dung cho Stage do.
PathUnit? nextUnit(ContentPack pack, CefrLevel level, EnglishPathState state) {
  for (final unit in _stageOf(pack, level)?.units ?? const <PathUnit>[]) {
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
  final units = _stageOf(pack, level)?.units ?? const <PathUnit>[];
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

/// English Level dang ap dung: da luu thi dung, chua co thi theo Persona.
CefrLevel effectiveLevel(EnglishPathState state, LearningPersona? persona) =>
    state.level ?? defaultLevelForPersona(persona);
