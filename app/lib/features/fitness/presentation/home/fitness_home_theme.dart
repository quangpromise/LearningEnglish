import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Bang do do TRUC TIEP tu anh thiet ke Trang chu Fitness
/// (`docs/design/fitness-redesign/_ref.jpg`, bang so trong TOKENS.md cung
/// thu muc). Gom o 1 cho de 6 widget con cua man Home khong ai tu viet lai
/// 1 con so mau/kich thuoc rieng.
class FitnessHome {
  FitnessHome._();

  // --- Khoang cach (dp, do tren anh 1080px @2.769 px/dp) ---
  static const pagePadding = 16.0;
  static const heroHeight = 158.0;
  // 96 chu khong phai 93 nhu do tren anh: o co chu toi thieu doc duoc cua
  // app (nhan 9.5 / so 19) thi 93dp lam trong o bi tran 4dp.
  static const statsHeight = 98.0;
  static const programCardWidth = 116.0;
  static const programCardHeight = 102.0;
  static const quickActionHeight = 46.0;

  static const cardRadius = 16.0;
  static const heroRadius = 18.0;
  static const programRadius = 14.0;
  static const quickRadius = 12.0;

  // --- Mau ---
  static const background = Color(0xFF050505);
  static const card = AppColors.fitnessCard;
  static const cardBorder = AppColors.fitnessCardBorder;
  static const divider = AppColors.fitnessDivider;
  static const red = AppColors.fitnessAccent;
  static const redBright = AppColors.fitnessAccentBright;
  static const textSecondary = AppColors.fitnessTextSecondary;

  /// Nen the "Tien ich nhanh" - do tham pha vao den, KHONG phai do thuan.
  static const quickFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF190A0C), Color(0xFF120708)],
  );
  static const quickBorder = Color(0xFF3A1418);

  // --- Kieu chu (do tu anh: ten/tieu de dung SpaceGrotesk, phan con lai
  // Manrope - dung y het 2 font da bundle san trong app) ---
  static TextStyle sectionTitle() =>
      AppTextStyles.heading(size: 16.5).copyWith(letterSpacing: -0.3);

  static TextStyle sectionAction() => AppTextStyles.body(
    size: 11.5,
    weight: FontWeight.w600,
    color: textSecondary,
  );

  static TextStyle statLabel() => AppTextStyles.body(
    size: 9,
    weight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle statValue() =>
      AppTextStyles.heading(size: 19).copyWith(letterSpacing: -0.5);

  static TextStyle statUnit() => AppTextStyles.body(
    size: 10.5,
    weight: FontWeight.w600,
    color: textSecondary,
  );

  static TextStyle bodySecondary({double size = 11}) => AppTextStyles.body(
    size: size,
    weight: FontWeight.w500,
    color: textSecondary,
  );
}

/// The nen chung cua man Home (thay cho GlowBox "kinh mo" dung o phan con
/// lai cua app): nen DAC #111111 + vien mong, vi nen man hinh o day la den
/// tuyet doi nen the trong suot se khong tach duoc khoi nen.
class FitnessCard extends StatelessWidget {
  const FitnessCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = FitnessHome.cardRadius,
    this.onTap,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  /// true khi ben trong co anh nen tran vien (the "Ke hoach hom nay",
  /// the chuong trinh) - can cat theo goc bo tron.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: FitnessHome.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: FitnessHome.cardBorder),
      ),
      child: child,
    );
    if (onTap == null) return decorated;
    return _PressableScale(onTap: onTap!, child: decorated);
  }
}

/// Thu nho nhe khi bam (150ms) - hieu ung bam dung chung cho moi the/nut
/// cua man Home, thay vi moi cho tu viet 1 kieu.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Dung ngoai [FitnessCard] khi can hieu ung bam cho 1 widget bat ky.
class FitnessPressable extends StatelessWidget {
  const FitnessPressable({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      _PressableScale(onTap: onTap, child: child);
}

/// Tieu de 1 khu vuc + hanh dong "Xem tat ca" ben phai.
class FitnessSectionHeader extends StatelessWidget {
  const FitnessSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: FitnessHome.sectionTitle())),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(actionLabel!, style: FitnessHome.sectionAction()),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: FitnessHome.textSecondary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Khung chung cho cac man Fitness mo dang popup theo thiet ke moi (Nhip
/// tim, Giac ngu, Thong ke): nen den dac + 1 hang "nut quay lai + tieu de".
/// Dung thay cho [ScreenBackground] o nhung man thuoc bo thiet ke lai, de
/// khong bi anh nen phong gym lam mo chu/bieu do.
class FitnessScreenScaffold extends StatelessWidget {
  const FitnessScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FitnessHome.background,
      child: SafeArea(
        child: DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FitnessHome.pagePadding,
              10,
              FitnessHome.pagePadding,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FitnessHome.card,
                          border: Border.all(color: FitnessHome.cardBorder),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 18),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
