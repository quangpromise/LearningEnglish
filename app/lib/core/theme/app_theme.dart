import 'dart:ui' as ui;

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

  // --- Do truc tiep tu anh thiet ke Quan ly tai san ---
  /// Vien the Tong tai san: vang champagne SANG, gan nhu dac (#E4D49A o diem
  /// sang nhat cua net vien). Khac han vang tham wealthAccent - dung
  /// wealthAccent@45% cho ra net vien toi xin, nhin khong ra vanh vang.
  static const wealthHeroBorder = Color(0xFFE4D49A);

  /// Mau so tien tren the Tong tai san.
  static const wealthAmount = Color(0xFFFFE788);

  /// Vien cac the CON LAI (4 muc, Tong quan, o so lieu) - XAM chu khong phai
  /// vang: trong anh goc chi rieng the Tong tai san co vien vang, cac the
  /// khac deu la vien xam mong.
  static const wealthCardBorder = Color(0x29FFFFFF);

  /// Duong bieu do tang truong: vang KEM SANG - do doc theo tung cot tren ca
  /// 2 bieu do trong anh goc, dai #E4C966..#FFFFC7, trung binh ~#F8E98E.
  /// Dung wealthAccent (#D4AF37) thi duong ra toi va chim han.
  static const wealthChartLine = Color(0xFFF8E98E);

  /// Xanh la cua cac chi so tang trong anh goc (#46FFCF / #32FFEC) - sang va
  /// ngA xanh ngoc hon AppColors.teal.
  static const wealthUp = Color(0xFF3BFFC9);
  static const wealthAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [wealthAccent, Color(0xFFF0D585)],
  );

  static const textPrimary = Color(0xFFEEF1FB);
  static const textMuted = Color(0x8DEEF1FB);

  // Bo mau do TRUC TIEP tu anh thiet ke cua chu du an (lay trung binh 2%
  // pixel sang nhat trong o chua chu) - dung cho 2 man Home thiet ke lai.
  // Chu phu truoc day la textMuted (trang mo 55%) nen ra xam bech; ban thiet
  // ke dung xanh-sang dac nen chu "trong" va ro hon han.
  /// Chu phu ("Con 420 XP nua", "Ngay lien tiep").
  static const textSecondary = Color(0xFF9BB9DA);

  /// Nhan nho in hoa ("KY NANG CHINH", "LUYEN TAP").
  static const textLabel = Color(0xFF9EB4CC);

  /// Mat kinh cua the o man Home thiet ke lai - do duoc long the #0D1622 tren
  /// nen #02070F, tuong duong lop phu nay. The PHANG, khong gradient: cho nao
  /// sang hon la do anh sang NEN hat qua chu khong phai tung the tu sang.
  static const homeCardFill = Color(0x1682B2F0);

  /// Vien the o man Home thiet ke lai.
  static const homeCardBorder = Color(0x24C8E0FF);

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
  /// phan con lai don het vao dong 2. Tra ve mot danh sach dong (1 hoac 2
  /// dong) thay vi 1 chuoi noi '\n' - LUU Y QUAN TRONG: ban dau tung thu ghep '\n'
  /// vao 1 Text duy nhat voi softWrap:false + maxLines:2, nhung to hop nay
  /// co hanh vi KHONG ON DINH trong Flutter (da xac nhan tren thiet bi that:
  /// dong 2 bien mat hoan toan, chi con dong 1 - te hon ca bug goc). Gio moi
  /// dong la 1 Text DOC LAP, maxLines:1, day la co che overflow don dong cuc
  /// ky on dinh cua Flutter, khong con phu thuoc vao tuong tac an giua
  /// nhieu thuoc tinh multi-line nua.
  List<String> _wrapIntoLines(double fontSize) {
    final words = label.split(' ');
    if (words.length <= 1) return [label];
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
    if (splitIndex == words.length) return [label];
    final line1 = words.sublist(0, splitIndex).join(' ');
    final line2 = words.sublist(splitIndex).join(' ');
    return [line1, line2];
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
    final textStyle = AppTextStyles.body(
      size: fontSize,
      weight: weight,
      color: color,
    ).copyWith(height: 1.15);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final line in _wrapIntoLines(fontSize))
          Text(
            line,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            // Khong scale theo cai dat "co chu" cua may (Accessibility) -
            // do do rong tinh o _widestWordWidth()/_lineWidth() gia dinh
            // scale=1, neu khac se lam sai lech phep tinh vua khit.
            textScaler: TextScaler.noScaling,
            style: textStyle,
          ),
      ],
    );
  }
}

/// Nen rieng cho 2 man Home da thiet ke lai (Hoc Tieng Anh / Quan ly tai san).
///
/// KHONG dung [ScreenBackground]: nen do phu anh chup that (toa nha, van da...)
/// cua tung khu vuc, ma toan bo bang mau cua ban thiet ke moi duoc do tren NEN
/// GAN DEN - the la kinh mo alpha ~0.085, chi ra dung mau #0D1622 khi nam tren
/// nen den. Dat cung bang mau do len anh chup thi anh xuyen qua the, mau bi
/// bech va man hinh khong con giong thiet ke.
///
/// Nen nay gom 3 lop dung nhu file thiet ke:
///   1. Doc gan den, hoi xanh o tren, tat han o day
///   2. Quang sang mo o goc tren-phai
///   3. Vanh sang hanh tinh - cung tron tam (452, 434) ban kinh 379 tren khung
///      390px, do bang cach do vet diem sang nhat theo tung cot tren anh goc
class HomeDesignBackground extends StatelessWidget {
  const HomeDesignBackground({
    super.key,
    required this.child,
    this.glow = const Color(0xFF68A6FF),
  });

  final Widget child;

  /// Mau quang sang + vanh sang. Xanh cho Hoc Tieng Anh, vang cho Tai san.
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF070C18),
                  Color(0xFF040B15),
                  Color(0xFF02070F),
                  Color(0xFF01050C),
                  Color(0xFF000206),
                ],
                stops: [0, 0.18, 0.5, 0.78, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _PlanetLimbPainter(glow)),
          ),
        ),
        // SafeArea CHI boc noi dung, KHONG boc 2 lop nen phia tren: nen van
        // trai het man (chay ca duoi thanh trang thai/notch) nhu thiet ke,
        // nhung chu + the khong con bi thanh trang thai cua may che mat.
        // [ScreenBackground] da lam dung viec nay, 2 nen Home moi thi quen -
        // do la ly do man Home bi "de" o tren con cac man khac thi khong.
        // bottom: false - thanh nhac o day do Scaffold.bottomNavigationBar
        // dam nhiem (Scaffold tu cong le an toan duoi cho no).
        Positioned.fill(child: SafeArea(bottom: false, child: child)),
      ],
    );
  }
}

/// Nen man Quan ly tai san - KHAC [HomeDesignBackground]: ban thiet ke vang
/// khong co vanh hanh tinh, chi la nen den sau voi 2 quang vang rat nhe (goc
/// tren-phai manh hon, day man rat mo) de cac the vien vang noi len. Dung
/// chung HomeDesignBackground voi glow vang tung lam man nay bi am xanh navy
/// vi doc nen va vanh sang deu nga xanh.
class WealthDesignBackground extends StatelessWidget {
  const WealthDesignBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cac mau duoi day DO TRUC TIEP tu anh thiet ke goc (trung vi 8px sat
        // mep trai, theo tung 5% chieu cao): #04090E o dinh, nhat dan den
        // #000307 o khoang 35% roi PHANG cho toi day. Nen la den LANH nga
        // xanh (B > G > R), KHONG co quang vang - ban truoc do to nen am nau
        // + quang vang o goc nen nhin khac han anh goc.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF04090E),
                  Color(0xFF04090D),
                  Color(0xFF02060B),
                  Color(0xFF000307),
                  Color(0xFF000307),
                ],
                stops: [0, 0.16, 0.26, 0.36, 1],
              ),
            ),
          ),
        ),
        // Anh nen chu de thi truong (qua dia cau vang o dinh, cot nen vang 2
        // ben, giua man de trong) phu ca man, duoi 1 lop den 0.45. Ban than
        // file anh DA de giua man gan nhu den san nen khong can to den day
        // nhu ban dau (0.62) - to dam qua thi vang o dinh/day mat gan het,
        // khac han anh mau. Chua co file anh thi chi mat rieng lop nay, man
        // hinh ve lai dung nen den nhu truoc (errorBuilder).
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/wealth/wealth_home_bg.jpg',
              fit: BoxFit.cover,
              // To lop den NGAY TREN anh (srcATop) thay vi them 1 lop phu
              // rieng de len ca Stack: neu thieu file anh thi khong con gi bi
              // to den ca, nen mau nen den goc giu nguyen tuyet doi.
              color: AppColors.bgTop.withValues(alpha: 0.45),
              colorBlendMode: BlendMode.srcATop,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
        // Vet toi vuot dan o DINH man: qua dia cau trong anh nen sang nhat
        // dung ngay sau loi chao + ten + pill chuyen app, lam chu chim han
        // vao cac net ban do vang. Chi to dam 1/4 tren cung roi tat han nen
        // phan con lai cua anh nen khong bi anh huong.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6000306),
                    Color(0xB3000306),
                    Color(0x00000306),
                  ],
                  stops: [0, 0.12, 0.30],
                ),
              ),
            ),
          ),
        ),
        // Nhu [HomeDesignBackground]: nen trai het man, rieng noi dung duoc
        // day xuong duoi thanh trang thai. O day GIU ca le duoi vi thanh nhac
        // cua man Tai san nam TRONG than trang (xem wealth_home_screen.dart)
        // chu khong phai bottomNavigationBar, nen phai tu tranh vach cu chi.
        Positioned.fill(child: SafeArea(child: child)),
      ],
    );
  }
}

/// Ve quang sang + vanh sang hanh tinh o goc tren-phai.
class _PlanetLimbPainter extends CustomPainter {
  const _PlanetLimbPainter(this.glow);
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    // Moi toa do do tren khung rong 390 -> nhan he so cho vua be rong that.
    final k = size.width / 390;
    final center = Offset(452 * k, 434 * k);
    final radius = 379 * k;

    // 1. Quang sang mo goc tren-phai
    final hazeCenter = Offset(352 * k, 74 * k);
    final hazeRadius = 300 * k;
    canvas.drawCircle(
      hazeCenter,
      hazeRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glow.withValues(alpha: 0.26),
            glow.withValues(alpha: 0.10),
            glow.withValues(alpha: 0),
          ],
          stops: const [0, 0.44, 1],
        ).createShader(Rect.fromCircle(center: hazeCenter, radius: hazeRadius)),
    );

    // 2. Vanh sang - 3 lop nhoe chong nhau nen doc ra la 1 DAI SANG DAM LEN,
    // khong phai 1 duong ke. Gradient doc theo cung lam duoi cung tat han va
    // sang nhat o khoang 80% - dung nhu tren anh thiet ke.
    final rect = Rect.fromCircle(center: center, radius: radius);
    Shader shaderFor(double opacity) => ui.Gradient.linear(
      Offset(120 * k, 240 * k),
      Offset(392 * k, 52 * k),
      [
        glow.withValues(alpha: 0),
        glow.withValues(alpha: 0.05 * opacity),
        Color.lerp(glow, Colors.white, 0.55)!.withValues(alpha: 0.55 * opacity),
        Colors.white.withValues(alpha: opacity),
        Color.lerp(glow, Colors.white, 0.45)!.withValues(alpha: 0.42 * opacity),
      ],
      const [0, 0.34, 0.6, 0.8, 1],
    );

    for (final (width, blur, opacity) in [
      (34.0 * k, 9.0 * k, 0.26),
      (10.0 * k, 3.4 * k, 0.48),
      (2.2 * k, 1.0 * k, 0.95),
    ]) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
          ..shader = shaderFor(opacity),
      );
    }
    // rect chi dung de doc ro y do; shader da tu dat theo toa do tuyet doi.
    assert(rect.width > 0);
  }

  @override
  bool shouldRepaint(_PlanetLimbPainter oldDelegate) =>
      oldDelegate.glow != glow;
}
