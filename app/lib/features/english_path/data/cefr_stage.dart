/// Mot bac CEFR trong lo trinh tieng Anh (xem CONTEXT.md: Stage, English
/// Level). Khong co C2 - xem spec #45.
enum CefrStage {
  a1('A1'),
  a2('A2'),
  b1('B1'),
  b2('B2'),
  c1('C1');

  const CefrStage(this.code);

  /// Ma CEFR viet hoa dung trong Content Pack, vd "B1".
  final String code;

  static CefrStage fromCode(String code) => CefrStage.values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw FormatException('Unknown CEFR stage: $code'),
  );
}
