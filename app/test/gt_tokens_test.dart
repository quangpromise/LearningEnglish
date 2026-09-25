import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';

/// Ti le tuong phan WCAG giua 2 mau dac (khong alpha).
double _contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) =>
        v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final la = lum(a), lb = lum(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  group('handoff token values', () {
    test('dark palette matches the handoff', () {
      const t = GtTokens.dark;
      expect(t.bg, const Color(0xFF08090B));
      expect(t.s1, const Color(0xFF121418));
      expect(t.s2, const Color(0xFF1B1E23));
      expect(t.bd, const Color(0x14FFFFFF));
      expect(t.tx, const Color(0xFFF4F5F7));
      expect(t.inv, const Color(0xFFF4F5F7));
      expect(t.onInv, const Color(0xFF0B0C0E));
      expect(t.glass.a, closeTo(0.86, 0.005));
      expect(t.glass.withValues(alpha: 1), const Color(0xFF121418));
      expect(t.tx2, const Color(0xFFA3A8B1));
      expect(t.tx3, const Color(0xFF6E737C));
      expect(t.red, const Color(0xFFE5484D));
      expect(t.blue, const Color(0xFF6E8FF5));
      expect(t.gold, const Color(0xFFE8B84A));
      expect(t.teal, const Color(0xFF3DD6B5));
      expect(t.streak, const Color(0xFFFF8A3D));
    });

    test('light palette matches the handoff', () {
      const t = GtTokens.light;
      expect(t.bg, const Color(0xFFF4F4F2));
      expect(t.s1, const Color(0xFFFFFFFF));
      expect(t.s2, const Color(0xFFECECE9));
      expect(t.bd, const Color(0x140C0E12));
      expect(t.tx, const Color(0xFF0C0D10));
      expect(t.tx2, const Color(0xFF585D66));
      // Lech co chu dich so voi handoff (#8A8F97) de dat 3:1 - ADR-0004.
      expect(t.tx3, const Color(0xFF878C94));
      expect(t.inv, const Color(0xFF0C0D10));
      expect(t.onInv, const Color(0xFFFFFFFF));
      expect(t.glass.a, closeTo(0.86, 0.005));
      expect(t.glass.withValues(alpha: 1), const Color(0xFFFFFFFF));
      expect(t.streak, const Color(0xFFFF8A3D));
      expect(t.red, const Color(0xFFC8303A));
      expect(t.blue, const Color(0xFF3F63D6));
      expect(t.gold, const Color(0xFFB8862A));
      expect(t.teal, const Color(0xFF1F9B80));
    });

    test('tints use the handoff alphas', () {
      const t = GtTokens.dark;
      expect(t.redT.a, closeTo(0.18, 0.005));
      expect(t.blueT.a, closeTo(0.16, 0.005));
      expect(t.goldT.a, closeTo(0.13, 0.005));
      expect(t.tealT.a, closeTo(0.16, 0.005));
      expect(t.goldB.a, closeTo(0.35, 0.005));
      expect(GtTokens.light.goldB.a, closeTo(0.45, 0.005));
    });
  });

  group('readability', () {
    for (final (name, t) in [
      ('dark', GtTokens.dark),
      ('light', GtTokens.light),
    ]) {
      test('$name: text colours are readable on the background', () {
        expect(_contrast(t.tx, t.bg), greaterThanOrEqualTo(7));
        expect(_contrast(t.tx, t.s1), greaterThanOrEqualTo(7));
        expect(_contrast(t.tx2, t.bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(t.tx3, t.bg), greaterThanOrEqualTo(3));
        expect(_contrast(t.onInv, t.inv), greaterThanOrEqualTo(7));
      });
    }

    test('text on accent buttons is readable (dark)', () {
      const t = GtTokens.dark;
      expect(_contrast(t.onGold, t.gold), greaterThanOrEqualTo(4.5));
      expect(_contrast(t.onTeal, t.teal), greaterThanOrEqualTo(4.5));
      // Nut do: chu trang dam co lon -> muc large-text 3:1.
      expect(_contrast(t.onRed, t.red), greaterThanOrEqualTo(3));
    });
  });

  test('copyWith replaces only the given tokens', () {
    final t = GtTokens.dark.copyWith(gold: const Color(0xFF000001));
    expect(t.gold, const Color(0xFF000001));
    expect(t.red, GtTokens.dark.red);
    expect(t.glass, GtTokens.dark.glass);
  });

  test('lerp between themes stays within the two palettes', () {
    final mid = GtTokens.dark.lerp(GtTokens.light, 0.5);
    expect(mid.bg, Color.lerp(GtTokens.dark.bg, GtTokens.light.bg, 0.5));
    expect(GtTokens.dark.lerp(null, 0.5), same(GtTokens.dark));
    expect(GtTokens.dark.lerp(GtTokens.light, 1), same(GtTokens.light));
    expect(GtTokens.dark.lerp(GtTokens.light, 0), same(GtTokens.dark));
  });

  testWidgets('context.gt reads the theme extension, dark by default', (
    tester,
  ) async {
    late GtTokens seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.light]),
        home: Builder(
          builder: (context) {
            seen = context.gt;
            return const SizedBox();
          },
        ),
      ),
    );
    // MaterialApp co the noi suy (lerp) theme -> so theo gia tri.
    expect(seen.bg, GtTokens.light.bg);
    expect(seen.tx, GtTokens.light.tx);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.gt;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen.bg, GtTokens.dark.bg);
  });
}
