/// Mot bac tren thang CEFR A1 -> C1 (khong co C2 - spec #45). Dung cho ca
/// Stage cua lo trinh lan English Level cua nguoi hoc (CONTEXT.md).
enum CefrLevel {
  a1('A1'),
  a2('A2'),
  b1('B1'),
  b2('B2'),
  c1('C1');

  const CefrLevel(this.code);

  /// Ma CEFR viet hoa dung trong Content Pack, vd "B1".
  final String code;

  /// Khoa chuoi ten Stage trong AppStrings, vd "path_stage_b1".
  String get labelKey => 'path_stage_${code.toLowerCase()}';

  static CefrLevel fromCode(String code) => CefrLevel.values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw FormatException('Unknown CEFR level: $code'),
  );
}
