import 'cefr_level.dart';
import 'placement.dart';

/// Phien ban cau truc state lo trinh. BAT BUOC tang (va them 1 buoc migrate
/// trong [migrateEnglishPathState]) moi khi them/doi truong - vd Level Test,
/// che do Rest Game o cac ticket sau. Neu khong, ban app cu doc state cung
/// version se ghi de va lam mat cac truong no khong biet.
///
/// Lich su: v1 level + correctItems; v2 them placement + placementSkipped.
const kEnglishPathSchemaVersion = 2;

/// Tien do lo trinh tieng Anh cua nguoi hoc (local-first, xem spec #45).
class EnglishPathState {
  const EnglishPathState({
    this.level,
    this.correctItems = const {},
    this.placement,
    this.placementSkipped = false,
  });

  /// English Level da xac dinh (Placement/Level Test). null = chua co, dung
  /// Stage mac dinh theo Persona - xem `effectiveLevel`.
  final CefrLevel? level;

  /// unitId -> id cac Practice Item da tra loi dung it nhat 1 lan.
  final Map<String, Set<String>> correctItems;

  /// Lan Placement Test gan nhat (ban ghi audit day du).
  final PlacementRecord? placement;

  /// Nguoi hoc da bo qua Placement - khong hoi lai, dung Stage theo Persona.
  final bool placementSkipped;

  EnglishPathState _copy({
    CefrLevel? level,
    Map<String, Set<String>>? correctItems,
    PlacementRecord? placement,
    bool? placementSkipped,
  }) => EnglishPathState(
    level: level ?? this.level,
    correctItems: correctItems ?? this.correctItems,
    placement: placement ?? this.placement,
    placementSkipped: placementSkipped ?? this.placementSkipped,
  );

  EnglishPathState copyWith({CefrLevel? level}) => _copy(level: level);

  EnglishPathState recordCorrect(String unitId, String itemId) {
    if (correctItems[unitId]?.contains(itemId) ?? false) return this;
    return _copy(
      correctItems: {
        ...correctItems,
        unitId: {...?correctItems[unitId], itemId},
      },
    );
  }

  /// Ket qua Placement la quyet dinh cuoi cung ve English Level (spec #45).
  /// Ghi de English Level hien tai (ke ca khi thap hon) va xoa co "bo qua".
  EnglishPathState withPlacement(PlacementRecord record) =>
      _copy(placement: record, level: record.result, placementSkipped: false);

  EnglishPathState skipPlacement() => _copy(placementSkipped: true);

  Map<String, dynamic> toJson() => {
    'schemaVersion': kEnglishPathSchemaVersion,
    'level': level?.code,
    'correctItems': {
      for (final e in correctItems.entries) e.key: (e.value.toList()..sort()),
    },
    'placement': placement?.toJson(),
    'placementSkipped': placementSkipped,
  };
}

/// State do ban app MOI HON ghi (schemaVersion la so nguyen lon hon ban
/// nay): phai giu nguyen, khong bao gio ghi de.
bool isFromNewerVersion(Object? raw) =>
    raw is Map &&
    raw['schemaVersion'] is int &&
    (raw['schemaVersion'] as int) > kEnglishPathSchemaVersion;

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
    // v1 -> v2: chua co placement (null) va chua bo qua (false) - cac truong
    // v2 vang mat duoc doc ra dung gia tri mac dinh do.
    final levelCode = raw['level'] as String?;
    final items = (raw['correctItems'] as Map?) ?? const {};
    final placement = raw['placement'] as Map?;
    return EnglishPathState(
      level: levelCode == null ? null : CefrLevel.fromCode(levelCode),
      correctItems: {
        for (final e in items.entries)
          e.key as String: (e.value as List).cast<String>().toSet(),
      },
      placement: placement == null
          ? null
          : PlacementRecord.fromJson(Map<String, dynamic>.from(placement)),
      placementSkipped: raw['placementSkipped'] as bool? ?? false,
    );
  } catch (_) {
    return null;
  }
}
