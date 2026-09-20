import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'fitness_home_theme.dart';

/// The lon dau man Home.
///
/// Anh nen `assets/fitness/home/hero.jpg` duoc cat ra tu chinh file thiet
/// ke cua chu du an (xem docs/design/fitness-redesign/README.md): phan chu
/// tieu de/nut ben trai da bi xoa de widget nay ve chu that len tren (co
/// dich ngon ngu), con cum khau hieu STRONGER/HEALTHIER/HAPPIER va duong
/// nhip tim ben phai thi GIU NGUYEN tren anh - nen o day khong con widget
/// nao ve lai 2 thu do nua.
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
            const ColoredBox(color: Color(0xFF080808)),
            Image.asset('assets/fitness/home/hero.jpg', fit: BoxFit.cover),
            // Lop phu rat nhe: nua trai cua anh da den dac san nen chi can
            // phu them mot chut cho chac chan doc duoc chu, khong lam toi
            // ca buc anh nhu ban dung anh phong gym truoc day.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.5, 1],
                  colors: [
                    Color(0x99050505),
                    Color(0x33050505),
                    Color(0x00050505),
                  ],
                ),
              ),
              child: SizedBox.expand(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 9),
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
