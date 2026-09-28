import 'package:flutter/material.dart';

import 'gt_tokens.dart';

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
  ///
  /// Doi tu CAM (#F0883D) sang DO theo anh thiet ke lai man Fitness Home
  /// (`docs/design/fitness-redesign/_ref.jpg`, bang do mau trong TOKENS.md
  /// cung thu muc). Chi doi GIA TRI o day - moi man Fitness deu tham chieu
  /// qua ten bien nay nen tu dong doi mau theo, khong phai sua tung file.
  static const fitnessAccent = Color(0xFFE50914);

  /// Do SANG hon accent - dung cho net do sac (duong nhip tim, mui ten
  /// tang) tren nen den, noi accent thuong bi chim.
  static const fitnessAccentBright = Color(0xFFFF2028);

  /// Do THAM - chi dung pha vao nen (the Tien ich nhanh, lop phu anh hero),
  /// khong bao gio dung lam mau chu.
  static const fitnessAccentDeep = Color(0xFF5C080D);

  /// Nen the cua man Fitness thiet ke lai - DAC (khong phai kinh mo nhu
  /// [glassFill]) vi nen man hinh do da la den tuyet doi, the trong suot se
  /// khong tach duoc khoi nen.
  static const fitnessCard = Color(0xFF111111);
  static const fitnessCardBorder = Color(0xFF1C1C1C);
  static const fitnessDivider = Color(0xFF262626);

  /// Chu phu tren nen den cua man Fitness - sang hon [textMuted] (von hoi
  /// xanh vi ke thua bang mau cua Hoc Tieng Anh).
  static const fitnessTextSecondary = Color(0xFFA5A5A5);

  static const fitnessAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fitnessAccent, Color(0xFFFF2028)],
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

  /// Ban TOI hon cua [homeCardFill] - phu them 1 lop den thay vi lop kinh
  /// sang. Dung xen ke cho 1 so khoi o man Home (hang 4 ky nang, khoi Luyen
  /// thi) de cac khoi khong dinh lien thanh 1 mang phang, de doc ranh gioi
  /// giua chung hon.
  static const homeCardFillDim = Color(0x40000000);

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

class ScreenBackground extends StatelessWidget {
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

  /// Anh nen rieng cho MAN HINH NAY (hiem khi dung). Mac dinh nen PHANG
  /// mau `bg` cua design token - ban redesign bo anh nen theo khu vuc
  /// (ADR-0004, docs/design/gymtalk-redesign/), anh chi con trong hero card.
  final String? backgroundImage;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundImage = backgroundImage;
    return Stack(
      children: [
        // Positioned.fill BAT BUOC cho moi lop, ke ca gradient nen: 1
        // Container khong con/khong width/height se co gian ve 0x0 duoi
        // constraints long cua Stack (loose, khong phai tight nhu Container
        // don truoc day) neu khong duoc ep fill kich thuoc Stack.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: gradient == null ? context.gt.bg : null,
              gradient: gradient,
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
            // Material trong suot: man goc (dang nhap, dat lai mat khau) khong
            // nam trong Scaffold/popup nen TextField/InkWell khong co Material
            // to tien -> ban debug bao "No Material widget found". Trong suot
            // nen khong ve gi; dat NGOAI DefaultTextStyle.merge ben duoi vi
            // Material tu dat kieu chu mac dinh theo theme.
            child: Material(
              type: MaterialType.transparency,
              child: DefaultTextStyle.merge(
                style: const TextStyle(decoration: TextDecoration.none),
                child: child,
              ),
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

/// Nen man Quan ly tai san - KHAC nen phang cua ban redesign: ban thiet ke vang
/// khong co vanh hanh tinh, chi la nen den sau voi 2 quang vang rat nhe (goc
/// tren-phai manh hon, day man rat mo) de cac the vien vang noi len. Dung
/// chung nen Home cu voi glow vang tung lam man nay bi am xanh navy
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
        // Nen trai het man, rieng noi dung duoc
        // day xuong duoi thanh trang thai. O day GIU ca le duoi vi thanh nhac
        // cua man Tai san nam TRONG than trang (xem wealth_home_screen.dart)
        // chu khong phai bottomNavigationBar, nen phai tu tranh vach cu chi.
        Positioned.fill(child: SafeArea(child: child)),
      ],
    );
  }
}
