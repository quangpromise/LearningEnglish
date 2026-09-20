import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'fitness_home_theme.dart';

/// The lon dau man Home: anh phong gym toi + lop phu den->trong suot (pha
/// chut do tham o mep phai), khau hieu va nut "Bat dau tap".
///
/// Anh nen dung lai `assets/fitness/fitness_background.jpg` da co san trong
/// app (KHONG tai anh tu internet - xem quy tac asset trong CLAUDE.md).
class FitnessHeroCard extends StatelessWidget {
  const FitnessHeroCard({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onStart,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FitnessHome.heroHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FitnessHome.heroRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/fitness/fitness_background.jpg',
              fit: BoxFit.cover,
              // Neo lech han sang PHAI: nua trai cua the bi lop phu den +
              // chu de kin, phan anh dang xem duoc chi con o nua phai.
              alignment: const Alignment(0.75, -0.1),
              // Phong to nhe khung anh de khong lo vung tran/san trong o
              // mep tren - anh goc rong hon nhieu so voi o 158dp nay.
              scale: 0.9,
            ),
            // Lop phu: chu nam nua trai nen phai gan nhu den dac o do, mo
            // dan sang phai de van thay duoc anh.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.26, 0.46, 0.78, 1],
                  colors: [
                    Color(0xFF050505),
                    Color(0xDB050505),
                    Color(0x4D050505),
                    Color(0x475C080D),
                  ],
                ),
              ),
              child: SizedBox.expand(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded thay vi rong cung 206dp: khung thiet ke cua
                  // man Home co the hep hon 390dp (xem _FittedCanvas), luc
                  // do cot chu + cum khau hieu se tran ra ngoai the.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          kicker.toUpperCase(),
                          style: AppTextStyles.body(
                            size: 9,
                            weight: FontWeight.w800,
                            color: FitnessHome.red,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: AppTextStyles.heading(size: 17.5)
                              .copyWith(height: 1.24, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: FitnessHome.bodySecondary(size: 10.5)
                              .copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        _StartButton(label: ctaLabel, onTap: onStart),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _SloganColumn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPressable(
      onTap: onTap,
      child: Container(
        height: 33,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: FitnessHome.red,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: FitnessHome.red.withValues(alpha: 0.42),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.body(
                size: 12.5,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cot khau hieu goc phai + duong nhip tim do - phan trang tri thuan tuy,
/// giu dung anh thiet ke.
class _SloganColumn extends StatelessWidget {
  const _SloganColumn();

  static const _lines = ['STRONGER', 'HEALTHIER', 'HAPPIER'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        for (final line in _lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              line,
              style: AppTextStyles.body(
                size: 8.5,
                weight: FontWeight.w600,
                color: const Color(0xFFBDBDBD),
              ).copyWith(letterSpacing: 0.6),
            ),
          ),
        const SizedBox(height: 4),
        const SizedBox(
          width: 72,
          height: 24,
          child: CustomPaint(painter: _EcgPainter()),
        ),
      ],
    );
  }
}

class _EcgPainter extends CustomPainter {
  const _EcgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FitnessHome.redBright
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Toa do chuan hoa 0..1 roi nhan theo kich thuoc that - nho vay duong
    // ve giu dung hinh dang o moi be rong man hinh.
    const points = <Offset>[
      Offset(0, 0.66),
      Offset(0.19, 0.66),
      Offset(0.25, 0.22),
      Offset(0.32, 0.92),
      Offset(0.38, 0.4),
      Offset(0.43, 0.68),
      Offset(0.49, 0.54),
      Offset(0.55, 0.74),
      Offset(0.62, 0.2),
      Offset(0.68, 0.62),
      Offset(0.73, 0.46),
      Offset(1, 0.46),
    ];
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) => false;
}
