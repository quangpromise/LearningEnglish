import 'package:flutter/material.dart';

/// Design tokens theo `.claude/skills/ui-design-system/SKILL.md`.
class AppColors {
  AppColors._();

  static const bgTop = Color(0xFF0A0E1C);
  static const bgMid = Color(0xFF0D1330);
  static const bgBottom = Color(0xFF080B16);

  static const blue = Color(0xFF5B8CFF);
  static const purple = Color(0xFF9B6BFF);
  static const teal = Color(0xFF5BE0D0);
  static const amber = Color(0xFFFFB23C);
  static const pink = Color(0xFFFF6B9D);

  static const textPrimary = Color(0xFFEEF1FB);
  static const textMuted = Color(0x8DEEF1FB);

  static const glassFill = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x17FFFFFF);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, purple],
  );

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading({
    double size = 20,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: size,
    fontWeight: weight,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    decoration: TextDecoration.none,
  );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    decoration: TextDecoration.none,
  );

  static TextStyle muted({
    double size = 12,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    fontWeight: weight,
    color: AppColors.textMuted,
    decoration: TextDecoration.none,
  );
}

class GlowBox extends StatelessWidget {
  const GlowBox({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.light = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.95)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: light ? null : Border.all(color: AppColors.glassBorder),
        boxShadow: light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.filled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.accentGradient : null,
            color: filled ? null : AppColors.glassFill,
            border: filled ? null : Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(999),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screenGradient),
      child: SafeArea(
        // Ep decoration mac dinh la none o tang goc man hinh: bat ky
        // TextStyle nao (kem ca cac TextStyle() viet tay khong qua
        // AppTextStyles) khong tu khai bao decoration rieng se ke thua gia
        // tri nay thay vi ke thua tu DefaultTextStyle cua Theme/Material o
        // xa hon - nghi ngo day la nguyen nhan gach chan vang xuat hien
        // khap noi trong app du khong co dong code nao chu dong "set" no.
        child: DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none),
          child: child,
        ),
      ),
    );
  }
}
