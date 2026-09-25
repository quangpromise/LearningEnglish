import 'cefr_level.dart';

/// Phien ban cau truc state lo trinh. Tang khi doi cau truc va them 1 buoc
/// migrate trong [migrateEnglishPathState].
const kEnglishPathSchemaVersion = 1;

/// Tien do lo trinh tieng Anh cua nguoi hoc (local-first, xem spec #45).
class EnglishPathState {
  const EnglishPathState({this.level, this.correctItems = const {}});

  /// English Level da xac dinh (Placement/Level Test). null = chua co, dung
  /// Stage mac dinh theo Persona - xem `effectiveLevel`.
  final CefrLevel? level;

  /// unitId -> id cac Practice Item da tra loi dung it nhat 1 lan.
  final Map<String, Set<String>> correctItems;

  EnglishPathState copyWith({CefrLevel? level}) =>
      EnglishPathState(level: level ?? this.level, correctItems: correctItems);

  EnglishPathState recordCorrect(String unitId, String itemId) {
    if (correctItems[unitId]?.contains(itemId) ?? false) return this;
    return EnglishPathState(
      level: level,
      correctItems: {
        ...correctItems,
        unitId: {...?correctItems[unitId], itemId},
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': kEnglishPathSchemaVersion,
    'level': level?.code,
    'correctItems': {
      for (final e in correctItems.entries) e.key: (e.value.toList()..sort()),
    },
  };
}

/// Doc state tu JSON (local hoac remote), migrate len phien ban hien tai.
/// Tra ve null khi du lieu hong hoac do ban app MOI HON ghi (version la) -
/// noi goi phai giu nguyen state cu va KHONG ghi de du lieu do.
EnglishPathState? migrateEnglishPathState(Object? raw) {
  if (raw is! Map) return null;
  final version = raw['schemaVersion'];
  if (version is! int || version > kEnglishPathSchemaVersion || version < 1) {
    return null;
  }
  try {
    // version == 1 - cac buoc migrate v1 -> v2... them o day khi can.
    final levelCode = raw['level'] as String?;
    final items = (raw['correctItems'] as Map?) ?? const {};
    return EnglishPathState(
      level: levelCode == null ? null : CefrLevel.fromCode(levelCode),
      correctItems: {
        for (final e in items.entries)
          e.key as String: (e.value as List).cast<String>().toSet(),
      },
    );
  } catch (_) {
    return null;
  }
}
