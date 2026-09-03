import 'package:flutter/material.dart';

/// Design tokens theo `.claude/skills/ui-design-system/SKILL.md`.
class AppColors {
  AppColors._();

  // Doi sang bang mau "smart-home app" (nen den tuyet doi + xanh la neon lam
  // mau nhan chinh) theo yeu cau thiet ke lai dong bo toan app - GIU NGUYEN
  // TEN BIEN cu (bgTop/bgMid/bgBottom/blue/accentGradient...) va chi doi GIA
  // TRI mau, de MOI man hinh dang dung cac ten nay (qua GlowBox/ScreenBackground/
  // AppTextStyles ben duoi) tu dong ap dung mau moi ma khong phai sua tung
  // file rieng le - giam toi da rui ro bo sot 1 man hinh nao do.
  static const bgTop = Color(0xFF0A0D0A);
  static const bgMid = Color(0xFF10140D);
  static const bgBottom = Color(0xFF050604);

  /// Van ten "blue" nhu cu nhung gia tri la CAM (theo mau tham khao app dat
  /// lich kieu "valyioo") - day la mau NHAN CHINH dung khap noi trong app
  /// (nut, active state, progress bar...).
  static const blue = Color(0xFFF0883D);
  static const purple = Color(0xFF9B6BFF);
  static const teal = Color(0xFF5BE0D0);
  static const amber = Color(0xFFFFB23C);
  static const pink = Color(0xFFFF6B9D);

  static const textPrimary = Color(0xFFEEF1FB);
  static const textMuted = Color(0x8DEEF1FB);

  static const glassFill = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x17FFFFFF);

  // Cam dam -> cam nhat, giu 1 tong mau nhat quan cho gradient nut/avatar
  // dung khap app (khong con ghep voi purple/teal de tranh xung dot mau).
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, Color(0xFFF2A35C)],
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
              // Flexible bat buoc phai co o day: PillButton thuong nam trong
              // Expanded (vd 2 nut canh nhau), khien Container bi ep vao 1
              // chieu rong co dinh - neu Text khong duoc boc Flexible, no se
              // lay chieu rong tu nhien (khong gioi han) va tran ra ngoai
              // vien bo tron cua nut khi label dai (vd "Xem bang xep hang").
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child, this.gradient});
  final Widget child;

  /// Cho phep 1 man hinh cu the (vd ChatScreen voi theme nen tuy chinh) doi
  /// nen rieng thay vi dung mac dinh chung ca app.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient ?? AppColors.screenGradient),
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
