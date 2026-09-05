import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

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

  /// Mau nhan chinh cua app "Hoc Tieng Anh" (mac dinh toan app, tru Fitness)
  /// - da doi lai xanh nhu ban goc theo yeu cau, sau khi thu doi sang cam
  /// cho toan app roi nhan ra can phan biet theo tung "app" trong switcher.
  static const blue = Color(0xFF5B8CFF);
  static const purple = Color(0xFF9B6BFF);
  static const teal = Color(0xFF5BE0D0);
  static const amber = Color(0xFFFFB23C);
  static const pink = Color(0xFFFF6B9D);

  /// Mau nhan chinh RIENG cho khu vuc Fitness (app-switcher) - dung thay the
  /// [blue] trong moi man hinh duoi `features/fitness/`, KHONG dung o cac
  /// man hinh khac.
  static const fitnessAccent = Color(0xFFF0883D);
  static const fitnessAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fitnessAccent, Color(0xFFF2A35C)],
  );

  /// Mau nhan chinh RIENG cho khu vuc Quan ly tai san (Wealth) - vang/gold.
  static const wealthAccent = Color(0xFFD4AF37);
  static const wealthAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [wealthAccent, Color(0xFFF0D585)],
  );

  static const textPrimary = Color(0xFFEEF1FB);
  static const textMuted = Color(0x8DEEF1FB);

  // Den (khong phai trang) va do dam cao hon truoc (0x0D -> 0x59) - man hinh
  // co anh nen (Home/Fitness) truoc do qua trong suot, thay ro anh xuyen qua
  // GlowBox lam chu kho doc; nen den lam diu anh nen ngay ben trong box ma
  // van giu duoc hieu ung "kinh mo" (khong dac hoan toan).
  static const glassFill = Color(0x59000000);
  static const glassBorder = Color(0x26FFFFFF);

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
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool light;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.95)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ?? (light ? null : Border.all(color: AppColors.glassBorder)),
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
    this.accentGradient,
    this.accentColor,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Widget? icon;

  /// Cho phep 1 khu vuc (vd Fitness) doi mau nhan rieng thay vi
  /// [AppColors.accentGradient]/[AppColors.blue] mac dinh cua app.
  final Gradient? accentGradient;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final gradient = accentGradient ?? AppColors.accentGradient;
    final shadowColor = accentColor ?? AppColors.blue;
    // Khi khong filled (outline), TRUOC DAY luon dung mau vien/chu trung
    // tinh (glassBorder/textPrimary trang) du co truyen accentColor - khien
    // nut trong mo nhat, khong noi bat mau rieng cua tung man (vd Debt
    // pay/collect da truyen pink/teal nhung khong hien ra). Gio dung thang
    // accentColor lam vien + mau chu de nut ro rang, "co mau" hon.
    final outlineColor = accentColor ?? AppColors.wealthAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            gradient: filled ? gradient : null,
            color: filled ? null : outlineColor.withValues(alpha: 0.14),
            border: filled
                ? null
                : Border.all(color: outlineColor.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(999),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.45),
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
                  style: AppTextStyles.body(
                    size: 14,
                    weight: FontWeight.w800,
                    color: filled ? null : outlineColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenBackground extends ConsumerWidget {
  const ScreenBackground({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundImage,
  });
  final Widget child;

  /// Cho phep 1 man hinh cu the (vd ChatScreen voi theme nen tuy chinh) doi
  /// nen rieng thay vi dung mac dinh chung ca app.
  final Gradient? gradient;

  /// Anh nen phu rieng cho MAN HINH NAY - thuong KHONG can truyen, de trong
  /// se tu dong lay theo [currentAppBackgroundProvider] (dung "app" dang mo:
  /// Hoc Tieng Anh/Fitness/Wealth) de moi man hinh trong 1 khu vuc tu dong
  /// dong bo anh nen ma khong phai sua tung file. Chi truyen rieng khi 1 man
  /// hinh CO CHU DINH khac voi mac dinh cua khu vuc no dang o.
  final String? backgroundImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveBackgroundImage =
        backgroundImage ?? ref.watch(currentAppBackgroundProvider);
    return Stack(
      children: [
        // Positioned.fill BAT BUOC cho moi lop, ke ca gradient nen: 1
        // Container khong con/khong width/height se co gian ve 0x0 duoi
        // constraints long cua Stack (loose, khong phai tight nhu Container
        // don truoc day) neu khong duoc ep fill kich thuoc Stack.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppColors.screenGradient,
            ),
          ),
        ),
        if (effectiveBackgroundImage != null)
          Positioned.fill(
            child: Image.asset(effectiveBackgroundImage, fit: BoxFit.cover),
          ),
        if (effectiveBackgroundImage != null)
          // Lop toi phu tren anh nen de chu/GlowBox phia tren van doc duoc.
          Positioned.fill(
            child: Container(color: AppColors.bgTop.withValues(alpha: 0.72)),
          ),
        Positioned.fill(
          child: SafeArea(
            // Ep decoration mac dinh la none o tang goc man hinh: bat ky
            // TextStyle nao (kem ca cac TextStyle() viet tay khong qua
            // AppTextStyles) khong tu khai bao decoration rieng se ke thua
            // gia tri nay thay vi ke thua tu DefaultTextStyle cua Theme/
            // Material o xa hon - nghi ngo day la nguyen nhan gach chan vang
            // xuat hien khap noi trong app du khong co dong code nao chu
            // dong "set" no.
            child: DefaultTextStyle.merge(
              style: const TextStyle(decoration: TextDecoration.none),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Nhan chu duoi 1 icon-tile (Home cua 3 "app") - cho phep xuong toi da 2
/// dong tai ranh gioi TU (space) binh thuong, nhung tu GIAM CO CHU truoc khi
/// wrap neu TU DAI NHAT trong nhan (vd "Pronunciation", "Management",
/// "Entertainment") van rong hon [maxWidth] o co chu mac dinh - tranh dung
/// Text(maxLines:2) tran vao giua 1 tu dai roi "roi" lai 1-2 chu cai le loi
/// xuong dong 2 (bug da bi bao cao truoc day). Khac voi FittedBox+maxLines:1
/// (chi 1 dong, luon co giam neu dai) - widget nay UU TIEN giu co chu binh
/// thuong va CHO PHEP xuong 2 dong o cac ranh gioi tu, chi giam co chu khi
/// that su can thiet (1 tu don le qua dai).
class TileLabelText extends StatelessWidget {
  const TileLabelText({
    super.key,
    required this.label,
    required this.maxWidth,
    this.baseSize = 10.5,
    this.minSize = 6.5,
    this.weight = FontWeight.w600,
    this.color,
  });

  final String label;
  final double maxWidth;
  final double baseSize;
  final double minSize;
  final FontWeight weight;
  final Color? color;

  double _widestWordWidth(double fontSize) {
    var widest = 0.0;
    for (final word in label.split(' ')) {
      final painter = TextPainter(
        text: TextSpan(
          text: word,
          style: AppTextStyles.body(size: fontSize, weight: weight),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
    }
    return widest;
  }

  /// Do be rong 1 DONG (co the nhieu tu) tai 1 co chu cu the - dung de tu
  /// chia dong thu cong, khac [_widestWordWidth] chi do TUNG TU rieng le.
  double _lineWidth(String text, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.body(size: fontSize, weight: weight),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  /// Tu chia [label] thanh TOI DA 2 dong tai RANH GIOI TU (khong bao gio be
  /// doi tu) - gop tu vao dong 1 cho toi khi tu TIEP THEO lam vuot maxWidth,
  /// phan con lai don het vao dong 2 (co the vuot maxWidth va bi ellipsis,
  /// nhung KHONG BAO GIO tach roi 1-2 ky tu le loi cua 1 tu nhu khi de
  /// Flutter tu dong wrap). Day la luoi an toan CUOI CUNG, khong phu thuoc
  /// vao do chinh xac cua phep do co chu o tren nua - du _widestWordWidth
  /// tinh sai lech so voi thiet bi that (van chua ro nguyen nhan chinh xac
  /// du da do bang nhieu cach, nguoi dung van bao loi tren thiet bi that du
  /// phep tinh ty le da "dam bao toan hoc"), viec tat softWrap va tu chen
  /// '\n' khien Flutter KHONG THE ky thuat be doi tu duoc nua.
  String _wrapIntoTwoLines(double fontSize) {
    final words = label.split(' ');
    if (words.length <= 1) return label;
    var splitIndex = words.length;
    var current = words[0];
    for (var i = 1; i < words.length; i++) {
      final candidate = '$current ${words[i]}';
      if (_lineWidth(candidate, fontSize) <= maxWidth) {
        current = candidate;
      } else {
        splitIndex = i;
        break;
      }
    }
    if (splitIndex == words.length) return label;
    final line1 = words.sublist(0, splitIndex).join(' ');
    final line2 = words.sublist(splitIndex).join(' ');
    return '$line1\n$line2';
  }

  @override
  Widget build(BuildContext context) {
    // Buoc 1: giam co chu (nhu truoc) de TU DAI NHAT co co hoi vua tren 1
    // dong truoc khi phai tinh den chia dong thu cong.
    const hardFloor = 3.5;
    var fontSize = baseSize;
    while (fontSize > hardFloor && _widestWordWidth(fontSize) > maxWidth) {
      fontSize -= 0.5;
    }
    final widestAtFloor = _widestWordWidth(fontSize);
    if (widestAtFloor > maxWidth && widestAtFloor > 0) {
      fontSize = (fontSize * maxWidth / widestAtFloor * 0.97).clamp(
        1.0,
        fontSize,
      );
    }
    return Text(
      // Buoc 2 (luoi an toan chinh, xem giai thich o _wrapIntoTwoLines):
      // TU chen '\n' tai ranh gioi tu thay vi de Flutter tu dong wrap -
      // loai bo hoan toan kha nang be doi tu bat ke phep tinh co chu o tren
      // co chinh xac 100% voi thiet bi that hay khong.
      _wrapIntoTwoLines(fontSize),
      textAlign: TextAlign.center,
      maxLines: 2,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      // Khong scale theo cai dat "co chu" cua may (Accessibility) - do do
      // rong tinh o _widestWordWidth() gia dinh scale=1, neu may nguoi dung
      // bat co chu lon hon thi chu render THAT SU se to hon phep tinh, gay
      // xuong dong giua tu (vd "Pronunciatio"/"n Lessons") du da tinh vua khit.
      textScaler: TextScaler.noScaling,
      style: AppTextStyles.body(
        size: fontSize,
        weight: weight,
        color: color,
      ).copyWith(height: 1.15),
    );
  }
}
