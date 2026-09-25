import 'package:flutter/material.dart';

/// Design token cua ban redesign GymTalk (docs/design/gymtalk-redesign/,
/// ADR-0004). Doc qua `context.gt`; man chua redesign van dung AppColors.
@immutable
class GtTokens extends ThemeExtension<GtTokens> {
  const GtTokens({
    required this.bg,
    required this.s1,
    required this.s2,
    required this.bd,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.inv,
    required this.onInv,
    required this.glass,
    required this.red,
    required this.blue,
    required this.gold,
    required this.teal,
    required this.streak,
    required this.goldB,
  });

  /// Nen man hinh.
  final Color bg;

  /// The (card).
  final Color s1;

  /// Nen phu ben trong, thanh tien do, chip.
  final Color s2;

  /// Vien 1px, duong ke.
  final Color bd;
  final Color tx;
  final Color tx2;
  final Color tx3;

  /// Nut chinh trung tinh (vien trang chu den o dark).
  final Color inv;
  final Color onInv;

  /// Nen kinh mo cua tab bar / mini player (kem blur 20).
  final Color glass;

  /// Accent theo khu vuc: Tap (do), Hoc (xanh), Thuong/XP/Tien do (vang),
  /// Noi (xanh ngoc), ngon lua chuoi ngay (cam).
  final Color red;
  final Color blue;
  final Color gold;
  final Color teal;
  final Color streak;

  /// Vien vang cua the hang / the tong tai san.
  final Color goldB;

  Color get redT => red.withValues(alpha: 0.18);
  Color get blueT => blue.withValues(alpha: 0.16);
  Color get goldT => gold.withValues(alpha: 0.13);
  Color get tealT => teal.withValues(alpha: 0.16);

  /// Chu tren nen accent.
  Color get onGold => const Color(0xFF1A1406);
  Color get onRed => const Color(0xFFFFFFFF);
  Color get onTeal => const Color(0xFF04201A);

  static const dark = GtTokens(
    bg: Color(0xFF08090B),
    s1: Color(0xFF121418),
    s2: Color(0xFF1B1E23),
    bd: Color(0x14FFFFFF),
    tx: Color(0xFFF4F5F7),
    tx2: Color(0xFFA3A8B1),
    tx3: Color(0xFF6E737C),
    inv: Color(0xFFF4F5F7),
    onInv: Color(0xFF0B0C0E),
    glass: Color(0xDB121418),
    red: Color(0xFFE5484D),
    blue: Color(0xFF6E8FF5),
    gold: Color(0xFFE8B84A),
    teal: Color(0xFF3DD6B5),
    streak: Color(0xFFFF8A3D),
    goldB: Color(0x59E8B84A),
  );

  static const light = GtTokens(
    bg: Color(0xFFF4F4F2),
    s1: Color(0xFFFFFFFF),
    s2: Color(0xFFECECE9),
    bd: Color(0x140C0E12),
    tx: Color(0xFF0C0D10),
    tx2: Color(0xFF585D66),
    // Handoff ghi #8A8F97 nhung chi dat 2,95:1 tren nen #F4F4F2 (duoi muc
    // 3:1 cho nhan) -> toi nhe con #878C94 (3,07:1), gan nhu khong khac mau.
    tx3: Color(0xFF878C94),
    inv: Color(0xFF0C0D10),
    onInv: Color(0xFFFFFFFF),
    glass: Color(0xDBFFFFFF),
    red: Color(0xFFC8303A),
    blue: Color(0xFF3F63D6),
    gold: Color(0xFFB8862A),
    teal: Color(0xFF1F9B80),
    streak: Color(0xFFFF8A3D),
    goldB: Color(0x73B8862A),
  );

  @override
  GtTokens copyWith({Color? bg, Color? s1, Color? s2}) => GtTokens(
    bg: bg ?? this.bg,
    s1: s1 ?? this.s1,
    s2: s2 ?? this.s2,
    bd: bd,
    tx: tx,
    tx2: tx2,
    tx3: tx3,
    inv: inv,
    onInv: onInv,
    glass: glass,
    red: red,
    blue: blue,
    gold: gold,
    teal: teal,
    streak: streak,
    goldB: goldB,
  );

  @override
  GtTokens lerp(GtTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return GtTokens(
      bg: l(bg, other.bg),
      s1: l(s1, other.s1),
      s2: l(s2, other.s2),
      bd: l(bd, other.bd),
      tx: l(tx, other.tx),
      tx2: l(tx2, other.tx2),
      tx3: l(tx3, other.tx3),
      inv: l(inv, other.inv),
      onInv: l(onInv, other.onInv),
      glass: l(glass, other.glass),
      red: l(red, other.red),
      blue: l(blue, other.blue),
      gold: l(gold, other.gold),
      teal: l(teal, other.teal),
      streak: l(streak, other.streak),
      goldB: l(goldB, other.goldB),
    );
  }
}

extension GtTokensContext on BuildContext {
  /// Token redesign cua theme hien tai (mac dinh dark - ADR-0004).
  GtTokens get gt => Theme.of(this).extension<GtTokens>() ?? GtTokens.dark;
}

/// Thang chu cua ban redesign: SpaceGrotesk cho tieu de/so, Manrope cho noi
/// dung. Nho nhat 12.
abstract final class GtText {
  static TextStyle _grotesk(double size, double tracking, Color color) =>
      TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: tracking,
        height: 1.05,
        color: color,
        decoration: TextDecoration.none,
      );

  static TextStyle _manrope(double size, FontWeight w, Color color) =>
      TextStyle(
        fontFamily: 'Manrope',
        fontSize: size,
        fontWeight: w,
        color: color,
        decoration: TextDecoration.none,
      );

  /// Tieu de lon cua man (30).
  static TextStyle heroTitle(Color c) => _grotesk(30, -0.8, c);

  /// So lon (40) - vd chi so the thong ke.
  static TextStyle bigStat(Color c) => _grotesk(40, -1.5, c);

  /// So cua vong muc tieu (26).
  static TextStyle ringStat(Color c) => _grotesk(26, -0.5, c);

  /// Tieu de the (20).
  static TextStyle cardTitle(Color c) => _grotesk(20, 0, c);

  /// Ten o top bar (21).
  static TextStyle topName(Color c) => _grotesk(21, -0.3, c);

  /// Tieu de dong (15/800).
  static TextStyle rowTitle(Color c) => _manrope(15, FontWeight.w800, c);

  /// Noi dung (13-15/600-700).
  static TextStyle body(Color c, {double size = 14}) =>
      _manrope(size, FontWeight.w600, c);

  /// Nhan tren (12/800/+1.4, VIET HOA khi hien thi).
  static TextStyle overline(Color c) =>
      _manrope(12, FontWeight.w800, c).copyWith(letterSpacing: 1.4);

  /// Nhan tab (12, 800 khi active).
  static TextStyle tabLabel(Color c, {required bool active}) =>
      _manrope(12, active ? FontWeight.w800 : FontWeight.w600, c);
}
